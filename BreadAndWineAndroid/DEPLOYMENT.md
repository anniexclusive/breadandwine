# Play Store Deployment Guide

## Current Status
- ✅ Version updated to 2.0.0 (versionCode: 2)
- ✅ Firebase configured (google-services.json present)
- ✅ Release build optimizations enabled (R8 + resource shrinking)
- ⚠️ Keystore signing needs to be configured

---

## Pre-Deployment Checklist

### 1. Test the App Thoroughly
```bash
# Run all unit tests
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew test

# Build and test debug APK on physical device
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew assembleDebug
```

**Manual Testing:**
- [ ] Test on physical Android device (notifications unreliable on emulator)
- [ ] Verify all notifications work (local morning/nugget + push)
- [ ] Test offline mode with cached content
- [ ] Test text-to-speech with full devotional
- [ ] Verify splash screen appears for 3 seconds
- [ ] Test adaptive layout on different screen sizes
- [ ] Verify drawer menu opens and logo displays correctly
- [ ] Test About screen shows correct version (2.0.0)

### 2. Create Release Keystore (First Time Only)

If you don't have a keystore yet, create one:

```bash
keytool -genkey -v -keystore breadandwine-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias breadandwine

# You'll be prompted for:
# - Keystore password (save this securely!)
# - Key password (can be same as keystore password)
# - Your name, organization, city, state, country
```

**IMPORTANT:**
- Save the keystore file (`breadandwine-release.jks`) in a secure location
- NEVER commit the keystore to git
- Store passwords in a password manager
- Make backups - if you lose this, you can't update the app!

### 3. Configure Signing in build.gradle.kts

Option A: Using environment variables (recommended for security)
```bash
# Add to ~/.zshrc or ~/.bashrc
export KEYSTORE_PASSWORD="your_keystore_password"
export KEY_ALIAS="breadandwine"
export KEY_PASSWORD="your_key_password"
export KEYSTORE_PATH="/path/to/breadandwine-release.jks"
```

Then uncomment and update in `app/build.gradle.kts`:
```kotlin
signingConfigs {
    create("release") {
        storeFile = file(System.getenv("KEYSTORE_PATH"))
        storePassword = System.getenv("KEYSTORE_PASSWORD")
        keyAlias = System.getenv("KEY_ALIAS")
        keyPassword = System.getenv("KEY_PASSWORD")
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        // ... rest of config
    }
}
```

Option B: Using local.properties (simpler but less secure)
```properties
# In local.properties (gitignored)
KEYSTORE_FILE=/path/to/breadandwine-release.jks
KEYSTORE_PASSWORD=your_password
KEY_ALIAS=breadandwine
KEY_PASSWORD=your_password
```

### 4. Verify Firebase Configuration

- [ ] `google-services.json` is the PRODUCTION version (not debug)
- [ ] Package name matches: `com.firstloveassembly.breadandwine`
- [ ] Firebase project is `pushbreadandwine` (shared with iOS)

---

## Build Release Bundle

Once signing is configured:

```bash
# Clean previous builds
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew clean

# Build release App Bundle (AAB) for Play Store
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew bundleRelease

# Output: app/build/outputs/bundle/release/app-release.aab
```

Or build a signed APK (for direct distribution):
```bash
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew assembleRelease

# Output: app/build/outputs/apk/release/app-release.apk
```

**Verify the build:**
```bash
# Check file exists and size is reasonable (should be ~15-25MB)
ls -lh app/build/outputs/bundle/release/app-release.aab

# Optional: Analyze the bundle
bundletool build-apks --bundle=app/build/outputs/bundle/release/app-release.aab \
  --output=output.apks \
  --mode=universal
```

---

## Play Store Upload Steps

### 1. Sign in to Google Play Console
- Go to: https://play.google.com/console
- Select "Bread & Wine Devotional" app (or create new app)

### 2. Create New Release

**Production Track:**
1. Navigate to: **Production** → **Create new release**
2. Upload `app-release.aab`
3. Add release notes:

```
Version 2.0.0 - What's New:
• Enhanced splash screen with app branding
• Updated app logo throughout the interface
• Improved user interface and navigation
• Performance improvements and bug fixes
• Updated copyright information
```

### 3. Complete Store Listing (if new app)

