package com.firstloveassembly.breadandwine

import com.firstloveassembly.breadandwine.data.api.ApiService
import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

/**
 * Unit tests for ApiService
 * Tests configuration and result types
 */
class ApiServiceTest {

    @Test
    fun `ApiResult Success holds data`() {
        // Given success result
        val data = listOf("Item1", "Item2")
        val result = ApiService.ApiResult.Success(data)

        // Then data is accessible
        assertEquals(data, result.data)
        assertEquals(2, result.data.size)
    }

    @Test
    fun `ApiResult Error holds message`() {
        // Given error result
        val errorMessage = "Network timeout"
        val result = ApiService.ApiResult.Error(errorMessage)

        // Then message is accessible
        assertEquals(errorMessage, result.message)
    }

    @Test
    fun `ApiResult Error can hold exception`() {
        // Given error with exception
        val exception = Exception("Connection failed")
        val result = ApiService.ApiResult.Error("Failed", exception)

        // Then exception is accessible
        assertNotNull(result.exception)
        assertEquals("Connection failed", result.exception?.message)
    }

    @Test
    fun `ApiResult Loading is singleton`() {
        // Given loading results
        val loading1 = ApiService.ApiResult.Loading
        val loading2 = ApiService.ApiResult.Loading

        // Then same instance
        assert(loading1 === loading2)
    }

    @Test
    fun `ApiResult types are sealed`() {
        // Given API result
        val result: ApiService.ApiResult<String> = ApiService.ApiResult.Success("data")

        // When pattern matching
        val matched = when (result) {
            is ApiService.ApiResult.Success -> "success"
            is ApiService.ApiResult.Error -> "error"
            ApiService.ApiResult.Loading -> "loading"
        }

        // Then pattern match works
        assertEquals("success", matched)
    }

    @Test
    fun `ApiService singleton is initialized`() {
        // When accessing API
        val api = ApiService.api

        // Then API is not null
        assertNotNull(api)
    }
}
