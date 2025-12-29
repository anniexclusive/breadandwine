package com.firstloveassembly.breadandwine.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Boot Receiver
 * Reschedules notifications after device reboot
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d(TAG, "Device booted, rescheduling notifications")

            // Reschedule notifications
            NotificationScheduler.scheduleMorningNotification(context)
            NotificationScheduler.scheduleNuggetNotification(context)

            // Reschedule background work
            DevotionalWorker.schedule(context)

            Log.d(TAG, "Notifications and background work rescheduled")
        }
    }
}
