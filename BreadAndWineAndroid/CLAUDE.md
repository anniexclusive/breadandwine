# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Bread & Wine Devotional - Android App**

Native Android companion to the iOS app, delivering daily spiritual devotionals. Built with Kotlin + Jetpack Compose, using WordPress REST API backend and Firebase for push notifications.

**Package:** `breadandwineandroid.breadandwineandroid`
**Min SDK:** 21 (Android 5.0) | **Target SDK:** 36 (Android 14)
**Current Version:** 2.0.3 (versionCode: 19)

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

### Package Structure
```
app/src/main/java/breadandwineandroid/breadandwineandroid/
├── BreadAndWineApp.kt          # Application class
├── MainActivity.kt              # Main entry point
├── data/
│   ├── api/                     # Retrofit API interfaces
│   ├── cache/                   # DataStore caching
│   └── repository/              # Repository pattern
├── model/                       # Data models
├── service/                     # Background services
├── ui/                          # Compose screens
├── util/                        # Utilities
└── viewmodel/                   # ViewModels
```

**Important:** The namespace and applicationId are both `breadandwineandroid.breadandwineandroid`. This must match in:
- `build.gradle.kts` (namespace & applicationId)
- `google-services.json` (package_name)
- All Kotlin package declarations
- AndroidManifest.xml component names

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

**3. Share Functionality (v2.0.3+)**
Devotionals can be shared via the Android share sheet. The share functionality includes:

```kotlin
// DevotionalDetailScreen.kt - shareDevotional()
// Builds complete devotional text with proper formatting
// Handles HTML entity decoding (&#8230; → …, &#8220; → ", etc.)
// Removes duplicate nuggets from main content
```

**Duplicate Nugget Handling:**
- Some devotionals have the nugget embedded in the main content AND at the bottom
- When multiple nuggets appear, only the LAST occurrence is removed from main content
- Single nuggets in content are kept (not removed)
- Final nugget always appears at bottom under "💡 Today's Nugget"

**HTML Entity Decoding:**
The `decodeHtmlEntities()` function converts WordPress entities:
- `&#8230;` → `…` (ellipsis)
- `&#8220;` → `"` (left double quote)
- `&#8221;` → `"` (right double quote)
- And other common HTML entities

**Ellipsis Normalization:**
- Nugget field may contain `...` (three dots)
- Content may contain `…` (Unicode ellipsis U+2026)
- Code normalizes both to `...` for comparison, then converts back to `…`

**4. Notification System (Hybrid Approach - v2.0.3+)**

**Current Architecture:**
- **Morning Notification (6:00 AM):** Hybrid approach using both AlarmManager + WorkManager for redundancy
  - `NotificationScheduler.scheduleMorningNotification()` - AlarmManager (exact timing)
  - `NotificationWorker.scheduleMorningNotification()` - WorkManager (survives force-stop)
- **Nugget Notification (4:00 AM):** WorkManager only via `NotificationWorker`
  - Changed from 10:00 AM to 4:00 AM to avoid timing conflicts
  - WorkManager-only approach is sufficient for nugget notifications
- **Background Data Refresh:** `DevotionalWorker` runs at 9:45 AM to fetch latest content

**WorkManager Benefits:**
- Survives app force-stops, device reboots, battery optimization
- Automatically reschedules after system events
- Trade-off: ±15 minute timing variance (Android system limitation)

**AlarmManager (Legacy):**
- **NotificationScheduler.kt** uses `setExactAndAllowWhileIdle()` for exact timing
- **Requires:** `SCHEDULE_EXACT_ALARM` permission check on Android 12+
- **Deprecated:** `scheduleNuggetNotification()` is no longer used (migrated to WorkManager)

**Remote Push:**
- Firebase Cloud Messaging (FCM) handles server-sent notifications
- Device tokens saved to Firestore `devices/{token}` collection

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
// NotificationWorker.kt (WorkManager-based)
scheduleMorningNotification() // 6:00 AM - see calculateDelayUntil(6, 0)
scheduleNuggetNotification()  // 4:00 AM - see calculateDelayUntil(4, 0)

// NotificationScheduler.kt (AlarmManager-based)
scheduleMorningNotification() // 6:00 AM - hybrid with WorkManager
// scheduleNuggetNotification() - DEPRECATED, use WorkManager only

