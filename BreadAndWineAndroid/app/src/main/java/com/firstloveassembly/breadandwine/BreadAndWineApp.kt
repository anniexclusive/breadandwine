package com.firstloveassembly.breadandwine

import android.app.Application
import android.util.Log
import com.firstloveassembly.breadandwine.service.DeviceTokenManager
import com.firstloveassembly.breadandwine.service.NotificationScheduler
import com.google.firebase.FirebaseApp

/**
 * Application class
 */
class BreadAndWineApp : Application() {

    override fun onCreate() {
        super.onCreate()

        try {
            // Initialize Firebase
            FirebaseApp.initializeApp(this)
            Log.d("BreadAndWineApp", "Firebase initialized")

            // Create notification channels
            NotificationScheduler.createNotificationChannel(this)
            Log.d("BreadAndWineApp", "Notification channels created")

            // Get FCM token for push notifications
            DeviceTokenManager.initializeToken(this)
            Log.d("BreadAndWineApp", "FCM token initialization started")

        } catch (e: Exception) {
            Log.e("BreadAndWineApp", "Initialization failed: ${e.message}", e)
        }
    }
}
