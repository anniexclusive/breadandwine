package com.firstloveassembly.breadandwine.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

/**
 * Color scheme matching iOS ColorTheme.swift exactly
 * iOS uses a clean blue/white theme
 */
private val LightColorScheme = lightColorScheme(
    primary = Color(0xFF738CD1),           // navBar blue from iOS
    onPrimary = Color.White,
    primaryContainer = Color(0xFF3366CC),  // accentPrimary from iOS
    onPrimaryContainer = Color.White,
    secondary = Color(0xFF6C757D),         // textSecondary from iOS
    onSecondary = Color.White,
    tertiary = Color(0xFF3366CC),
    background = Color(0xFFF8F9FA),        // BackgroundColor from iOS
    onBackground = Color(0xFF2D2D2D),      // TextPrimary from iOS
    surface = Color.White,                 // cardBackground from iOS
    onSurface = Color(0xFF2D2D2D),
    surfaceVariant = Color(0xFFF8F9FA),
    onSurfaceVariant = Color(0xFF6C757D),
    outline = Color(0xFFE0E0E0),
)

private val DarkColorScheme = darkColorScheme(
    primary = Color(0xFF1A1A1A),           // navBar dark from iOS
    onPrimary = Color.White,
    primaryContainer = Color(0xFF6699FF),  // accentPrimary dark from iOS
    onPrimaryContainer = Color.White,
    secondary = Color(0xFFCCCCCC),         // textSecondary dark from iOS
    onSecondary = Color.Black,
    tertiary = Color(0xFF6699FF),
    background = Color(0xFF1A1A1A),        // background dark from iOS
    onBackground = Color.White,
    surface = Color(0xFF333333),           // cardBackground dark from iOS
    onSurface = Color.White,
    surfaceVariant = Color(0xFF333333),
    onSurfaceVariant = Color(0xFFCCCCCC),
    outline = Color(0xFF444444),
)

@Composable
fun BreadAndWineTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.primary.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}