// DevotionalWorker.kt (Background data fetch)
set(Calendar.HOUR_OF_DAY, 9)  // Background fetch at 9:45 AM
set(Calendar.MINUTE, 45)
```

### Testing Notifications
1. Build and install debug APK: `./gradlew assembleDebug`
2. Open app and enable notifications in Settings
3. Run diagnostic script: `./test-notifications.sh`
4. Or manually check:
```bash
# Check scheduled WorkManager jobs
adb shell dumpsys jobscheduler | grep -A 10 breadandwineandroid

# Check AlarmManager alarms
adb shell dumpsys alarm | grep breadandwineandroid

# Advance system time (requires root)
adb shell su root date 010510002026.00  # Jan 5 10:00 2026

# Monitor live logs
adb logcat | grep -E "(NotificationWorker|NotificationReceiver|DevotionalWorker)"
```
5. **Important:** WorkManager notifications may fire ±15 minutes from target time

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

**Git Commit Conventions:**
- Use standard conventional commit format: `type: description`
- Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`, `test`, `perf`
- Keep message to one line, concise and descriptive
- Never mention AI assistance or Claude in commit messages
- Examples:
  - `feat: add loading indicator to devotional list`
  - `fix: resolve proguard stripping api classes`
  - `chore: update version to 2.0.1`
  - `refactor: migrate to breadandwineandroid package`

## Known Gotchas

1. **BlockQuote Styling:** Uses `QuoteSpan` not CSS. Add `<br>` tags via string replacement for padding.

2. **TTS State Management:** `isSpeaking` must be tracked in Compose state AND passed to TTS callback to update UI.

3. **Notification Channels:** Must be created in Application.onCreate() before scheduling notifications.

4. **Gradle Sync Issues:** If you see desugaring errors, ensure both:
   - `compileOptions { isCoreLibraryDesugaringEnabled = true }`
   - `dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") }`

5. **Firebase Not Working:** Check `google-services.json` exists and package name matches exactly: `breadandwineandroid.breadandwineandroid`

6. **ProGuard/R8 Stripping API Classes:** If release build shows blank screens (no API data), ProGuard may be removing critical classes. The `proguard-rules.pro` file includes rules to keep:
   - Retrofit API interfaces and Gson models
   - ViewModels and Repository classes
   - Data models and serialization annotations
   - Never disable these rules in release builds

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
  - appVersion: "2.0.3"
  - lastActive: Timestamp
```

## ProGuard/R8 Configuration

**Critical for Release Builds:** The app uses ProGuard/R8 for code shrinking and obfuscation. The following classes MUST be kept or the app will show blank screens in release builds:

**Key Rules in `proguard-rules.pro`:**
```proguard
# Data models - required for Gson serialization
-keep class breadandwineandroid.breadandwineandroid.model.** { *; }

# API interfaces - required for Retrofit
-keep interface breadandwineandroid.breadandwineandroid.data.api.** { *; }
-keep class breadandwineandroid.breadandwineandroid.data.api.** { *; }

