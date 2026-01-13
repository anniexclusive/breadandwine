package breadandwineandroid.breadandwineandroid.service

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import breadandwineandroid.breadandwineandroid.MainActivity
import breadandwineandroid.breadandwineandroid.R
import breadandwineandroid.breadandwineandroid.data.api.ApiService
import breadandwineandroid.breadandwineandroid.data.cache.DevotionalCache
import breadandwineandroid.breadandwineandroid.data.repository.DevotionalRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.*

/**
 * Notification Scheduler (AlarmManager-based)
 *
 * CURRENT USAGE:
 * - Morning notifications (6 AM): ACTIVE - Used alongside WorkManager for redundancy
 * - Nugget notifications: DEPRECATED - Migrated to WorkManager (see NotificationWorker.kt)
 *
 * ARCHITECTURE:
 * - Morning: AlarmManager + WorkManager (dual approach for reliability)
 * - Nugget: WorkManager only at 4 AM (AlarmManager unreliable, didn't fire at 10 AM)
 *
 * See NotificationWorker.kt for WorkManager implementation
 */
object NotificationScheduler {

    const val CHANNEL_ID = "devotional_local_channel"
    private const val CHANNEL_NAME = "Daily Reminders"

    // Notification IDs (internal so NotificationWorker can use them)
    internal const val MORNING_NOTIFICATION_ID = 100
    internal const val NUGGET_NOTIFICATION_ID = 101

    private const val MORNING_REQUEST_CODE = 1000
    private const val NUGGET_REQUEST_CODE = 1001

    // Action constants
    const val ACTION_MORNING_REMINDER = "MORNING_REMINDER"
    const val ACTION_DAILY_NUGGET = "DAILY_NUGGET"

    private const val TAG = "NotificationScheduler"

    /**
     * Check if app has notification permission (Android 13+)
     * Returns true on older Android versions for backward compatibility
     */
    private fun hasNotificationPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val permission = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            )
            val granted = permission == PackageManager.PERMISSION_GRANTED
            if (!granted) {
                Log.w(TAG, "POST_NOTIFICATIONS permission not granted. Notifications will not work on Android 13+")
            }
            granted
        } else {
            true // Permission not required on Android 12 and below
        }
    }

    /**
     * Check if app can schedule exact alarms (Android 12+)
     * Returns true on older Android versions for backward compatibility
     */
    private fun canScheduleExactAlarms(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val canSchedule = alarmManager.canScheduleExactAlarms()
            if (!canSchedule) {
                Log.w(TAG, "SCHEDULE_EXACT_ALARM permission not granted. Exact alarms will not work on Android 12+")
                Log.w(TAG, "User must grant permission in Settings > Apps > Special app access > Alarms & reminders")
            }
            canSchedule
        } else {
            true // Permission not required on Android 11 and below
        }
    }

    /**
     * Schedule morning reminder (6:00 AM)
     * Mirrors iOS scheduleMorningNotification()
     */
    fun scheduleMorningNotification(context: Context) {
        if (!hasNotificationPermission(context)) {
            Log.w(TAG, "Cannot schedule morning notification: POST_NOTIFICATIONS permission not granted")
            return
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent = Intent(context, NotificationReceiver::class.java).apply {
            action = ACTION_MORNING_REMINDER
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

        // Use exact alarm for Android 12+ (API 31+) for reliable daily notifications
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (canScheduleExactAlarms(context)) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
                Log.d(TAG, "Morning notification scheduled for 6:00 AM using exact alarm")
            } else {
                // Fallback to inexact alarm if permission not granted
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
                Log.w(TAG, "Morning notification scheduled for ~6:00 AM using inexact alarm (permission not granted)")
            }
        } else {
            alarmManager.setRepeating(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                AlarmManager.INTERVAL_DAY,
                pendingIntent
            )
            Log.d(TAG, "Morning notification scheduled for 6:00 AM using repeating alarm")
        }
    }

    /**
     * Schedule nugget notification (10:00 AM) - DEPRECATED
     * MIGRATION NOTE: Nugget notifications now use WorkManager (4 AM) for reliability
     * This function kept for backward compatibility but should not be called
     * Use NotificationWorker.scheduleNuggetNotification() instead
     */
    @Deprecated("Use NotificationWorker.scheduleNuggetNotification() instead")
    fun scheduleNuggetNotification(context: Context, nuggetContent: String? = null) {
        if (!hasNotificationPermission(context)) {
            Log.w(TAG, "Cannot schedule nugget notification: POST_NOTIFICATIONS permission not granted")
            return
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val message = nuggetContent ?: "Your spiritual insight for today is ready!"

        val intent = Intent(context, NotificationReceiver::class.java).apply {
            action = ACTION_DAILY_NUGGET
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

        // Set alarm for 10:00 AM (matches iOS)
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 10)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)

            // If time has passed today, schedule for tomorrow
            if (timeInMillis < System.currentTimeMillis()) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        // Use exact alarm for Android 12+ (API 31+) for reliable daily notifications
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (canScheduleExactAlarms(context)) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
                Log.d(TAG, "Nugget notification scheduled for 10:00 AM using exact alarm. Content: ${message.take(50)}...")
            } else {
                // Fallback to inexact alarm if permission not granted
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
                Log.w(TAG, "Nugget notification scheduled for ~10:00 AM using inexact alarm (permission not granted)")
            }
        } else {
            alarmManager.setRepeating(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                AlarmManager.INTERVAL_DAY,
                pendingIntent
            )
            Log.d(TAG, "Nugget notification scheduled for 10:00 AM using repeating alarm. Content: ${message.take(50)}...")
        }
    }

    /**
     * Cancel morning notification
     */
    fun cancelMorningNotification(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Cancel future alarms - MUST include action to match scheduling intent
        val intent = Intent(context, NotificationReceiver::class.java).apply {
            action = ACTION_MORNING_REMINDER
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            MORNING_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        alarmManager.cancel(pendingIntent)

        // Clear any existing notification from tray
        notificationManager.cancel(MORNING_NOTIFICATION_ID)

        Log.d(TAG, "Morning notification cancelled")
    }

    /**
     * Cancel nugget notification
     */
    fun cancelNuggetNotification(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Cancel future alarms - MUST include action to match scheduling intent
        val intent = Intent(context, NotificationReceiver::class.java).apply {
            action = ACTION_DAILY_NUGGET
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            NUGGET_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        alarmManager.cancel(pendingIntent)

        // Clear any existing notification from tray
        notificationManager.cancel(NUGGET_NOTIFICATION_ID)

        Log.d(TAG, "Nugget notification cancelled")
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

    companion object {
        private const val TAG = "NotificationReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.d(TAG, "Notification received: action=$action")

        // Handle notification based on type
        when (action) {
            NotificationScheduler.ACTION_MORNING_REMINDER -> {
                val title = "Morning Devotional"
                val message = "Refresh your spirit—your devotional awaits!"
                showNotification(context, title, message, NotificationScheduler.MORNING_NOTIFICATION_ID)

                // Reschedule for next day
                NotificationScheduler.scheduleMorningNotification(context)
                Log.d(TAG, "Morning notification displayed and rescheduled")
            }
            NotificationScheduler.ACTION_DAILY_NUGGET -> {
                // DEPRECATED: Nugget notifications now handled by WorkManager (4 AM)
                // This code path should not execute - AlarmManager nugget scheduling removed
                Log.w(TAG, "AlarmManager nugget notification received - this should not happen (migrated to WorkManager)")
            }
        }
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

        Log.d(TAG, "Notification displayed: id=$notificationId, title=$title")
    }
}
