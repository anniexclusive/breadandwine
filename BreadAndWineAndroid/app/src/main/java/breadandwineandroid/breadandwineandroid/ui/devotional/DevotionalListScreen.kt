package breadandwineandroid.breadandwineandroid.ui.devotional

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Error
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import breadandwineandroid.breadandwineandroid.model.Devotional
import breadandwineandroid.breadandwineandroid.viewmodel.DevotionalViewModel

/**
 * Devotional List Screen
 * Mirrors iOS DevotionalListView
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DevotionalListScreen(
    viewModel: DevotionalViewModel,
    onDevotionalClick: (Int) -> Unit
) {
    val devotionals by viewModel.devotionals.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val isRefreshing by viewModel.isRefreshing.collectAsState()
    val error by viewModel.error.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Daily Devotionals", fontWeight = FontWeight.Bold) },
                actions = {
                    IconButton(onClick = { viewModel.refreshDevotionals() }) {
                        Icon(Icons.Default.Refresh, "Refresh")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                    actionIconContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            when {
                devotionals.isEmpty() && !isLoading && error == null -> {
                    Text(
                        text = "No devotionals available",
                        modifier = Modifier.align(Alignment.Center),
                        style = MaterialTheme.typography.bodyLarge
                    )
                }
                error != null && devotionals.isEmpty() -> {
                    ErrorView(
                        message = error ?: "Unknown error",
                        onRetry = { viewModel.fetchDevotionals() },
                        modifier = Modifier.align(Alignment.Center)
                    )
                }
                devotionals.isNotEmpty() -> {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(vertical = 8.dp)
                    ) {
                        items(devotionals) { devotional ->
                            DevotionalListItem(
                                devotional = devotional,
                                onClick = { onDevotionalClick(devotional.id) }
                            )
                        }
                    }
                }
            }

            // Show loading indicator whenever loading (initial or refresh)
            if (isLoading || isRefreshing) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp),
                    contentAlignment = if (devotionals.isEmpty()) Alignment.Center else Alignment.TopCenter
                ) {
                    CircularProgressIndicator()
                }
            }
        }
    }
}

/**
 * Individual devotional list item
 * Mirrors iOS DevotionalRow with clean Material Design
 */
@Composable
fun DevotionalListItem(
    devotional: Devotional,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 6.dp)
            .clickable(onClick = onClick),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.Top
        ) {
            // Thumbnail image with rounded corners
            devotional.getBannerImageUrl()?.let { imageUrl ->
                Card(
                    modifier = Modifier.size(70.dp),
                    shape = MaterialTheme.shapes.medium
                ) {
                    AsyncImage(
                        model = imageUrl,
                        contentDescription = "Devotional banner",
                        modifier = Modifier.fillMaxSize()
                    )
                }
                Spacer(modifier = Modifier.width(16.dp))
            }

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = devotional.getPlainTitle(),
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = devotional.getFormattedDate(),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = devotional.getPreviewText(),
                    style = MaterialTheme.typography.bodyMedium,
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    lineHeight = MaterialTheme.typography.bodyMedium.lineHeight
                )
            }
        }
    }
}

/**
 * Error view with retry button
 */
@Composable
fun ErrorView(
    message: String,
    onRetry: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            imageVector = Icons.Default.Error,
            contentDescription = "Error",
            tint = MaterialTheme.colorScheme.error,
            modifier = Modifier.size(64.dp)
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = message,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.error
        )
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = onRetry) {
            Text("Retry")
        }
    }
}