# ViewModels and Repository - required for data flow
-keep class breadandwineandroid.breadandwineandroid.viewmodel.** { *; }
-keep class breadandwineandroid.breadandwineandroid.data.repository.** { *; }
-keep class breadandwineandroid.breadandwineandroid.data.cache.** { *; }
```

**Debugging ProGuard Issues:**
1. If release build works but shows no data → ProGuard stripped API classes
2. Build with `minifyEnabled = false` temporarily to confirm
3. Check `app/build/outputs/mapping/release/usage.txt` to see removed classes
4. Add `-keep` rules for any missing classes
5. Never ship to Play Store without testing release build on physical device

## Deployment Checklist

**Before releasing:**
- [ ] Update version in `app/build.gradle.kts` (versionCode + versionName)
- [ ] Build release APK: `./gradlew assembleRelease`
- [ ] Install release APK on physical device (NOT debug build)
- [ ] **CRITICAL:** Verify API data loads correctly in release build
- [ ] Test on physical device (emulator notifications unreliable)
- [ ] Verify all notifications work (local + push)
- [ ] Test offline mode with cached content
- [ ] Check text-to-speech with actual devotional content
- [ ] Build release bundle: `./gradlew bundleRelease`
- [ ] Sign with production keystore (BNW_KEYSTORE_PASSWORD env var)
- [ ] Upload `.aab` file to Play Store (NOT `.apk`)

## When Things Break

**Check in order:**
1. Logcat for stack traces (`adb logcat | grep breadandwine`)
2. Build → Clean Project → Rebuild
3. Invalidate Caches / Restart (Android Studio)
4. Delete `app/build/` and re-sync Gradle
5. Compare with iOS implementation for expected behavior

**Common fixes:**
- **Release build shows blank screen/no data** → ProGuard stripped API classes, check proguard-rules.pro
- DataStore errors → wrap in try-catch with defaults
- Notification not showing → check channel creation in Application class
- TTS not speaking → verify permissions and TTS engine installed
- Date format wrong → ensure desugaring enabled and app rebuilt
- Package name mismatch → ensure namespace and applicationId both use `breadandwineandroid.breadandwineandroid`

## Important Files Reference

**Must-read for understanding architecture:**
- `BreadAndWineApp.kt` - App initialization, Firebase, notification channels, defensive scheduling
- `MainActivity.kt` - Navigation setup, bottom bar
- `DevotionalViewModel.kt` - Main business logic, API calls, caching
- `DevotionalDetailScreen.kt` - Complex HTML rendering + TTS
- `NotificationWorker.kt` - WorkManager-based recurring notifications (PRIMARY)
- `NotificationScheduler.kt` - AlarmManager-based notifications (LEGACY FALLBACK)
- `DevotionalWorker.kt` - Background data fetch at 9:45 AM

**iOS counterparts for feature parity:**
- iOS `DevotionalDetailView.swift` ↔ Android `DevotionalDetailScreen.kt`
- iOS `SpeechSynthesizer.swift` ↔ Android `TextToSpeechManager.kt`
- iOS `NotificationManager.swift` ↔ Android `NotificationScheduler.kt`
- iOS `AppDelegate.swift` ↔ Android `BreadAndWineApp.kt`

## Recent Changes

**v2.0.3 (January 2026) - Notification Architecture & Share Fixes:**
- **CRITICAL FIX:** Revised notification architecture to hybrid approach
  - Morning notification (6 AM): Both AlarmManager + WorkManager for redundancy
  - Nugget notification (4 AM): WorkManager only (changed from 10 AM)
  - Deprecated AlarmManager nugget scheduling
- **Share Functionality Improvements:**
  - Fixed duplicate nugget removal (removes only last occurrence when multiple exist)
  - Added HTML entity decoding for proper character rendering
  - Implemented ellipsis normalization (`...` ↔ `…`)
  - Single nuggets in content are now preserved

**Why this matters:** The hybrid approach combines WorkManager's reliability (survives force-stop) with AlarmManager's exact timing for morning notifications. Nugget notifications at 4 AM avoid timing conflicts and use WorkManager-only approach.

**v2.0.2 (January 2026) - Notification System Overhaul:**
- **CRITICAL FIX:** Migrated to WorkManager for reliable recurring notifications
- Fixed nugget notification time from 11:08 AM → 10:00 AM (iOS parity)
- Updated background fetch time from 5:00 AM → 9:45 AM (iOS parity)
- Added `SCHEDULE_EXACT_ALARM` permission check for Android 12+
- Added defensive notification initialization on app startup
- Enhanced logging for debugging notification issues
- Added `test-notifications.sh` diagnostic script

**Why this matters:** Previous AlarmManager-based system was fragile - notifications stopped after app force-stop or device reboot. WorkManager survives these scenarios and automatically reschedules.

**v2.0.1 (December 2024) - Namespace Refactoring:**
- Changed package from `com.firstloveassembly.breadandwine` → `breadandwineandroid.breadandwineandroid`
- Moved all source files to new package structure
- Updated all package declarations, imports, and ProGuard rules
- Enhanced ProGuard rules to prevent API data loading issues in release builds
- **Important:** The applicationId and namespace are now identical for consistency

**Why this matters:** Previous builds had mismatched namespace/applicationId causing confusion. Both are now `breadandwineandroid.breadandwineandroid` throughout the codebase, Firebase config, and build files.
