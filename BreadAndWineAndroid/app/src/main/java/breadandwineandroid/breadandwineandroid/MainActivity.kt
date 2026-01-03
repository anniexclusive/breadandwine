package breadandwineandroid.breadandwineandroid

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.Crossfade
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.MenuBook
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import breadandwineandroid.breadandwineandroid.ui.about.AboutScreen
import breadandwineandroid.breadandwineandroid.ui.devotional.DevotionalDetailScreen
import breadandwineandroid.breadandwineandroid.ui.devotional.DevotionalListScreen
import breadandwineandroid.breadandwineandroid.ui.nuggets.NuggetsScreen
import breadandwineandroid.breadandwineandroid.ui.settings.SettingsScreen
import breadandwineandroid.breadandwineandroid.ui.splash.SplashScreen
import breadandwineandroid.breadandwineandroid.ui.theme.BreadAndWineTheme
import breadandwineandroid.breadandwineandroid.viewmodel.DevotionalViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Main Activity
 * Sets up navigation and theme
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            BreadAndWineTheme {
                MainContent()
            }
        }
    }
}

/**
 * Main content with splash screen
 * Mirrors iOS BreadAndWineApp.swift
 */
@Composable
fun MainContent() {
    var showSplash by remember { mutableStateOf(true) }

    // Hide splash screen after 3 seconds (matches iOS)
    LaunchedEffect(Unit) {
        delay(3000) // 3 seconds
        showSplash = false
    }

    // Crossfade animation (matches iOS 0.3s fade)
    Crossfade(
        targetState = showSplash,
        label = "splash_crossfade"
    ) { isSplashVisible ->
        if (isSplashVisible) {
            SplashScreen()
        } else {
            BreadAndWineAppContent()
        }
    }
}

/**
 * Main app content with navigation
 * Mirrors iOS RootView.swift with drawer menu
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BreadAndWineAppContent() {
    val navController = rememberNavController()
    val devotionalViewModel: DevotionalViewModel = viewModel()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope()
    val context = LocalContext.current

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            DrawerMenuContent(
                onNavigate = { route ->
                    scope.launch {
                        drawerState.close()
                        navController.navigate(route) {
                            popUpTo(navController.graph.findStartDestination().id) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                },
                onOpenUrl = { url ->
                    scope.launch {
                        drawerState.close()
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                        context.startActivity(intent)
                    }
                }
            )
        }
    ) {
        Scaffold(
            topBar = {
                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentRoute = navBackStackEntry?.destination?.route

                // Only show top bar with menu icon on main screens
                if (currentRoute in listOf("devotionals", "nuggets", "settings", "about")) {
                    TopAppBar(
                        title = {
                            Text(
                                when (currentRoute) {
                                    "devotionals" -> "Devotionals"
                                    "nuggets" -> "Daily Nuggets"
                                    "settings" -> "Settings"
                                    "about" -> "About"
                                    else -> "Bread & Wine"
                                }
                            )
                        },
                        navigationIcon = {
                            IconButton(onClick = {
                                scope.launch {
                                    drawerState.open()
                                }
                            }) {
                                Icon(
                                    imageVector = Icons.Default.Menu,
                                    contentDescription = "Menu"
                                )
                            }
                        },
                        colors = TopAppBarDefaults.topAppBarColors(
                            containerColor = MaterialTheme.colorScheme.primary,
                            titleContentColor = MaterialTheme.colorScheme.onPrimary,
                            navigationIconContentColor = MaterialTheme.colorScheme.onPrimary
                        )
                    )
                }
            },
            bottomBar = {
                NavigationBar {
                    val navBackStackEntry by navController.currentBackStackEntryAsState()
                    val currentDestination = navBackStackEntry?.destination

                    bottomNavItems.forEach { item ->
                        NavigationBarItem(
                            icon = { Icon(item.icon, contentDescription = item.label) },
                            label = { Text(item.label) },
                            selected = currentDestination?.hierarchy?.any { it.route == item.route } == true,
                            onClick = {
                                navController.navigate(item.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            }
                        )
                    }
                }
            }
        ) { paddingValues ->
        NavHost(
            navController = navController,
            startDestination = "devotionals",
            modifier = Modifier.padding(paddingValues)
        ) {
            composable("devotionals") {
                DevotionalListScreen(
                    viewModel = devotionalViewModel,
                    onDevotionalClick = { devotionalId ->
                        navController.navigate("devotional/$devotionalId")
                    }
                )
            }
            composable("devotional/{devotionalId}") { backStackEntry ->
                val devotionalId = backStackEntry.arguments?.getString("devotionalId")?.toIntOrNull()
                if (devotionalId != null) {
                    DevotionalDetailScreen(
                        devotionalId = devotionalId,
                        viewModel = devotionalViewModel,
                        onBackClick = { navController.popBackStack() }
                    )
                }
            }
            composable("nuggets") {
                NuggetsScreen(viewModel = devotionalViewModel)
            }
            composable("settings") {
                SettingsScreen()
            }
            composable("about") {
                AboutScreen()
            }
        }
        }
    }
}

/**
 * Drawer menu content
 * Mirrors iOS UnifiedMenuView.swift
 */
