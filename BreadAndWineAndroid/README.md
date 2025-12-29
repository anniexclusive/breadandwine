# Bread & Wine Devotional - Android

Native Android version of the Bread & Wine Daily Devotional app, built with Kotlin and Jetpack Compose.

## 📱 Overview

This is a companion Android application to the existing iOS app, providing daily spiritual devotionals, scripture readings, and inspirational nuggets to Android users. The app maintains feature parity with the iOS version while following Android best practices.

## 🏗️ Architecture

**Pattern:** MVVM (Model-View-ViewModel)

**Tech Stack:**
- **Language:** Kotlin
- **UI Framework:** Jetpack Compose (Material 3)
- **Architecture Components:** ViewModel, LiveData, Navigation
- **Networking:** Retrofit + OkHttp
- **Async:** Kotlin Coroutines + Flow
- **Serialization:** Gson
- **Dependency Injection:** Manual (easily upgradeable to Hilt)
- **Backend:** Firebase (FCM, Firestore)
- **Caching:** DataStore Preferences
- **Background Tasks:** WorkManager
- **Image Loading:** Coil

## 📂 Project Structure

```
app/src/main/java/com/firstloveassembly/breadandwine/
├── BreadAndWineApp.kt              # Application class
├── MainActivity.kt                  # Main entry point with navigation
│
├── model/                          # Data models
│   └── Devotional.kt               # Core data structures
│
├── data/                           # Data layer
│   ├── api/
│   │   ├── WordPressApi.kt         # API interface
│   │   └── ApiService.kt           # Retrofit configuration
│   ├── repository/
│   │   └── DevotionalRepository.kt # Data repository
│   └── cache/
│       └── DevotionalCache.kt      # DataStore caching
│
├── viewmodel/                      # ViewModels
│   ├── DevotionalViewModel.kt      # Main devotional logic
│   └── SettingsViewModel.kt        # Settings management
│
├── ui/                             # UI layer (Compose)
│   ├── theme/                      # App theme
│   │   ├── Theme.kt
│   │   └── Typography.kt
│   ├── devotional/                 # Devotional screens
│   │   ├── DevotionalListScreen.kt
│   │   └── DevotionalDetailScreen.kt
│   ├── nuggets/
│   │   └── NuggetsScreen.kt
│   ├── settings/
│   │   └── SettingsScreen.kt
│   └── about/
│       └── AboutScreen.kt
│
├── service/                        # Services & background tasks
│   ├── BreadAndWineMessagingService.kt  # FCM service
│   ├── DeviceTokenManager.kt            # Firestore token management
│   ├── NotificationScheduler.kt         # Local notifications
│   ├── NotificationReceiver.kt          # Notification broadcast receiver
│   ├── DevotionalWorker.kt              # Background fetch worker
│   └── BootReceiver.kt                  # Reschedule after reboot
│
└── util/                           # Utilities
    ├── NetworkMonitor.kt           # Network connectivity
    └── TextToSpeechManager.kt      # TTS functionality
```

## ✨ Features

### Implemented
- ✅ **Daily Devotionals List** - Scrollable list with pull-to-refresh
- ✅ **Devotional Detail View** - Rich HTML content with images
- ✅ **Daily Nuggets** - Quick spiritual insights
- ✅ **Push Notifications** - Firebase Cloud Messaging integration
- ✅ **Local Notifications** - Scheduled reminders (6 AM, 10 AM)
- ✅ **Background Fetch** - Auto-refresh at 9:45 AM daily
- ✅ **Offline Caching** - DataStore persistence
- ✅ **Settings** - Notification preferences
- ✅ **Share Functionality** - Share devotionals via Android share sheet
- ✅ **Material Design 3** - Modern UI with light/dark theme support
- ✅ **Network Monitoring** - Automatic retry on connection restore
- ✅ **Text-to-Speech** - Read devotionals aloud (British English)

