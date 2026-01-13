# Bread & Wine Devotional - Android

Native Android app delivering daily spiritual devotionals from Firstlove Assembly. Built with Kotlin and Jetpack Compose.

## Overview

Daily devotional app featuring scripture readings, spiritual insights, prayers, and Bible reading plans. Companion to the iOS version with feature parity.

**Key Features:**
- Daily devotionals with rich HTML content
- Daily nuggets (quick spiritual insights)
- Text-to-speech (British English)
- Share functionality with proper formatting
- Local notifications (6 AM morning, 4 AM nugget)
- Offline caching
- Dark mode support

## Tech Stack

- **Language**: Kotlin
- **UI**: Jetpack Compose (Material 3)
- **Architecture**: MVVM
- **Backend**: WordPress REST API + Firebase (FCM, Firestore)
- **Storage**: DataStore
- **Background**: WorkManager + AlarmManager (hybrid)
- **Networking**: Retrofit + OkHttp
- **Image Loading**: Coil

## Build Commands

```bash
# Debug APK
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew assembleDebug

# Release bundle for Play Store
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew bundleRelease

# Run tests
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew test
```

## Setup

1. Clone repository
2. Add `google-services.json` to `app/` directory (from Firebase Console)
3. Set `BNW_KEYSTORE_PASSWORD` environment variable for release builds
4. Open in Android Studio
5. Sync Gradle dependencies
6. Run on device or emulator

## Key Architecture

**Notification System (Hybrid):**
- Morning (6 AM): AlarmManager + WorkManager for redundancy
- Nugget (4 AM): WorkManager only
- Background fetch (9:45 AM): Updates content before nugget notification

**Share Functionality:**
- HTML entity decoding (e.g., `&#8230;` → `…`)
- Ellipsis normalization (`...` ↔ `…`)
- Duplicate nugget handling (removes last occurrence if multiple exist)

## Documentation

See `CLAUDE.md` for detailed architecture, development guide, and troubleshooting.

## Version Info

- **Current**: 2.0.3 (versionCode 19)
- **Package**: `breadandwineandroid.breadandwineandroid`
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 36 (Android 14)
