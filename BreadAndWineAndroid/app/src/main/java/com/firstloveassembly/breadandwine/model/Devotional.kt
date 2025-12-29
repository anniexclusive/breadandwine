package com.firstloveassembly.breadandwine.model

import com.google.gson.annotations.SerializedName
import java.time.format.DateTimeParseException
import java.time.format.DateTimeFormatter
import java.util.Locale
import java.time.LocalDateTime
import java.time.OffsetDateTime

/**
 * Data model for devotional content fetched from WordPress API
 * Mirrors the iOS Devotional struct
 */
data class Devotional(
    val id: Int,
    val date: String,
    val title: Title,
    val content: Content,
    val acf: ACF? = null,
    @SerializedName("yoast_head_json")
    val yoastHeadJson: YoastHeadJSON? = null
) {
    /**
     * Get the banner image URL from Yoast SEO metadata
     */
    fun getBannerImageUrl(): String? {
        return yoastHeadJson?.ogImage?.firstOrNull()?.url
    }

    /**
     * Get plain text title
     */
    fun getPlainTitle(): String {
        return title.rendered.replace(Regex("<.*?>"), "")
    }

    /**
     * Get formatted date string
     */
    fun getFormattedDate(): String {
        // Parse ISO 8601 date and format it
        // primary formatter (matches your Swift pattern)
        val isoFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss")
            .withLocale(Locale.US)

        // output formatter
        val displayFormatter = DateTimeFormatter.ofPattern("d MMMM yyyy")
            .withLocale(Locale.getDefault())

        return try {
            val parsed = LocalDateTime.parse(date, isoFormatter)
            parsed.format(displayFormatter)
        } catch (e: DateTimeParseException) {
            // fallback: try parsing with OffsetDateTime/ISO variants (handles "Z" or offsets)
            try {
                val odt = OffsetDateTime.parse(date) // ISO_OFFSET_DATE_TIME
                odt.toLocalDate().format(displayFormatter)
            } catch (ex: Exception) {
                // final fallback: return original string
                date
            }
        }
    }

    /**
     * Get preview text from content (first 150 characters)
     */
    fun getPreviewText(): String {
        val plainText = content.rendered.replace(Regex("<.*?>"), "")
            .replace("&nbsp;", " ")
            .trim()
        return if (plainText.length > 150) {
            plainText.substring(0, 150) + "..."
        } else {
            plainText
        }
    }
}

data class Title(
    val rendered: String
)

data class Content(
    val rendered: String
)

/**
 * Advanced Custom Fields data
 */
data class ACF(
    @SerializedName("bible_reading_plan")
    val bibleReadingPlan: String? = null,
    @SerializedName("bible_verse")
    val bibleVerse: String? = null,
    val prayer: String? = null,
    @SerializedName("further_study")
    val furtherStudy: String? = null,
    val nugget: String? = null
)

/**
 * Yoast SEO metadata
 */
data class YoastHeadJSON(
    @SerializedName("og_image")
    val ogImage: List<OGImage>? = null
)

data class OGImage(
    val url: String,
    val width: Int? = null,
    val height: Int? = null
)
