# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Bread & Wine Devotional** is a dual-platform mobile application delivering daily spiritual devotionals. The repository contains both iOS (Swift/SwiftUI) and Android (Kotlin/Jetpack Compose) implementations that share the same WordPress REST API backend and Firebase Cloud Messaging infrastructure.

## Build & Run Commands

### iOS

```bash
# Build the project
xcodebuild -project BreadAndWine.xcodeproj -scheme BreadAndWine -configuration Debug build

# Run tests
xcodebuild test -project BreadAndWine.xcodeproj -scheme BreadAndWine -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean build folder
xcodebuild clean -project BreadAndWine.xcodeproj -scheme BreadAndWine
```

**Development Workflow:**
- Open `BreadAndWine.xcodeproj` in Xcode
- Select a simulator or device
- Press Cmd+R to build and run
- Press Cmd+U to run tests

### Android

```bash
# Navigate to Android directory
cd BreadAndWineAndroid

# Sync Gradle dependencies
./gradlew build

# Debug APK
./gradlew assembleDebug

# Run all unit tests (requires JAVA_HOME)
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew test

# Run specific test class
./gradlew test --tests SettingsViewModelTest

# Clean build
./gradlew clean build
```

Refer to `BreadAndWineAndroid/CLAUDE.md` for detailed Android-specific guidance.

## Architecture Overview

### High-Level Structure

```
WordPress API Backend (breadandwinedevotional.com)
           ↓
    ┌──────┴──────┐
    ↓             ↓
iOS App      Android App
(SwiftUI)    (Jetpack Compose)
    ↓             ↓
    └──────┬──────┘
           ↓
Firebase Cloud Messaging (Shared)
```

### iOS App Architecture (MVVM)

**Directory Structure:**
- `Model/` - Data models matching WordPress API JSON
- `ViewModel/` - Business logic and state management with Combine
- `Views/` - SwiftUI screens and UI components
- `Services/` - API client, network monitoring, HTML rendering
- `Utils/` - Reusable UI components, device management, TTS

**Key Design Patterns:**

1. **MVVM with Combine**
   - ViewModels use `@Published` properties for reactive UI updates
   - DevotionalViewModel is the primary data coordinator
   - UserDefaults for caching devotionals offline

2. **Adaptive Layout System**
   - RootView.swift detects device type via `horizontalSizeClass`
   - iPad: NavigationSplitView with sidebar menu
   - iPhone: NavigationView with slide-out menu
   - Uses same content views across both form factors

3. **Dual Navigation System**
   - TabView for primary navigation (Devotionals/Nuggets)
   - UnifiedMenuView for secondary features (Settings/About)
   - Menu adapts: sidebar on iPad, slide-out drawer on iPhone

### Data Flow

```
APIService.fetchDevotionals()
    ↓
DevotionalViewModel (caching + state)
    ↓
Views (DevotionalListView, NuggetsListView)
    ↓
DevotionalDetailView (HTML rendering + TTS)
```

**Offline Support:**
- Devotionals cached in UserDefaults on fetch
- App loads cached data on launch before network request
- Background fetch updates content at 9:45 AM daily

### Cross-Platform Feature Parity

The iOS and Android apps mirror each other's functionality. When implementing features:

**iOS → Android Mappings:**
- `AVSpeechSynthesizer` → `TextToSpeechManager`
- `UserDefaults` → `DataStore`
- `UNUserNotificationCenter` → `NotificationScheduler` + `AlarmManager`
- `BGTaskScheduler` → `WorkManager`

Check the Android implementation in `BreadAndWineAndroid/` when uncertain about behavior.

## Critical Implementation Details

### 1. WordPress API Integration

**Endpoint:** `https://breadandwinedevotional.com/wp-json/wp/v2/devotional`

The API returns an array of devotionals with:
- Root-level `date` field (ISO 8601 format)
- `title.rendered` (may contain HTML)
- `content.rendered` (full HTML content)
- `acf.nugget` (daily nugget text)
- `yoast_head_json.og_image[0].url` (featured image)

