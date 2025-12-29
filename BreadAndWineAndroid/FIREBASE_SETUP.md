# Firebase Setup Guide for Android

This guide will help you configure Firebase for the Bread & Wine Android app.

## Prerequisites

- Access to Firebase Console: https://console.firebase.google.com/
- Google account
- Android package name: `com.firstloveassembly.breadandwine`

## Option 1: Add Android to Existing iOS Firebase Project (Recommended)

Since you already have a Firebase project for the iOS app (`pushbreadandwine`), you can add the Android app to the same project.

### Steps:

1. **Go to Firebase Console**
   - Navigate to: https://console.firebase.google.com/
   - Select project: `pushbreadandwine`

2. **Add Android App**
   - Click the ⚙️ (Settings) icon → Project settings
   - Scroll to "Your apps" section
   - Click "Add app" → Select Android icon

3. **Register App**
   - **Android package name:** `com.firstloveassembly.breadandwine`
   - **App nickname (optional):** Bread & Wine Android
   - **Debug signing certificate SHA-1 (optional):** Leave blank for now
   - Click "Register app"

4. **Download config file**
   - Download `google-services.json`
   - Place it in: `BreadAndWineAndroid/app/google-services.json`

5. **Enable Services**

   Navigate to each service and enable:

   **a) Cloud Messaging (FCM)**
   - Go to: Build → Cloud Messaging
   - Already enabled if iOS is using it
   - Note the Server Key for backend notifications

   **b) Firestore Database**
   - Go to: Build → Firestore Database
   - Should already have `devices` collection from iOS
   - Android devices will write to the same collection with `platform: "android"`

   **c) Analytics (Optional but Recommended)**
   - Go to: Build → Analytics
   - Enable Google Analytics
   - Link to Analytics property

6. **Verify Setup**
   - Build and run the app
   - Check Logcat for: "FCM Token: ..."
   - Go to Firestore → `devices` collection
   - Verify a new document with `platform: "android"` appears

---

## Option 2: Create New Firebase Project

If you want a separate Firebase project for Android:

### Steps:

1. **Create Project**
   - Go to: https://console.firebase.google.com/
   - Click "Add project"
   - Name: `breadandwine-android` (or your choice)
   - Enable Google Analytics: Yes (recommended)
   - Select Analytics location and accept terms
   - Click "Create project"

2. **Add Android App**
   - Click "Add app" → Select Android
   - Package name: `com.firstloveassembly.breadandwine`
   - Click "Register app"

3. **Download Config**
   - Download `google-services.json`
   - Place in: `BreadAndWineAndroid/app/google-services.json`

4. **Enable Cloud Messaging**
   - Go to: Build → Cloud Messaging
   - Note the Sender ID and Server Key

5. **Create Firestore Database**
   - Go to: Build → Firestore Database
   - Click "Create database"
   - Start in **production mode**
   - Choose location: `us-central1` (or closest to your users)

   **Set up Security Rules:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /devices/{device} {
         allow read, write: if true;  // Adjust for production
       }
     }
   }
   ```

6. **Configure Cloud Messaging**
   - Go to: Build → Cloud Messaging
   - No additional setup needed
   - Server Key will be used for sending push notifications

---

## Testing Firebase Integration

### Test 1: Device Token Registration

1. Run the app on a device/emulator
2. Check Android Studio Logcat:
   ```
   DeviceTokenManager: FCM Token: ey...
   DeviceTokenManager: Device token saved successfully
   ```

3. Verify in Firestore:
   - Open Firebase Console → Firestore Database
   - Check `devices` collection
   - Should see a document with:
     ```json
     {
       "token": "ey...",
       "platform": "android",
       "appVersion": "1.0.0",
       "lastActive": Timestamp
     }
     ```

### Test 2: Push Notifications

1. **From Firebase Console:**
   - Go to: Engage → Cloud Messaging
   - Click "Send your first message"
   - **Notification title:** "Test Notification"
   - **Notification text:** "This is a test from Firebase"
   - Click "Next"
   - **Target:** Select your Android app
   - Click "Next" → "Review" → "Publish"

2. **Check Device:**
   - Notification should appear on device
   - Check Logcat for delivery confirmation

### Test 3: Firestore Write

1. Run the app
2. Toggle notification settings in Settings screen
3. Check Firestore:
   - Verify device document is updated
   - Check `lastActive` timestamp updates

---

## Firebase Configuration Files

### google-services.json Structure

Your `google-services.json` should look like:

```json
{
  "project_info": {
    "project_number": "273197662053",
    "firebase_url": "https://pushbreadandwine.firebaseio.com",
    "project_id": "pushbreadandwine",
    "storage_bucket": "pushbreadandwine.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:273197662053:android:...",
        "android_client_info": {
          "package_name": "com.firstloveassembly.breadandwine"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIza..."
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ]
}
```

---

## Security Rules

### Firestore Rules (Production-Ready)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Device tokens collection
    match /devices/{deviceToken} {
      // Allow devices to create/update their own token
      allow create, update: if request.resource.data.token == deviceToken;

      // Allow devices to read their own data
      allow read: if resource.data.token == deviceToken;

      // Only allow deletion by authenticated admins
      allow delete: if false;  // Adjust based on admin auth
    }

    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Storage Rules (if using Firebase Storage)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /devotional_images/{imageId} {
      allow read: if true;  // Public read
      allow write: if false;  // No writes from app
    }
  }
}
```

---

## Backend Integration (Optional)

If you want to send push notifications from a backend server:

### Using Node.js with Firebase Admin SDK

```javascript
const admin = require('firebase-admin');

// Initialize with service account
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Send notification to Android devices
async function sendDailyNugget(nuggetText) {
  const db = admin.firestore();
  const devicesSnapshot = await db.collection('devices')
    .where('platform', '==', 'android')
    .get();

  const tokens = devicesSnapshot.docs.map(doc => doc.data().token);

  const message = {
    notification: {
      title: 'Daily Nugget',
      body: nuggetText
    },
    tokens: tokens
  };

  const response = await admin.messaging().sendMulticast(message);
  console.log(`Successfully sent to ${response.successCount} devices`);
}
```

---

## Troubleshooting

### Issue: "google-services.json not found"

**Solution:** Ensure file is in `app/` directory, not `app/src/`

### Issue: "FCM token not generated"

**Solutions:**
1. Check internet connection
2. Verify Google Play Services is installed (on emulator)
3. Check Logcat for Firebase initialization errors
4. Rebuild project: `./gradlew clean build`

### Issue: "Notifications not received"

**Solutions:**
1. Check notification permissions (Android 13+)
2. Verify FCM service is running in Logcat
3. Test with Firebase Console test message
4. Check device is not in Doze mode
5. Verify `google-services.json` is correct

### Issue: "Firestore permission denied"

**Solution:** Update Firestore security rules (see above)

---

## Production Checklist

Before releasing to production:

- [ ] `google-services.json` is NOT committed to public repo
- [ ] Firestore security rules are configured
- [ ] Analytics is enabled and working
- [ ] Test notifications on multiple devices
- [ ] Test on Android 7.0+ (API 24+)
- [ ] Verify device tokens are being saved
- [ ] Test background notifications
- [ ] Test with app in background/killed state
- [ ] Configure notification channels properly
- [ ] Add notification icon (replace `ic_notification.xml`)

---

## Additional Resources

- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging/android/client)
- [Firestore Android Guide](https://firebase.google.com/docs/firestore/quickstart)
- [Firebase Console](https://console.firebase.google.com/)

---

**Questions?** Check the main [README.md](README.md) or Firebase documentation.
