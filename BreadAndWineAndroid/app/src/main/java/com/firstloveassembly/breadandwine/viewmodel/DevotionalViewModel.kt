package com.firstloveassembly.breadandwine.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.firstloveassembly.breadandwine.data.api.ApiService
import com.firstloveassembly.breadandwine.data.cache.DevotionalCache
import com.firstloveassembly.breadandwine.data.repository.DevotionalRepository
import com.firstloveassembly.breadandwine.model.Devotional
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel for managing devotional data and UI state
 * Mirrors iOS DevotionalViewModel
 */
class DevotionalViewModel(application: Application) : AndroidViewModel(application) {

    private val cache = DevotionalCache(application)
    private val repository = DevotionalRepository(
        api = ApiService.api,
        cache = cache
    )

    // UI State
    private val _devotionals = MutableStateFlow<List<Devotional>>(emptyList())
    val devotionals: StateFlow<List<Devotional>> = _devotionals.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()

    init {
        // Load cached data first
        loadCachedDevotionals()
        // Then fetch fresh data
        fetchDevotionals()
    }

    /**
     * Load cached devotionals immediately
     */
    private fun loadCachedDevotionals() {
        viewModelScope.launch {
            repository.getCachedDevotionals().collect { cached ->
                if (cached.isNotEmpty() && _devotionals.value.isEmpty()) {
                    _devotionals.value = cached
                }
            }
        }
    }

    /**
     * Fetch devotionals from API
     */
    fun fetchDevotionals() {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null

            repository.getDevotionals().collect { result ->
                when (result) {
                    is ApiService.ApiResult.Loading -> {
                        _isLoading.value = true
                    }
                    is ApiService.ApiResult.Success -> {
                        _devotionals.value = result.data
                        _isLoading.value = false
                        _error.value = null
                    }
                    is ApiService.ApiResult.Error -> {
                        _isLoading.value = false
                        _error.value = result.message
                    }
                }
            }
        }
    }

    /**
     * Refresh devotionals (pull to refresh)
     */
    fun refreshDevotionals() {
        viewModelScope.launch {
            _isRefreshing.value = true
            _error.value = null

            val result = repository.refreshDevotionals()
            result.onSuccess { devotionals ->
                _devotionals.value = devotionals
                _error.value = null
            }.onFailure { exception ->
                _error.value = exception.localizedMessage ?: "Failed to refresh"
            }

            _isRefreshing.value = false
        }
    }

    /**
     * Get devotional by ID
     */
    fun getDevotionalById(id: Int): Devotional? {
        return _devotionals.value.firstOrNull { it.id == id }
    }

    /**
     * Get nuggets (devotionals with nugget field)
     */
    fun getNuggets(): List<Devotional> {
        return _devotionals.value.filter { it.acf?.nugget != null }
    }

    /**
     * Clear error message
     */
    fun clearError() {
        _error.value = null
    }
}
