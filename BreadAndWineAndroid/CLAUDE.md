# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Bread & Wine Devotional - Android App**

Native Android companion to the iOS app, delivering daily spiritual devotionals. Built with Kotlin + Jetpack Compose, using WordPress REST API backend and Firebase for push notifications.

**Package:** `com.firstloveassembly.breadandwine`
**Min SDK:** 24 (Android 7.0) | **Target SDK:** 34 (Android 14)

## Build & Test Commands

### Building
```bash
# Sync Gradle dependencies
./gradlew build

# Debug APK
./gradlew assembleDebug
# Output: app/build/outputs/apk/debug/app-debug.apk

# Release APK (requires signing config)
./gradlew assembleRelease

# App Bundle for Play Store
./gradlew bundleRelease
```

### Testing
```bash
# Run all unit tests
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew test

# Run specific test class
./gradlew test --tests SettingsViewModelTest

# View test report
open app/build/reports/tests/testDebugUnitTest/index.html

# Clean build (fixes most caching issues)
./gradlew clean build
```

## Architecture & Key Patterns

### MVVM Architecture
- **Model:** `model/Devotional.kt` - Data classes matching WordPress API JSON
- **ViewModel:** `viewmodel/` - State management with Kotlin Flow
- **View:** `ui/` - Jetpack Compose screens (no XML layouts)

### Data Flow
```
WordPress API → Repository → ViewModel → Compose UI
                    ↓
                DataStore Cache (offline)
```

### Critical Implementation Details

**1. iOS Feature Parity**
This app mirrors the iOS version (`/BreadAndWine/` directory). When implementing features:
- Check iOS Swift code first for behavior/UX reference
- Match notification times, TTS settings, content formatting
- iOS uses AVSpeechSynthesizer → Android uses TextToSpeechManager
- iOS uses UserDefaults → Android uses DataStore

**2. HTML Content Rendering**
Devotional content is WordPress HTML. Current approach:
```kotlin
// DevotionalDetailScreen.kt
// Uses TextView + HtmlCompat.fromHtml() NOT WebView
// Custom styling for blockquotes via QuoteSpan
val processedHtml = htmlContent
    .replace("<blockquote>", "<br><blockquote>")
    .replace("</blockquote>", "</blockquote><br>")
```

**Why not WebView?** Tried initially but caused height calculation issues. TextView + HtmlCompat is simpler and works.

**3. Notification System (Dual)**
- **Local Notifications:** AlarmManager schedules at 6 AM (morning) and 10 AM (nugget)
- **Remote Push:** Firebase Cloud Messaging (FCM) handles server-sent notifications
- Device tokens saved to Firestore `devices/{token}` collection
- Both types go through `NotificationScheduler.kt` → `NotificationReceiver.kt`

**4. Background Data Refresh**
WorkManager runs `DevotionalWorker` at 9:45 AM daily to fetch latest devotionals and update nugget notification content. Mirrors iOS `BackgroundFetchManager`.

**5. Text-to-Speech**
```kotlin
// TextToSpeechManager.kt
// Speed: 0.9f (user adjusted from iOS default 0.65f)
// Voice: Locale.UK (British English)
// Converts HTML to plain text, reads full devotional
```

**6. Date Formatting**
```kotlin
// Pattern: "d MMMM yyyy" → "10 November 2025"
// Uses java.time API (requires desugaring for API 24+)
// Build config enables: isCoreLibraryDesugaringEnabled = true
```

### Important Code Locations

**ViewModel Factory Pattern**
```kotlin
// Required for AndroidViewModel with Application parameter
// SettingsScreen.kt:26-30
val viewModel: SettingsViewModel = viewModel(
    factory = androidx.lifecycle.ViewModelProvider.AndroidViewModelFactory.getInstance(
        context.applicationContext as android.app.Application
    )
)
```

**Firebase Configuration**
- Place `google-services.json` in `app/` directory (gitignored)
- Uses `pushbreadandwine` Firebase project (shared with iOS)
- FCM service: `BreadAndWineMessagingService.kt`

**WordPress API**
```kotlin
// data/api/WordPressApi.kt
// Endpoint: https://breadandwinedevotional.com/wp-json/wp/v2/devotional
// No auth required, uses Retrofit + Gson
```

## Common Development Tasks

### Adding a New Screen
1. Create Composable in `ui/{feature}/`
2. Add route to `MainActivity.kt` NavHost
3. Create ViewModel if needed in `viewmodel/`
4. Add navigation icon to bottom bar if top-level

### Modifying Notification Times
```kotlin
// NotificationScheduler.kt
set(Calendar.HOUR_OF_DAY, 6)  // Morning notification
set(Calendar.HOUR_OF_DAY, 10) // Nugget notification

// DevotionalWorker.kt
set(Calendar.HOUR_OF_DAY, 9)  // Background fetch
set(Calendar.MINUTE, 45)
```

