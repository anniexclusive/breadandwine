package breadandwineandroid.breadandwineandroid.service

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import breadandwineandroid.breadandwineandroid.MainActivity
import breadandwineandroid.breadandwineandroid.R
import java.util.*

/**
 * Notification Scheduler
 * Schedules local notifications using AlarmManager
 * Mirrors iOS NotificationManager
 */
object NotificationScheduler {

    const val CHANNEL_ID = "devotional_local_channel"
    private const val CHANNEL_NAME = "Daily Reminders"

    private const val MORNING_NOTIFICATION_ID = 100
    private const val NUGGET_NOTIFICATION_ID = 101

    private const val MORNING_REQUEST_CODE = 1000
    private const val NUGGET_REQUEST_CODE = 1001

    /**
     * Schedule morning reminder (6:00 AM)
     * Mirrors iOS scheduleMorningNotification()
     */
    fun scheduleMorningNotification(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent = Intent(context, NotificationReceiver::class.java).apply {
            action = "MORNING_REMINDER"
            putExtra("title", "Morning Devotional")
            putExtra("message", "Refresh your spirit—your devotional awaits!")
            putExtra("notificationId", MORNING_NOTIFICATION_ID)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            MORNING_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Set alarm for 6:00 AM
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 6)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)

            // If time has passed today, schedule for tomorrow
            if (timeInMillis < System.currentTimeMillis()) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        // Schedule repeating alarm
        alarmManager.setRepeating(
            AlarmManager.RTC_WAKEUP,
            calendar.timeInMillis,
            AlarmManager.INTERVAL_DAY,
            pendingIntent
        )
    }

    /**
     * Schedule nugget notification (10:00 AM)
     * Mirrors iOS scheduleNuggetNotification()
     */
    fun scheduleNuggetNotification(context: Context, nuggetContent: String? = null) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val message = nuggetContent ?: "Your spiritual insight for today is ready!"

        val intent = Intent(context, NotificationReceiver::class.java).apply {
            action = "DAILY_NUGGET"
            putExtra("title", "Daily Nugget")
            putExtra("message", message)
            putExtra("notificationId", NUGGET_NOTIFICATION_ID)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            NUGGET_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Set alarm for 10:00 AM
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 10)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)

            // If time has passed today, schedule for tomorrow
            if (timeInMillis < System.currentTimeMillis()) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        // Schedule repeating alarm (replaces existing one with same request code)
        alarmManager.setRepeating(
            AlarmManager.RTC_WAKEUP,
            calendar.timeInMillis,
            AlarmManager.INTERVAL_DAY,
            pendingIntent
        )
    }

    /**
     * Cancel morning notification
     */
    fun cancelMorningNotification(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, NotificationReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            MORNING_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        alarmManager.cancel(pendingIntent)
    }

    /**
     * Cancel nugget notification
     */
    fun cancelNuggetNotification(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, NotificationReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            NUGGET_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        alarmManager.cancel(pendingIntent)
    }

    /**
     * Create notification channel
     */
    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance).apply {
                description = "Daily devotional reminders and nuggets"
                enableLights(true)
                enableVibration(true)
            }

            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}

/**
 * Broadcast Receiver for scheduled notifications
 */
class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: "Bread & Wine"
        val message = intent.getStringExtra("message") ?: "Check your devotional"
        val notificationId = intent.getIntExtra("notificationId", 0)

        showNotification(context, title, message, notificationId)
    }

    private fun showNotification(context: Context, title: String, message: String, notificationId: Int) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notificationBuilder = NotificationCompat.Builder(context, NotificationScheduler.CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId, notificationBuilder.build())
    }

    companion object {
        private const val CHANNEL_ID = "devotional_local_channel"
    }
}
