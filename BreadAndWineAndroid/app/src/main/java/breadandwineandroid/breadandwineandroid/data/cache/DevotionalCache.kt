package breadandwineandroid.breadandwineandroid.data.cache

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import breadandwineandroid.breadandwineandroid.model.Devotional
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

/**
 * Cache layer for devotional data using DataStore
 * Mirrors iOS UserDefaults caching strategy
 * CRITICAL: DataStore MUST be a singleton - multiple instances cause crashes!
 * This class is now a singleton to ensure only one DataStore instance exists
 */

// Singleton DataStore instance - MUST be at top level
private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "devotional_prefs")

class DevotionalCache private constructor(private val context: Context) {

    private val gson = Gson()

    companion object {
        @Volatile
        private var INSTANCE: DevotionalCache? = null

        fun getInstance(context: Context): DevotionalCache {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: DevotionalCache(context.applicationContext).also { INSTANCE = it }
            }
        }

        private val CACHED_DEVOTIONALS_KEY = stringPreferencesKey("cachedDevotionals")
        private val NOTIFICATIONS_ENABLED_KEY = stringPreferencesKey("notificationsEnabled")
        private val MORNING_NOTIFICATIONS_KEY = stringPreferencesKey("morningNotificationsEnabled")
        private val NUGGET_NOTIFICATIONS_KEY = stringPreferencesKey("nuggetNotificationsEnabled")
    }

    /**
     * Save devotionals to cache
     */
    suspend fun saveDevotionals(devotionals: List<Devotional>) {
        context.dataStore.edit { preferences ->
            val json = gson.toJson(devotionals)
            preferences[CACHED_DEVOTIONALS_KEY] = json
        }
    }

    /**
     * Get cached devotionals as Flow
     */
    fun getCachedDevotionals(): Flow<List<Devotional>> {
        return context.dataStore.data.map { preferences ->
            val json = preferences[CACHED_DEVOTIONALS_KEY] ?: return@map emptyList()
            try {
                val type = object : TypeToken<List<Devotional>>() {}.type
                gson.fromJson<List<Devotional>>(json, type)
            } catch (e: Exception) {
                emptyList()
            }
        }
    }

    /**
     * Save notification settings
     */
    suspend fun saveNotificationSettings(
        enabled: Boolean,
        morningEnabled: Boolean,
        nuggetEnabled: Boolean
    ) {
        context.dataStore.edit { preferences ->
            preferences[NOTIFICATIONS_ENABLED_KEY] = enabled.toString()
            preferences[MORNING_NOTIFICATIONS_KEY] = morningEnabled.toString()
            preferences[NUGGET_NOTIFICATIONS_KEY] = nuggetEnabled.toString()
        }
    }

    /**
     * Get notification settings
     */
    fun getNotificationSettings(): Flow<NotificationSettings> {
        return context.dataStore.data.map { preferences ->
            NotificationSettings(
                enabled = preferences[NOTIFICATIONS_ENABLED_KEY]?.toBoolean() ?: true,
                morningEnabled = preferences[MORNING_NOTIFICATIONS_KEY]?.toBoolean() ?: true,
                nuggetEnabled = preferences[NUGGET_NOTIFICATIONS_KEY]?.toBoolean() ?: true
            )
        }
    }

    data class NotificationSettings(
        val enabled: Boolean,
        val morningEnabled: Boolean,
        val nuggetEnabled: Boolean
    )
}
