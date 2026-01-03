package breadandwineandroid.breadandwineandroid.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import breadandwineandroid.breadandwineandroid.MainActivity
import breadandwineandroid.breadandwineandroid.R
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/**
 * Firebase Cloud Messaging Service
 * Handles push notifications from FCM
 * Mirrors iOS AppDelegate notification handling
 */
class BreadAndWineMessagingService : FirebaseMessagingService() {

    companion object {
        private const val CHANNEL_ID = "devotional_channel"
        private const val CHANNEL_NAME = "Devotional Notifications"
        private const val NOTIFICATION_ID = 1
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    /**
     * Called when a new FCM token is generated
     * Mirrors iOS didRegisterForRemoteNotificationsWithDeviceToken
     */
    override fun onNewToken(token: String) {
        super.onNewToken(token)

        // Save token to Firebase Firestore
        DeviceTokenManager.saveDeviceToken(this, token)
    }

    /**
     * Called when a message is received
     * Mirrors iOS userNotificationCenter willPresent
     */
    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)

        // Extract notification data
        val title = message.notification?.title ?: "Bread & Wine"
        val body = message.notification?.body ?: "New devotional available"

        // Show notification
        showNotification(title, body)
    }

    /**
     * Show notification to user
     */
    private fun showNotification(title: String, body: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notificationBuilder.build())
    }

    /**
     * Create notification channel (required for Android O+)
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance).apply {
                description = "Notifications for daily devotionals and spiritual insights"
                enableLights(true)
                enableVibration(true)
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