**App Details:**
- **App name:** Bread & Wine Devotional
- **Short description:** Daily spiritual nourishment through devotionals and scripture
- **Full description:**
```
Bread & Wine Devotional is your daily companion for spiritual growth and reflection.

FEATURES:
• Daily Devotionals - Fresh spiritual content delivered every day
• Daily Nuggets - Quick spiritual insights and inspiration
• Smart Reminders - Morning and daily notifications to keep you engaged
• Offline Access - Read devotionals anytime, anywhere
• Text-to-Speech - Listen to devotionals on the go
• Clean, modern interface - Easy to navigate and read

NOTIFICATIONS:
• Morning Reminder at 6 AM - Start your day with spiritual nourishment
• Daily Nugget at 10 AM - Quick inspiration throughout the day

Stay connected with Firstlove Assembly and grow in your faith journey with daily spiritual nourishment.

© 2026 First Love Assembly. All rights reserved.
```

**Categories:**
- Primary: Books & Reference
- Secondary: Lifestyle

**Content Rating:**
- Fill out questionnaire (should be "Everyone")

**Target Audience:**
- Age: 13+

### 4. Graphics Assets Required

You'll need to provide:
- **App icon:** 512x512 PNG (already have in iOS)
- **Feature graphic:** 1024x500 PNG
- **Screenshots:**
  - Phone: At least 2 screenshots (max 8)
  - 7-inch tablet: At least 2 screenshots (optional but recommended)
  - 10-inch tablet: At least 2 screenshots (optional)

**Tip:** Take screenshots from emulator or use `adb`:
```bash
# Launch app on device/emulator
# Navigate to desired screen
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

Recommended screens to capture:
1. Devotional list (home screen)
2. Devotional detail with TTS controls
3. Daily nuggets list
4. Settings screen

### 5. Pricing & Distribution

- **Price:** Free
- **Countries:** All countries (or select specific ones)
- **Content rating:** Complete questionnaire
- **App content:** Privacy policy URL required

**Privacy Policy URL:**
```
https://breadandwinedevotional.com/privacy-policy
```

### 6. App Access & Declarations

- **Ads:** No (unless you add ads)
- **In-app purchases:** No
- **Data safety:** Fill out data collection questionnaire
  - Collects: Device ID (for push notifications)
  - All data encrypted in transit
  - Users can request data deletion
  - Data collected for: App functionality

---

## Post-Deployment

### Monitor the Release

1. **Check for crashes:**
   - Play Console → Quality → Crashes & ANRs

2. **Monitor reviews:**
   - Respond to user feedback promptly

3. **Track installs:**
   - Play Console → Statistics

### Update Process for Future Releases

1. Update version in `build.gradle.kts`:
   ```kotlin
   versionCode = 3  // Increment by 1
   versionName = "2.1.0"  // Follow semantic versioning
   ```

2. Build and test

3. Build release bundle:
   ```bash
   ./gradlew bundleRelease
   ```

4. Upload to Play Console → Create new release

---

## Troubleshooting

### Build Fails with Signing Error
- Verify keystore path is correct
- Check environment variables are set
- Ensure passwords are correct

### Upload Rejected - Version Code
- Play Store requires versionCode to be higher than previous release
- Increment versionCode in build.gradle.kts

### APK Size Too Large
- Current size should be ~15-25MB (acceptable)
- If larger, check for unnecessary resources
- ProGuard/R8 is already enabled

### Missing Permissions Error
- All required permissions are in AndroidManifest.xml
- Ensure you're testing on Android 7.0+ (API 24+)

---

## Quick Command Reference

```bash
# Run tests
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew test

# Build debug
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew assembleDebug

# Build release bundle (Play Store)
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew bundleRelease

# Build release APK (direct distribution)
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew assembleRelease

# Clean build
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew clean
```

---

## Important Files

- `app/build.gradle.kts` - Version configuration
- `app/google-services.json` - Firebase configuration
- `app/proguard-rules.pro` - Code obfuscation rules
- `app/src/main/AndroidManifest.xml` - App configuration
- `.gitignore` - Ensures keystore is never committed

---

## Contact & Support

**Developer:** Anne Ezurike
**Organization:** First Love Assembly
**Website:** https://breadandwinedevotional.com
**Support Email:** info@breadandwinedevotional.com
