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
 * Runs at 9:45 AM daily to refresh content before nugget notification (10:00 AM)
 */
class DevotionalWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        private const val TAG = "DevotionalWorker"
        private const val WORK_NAME = "devotional_fetch_work"

        /**
         * Schedule daily background fetch at 9:45 AM (matches iOS)
         * Runs 15 minutes before nugget notification to ensure fresh content
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

            Log.d(TAG, "Background fetch scheduled for 9:45 AM daily (matches iOS)")
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
            val cache = DevotionalCache.getInstance(applicationContext)
            val repository = DevotionalRepository(
                api = ApiService.api,
                cache = cache
            )

            // Fetch fresh devotionals
            val result = repository.refreshDevotionals()

            if (result.isSuccess) {
                val devotionals = result.getOrNull()
                Log.d(TAG, "Successfully fetched ${devotionals?.size} devotionals")

                // Verify nugget is cached for WorkManager notification (4 AM)
                val todayNugget = repository.getTodaysNugget()
                if (todayNugget != null) {
                    Log.d(TAG, "Today's nugget cached: ${todayNugget.take(50)}...")
                } else {
                    Log.w(TAG, "No nugget found for today - notification will use fallback message")
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