### To Be Enhanced
- ⏳ **Text-to-Speech UI** - Add playback controls to detail screen
- ⏳ **Search Functionality** - Search devotionals by keyword
- ⏳ **Favorites** - Bookmark favorite devotionals
- ⏳ **Analytics** - Firebase Analytics integration
- ⏳ **App Icon & Splash Screen** - Custom branding assets

## 🚀 Setup Instructions

### Prerequisites

1. **Android Studio** - Latest stable version (Giraffe or newer)
2. **JDK 17** - Required for Android Gradle Plugin 8.x
3. **Android SDK** - API Level 34 (minimum API 24)
4. **Firebase Project** - Access to `pushbreadandwine` Firebase project

### Step 1: Clone and Open Project

```bash
cd BreadAndWineAndroid
```

Open the project in Android Studio.

### Step 2: Firebase Configuration

#### Option A: Use Existing iOS Firebase Project (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select the `pushbreadandwine` project
3. Click "Add app" → Select Android
4. Register app with package name: `com.firstloveassembly.breadandwine`
5. Download `google-services.json`
6. Place it in `app/` directory

#### Option B: Create New Firebase Project

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an Android app with package name: `com.firstloveassembly.breadandwine`
3. Download `google-services.json` and place in `app/`
4. Enable **Cloud Messaging** and **Firestore Database**

### Step 3: Sync Gradle

```bash
# From Android Studio terminal
./gradlew build
```

Or click "Sync Now" in Android Studio when prompted.

### Step 4: Update API Endpoint (Optional)

The app uses the WordPress REST API at:
```
https://breadandwinedevotional.com/wp-json/wp/v2/devotional
```

If you need to change this, edit:
```kotlin
// ApiService.kt
private const val BASE_URL = "https://your-domain.com/wp-json/wp/v2/"
```

### Step 5: Configure Signing (For Release Builds)

