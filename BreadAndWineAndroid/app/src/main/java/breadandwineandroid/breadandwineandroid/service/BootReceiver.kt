package breadandwineandroid.breadandwineandroid.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import breadandwineandroid.breadandwineandroid.data.cache.DevotionalCache
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

/**
 * Boot Receiver
 * Reschedules notifications after device reboot
 * CRITICAL: Respects user notification preferences
 * Hybrid: Morning (6 AM) via AlarmManager + WorkManager, Nugget (4 AM) via WorkManager only
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d(TAG, "Device booted, checking notification preferences")

            // Must use goAsync() for coroutines in BroadcastReceiver
            val pendingResult = goAsync()

            CoroutineScope(Dispatchers.IO).launch {
                try {
                    val cache = DevotionalCache.getInstance(context)
                    val settings = cache.getNotificationSettings().first()

                    // Cancel any stale AlarmManager nugget notifications from previous versions
                    NotificationScheduler.cancelNuggetNotification(context)
                    Log.d(TAG, "Cancelled any stale AlarmManager nugget notifications")

                    // Only reschedule if user has enabled notifications
                    if (settings.enabled) {
                        if (settings.morningEnabled) {
                            NotificationScheduler.scheduleMorningNotification(context)
                            NotificationWorker.scheduleMorningNotification(context)
                            Log.d(TAG, "Morning notification rescheduled via AlarmManager + WorkManager (6 AM)")
                        }

                        if (settings.nuggetEnabled) {
                            NotificationWorker.scheduleNuggetNotification(context)
                            Log.d(TAG, "Nugget notification rescheduled via WorkManager (4 AM)")
                        }
                    } else {
                        Log.d(TAG, "Notifications disabled by user, not rescheduling")
                    }

                    // Background work disabled - cache-first strategy works without pre-fetch
                    Log.d(TAG, "Background work not scheduled (not needed)")

                } catch (e: Exception) {
                    Log.e(TAG, "Error rescheduling after boot", e)
                } finally {
                    pendingResult.finish()
                }
            }
        }
    }
}