**Key Code:** `Services/APIService.swift:13-36`

Date parsing uses ISO 8601 format, formatted for display as "d MMMM yyyy" (e.g., "10 November 2025").

### 2. HTML Content Rendering

Devotional content is WordPress HTML that must be rendered in native UI, not WebView.

**iOS Approach:**
- Uses `HTMLStringView` with `UIViewRepresentable` wrapping `WKWebView`
- Custom CSS injected for typography and blockquote styling
- System font integration for native feel
- Dark mode support via `colorScheme` environment value

**Key Files:**
- `Services/HTMLStringView.swift` - Main HTML renderer
- `Services/HTMLText.swift` - Plain text HTML parser for TTS

**Why this approach?** WebView provides better HTML rendering than AttributedString, supports custom styling, and handles complex formatting like nested blockquotes.

### 3. Notification System

**Two Types:**

**Local Notifications (via NotificationManager.swift):**
- Morning Reminder: 6 AM daily ("Refresh your spirit—your devotional awaits!")
- Daily Nugget: 10 AM with actual nugget text from today's devotional
- Uses `UNCalendarNotificationTrigger` for repeating schedule
- Scheduled in `AppDelegate.swift:49` after permission granted

**Remote Push Notifications (via Firebase):**
- Device tokens saved to Firestore `devices/{token}` collection
- FCM token handling in `AppDelegate.swift:94-99`
- Background mode: `remote-notification` in Info.plist

**Background Fetch:**
- `BackgroundFetchManager.swift` schedules at 9:45 AM daily
- Updates nugget notification content before 10 AM delivery
- Task ID: `com.devotionalapp.nuggetFetch`
- Registered in `AppDelegate.swift:25`

### 4. Text-to-Speech System

**Implementation:** `Utils/SpeechSynthesizer.swift`

- Voice: British English (`en-GB`)
- Speed: 0.65x default rate
- State: `@Published` properties for `isSpeaking` and `isPaused`
- Playback controls: Play/Pause/Stop

**Audio Session Configuration (BreadAndWineApp.swift:42-48):**
```swift
.setCategory(.playback, mode: .spokenAudio,
             options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers])
```

This allows:
- Background audio playback
- Ducking of other audio
- Interruption of other speech audio

**Content Processing:**
- HTML stripped to plain text via `HTMLText.swift`
- Reads full devotional content sequentially

### 5. Firebase Integration

**Setup:**
- `GoogleService-Info.plist` in project root (gitignored)
- Firebase initialized in `AppDelegate.swift:19`
- Shared Firebase project: `pushbreadandwine` (same as Android)

**Device Registration:**
- FCM token generated on app launch
- Saved to Firestore via `DeviceManager.swift`
- Collection: `devices/{token}`
- Fields: `token`, `platform: "ios"`, `appVersion`, `lastActive`

### 6. Adaptive UI for iPad/iPhone

**Detection:** `@Environment(\.horizontalSizeClass)`

**iPad (Regular Width):**
- NavigationSplitView with persistent/dismissible sidebar
- Three-column layout capability
- Menu always visible or toggleable
- Wider content area for reading

**iPhone (Compact Width):**
- NavigationView with slide-out drawer menu
- Edge swipe gesture to open menu (from left edge)
- Tap outside to dismiss
- Blur effect on content when menu open

**Key File:** `RootView.swift:38-115`

### 7. Splash Screen

App shows `SplashScreenView` for 3 seconds on launch before transitioning to main content with fade animation. Configured in `BreadAndWineApp.swift:22-36`.

## Common Development Tasks

### Adding a New View/Screen

1. Create new SwiftUI file in `Views/` directory
2. Add navigation logic to `RootView.swift` or within TabView
3. If adding to menu, update `UnifiedMenuView.swift`
4. Create ViewModel if needed in `ViewModel/` directory

