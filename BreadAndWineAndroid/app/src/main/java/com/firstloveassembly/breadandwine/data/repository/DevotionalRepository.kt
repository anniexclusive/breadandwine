package com.firstloveassembly.breadandwine.data.repository

import com.firstloveassembly.breadandwine.data.api.ApiService
import com.firstloveassembly.breadandwine.data.api.WordPressApi
import com.firstloveassembly.breadandwine.data.cache.DevotionalCache
import com.firstloveassembly.breadandwine.model.Devotional
import kotlinx.coroutines.flow.Flow
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
     */
    suspend fun getTodaysNugget(): String? {
        return try {
            val response = api.getDevotionalsWithLimit()
            if (response.isSuccessful && response.body() != null) {
                val today = java.time.LocalDate.now()
                val todayDevotional = response.body()!!.firstOrNull { devotional ->
                    try {
                        val devotionalDate = java.time.Instant.parse(devotional.date)
                            .atZone(java.time.ZoneId.systemDefault())
                            .toLocalDate()
                        devotionalDate.isEqual(today)
                    } catch (e: Exception) {
                        false
                    }
                }
                todayDevotional?.acf?.nugget
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }
}
