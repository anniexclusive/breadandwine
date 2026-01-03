package breadandwineandroid.breadandwineandroid.service

import android.content.Context
import android.util.Log
import androidx.work.*
import breadandwineandroid.breadandwineandroid.data.api.ApiService
import breadandwineandroid.breadandwineandroid.data.cache.DevotionalCache
import breadandwineandroid.breadandwineandroid.data.repository.DevotionalRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.TimeUnit

/**
 * Background Worker for fetching devotionals
 * Mirrors iOS BackgroundFetchManager
 * Runs at 9:45 AM daily to refresh content
 */
class DevotionalWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        private const val TAG = "DevotionalWorker"
        private const val WORK_NAME = "devotional_fetch_work"

        /**
         * Schedule daily background fetch at 9:45 AM
         */
        fun schedule(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()

            // Calculate delay until 9:45 AM
            val currentTime = java.util.Calendar.getInstance()
            val targetTime = java.util.Calendar.getInstance().apply {
                set(java.util.Calendar.HOUR_OF_DAY, 9)
                set(java.util.Calendar.MINUTE, 45)
                set(java.util.Calendar.SECOND, 0)

                // If time has passed today, schedule for tomorrow
                if (timeInMillis < currentTime.timeInMillis) {
                    add(java.util.Calendar.DAY_OF_YEAR, 1)
                }
            }

            val delay = targetTime.timeInMillis - currentTime.timeInMillis

            val workRequest = PeriodicWorkRequestBuilder<DevotionalWorker>(
                24, TimeUnit.HOURS  // Repeat every 24 hours
            )
                .setConstraints(constraints)
                .setInitialDelay(delay, TimeUnit.MILLISECONDS)
                .addTag(WORK_NAME)
                .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                workRequest
            )

            Log.d(TAG, "Background fetch scheduled for 9:45 AM daily")
        }

        /**
         * Cancel scheduled work
         */
        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
            Log.d(TAG, "Background fetch cancelled")
        }
    }

    /**
     * Perform background work
     */
    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        Log.d(TAG, "Starting background devotional fetch")

        try {
            val cache = DevotionalCache(applicationContext)
            val repository = DevotionalRepository(
                api = ApiService.api,
                cache = cache
            )

            // Fetch fresh devotionals
            val result = repository.refreshDevotionals()

            if (result.isSuccess) {
                val devotionals = result.getOrNull()
                Log.d(TAG, "Successfully fetched ${devotionals?.size} devotionals")

                // Update nugget notification with fresh content (mirrors iOS refreshNuggetNotificationContent)
                val todayNugget = repository.getTodaysNugget()
                todayNugget?.let { nugget ->
                    Log.d(TAG, "Today's nugget: $nugget")
                    // Reschedule nugget notification with updated content
                    NotificationScheduler.scheduleNuggetNotification(applicationContext, nugget)
                }

                Result.success()
            } else {
                Log.e(TAG, "Failed to fetch devotionals: ${result.exceptionOrNull()}")
                Result.retry()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error during background fetch", e)
            Result.failure()
        }
    }
}