### Modifying Notification Times

```swift
// NotificationManager.swift
dateComponents.hour = 6  // Morning notification (line 69)
dateComponents.hour = 10 // Nugget notification (line 107)

// BackgroundFetchManager.swift
targetComponents.hour = 9    // Background fetch (line 30)
targetComponents.minute = 45
```

### Testing Notifications Locally

1. Run app on simulator/device
2. Grant notification permissions
3. Background the app
4. Change system time via Settings or:
```bash
# For jailbroken devices
xcrun simctl status_bar booted override time "2025-11-10T06:00:00"
```

### Adding New ACF Fields

When WordPress adds new ACF (Advanced Custom Fields):

1. Update `Model/Devotional.swift:42-49` ACF struct
2. Add field to CodingKeys if snake_case
3. Access in views via `devotional.acf?.fieldName`

### Modifying TTS Voice/Speed

Edit `SpeechSynthesizer.swift:28-30`:
```swift
utterance.voice = AVSpeechSynthesisVoice(language: "en-GB") // Change locale
utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.65  // Adjust multiplier
```

## Firebase Setup

**Quick Setup:**
1. Download `GoogleService-Info.plist` from [Firebase Console](https://console.firebase.google.com/project/pushbreadandwine)
2. Add to Xcode project (drag into navigator)
3. Ensure "Copy items if needed" is checked
4. Verify bundle identifier matches: `com.firstloveassembly.breadandwine`

**Firestore Schema:**
```
devices/{fcm_token}
  - token: String
  - platform: "ios" | "android"
  - appVersion: String
  - lastActive: Timestamp
```

## Known Gotchas & Solutions

### 1. Device Type Detection Issues
**Problem:** Menu layout breaks on some iPad sizes
**Solution:** Always use `horizontalSizeClass`, never screen dimensions

### 2. TTS State Management
**Problem:** Play button state doesn't update when speech finishes
**Solution:** Ensure delegate methods update `@Published` properties on main thread

### 3. HTML Rendering Line Spacing
**Problem:** Paragraphs too close together in WebView
**Solution:** CSS is injected in `HTMLStringView.swift` with custom line-height

### 4. Background Tasks Not Running
**Problem:** BGTaskScheduler not firing
**Solution:**
- Verify `Info.plist` includes task identifier
- Use scheme editor to simulate: Product → Scheme → Edit Scheme → Run → Options → Background Fetch

### 5. Cached Devotionals Stale
**Problem:** App shows old content after API updates
**Solution:** Force refresh via pull-to-refresh or clear UserDefaults key `"cachedDevotionals"`

### 6. Notification Permissions Not Showing
**Problem:** Permission prompt never appears
**Solution:** Delete app and reinstall. Permissions are one-time per install.

## Testing

**Coverage:** ~25% (14 tests)

**Framework:** Swift Testing (modern, requires iOS 16+)

**What's Tested:**
- Devotional model (date parsing, ACF fields, content)
- DevotionalViewModel (search, caching, today's devotional)
- Singleton managers and configuration

**Run Tests:**
```bash
xcodebuild test -project BreadAndWine.xcodeproj \
  -scheme BreadAndWine \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Adding Tests:**
```swift
import Testing
@testable import BreadAndWine

struct MyTests {
    @Test func myTestName() throws {
        // Given
        let value = "test"

        // When/Then
        #expect(value == "test")
    }
}
```

**Guidelines:**
- Focus on business logic, not UI
- Test error handling and edge cases
- Keep tests simple and readable

## Swift Package Dependencies

Resolved packages (from `xcodebuild -list` output):
- Firebase iOS SDK 11.11.0 (Auth, Firestore, Messaging)
- Google utilities (GTMSessionFetcher, GoogleDataTransport, etc.)
- gRPC, Protobuf, Abseil for Firebase infrastructure

All dependencies are managed via Swift Package Manager in Xcode.

## Important Code Locations

**App Initialization & Lifecycle:**
- `BreadAndWineApp.swift` - App entry point, splash screen, audio session
- `AppDelegate.swift` - Firebase setup, notification registration, background tasks
- `RootView.swift` - Main navigation structure, adaptive layout

**Core Business Logic:**
- `ViewModel/DevotionalViewModel.swift` - Main data coordinator, API calls, caching
- `Services/APIService.swift` - WordPress REST API client
- `Model/Devotional.swift` - Data models with JSON decoding

**UI Components:**
- `Views/DevotionalListView.swift` - Home screen devotional list
- `Views/DevotionalDetailView.swift` - Full devotional with TTS controls
- `Views/NuggetsListView.swift` - List of daily nuggets
- `Views/SettingsView.swift` - Notification toggles, about section

**Services:**
- `Services/NotificationManager.swift` - Local notification scheduling
- `Services/BackgroundFetchManager.swift` - Background refresh tasks
- `Services/HTMLStringView.swift` - HTML content renderer
- `Utils/SpeechSynthesizer.swift` - Text-to-speech engine
- `Utils/DeviceManager.swift` - Firebase device token management

**Utilities:**
- `Utils/UnifiedMenuView.swift` - Adaptive menu for iPad/iPhone
- `Utils/SplashScreenView.swift` - Launch screen
- `ColorTheme.swift` - Theme colors and dark mode support

## Deployment Checklist

**Before submitting to App Store:**
- [ ] Update version and build number in Xcode project settings
- [ ] Test on both iPhone and iPad physical devices
- [ ] Verify notifications work (local and push)
- [ ] Test offline mode with cached content
- [ ] Test text-to-speech with full devotional
- [ ] Verify background fetch by changing device time
- [ ] Test adaptive layout on various screen sizes
- [ ] Ensure `GoogleService-Info.plist` is production version
- [ ] Build for release configuration
- [ ] Archive and upload via Xcode Organizer

## When Things Break

**Debugging Order:**
1. Check Xcode console for error messages
2. Product → Clean Build Folder (Cmd+Shift+K)
3. Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`
4. Verify Swift package dependencies are resolved
5. Check Android implementation for reference behavior
6. Test on physical device (simulator has limitations)

**Common Issues & Fixes:**
- **Notifications not appearing:** Check Info.plist capabilities and permission status
- **TTS not working:** Verify audio session category and simulator limitations
- **HTML rendering broken:** Check WebView initialization and CSS injection
- **Firebase crashes:** Ensure `GoogleService-Info.plist` present and valid
- **Background fetch fails:** Verify `BGTaskSchedulerPermittedIdentifiers` in Info.plist

## Codebase Conventions

**File Organization:**
- Group by layer (Model/View/ViewModel) not by feature
- Services are cross-cutting concerns
- Utils are reusable UI components

**Naming:**
- Views: Descriptive noun + "View" (e.g., `DevotionalListView`)
- ViewModels: Noun + "ViewModel" (e.g., `DevotionalViewModel`)
- Services: Noun + "Service" or "Manager" (e.g., `APIService`, `NotificationManager`)

**SwiftUI Patterns:**
- Use `@StateObject` for view ownership of ViewModels
- Use `@ObservedObject` when passing ViewModels down
- Prefer `@Published` over manual `objectWillChange` calls
- Extract subviews when body gets complex

**State Management:**
- ViewModels handle business logic
- Views are as "dumb" as possible
- UserDefaults for simple persistence
- Combine for reactive updates

**Git Commit Conventions:**
- Use standard conventional commit format: `type: description`
- Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`, `test`, `perf`
- Keep message to one line, concise and descriptive
- Never mention AI assistance or Claude in commit messages
- Examples:
  - `feat: add drawer menu to android app`
  - `fix: resolve tts volume issues on android`
  - `chore: remove dead code files`
  - `refactor: extract hardcoded values to constants`
