package breadandwineandroid.breadandwineandroid

import org.junit.Test
import org.junit.Assert.*

/**
 * Test for share devotional functionality
 * Verifies that nugget is removed from main content and HTML entities are decoded
 */
class ShareDevotionalTest {

    @Test
    fun `nugget should be removed from main content`() {
        // Given: HTML content with embedded nugget containing HTML entities
        val nugget = "What is easy is not always what is safe&#8230;Our safety valve is to follow the way of the Spirit."
        val contentWithNugget = """
            <p>Lot repeatedly chose the path of least resistance.</p>
            <p>What is easy is not always what is safe&#8230;Our safety valve is to follow the way of the Spirit.</p>
            <p>In our text, we see a similar thing playing out.</p>
        """.trimIndent()

        // When: Strip HTML, decode entities, then remove nugget
        var mainContent = contentWithNugget
            .replace(Regex("<.*?>"), "")
            .let { decodeHtmlEntities(it) }  // Decode BEFORE comparison
            .trim()

        val plainNugget = nugget
            .replace(Regex("<.*?>"), "")
            .let { decodeHtmlEntities(it) }  // Decode nugget too
            .trim()

        if (plainNugget.isNotEmpty()) {
            mainContent = mainContent.replace(plainNugget, "").trim()
        }

        // Then: Nugget should not appear in content
        assertFalse("Main content should not contain nugget", mainContent.contains(plainNugget))
        assertTrue("Main content should contain other text", mainContent.contains("Lot repeatedly chose"))
        assertTrue("Main content should contain other text", mainContent.contains("In our text"))
    }

    @Test
    fun `HTML entities should be decoded`() {
        // Given
        val textWithEntities = "Here&#8230; some text &amp; quotes &#8220;hello&#8221;"

        // When
        val decoded = decodeHtmlEntities(textWithEntities)

        // Then
        val expected = "Here\u2026 some text & quotes \u201Chello\u201D"
        assertEquals(expected, decoded)
    }

    @Test
    fun `nugget with different HTML tags should still be removed`() {
        // Given: Content has nugget wrapped in <em> tags
        val nuggetPlainText = "This is the nugget text."
        val contentWithNugget = """
            <p>First paragraph.</p>
            <em>This is the nugget text.</em>
            <p>Last paragraph.</p>
        """.trimIndent()

        // When: Strip HTML first, then remove nugget
        var mainContent = contentWithNugget
            .replace(Regex("<.*?>"), "")
            .trim()

        mainContent = mainContent.replace(nuggetPlainText, "").trim()

        // Then: Nugget should be removed
        assertFalse("Content should not contain nugget", mainContent.contains(nuggetPlainText))
        assertTrue("Content should contain first paragraph", mainContent.contains("First paragraph"))
        assertTrue("Content should contain last paragraph", mainContent.contains("Last paragraph"))
    }

    private fun decodeHtmlEntities(text: String): String {
        return text
            .replace("&nbsp;", " ")
            .replace("&amp;", "&")
            .replace("&lt;", "<")
            .replace("&gt;", ">")
            .replace("&quot;", "\"")
            .replace("&#039;", "'")
            .replace("&apos;", "'")
            .replace("&#8230;", "…")  // Ellipsis
            .replace("&#8220;", """)  // Left double quote
            .replace("&#8221;", """)  // Right double quote
            .replace("&#8216;", "'")  // Left single quote
            .replace("&#8217;", "'")  // Right single quote
            .replace("&#8211;", "–")  // En dash
            .replace("&#8212;", "—")  // Em dash
            .replace("&#8226;", "•")  // Bullet
            .replace("&#169;", "©")   // Copyright
            .replace("&#174;", "®")   // Registered
            .trim()
    }
}
