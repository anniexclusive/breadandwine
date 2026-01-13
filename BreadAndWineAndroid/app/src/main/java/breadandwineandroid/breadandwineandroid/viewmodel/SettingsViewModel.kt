package breadandwineandroid.breadandwineandroid.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import breadandwineandroid.breadandwineandroid.data.api.ApiService
import breadandwineandroid.breadandwineandroid.data.cache.DevotionalCache
import breadandwineandroid.breadandwineandroid.data.repository.DevotionalRepository
import breadandwineandroid.breadandwineandroid.service.NotificationScheduler
import breadandwineandroid.breadandwineandroid.service.NotificationWorker
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel for managing app settings
 * Handles notification preferences
 * Mirrors iOS SettingsView notification logic
 */
class SettingsViewModel(application: Application) : AndroidViewModel(application) {

    private val cache = DevotionalCache.getInstance(application)
    private val repository = DevotionalRepository(
        api = ApiService.api,
        cache = cache
    )
    private val context = application.applicationContext

    private val _notificationsEnabled = MutableStateFlow(true)
    val notificationsEnabled: StateFlow<Boolean> = _notificationsEnabled.asStateFlow()

    private val _morningNotificationsEnabled = MutableStateFlow(true)
    val morningNotificationsEnabled: StateFlow<Boolean> = _morningNotificationsEnabled.asStateFlow()

    private val _nuggetNotificationsEnabled = MutableStateFlow(true)
    val nuggetNotificationsEnabled: StateFlow<Boolean> = _nuggetNotificationsEnabled.asStateFlow()

    init {
        loadSettings()
    }

    /**
     * Load settings from cache
     */
    private fun loadSettings() {
        viewModelScope.launch {
            try {
                cache.getNotificationSettings().collect { settings ->
                    _notificationsEnabled.value = settings.enabled
                    _morningNotificationsEnabled.value = settings.morningEnabled
                    _nuggetNotificationsEnabled.value = settings.nuggetEnabled
                }
            } catch (e: Exception) {
                // Defaults are already set, just log the error
                android.util.Log.e("SettingsViewModel", "Failed to load settings", e)
            }
        }
    }

    /**
     * Toggle master notifications
     * Morning uses AlarmManager (6 AM), Nugget uses WorkManager (4 AM)
     */
    fun toggleNotifications(enabled: Boolean) {
        _notificationsEnabled.value = enabled

        try {
            if (enabled) {
                // Schedule both if they were enabled individually
                if (_morningNotificationsEnabled.value) {
                    NotificationScheduler.scheduleMorningNotification(context)
                    NotificationWorker.scheduleMorningNotification(context)
                }
                if (_nuggetNotificationsEnabled.value) {
                    NotificationWorker.scheduleNuggetNotification(context)
                }
            } else {
                // Cancel all notifications (both AlarmManager and WorkManager)
                NotificationScheduler.cancelMorningNotification(context)
                NotificationScheduler.cancelNuggetNotification(context)
                NotificationWorker.cancelMorningNotification(context)
                NotificationWorker.cancelNuggetNotification(context)
            }
        } catch (e: Exception) {
            android.util.Log.e("SettingsViewModel", "Failed to toggle notifications", e)
        }

        saveSettings()
    }

    /**
     * Toggle morning notifications (6 AM via AlarmManager + WorkManager)
     */
    fun toggleMorningNotifications(enabled: Boolean) {
        _morningNotificationsEnabled.value = enabled

        try {
            if (enabled && _notificationsEnabled.value) {
                NotificationScheduler.scheduleMorningNotification(context)
                NotificationWorker.scheduleMorningNotification(context)
            } else {
                NotificationScheduler.cancelMorningNotification(context)
                NotificationWorker.cancelMorningNotification(context)
            }
        } catch (e: Exception) {
            android.util.Log.e("SettingsViewModel", "Failed to toggle morning notifications", e)
        }

        saveSettings()
    }

    /**
     * Toggle nugget notifications (4 AM via WorkManager only)
     */
    fun toggleNuggetNotifications(enabled: Boolean) {
        _nuggetNotificationsEnabled.value = enabled

        try {
            if (enabled && _notificationsEnabled.value) {
                NotificationWorker.scheduleNuggetNotification(context)
            } else {
                NotificationScheduler.cancelNuggetNotification(context)
                NotificationWorker.cancelNuggetNotification(context)
            }
        } catch (e: Exception) {
            android.util.Log.e("SettingsViewModel", "Failed to toggle nugget notifications", e)
        }

        saveSettings()
    }

    /**
     * Save settings to cache
     */
    private fun saveSettings() {
        viewModelScope.launch {
            try {
                cache.saveNotificationSettings(
                    enabled = _notificationsEnabled.value,
                    morningEnabled = _morningNotificationsEnabled.value,
                    nuggetEnabled = _nuggetNotificationsEnabled.value
                )
            } catch (e: Exception) {
                android.util.Log.e("SettingsViewModel", "Failed to save settings", e)
            }
        }
    }
}