### Testing Notifications
1. Build and install debug APK
2. Go to Settings screen → Enable notifications
3. Use `adb shell` to advance system time:
```bash
adb shell su root date 110610002025.00  # Nov 6 10:00 2025
```
4. Check logcat for scheduled alarms

### Fixing Crashes
**Most common issues:**
- **"Method X in android.util.Log not mocked"** → Already fixed with `testOptions { unitTests.isReturnDefaultValues = true }`
- **ViewModel crashes** → Check factory pattern in Compose screen
- **DataStore errors** → Wrap in try-catch, defaults are acceptable
- **Date parsing fails** → Ensure desugaring enabled in build.gradle.kts

## Testing

**Coverage:** ~65% (45 tests)

**What's Tested:**
- DevotionalViewModel and Repository (date logic, API errors, today's nugget)
- Notification scheduling and settings
- Devotional model (parsing, ACF fields, preview text)
- ApiService result types
- Cache persistence

**Framework:** JUnit + MockK + Kotlin Test

**Guidelines:**
- Use Given-When-Then structure
- Test files mirror source: `SettingsViewModel.kt` → `SettingsViewModelTest.kt`
- Mock Android framework classes with MockK
- Keep tests simple and focused on business logic

## Code Style & Conventions

**Kotlin Best Practices:**
- Use `val` over `var` when possible
- Prefer extension functions for readability
- Use `?.let {}` for null safety, not `!!`
- StateFlow for ViewModels, avoid LiveData

**Compose Conventions:**
- Screen-level Composables: `@OptIn(ExperimentalMaterial3Api::class)`
- Remember expensive computations: `remember(devotional) { ... }`
- Use `DisposableEffect` for cleanup (TTS, subscriptions)
- Hoist state to caller, keep Composables stateless

**Naming:**
- Screens: `DevotionalListScreen`, `SettingsScreen`
- ViewModels: `DevotionalViewModel`, `SettingsViewModel`
- Services: `TextToSpeechManager`, `NotificationScheduler`

## Known Gotchas

1. **BlockQuote Styling:** Uses `QuoteSpan` not CSS. Add `<br>` tags via string replacement for padding.

2. **TTS State Management:** `isSpeaking` must be tracked in Compose state AND passed to TTS callback to update UI.

3. **Notification Channels:** Must be created in Application.onCreate() before scheduling notifications.

4. **Gradle Sync Issues:** If you see desugaring errors, ensure both:
   - `compileOptions { isCoreLibraryDesugaringEnabled = true }`
   - `dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") }`

5. **Firebase Not Working:** Check `google-services.json` exists and package name matches exactly: `com.firstloveassembly.breadandwine`

## Firebase Setup

**Quick Setup:**
1. Download `google-services.json` from [Firebase Console](https://console.firebase.google.com/project/pushbreadandwine)
2. Place in `app/` directory
3. Sync Gradle
4. FCM tokens auto-register on app launch

**Firestore Collections:**
```
devices/{fcm_token}
  - token: string
  - platform: "android"
  - appVersion: "1.0.0"
  - lastActive: Timestamp
```

## Deployment Checklist

**Before releasing:**
- [ ] Update version in `app/build.gradle.kts` (versionCode + versionName)
- [ ] Test on physical device (emulator notifications unreliable)
- [ ] Verify all notifications work (local + push)
- [ ] Test offline mode with cached content
- [ ] Check text-to-speech with actual devotional content
- [ ] Build release bundle: `./gradlew bundleRelease`
- [ ] Sign with production keystore (not debug key)

## When Things Break

**Check in order:**
1. Logcat for stack traces (`adb logcat | grep BreadAndWine`)
2. Build → Clean Project → Rebuild
3. Invalidate Caches / Restart (Android Studio)
4. Delete `app/build/` and re-sync Gradle
5. Compare with iOS implementation for expected behavior

**Common fixes:**
- DataStore errors → wrap in try-catch with defaults
- Notification not showing → check channel creation in Application class
- TTS not speaking → verify permissions and TTS engine installed
- Date format wrong → ensure desugaring enabled and app rebuilt

## Important Files Reference

**Must-read for understanding architecture:**
- `BreadAndWineApp.kt` - App initialization, Firebase, notification channels
- `MainActivity.kt` - Navigation setup, bottom bar
- `DevotionalViewModel.kt` - Main business logic, API calls, caching
- `DevotionalDetailScreen.kt` - Complex HTML rendering + TTS
- `NotificationScheduler.kt` - Both local and push notification logic

**iOS counterparts for feature parity:**
- iOS `DevotionalDetailView.swift` ↔ Android `DevotionalDetailScreen.kt`
- iOS `SpeechSynthesizer.swift` ↔ Android `TextToSpeechManager.kt`
- iOS `NotificationManager.swift` ↔ Android `NotificationScheduler.kt`
- iOS `AppDelegate.swift` ↔ Android `BreadAndWineApp.kt`
