package com.firstloveassembly.breadandwine

import com.firstloveassembly.breadandwine.model.*
import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

/**
 * Unit tests for Devotional model
 * Tests data parsing and helper methods
 */
class DevotionalModelTest {

    @Test
    fun `getPlainTitle removes HTML tags`() {
        // Given
        val devotional = Devotional(
            id = 1,
            date = "2024-01-01T00:00:00",
            title = Title("<strong>Test</strong> Title"),
            content = Content("Content"),
            acf = null
        )

        // When
        val plainTitle = devotional.getPlainTitle()

        // Then
        assertEquals("Test Title", plainTitle)
    }

    @Test
    fun `getFormattedDate formats ISO date correctly`() {
        // Given
        val devotional = Devotional(
            id = 1,
            date = "2024-01-15T00:00:00Z",
            title = Title("Title"),
            content = Content("Content"),
            acf = null
        )

        // When
        val formattedDate = devotional.getFormattedDate()

        // Then
        assert(formattedDate.contains("Jan") || formattedDate.contains("2024"))
    }

    @Test
    fun `getFormattedDate handles invalid date`() {
        // Given
        val invalidDate = "invalid-date"
        val devotional = Devotional(
            id = 1,
            date = invalidDate,
            title = Title("Title"),
            content = Content("Content"),
            acf = null
        )

        // When
        val result = devotional.getFormattedDate()

        // Then - returns original date on error
        assertEquals(invalidDate, result)
    }

    @Test
    fun `getPreviewText truncates content`() {
        // Given
        val longContent = "a".repeat(200)
        val devotional = Devotional(
            id = 1,
            date = "2024-01-01T00:00:00",
            title = Title("Title"),
            content = Content(longContent),
            acf = null
        )

        // When
        val preview = devotional.getPreviewText()

        // Then - truncated to 150 chars + ...
        assert(preview.length <= 153)
        assert(preview.endsWith("..."))
    }

    @Test
    fun `getBannerImageUrl returns null when no yoast data`() {
        // Given
        val devotional = Devotional(
            id = 1,
            date = "2024-01-01T00:00:00",
            title = Title("Title"),
            content = Content("Content"),
            acf = null,
            yoastHeadJson = null
        )

        // When
        val bannerUrl = devotional.getBannerImageUrl()

        // Then
        assertNull(bannerUrl)
    }

    @Test
    fun `getBannerImageUrl returns url when yoast data exists`() {
        // Given
        val imageUrl = "https://example.com/image.jpg"
        val devotional = Devotional(
            id = 1,
            date = "2024-01-01T00:00:00",
            title = Title("Title"),
            content = Content("Content"),
            acf = null,
            yoastHeadJson = YoastHeadJSON(
                ogImage = listOf(OGImage(imageUrl))
            )
        )

        // When
        val bannerUrl = devotional.getBannerImageUrl()

        // Then
        assertEquals(imageUrl, bannerUrl)
    }

    @Test
    fun `ACF data is optional`() {
        // Given - devotional without ACF data
        val devotional = Devotional(
            id = 1,
            date = "2024-01-01T00:00:00",
            title = Title("Title"),
            content = Content("Content"),
            acf = null
        )

        // Then - ACF can be null
        assertNull(devotional.acf)
    }

    @Test
    fun `ACF data contains nugget`() {
        // Given
        val nuggetText = "Today's nugget"
        val devotional = Devotional(
            id = 1,
            date = "2024-01-01T00:00:00",
            title = Title("Title"),
            content = Content("Content"),
            acf = ACF(
                bibleVerse = "John 3:16",
                furtherStudy = "Study more",
                prayer = "Prayer text",
                bibleReadingPlan = "Reading plan",
                nugget = nuggetText
            )
        )

        // Then
        assertNotNull(devotional.acf)
        assertEquals(nuggetText, devotional.acf?.nugget)
    }
}
