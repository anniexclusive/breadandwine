package com.firstloveassembly.breadandwine

import com.firstloveassembly.breadandwine.data.api.WordPressApi
import com.firstloveassembly.breadandwine.data.cache.DevotionalCache
import com.firstloveassembly.breadandwine.data.repository.DevotionalRepository
import com.firstloveassembly.breadandwine.model.*
import io.mockk.*
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test
import retrofit2.Response
import kotlin.test.assertNotNull
import kotlin.test.assertNull

/**
 * Unit tests for DevotionalRepository
 * Tests data fetching and date filtering logic
 */
class DevotionalRepositoryTest {

    private lateinit var api: WordPressApi
    private lateinit var cache: DevotionalCache
    private lateinit var repository: DevotionalRepository

    @Before
    fun setup() {
        api = mockk(relaxed = true)
        cache = mockk(relaxed = true)
        repository = DevotionalRepository(api, cache)

        // Setup default cache behavior
        every { cache.getCachedDevotionals() } returns flowOf(emptyList())
        coEvery { cache.saveDevotionals(any()) } just Runs
    }

    @Test
    fun `getTodaysNugget returns null when API fails`() = runTest {
        // Given API returns error
        coEvery { api.getDevotionalsWithLimit() } returns Response.error(
            500,
            okhttp3.ResponseBody.create(null, "")
        )

        // When getting today's nugget
        val result = repository.getTodaysNugget()

        // Then returns null
        assertNull(result)
    }

    @Test
    fun `getTodaysNugget returns null when no devotionals match today`() = runTest {
        // Given devotionals from yesterday
        val yesterday = java.time.LocalDate.now().minusDays(1)
        val yesterdayISO = "${yesterday}T00:00:00Z"

        val devotionals = listOf(
            Devotional(
                id = 1,
                date = yesterdayISO,
                title = Title("Yesterday"),
                content = Content("Content"),
                acf = ACF(
                    bibleVerse = "John 3:16",
                    furtherStudy = "Study",
                    prayer = "Prayer",
                    bibleReadingPlan = "Plan",
                    nugget = "Yesterday's nugget"
                )
            )
        )

        coEvery { api.getDevotionalsWithLimit() } returns Response.success(devotionals)

        // When getting today's nugget
        val result = repository.getTodaysNugget()

        // Then returns null (no match for today)
        assertNull(result)
    }

    @Test
    fun `getTodaysNugget handles malformed dates gracefully`() = runTest {
        // Given devotional with invalid date
        val devotionals = listOf(
            Devotional(
                id = 1,
                date = "invalid-date-format",
                title = Title("Title"),
                content = Content("Content"),
                acf = ACF(
                    bibleVerse = "John 3:16",
                    furtherStudy = "Study",
                    prayer = "Prayer",
                    bibleReadingPlan = "Plan",
                    nugget = "Today's nugget"
                )
            )
        )

        coEvery { api.getDevotionalsWithLimit() } returns Response.success(devotionals)

        // When getting today's nugget
        val result = repository.getTodaysNugget()

        // Then returns null without crashing
        assertNull(result)
    }

    @Test
    fun `getTodaysNugget returns null when ACF is null`() = runTest {
        // Given today's devotional without ACF
        val today = java.time.LocalDate.now()
        val todayISO = "${today}T00:00:00Z"

        val devotionals = listOf(
            Devotional(
                id = 1,
                date = todayISO,
                title = Title("Today"),
                content = Content("Content"),
                acf = null
            )
        )

        coEvery { api.getDevotionalsWithLimit() } returns Response.success(devotionals)

        // When getting today's nugget
        val result = repository.getTodaysNugget()

        // Then returns null (no ACF nugget)
        assertNull(result)
    }

    @Test
    fun `getTodaysNugget handles network exception`() = runTest {
        // Given API throws exception
        coEvery { api.getDevotionalsWithLimit() } throws Exception("Network error")

        // When getting today's nugget
        val result = repository.getTodaysNugget()

        // Then returns null without crashing
        assertNull(result)
    }

    @Test
    fun `refreshDevotionals returns failure when API fails`() = runTest {
        // Given API error
        coEvery { api.getDevotionalsWithLimit() } returns Response.error(
            404,
            okhttp3.ResponseBody.create(null, "Not found")
        )

        // When refreshing
        val result = repository.refreshDevotionals()

        // Then returns failure
        assert(result.isFailure)
    }

    @Test
    fun `refreshDevotionals returns failure on exception`() = runTest {
        // Given API throws exception
        coEvery { api.getDevotionalsWithLimit() } throws Exception("Connection timeout")

        // When refreshing
        val result = repository.refreshDevotionals()

        // Then returns failure
        assert(result.isFailure)
    }

    @Test
    fun `getCachedDevotionals returns flow from cache`() = runTest {
        // Given cached devotionals
        val cachedDevotionals = listOf(
            Devotional(
                id = 1,
                date = "2024-01-01T00:00:00Z",
                title = Title("Cached"),
                content = Content("Content"),
                acf = null
            )
        )
        every { cache.getCachedDevotionals() } returns flowOf(cachedDevotionals)

        // When getting cached devotionals
        val flow = repository.getCachedDevotionals()

        // Then returns flow
        assertNotNull(flow)
    }
}
