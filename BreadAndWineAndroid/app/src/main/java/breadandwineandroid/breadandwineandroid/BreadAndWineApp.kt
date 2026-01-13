package breadandwineandroid.breadandwineandroid

import android.app.Application
import android.util.Log
import breadandwineandroid.breadandwineandroid.data.cache.DevotionalCache
import breadandwineandroid.breadandwineandroid.service.DeviceTokenManager
import breadandwineandroid.breadandwineandroid.service.DevotionalWorker
import breadandwineandroid.breadandwineandroid.service.NotificationScheduler
import breadandwineandroid.breadandwineandroid.service.NotificationWorker
import com.google.firebase.FirebaseApp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

/**
 * Application class
 */
class BreadAndWineApp : Application() {

    private val applicationScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

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

            // Background worker to refresh nugget content daily at 9:45 AM
            // DISABLED: Testing proved cache-first + API fallback works without pre-fetch
            // Removed to eliminate timing race conditions and reduce battery usage
            // DevotionalWorker.cancel(this)
            Log.d("BreadAndWineApp", "Background devotional fetch disabled (not needed)")

            // CRITICAL: Defensively schedule notifications if user has them enabled
            // Using AlarmManager for precise timing (WorkManager had 10+ hour delays)
            // This ensures notifications work even if user never opens Settings after install
            initializeNotificationsWithAlarmManager()

        } catch (e: Exception) {
            Log.e("BreadAndWineApp", "Initialization failed: ${e.message}", e)
        }
    }

    /**
     * Initialize notifications based on user preferences
     * This is called on every app start to ensure notifications are always scheduled
     *
     * ARCHITECTURE DECISION: Hybrid approach for reliability
     * - Morning (6 AM): AlarmManager + WorkManager for redundancy
     * - Nugget (4 AM): WorkManager only (AlarmManager not working reliably)
     * - WorkManager survives app force-stops and provides dynamic content fetching
     */
    private fun initializeNotificationsWithAlarmManager() {
        applicationScope.launch {
            try {
                val cache = DevotionalCache.getInstance(applicationContext)
                val settings = cache.getNotificationSettings().first()

                // Cancel any stale AlarmManager nugget notifications from previous versions
                NotificationScheduler.cancelNuggetNotification(applicationContext)
                Log.d("BreadAndWineApp", "Cancelled any stale AlarmManager nugget notifications")

                if (settings.enabled) {
                    Log.d("BreadAndWineApp", "Initializing notifications (enabled: ${settings.enabled}, morning: ${settings.morningEnabled}, nugget: ${settings.nuggetEnabled})")

                    if (settings.morningEnabled) {
                        NotificationScheduler.scheduleMorningNotification(applicationContext)
                        NotificationWorker.scheduleMorningNotification(applicationContext)
                        Log.d("BreadAndWineApp", "Morning notification scheduled via AlarmManager + WorkManager (6 AM)")
                    }

                    if (settings.nuggetEnabled) {
                        NotificationWorker.scheduleNuggetNotification(applicationContext)
                        Log.d("BreadAndWineApp", "Nugget notification scheduled via WorkManager (4 AM)")
                    }
                } else {
                    Log.d("BreadAndWineApp", "Notifications disabled by user, not scheduling")
                }
            } catch (e: Exception) {
                Log.e("BreadAndWineApp", "Failed to initialize notifications", e)
            }
        }
    }
}