Create `keystore.properties` in project root:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=path/to/your/keystore.jks
```

Update `app/build.gradle.kts` to add signing config:

```kotlin
android {
    signingConfigs {
        create("release") {
            // Load from keystore.properties
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### Step 6: Run the App

1. Connect an Android device or start an emulator (API 24+)
2. Click **Run** (▶️) in Android Studio
3. Select your device/emulator

## 🔔 Notification Setup

### Local Notifications

The app schedules two daily local notifications:

1. **Morning Reminder** - 6:00 AM
   - "Refresh your spirit—your devotional awaits!"
2. **Daily Nugget** - 10:00 AM
   - "Your spiritual insight for today is ready!"

Notifications are automatically rescheduled after device reboot via `BootReceiver`.

### Push Notifications (FCM)

Firebase Cloud Messaging is configured to receive remote notifications. Device tokens are automatically saved to Firestore under the `devices` collection:

```
devices/
  └── {fcm_token}
      ├── token: "fcm_token_string"
      ├── platform: "android"
      ├── appVersion: "1.0.0"
      └── lastActive: Timestamp
```

**To send test notifications:**

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Target: Select the Android app
4. Send test message

### Notification Permissions

Android 13+ requires runtime permission for notifications. The app should request this on first launch. To manually enable:

**Settings → Apps → Bread & Wine → Notifications → Allow**

## 🧪 Testing

### Unit Tests (To Be Added)

```bash
./gradlew test
```

### Instrumented Tests (To Be Added)

```bash
./gradlew connectedAndroidTest
```

### Manual Testing Checklist

- [ ] Load devotionals from API
- [ ] View devotional detail with HTML rendering
- [ ] Pull to refresh works
- [ ] Offline caching works (airplane mode test)
- [ ] Navigate to Nuggets tab
- [ ] Toggle notification settings
- [ ] Receive scheduled notifications (6 AM, 10 AM)
- [ ] Receive push notifications from Firebase
- [ ] Share devotional via share sheet
- [ ] Background fetch works (check logs at 9:45 AM)
- [ ] App works on tablets (large screen layout)

## 🐛 Known Issues & Limitations

1. **WebView HTML Rendering** - Some complex HTML might not render perfectly. Consider using a better HTML parser library like `HtmlCompat` or `Markwon`.

2. **Notification Icon** - Default notification icon is a placeholder. Replace `ic_notification.xml` with your brand icon.

3. **Text-to-Speech Controls** - TTS is implemented but not yet exposed in the UI. Add playback controls to `DevotionalDetailScreen`.

4. **No Dependency Injection** - Manual dependency creation. Consider migrating to **Hilt** for production.

5. **Image Caching** - Coil handles image loading but no aggressive caching policy. Consider adding disk cache configuration.

## 🔧 Configuration

### Notification Times

To change notification times, edit:

```kotlin
// NotificationScheduler.kt
val calendar = Calendar.getInstance().apply {
    set(Calendar.HOUR_OF_DAY, 6)  // Change hour here
    set(Calendar.MINUTE, 0)         // Change minute here
}
```

### Background Fetch Time

To change background fetch time (default 9:45 AM):

```kotlin
// DevotionalWorker.kt
val targetTime = java.util.Calendar.getInstance().apply {
    set(java.util.Calendar.HOUR_OF_DAY, 9)   // Change here
    set(java.util.Calendar.MINUTE, 45)        // Change here
}
```

### Theme Colors

Colors are defined in:
- `ui/theme/Theme.kt` - Compose Material Theme
- `res/values/colors.xml` - XML color resources

### TTS Voice

Default is British English (`Locale.UK`). To change:

```kotlin
// TextToSpeechManager.kt
tts?.setLanguage(Locale.US)  // Change to US English
```

## 📦 Build & Release

### Debug Build

```bash
./gradlew assembleDebug
```

Output: `app/build/outputs/apk/debug/app-debug.apk`

### Release Build

```bash
./gradlew assembleRelease
```

Output: `app/build/outputs/apk/release/app-release.apk`

### App Bundle (For Play Store)

```bash
./gradlew bundleRelease
```

Output: `app/build/outputs/bundle/release/app-release.aab`

## 🚢 Deployment

### Google Play Store

1. Create a Google Play Developer account
2. Create new app listing
3. Upload `app-release.aab`
4. Complete store listing (title, description, screenshots)
5. Set content rating and pricing
6. Submit for review

### Internal Testing

Use Firebase App Distribution for internal testing:

```bash
./gradlew assembleDebug
firebase appdistribution:distribute app/build/outputs/apk/debug/app-debug.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups testers
```

## 🔐 Security Notes

- ❌ **Do NOT commit** `google-services.json` to public repos
- ❌ **Do NOT commit** `keystore.properties` or signing keys
- ✅ Use environment variables or secrets management for CI/CD
- ✅ Enable ProGuard/R8 for release builds (already configured)

## 📚 Resources

- [WordPress API Documentation](https://breadandwinedevotional.com/wp-json/wp/v2)
- [Firebase Console](https://console.firebase.google.com/project/pushbreadandwine)
- [Jetpack Compose Docs](https://developer.android.com/jetpack/compose)
- [Material Design 3](https://m3.material.io/)
- [Android Developers](https://developer.android.com/)

## 🤝 Contributing

This is a companion to the iOS app. Maintain feature parity when adding new features:

1. Match iOS functionality and UX
2. Follow Android Material Design guidelines
3. Use Kotlin idioms and best practices
4. Write unit tests for new features
5. Update this README with changes

## 📄 License

© 2024 First Love Assembly. All rights reserved.

## 🆘 Support

For issues or questions:
- **iOS App Code:** Check `BreadAndWine/` directory
- **Backend API:** Contact WordPress admin
- **Firebase Issues:** Check Firebase Console logs
- **Android Issues:** Check Logcat in Android Studio

---

**Version:** 1.0.0
**Target SDK:** 34 (Android 14)
**Minimum SDK:** 24 (Android 7.0 Nougat)
**Package:** `com.firstloveassembly.breadandwine`
