package breadandwineandroid.breadandwineandroid.service

import android.content.Context
import android.util.Log
import androidx.work.*
import breadandwineandroid.breadandwineandroid.data.api.ApiService
import breadandwineandroid.breadandwineandroid.data.cache.DevotionalCache
import breadandwineandroid.breadandwineandroid.data.repository.DevotionalRepository
import kotlinx.coroutines.flow.first
import java.util.Calendar
import java.util.concurrent.TimeUnit

/**
 * WorkManager-based notification worker for reliable recurring notifications
 * More robust than AlarmManager - survives app restarts and force-stops
 *
 * Two types:
 * 1. Morning Reminder (6:00 AM)
 * 2. Daily Nugget (10:00 AM)
 */
class NotificationWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        private const val TAG = "NotificationWorker"

        // Work names
        private const val MORNING_WORK_NAME = "morning_notification_work"
        private const val NUGGET_WORK_NAME = "nugget_notification_work"

        // Input data keys
        private const val KEY_NOTIFICATION_TYPE = "notification_type"
        const val TYPE_MORNING = "morning"
        const val TYPE_NUGGET = "nugget"

        /**
         * Schedule morning notification worker (6:00 AM daily)
         */
        fun scheduleMorningNotification(context: Context) {
            val constraints = Constraints.Builder()
                .build() // No network required for local notifications

            val delay = calculateDelayUntil(6, 0)

            val workRequest = PeriodicWorkRequestBuilder<NotificationWorker>(
                24, TimeUnit.HOURS
            )
                .setConstraints(constraints)
                .setInitialDelay(delay, TimeUnit.MILLISECONDS)
                .setInputData(workDataOf(KEY_NOTIFICATION_TYPE to TYPE_MORNING))
                .addTag(MORNING_WORK_NAME)
                .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                MORNING_WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                workRequest
            )

            Log.d(TAG, "Morning notification worker scheduled for 6:00 AM daily (delay: ${delay}ms)")
        }

        /**
         * Schedule nugget notification worker (4:00 AM daily)
         */
        fun scheduleNuggetNotification(context: Context) {
            val constraints = Constraints.Builder()
                .build() // No network required - nugget content cached by DevotionalWorker

            val delay = calculateDelayUntil(4, 0)

            val workRequest = PeriodicWorkRequestBuilder<NotificationWorker>(
                24, TimeUnit.HOURS
            )
                .setConstraints(constraints)
                .setInitialDelay(delay, TimeUnit.MILLISECONDS)
                .setInputData(workDataOf(KEY_NOTIFICATION_TYPE to TYPE_NUGGET))
                .addTag(NUGGET_WORK_NAME)
                .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                NUGGET_WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                workRequest
            )

            Log.d(TAG, "Nugget notification worker scheduled for 4:00 AM daily (delay: ${delay}ms)")
        }

        /**
         * Cancel morning notification worker
         */
        fun cancelMorningNotification(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(MORNING_WORK_NAME)
            Log.d(TAG, "Morning notification worker cancelled")
        }

        /**
         * Cancel nugget notification worker
         */
        fun cancelNuggetNotification(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(NUGGET_WORK_NAME)
            Log.d(TAG, "Nugget notification worker cancelled")
        }

        /**
         * Calculate delay until target time
         */
        private fun calculateDelayUntil(hour: Int, minute: Int): Long {
            val currentTime = Calendar.getInstance()
            val targetTime = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)

                // If time has passed today, schedule for tomorrow
                if (timeInMillis <= currentTime.timeInMillis) {
                    add(Calendar.DAY_OF_YEAR, 1)
                }
            }

            return targetTime.timeInMillis - currentTime.timeInMillis
        }
    }

    override suspend fun doWork(): Result {
        val notificationType = inputData.getString(KEY_NOTIFICATION_TYPE)
        Log.d(TAG, "NotificationWorker triggered: type=$notificationType")

        return try {
            // Check if notifications are enabled
            val cache = DevotionalCache.getInstance(applicationContext)
            val settings = cache.getNotificationSettings().first()

            if (!settings.enabled) {
                Log.d(TAG, "Notifications disabled by user, skipping")
                return Result.success()
            }

            when (notificationType) {
                TYPE_MORNING -> {
                    if (settings.morningEnabled) {
                        showMorningNotification()
                    } else {
                        Log.d(TAG, "Morning notifications disabled by user")
                    }
                }
                TYPE_NUGGET -> {
                    if (settings.nuggetEnabled) {
                        showNuggetNotification(cache)
                    } else {
                        Log.d(TAG, "Nugget notifications disabled by user")
                    }
                }
            }

            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "Error showing notification", e)
            Result.failure()
        }
    }

    private fun showMorningNotification() {
        NotificationHelper.showNotification(
            applicationContext,
            "Morning Devotional",
            "Refresh your spirit—your devotional awaits!",
            NotificationScheduler.MORNING_NOTIFICATION_ID
        )
        Log.d(TAG, "Morning notification displayed")
    }

    private suspend fun showNuggetNotification(cache: DevotionalCache) {
        val repository = DevotionalRepository(
            api = ApiService.api,
            cache = cache
        )

        val nugget = repository.getTodaysNugget()
        val message = nugget ?: "Your spiritual insight for today is ready!"

        NotificationHelper.showNotification(
            applicationContext,
            "Daily Nugget",
            message,
            NotificationScheduler.NUGGET_NOTIFICATION_ID
        )
        Log.d(TAG, "Nugget notification displayed: ${message.take(50)}...")
    }
}

/**
 * Helper object for showing notifications
 * Extracted from NotificationReceiver for reuse
 */
object NotificationHelper {
    private const val TAG = "NotificationHelper"

    fun showNotification(context: Context, title: String, message: String, notificationId: Int) {
        val intent = android.content.Intent(context, breadandwineandroid.breadandwineandroid.MainActivity::class.java).apply {
            flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK or android.content.Intent.FLAG_ACTIVITY_CLEAR_TASK
        }

        val pendingIntent = android.app.PendingIntent.getActivity(
            context,
            0,
            intent,
            android.app.PendingIntent.FLAG_IMMUTABLE or android.app.PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notificationBuilder = androidx.core.app.NotificationCompat.Builder(context, NotificationScheduler.CHANNEL_ID)
            .setSmallIcon(breadandwineandroid.breadandwineandroid.R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(androidx.core.app.NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(androidx.core.app.NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        notificationManager.notify(notificationId, notificationBuilder.build())

        Log.d(TAG, "Notification displayed: id=$notificationId, title=$title")
    }
}
