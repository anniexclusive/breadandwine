package breadandwineandroid.breadandwineandroid.data.repository

import breadandwineandroid.breadandwineandroid.data.api.ApiService
import breadandwineandroid.breadandwineandroid.data.api.WordPressApi
import breadandwineandroid.breadandwineandroid.data.cache.DevotionalCache
import breadandwineandroid.breadandwineandroid.model.Devotional
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow

/**
 * Repository pattern for managing devotional data
 * Handles API calls and caching strategy
 * Mirrors iOS DevotionalViewModel data fetching logic
 */
class DevotionalRepository(
    private val api: WordPressApi,
    private val cache: DevotionalCache
) {

    /**
     * Fetch devotionals with cache-first strategy
     */
    fun getDevotionals(): Flow<ApiService.ApiResult<List<Devotional>>> = flow {
        // Emit loading state
        emit(ApiService.ApiResult.Loading)

        try {
            // First, try to fetch from API
            val response = api.getDevotionalsWithLimit()

            if (response.isSuccessful && response.body() != null) {
                val devotionals = response.body()!!

                // Sort by date (newest first)
                val sortedDevotionals = devotionals.sortedByDescending { it.date }

                // Cache the result
                cache.saveDevotionals(sortedDevotionals)

                // Emit success
                emit(ApiService.ApiResult.Success(sortedDevotionals))
            } else {
                // API failed, try to load from cache
                emitCachedOrError("API Error: ${response.code()}")
            }
        } catch (e: Exception) {
            // Network error, try to load from cache
            emitCachedOrError("Network Error: ${e.localizedMessage}")
        }
    }

    /**
     * Helper to emit cached data or error
     */
    private suspend fun emitCachedOrError(errorMessage: String): Flow<ApiService.ApiResult<List<Devotional>>> = flow {
        cache.getCachedDevotionals().collect { cachedDevotionals ->
            if (cachedDevotionals.isNotEmpty()) {
                emit(ApiService.ApiResult.Success(cachedDevotionals))
            } else {
                emit(ApiService.ApiResult.Error(errorMessage))
            }
        }
    }

    /**
     * Get cached devotionals directly
     */
    fun getCachedDevotionals(): Flow<List<Devotional>> {
        return cache.getCachedDevotionals()
    }

    /**
     * Refresh devotionals (force network call)
     */
    suspend fun refreshDevotionals(): Result<List<Devotional>> {
        return try {
            val response = api.getDevotionalsWithLimit()

            if (response.isSuccessful && response.body() != null) {
                val devotionals = response.body()!!.sortedByDescending { it.date }
                cache.saveDevotionals(devotionals)
                Result.success(devotionals)
            } else {
                Result.failure(Exception("API Error: ${response.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Get today's nugget (from today's devotional)
     * CACHE-FIRST strategy for fast notification delivery
     */
    suspend fun getTodaysNugget(): String? {
        // Helper function to find today's devotional
        fun findTodaysNugget(devotionals: List<Devotional>): String? {
            val today = java.time.LocalDate.now()

            return devotionals.firstOrNull { devotional ->
                try {
                    // WordPress dates are in LocalDateTime format (2026-01-05T00:05:38), not Instant
                    val devotionalDate = java.time.LocalDateTime.parse(devotional.date).toLocalDate()
                    devotionalDate.isEqual(today)
                } catch (e: Exception) {
                    false
                }
            }?.acf?.nugget
        }

        return try {
            // Check cache FIRST for instant results (no network delay)
            // Use .first() to get current value immediately, not .collect() which blocks forever
            val cachedDevotionals = cache.getCachedDevotionals().first()
            val cachedNugget = findTodaysNugget(cachedDevotionals)

            // Return cached nugget if found
            if (cachedNugget != null) {
                return cachedNugget
            }

            // Cache empty/stale - try API as fallback (fresh install only)
            val response = api.getDevotionalsWithLimit()
            if (response.isSuccessful && response.body() != null) {
                findTodaysNugget(response.body()!!)
            } else {
                null
            }
        } catch (e: Exception) {
            // Any exception - return null (notification will use fallback message)
            null
        }
    }
}
