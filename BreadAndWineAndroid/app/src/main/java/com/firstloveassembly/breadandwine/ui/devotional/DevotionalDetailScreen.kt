package com.firstloveassembly.breadandwine.ui.devotional

import android.content.Intent
import android.text.SpannableString
import android.text.Spanned
import android.text.method.LinkMovementMethod
import android.text.style.ForegroundColorSpan
import android.text.style.QuoteSpan
import android.text.style.StyleSpan
import android.widget.TextView
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.text.HtmlCompat
import coil.compose.AsyncImage
import com.firstloveassembly.breadandwine.model.Devotional
import com.firstloveassembly.breadandwine.service.TextToSpeechManager
import com.firstloveassembly.breadandwine.viewmodel.DevotionalViewModel

/**
 * Devotional Detail Screen
 * Mirrors iOS DevotionalDetailView
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DevotionalDetailScreen(
    devotionalId: Int,
    viewModel: DevotionalViewModel,
    onBackClick: () -> Unit
) {
    val devotional = viewModel.getDevotionalById(devotionalId)
    val context = LocalContext.current

    // TTS state
    var isSpeaking by remember { mutableStateOf(false) }
    val ttsManager = remember {
        TextToSpeechManager(context).apply {
            onStateChanged = { speaking ->
                isSpeaking = speaking
            }
        }
    }

    // Extract plain text for TTS
    val plainText = remember(devotional) {
        devotional?.let {
            buildString {
                append("Welcome to the bread and wine devotional for ")
                append(it.getFormattedDate())
                append(". Topic: ")
                append(it.getPlainTitle())
                append(". ")
                it.acf?.bibleVerse?.let { verse ->
                    append("Bible verse: $verse. ")
                }
                append(it.content.rendered.replace(Regex("<.*?>"), ""))
                append(". ")
                it.acf?.furtherStudy?.let { study ->
                    append("Further study: $study. ")
                }
                it.acf?.prayer?.let { prayer ->
                    append("Prayer: $prayer. ")
                }
                it.acf?.bibleReadingPlan?.let { plan ->
                    append("Bible reading plan: $plan. ")
                }
                append("Thank you for listening.")
            }
        } ?: ""
    }

    // Cleanup TTS on dispose
    DisposableEffect(Unit) {
        onDispose {
            ttsManager.stop()
            ttsManager.shutdown()
        }
    }

    if (devotional == null) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = androidx.compose.ui.Alignment.Center) {
            Text("Devotional not found")
        }
        return
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Devotional", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back")
                    }
                },
                actions = {
                    // Play/Pause button
                    IconButton(
                        onClick = {
                            if (isSpeaking) {
                                ttsManager.stop()
                            } else {
                                ttsManager.speak(plainText)
                            }
                        },
                        enabled = plainText.isNotEmpty()
                    ) {
                        Icon(
                            imageVector = if (isSpeaking) Icons.Default.Pause else Icons.Default.PlayArrow,
                            contentDescription = if (isSpeaking) "Pause" else "Play"
                        )
                    }

                    // Share button
                    IconButton(onClick = {
                        shareDevotional(context, devotional)
                    }) {
                        Icon(Icons.Default.Share, "Share")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                    navigationIconContentColor = MaterialTheme.colorScheme.onPrimary,
                    actionIconContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
        ) {
            // Banner image
            devotional.getBannerImageUrl()?.let { imageUrl ->
                AsyncImage(
                    model = imageUrl,
                    contentDescription = "Devotional banner",
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(200.dp)
                )
            }

            Column(modifier = Modifier.padding(16.dp)) {
                // Title
                Text(
                    text = devotional.getPlainTitle(),
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(8.dp))

                // Date
                Text(
                    text = devotional.getFormattedDate(),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Spacer(modifier = Modifier.height(24.dp))

                // Bible Verse Section
                devotional.acf?.bibleVerse?.let { verse ->
                    DevotionalSection(
                        icon = Icons.Default.MenuBook,
                        title = "Bible Verse",
                        content = verse
                    )
                }

                // Main Content
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 8.dp),
                    colors = CardDefaults.cardColors()
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        DevotionalHtmlContent(devotional.content.rendered)
                    }
                }

                // Further Study
                devotional.acf?.furtherStudy?.let { study ->
                    DevotionalSection(
                        icon = Icons.Default.Book,
                        title = "Further Study",
                        content = study
                    )
                }

                // Prayer
                devotional.acf?.prayer?.let { prayer ->
                    DevotionalSection(
                        icon = Icons.Default.FavoriteBorder,
                        title = "Prayer",
                        content = prayer
                    )
                }

                // Bible Reading Plan
                devotional.acf?.bibleReadingPlan?.let { plan ->
                    DevotionalSection(
                        icon = Icons.Default.CalendarToday,
                        title = "Bible Reading Plan",
                        content = plan
                    )
                }

                // Nugget
                devotional.acf?.nugget?.let { nugget ->
                    DevotionalSection(
                        icon = Icons.Default.Lightbulb,
                        title = "Today's Nugget",
                        content = nugget,
                        highlighted = true
                    )
                }
            }
        }
    }
}

/**
 * Reusable section component
 */