@Composable
fun DrawerMenuContent(
    onNavigate: (String) -> Unit,
    onOpenUrl: (String) -> Unit
) {
    ModalDrawerSheet {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)
        ) {
            // Logo and Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 16.dp),
                verticalAlignment = androidx.compose.ui.Alignment.CenterVertically
            ) {
                // App Logo
                Image(
                    painter = androidx.compose.ui.res.painterResource(id = R.drawable.app_logo),
                    contentDescription = "App Logo",
                    modifier = Modifier
                        .size(60.dp)
                        .padding(end = 12.dp)
                )

                // App Name
                Text(
                    text = "Bread & Wine",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold
                )
            }

            HorizontalDivider()

            Spacer(modifier = Modifier.height(16.dp))

            // Daily Devotional Section
            Text(
                text = "DAILY DEVOTIONAL",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(start = 16.dp, bottom = 8.dp)
            )

            NavigationDrawerItem(
                icon = { Icon(Icons.AutoMirrored.Filled.MenuBook, contentDescription = null) },
                label = { Text("Bread and Wine") },
                selected = false,
                onClick = { onNavigate("devotionals") }
            )

            NavigationDrawerItem(
                icon = { Icon(Icons.Default.Archive, contentDescription = null) },
                label = { Text("Archives") },
                selected = false,
                onClick = { onOpenUrl("https://breadandwinedevotional.com/devotional/") }
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Social Handle Section
            Text(
                text = "SOCIAL HANDLE",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(start = 16.dp, bottom = 8.dp)
            )

            NavigationDrawerItem(
                icon = { Icon(Icons.Default.People, contentDescription = null) },
                label = { Text("Firstlove Social") },
                selected = false,
                onClick = { onOpenUrl("https://www.facebook.com/flarumuokwuta/") }
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Live Stream Section
            Text(
                text = "LIVE STREAM",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(start = 16.dp, bottom = 8.dp)
            )

            NavigationDrawerItem(
                icon = { Icon(Icons.Default.PlayCircle, contentDescription = null) },
                label = { Text("YouTube") },
                selected = false,
                onClick = { onOpenUrl("https://www.youtube.com/@flarumuokwuta/streams") }
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Other Section
            Text(
                text = "OTHER",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(start = 16.dp, bottom = 8.dp)
            )

            NavigationDrawerItem(
                icon = { Icon(Icons.Default.Star, contentDescription = null) },
                label = { Text("Rate & Update") },
                selected = false,
                onClick = { onOpenUrl("https://play.google.com/store/apps/details?id=com.firstloveassembly.breadandwine") }
            )

            NavigationDrawerItem(
                icon = { Icon(Icons.Default.Email, contentDescription = null) },
                label = { Text("Feedback") },
                selected = false,
                onClick = { onOpenUrl("mailto:info@breadandwinedevotional.com") }
            )

            NavigationDrawerItem(
                icon = { Icon(Icons.Default.Lock, contentDescription = null) },
                label = { Text("Privacy Policy") },
                selected = false,
                onClick = { onOpenUrl("https://breadandwinedevotional.com/privacy-policy") }
            )

            NavigationDrawerItem(
                icon = { Icon(Icons.Default.Settings, contentDescription = null) },
                label = { Text("Settings") },
                selected = false,
                onClick = { onNavigate("settings") }
            )
        }
    }
}

/**
 * Bottom navigation items
 */
data class BottomNavItem(
    val route: String,
    val icon: ImageVector,
    val label: String
)

val bottomNavItems = listOf(
    BottomNavItem("devotionals", Icons.AutoMirrored.Filled.MenuBook, "Devotionals"),
    BottomNavItem("nuggets", Icons.Default.Lightbulb, "Nuggets"),
    BottomNavItem("settings", Icons.Default.Settings, "Settings"),
    BottomNavItem("about", Icons.Default.Info, "About")
)