@Composable
fun DevotionalSection(
    icon: ImageVector,
    title: String,
    content: String,
    highlighted: Boolean = false
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        colors = if (highlighted) {
            CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer
            )
        } else {
            CardDefaults.cardColors()
        }
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = androidx.compose.ui.Alignment.CenterVertically) {
                Icon(
                    imageVector = icon,
                    contentDescription = title,
                    tint = if (highlighted) MaterialTheme.colorScheme.onPrimaryContainer
                          else MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(24.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = if (highlighted) MaterialTheme.colorScheme.onPrimaryContainer
                           else MaterialTheme.colorScheme.onSurface
                )
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = content.replace(Regex("<.*?>"), ""),
                style = MaterialTheme.typography.bodyLarge,
                color = if (highlighted) MaterialTheme.colorScheme.onPrimaryContainer
                       else MaterialTheme.colorScheme.onSurface
            )
        }
    }
}

/**
 * HTML content renderer using native Android TextView
 * This properly wraps content height without WebView issues
 */
@Composable
fun DevotionalHtmlContent(htmlContent: String) {
    val textColor = MaterialTheme.colorScheme.onSurface
    val italicColor = MaterialTheme.colorScheme.onSurfaceVariant
    val quoteColor = MaterialTheme.colorScheme.primary

    AndroidView(
        factory = { ctx ->
            TextView(ctx).apply {
                // Add spacing around blockquotes
                val processedHtml = htmlContent
                    .replace("<blockquote>", "<br><blockquote>")
                    .replace("</blockquote>", "</blockquote><br>")

                // Convert HTML to styled text
                val spanned = HtmlCompat.fromHtml(processedHtml, HtmlCompat.FROM_HTML_MODE_COMPACT)

                // Apply custom styling
                val styledText = applyCustomStyling(spanned, italicColor.toArgb(), quoteColor.toArgb())
                text = styledText

                // Enable link clicking if there are links
                movementMethod = LinkMovementMethod.getInstance()

                // Set text appearance for proper styling
                setTextAppearance(android.R.style.TextAppearance_Material_Body1)
                textSize = 16f
                setLineSpacing(0f, 1.5f)

                // Set text color to match theme dynamically
                setTextColor(textColor.toArgb())

                // Padding
                setPadding(0, 0, 0, 0)
            }
        },
        update = { textView ->
            // Add spacing around blockquotes
            val processedHtml = htmlContent
                .replace("<blockquote>", "<br><blockquote>")
                .replace("</blockquote>", "</blockquote><br>")

            val spanned = HtmlCompat.fromHtml(processedHtml, HtmlCompat.FROM_HTML_MODE_COMPACT)
            val styledText = applyCustomStyling(spanned, italicColor.toArgb(), quoteColor.toArgb())
            textView.text = styledText
            textView.setTextColor(textColor.toArgb())
        },
        modifier = Modifier
            .fillMaxWidth()
            .wrapContentHeight()
    )
}

/**
 * Apply custom styling to HTML content
 * - Italic text gets custom color
 * - Blockquotes get left border (QuoteSpan)
 */
private fun applyCustomStyling(spanned: Spanned, italicColor: Int, quoteColor: Int): SpannableString {
    val spannable = SpannableString(spanned)

    // Apply color to italic text
    val styleSpans = spanned.getSpans(0, spanned.length, StyleSpan::class.java)
    for (span in styleSpans) {
        if (span.style == android.graphics.Typeface.ITALIC) {
            val start = spanned.getSpanStart(span)
            val end = spanned.getSpanEnd(span)
            spannable.setSpan(
                ForegroundColorSpan(italicColor),
                start,
                end,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }
    }

    // Apply QuoteSpan to blockquotes (styled left border like iOS)
    val quoteSpans = spanned.getSpans(0, spanned.length, QuoteSpan::class.java)
    for (span in quoteSpans) {
        val start = spanned.getSpanStart(span)
        val end = spanned.getSpanEnd(span)
        // Replace default QuoteSpan with custom colored one (10dp stripe width)
        spannable.removeSpan(span)
        spannable.setSpan(
            QuoteSpan(quoteColor, 10, 20), // color, stripe width (10dp like iOS), gap width
            start,
            end,
            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
        )
    }

    return spannable
}

/**
 * Share devotional via Android share sheet
 */
private fun shareDevotional(context: android.content.Context, devotional: Devotional) {
    val shareText = """
        ${devotional.getPlainTitle()}

        ${devotional.getPreviewText()}

        Read more at: https://breadandwinedevotional.com
    """.trimIndent()

    val sendIntent = Intent().apply {
        action = Intent.ACTION_SEND
        putExtra(Intent.EXTRA_TEXT, shareText)
        type = "text/plain"
    }

    val shareIntent = Intent.createChooser(sendIntent, "Share Devotional")
    context.startActivity(shareIntent)
}
