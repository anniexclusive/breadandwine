package com.firstloveassembly.breadandwine

import android.app.Application
import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import com.firstloveassembly.breadandwine.viewmodel.SettingsViewModel
import io.mockk.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.*
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/**
 * Unit tests for SettingsViewModel
 * Tests notification toggle logic
 */
@OptIn(ExperimentalCoroutinesApi::class)
class SettingsViewModelTest {

    @get:Rule
    val instantExecutorRule = InstantTaskExecutorRule()

    private val testDispatcher = StandardTestDispatcher()

    private lateinit var application: Application
    private lateinit var viewModel: SettingsViewModel

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)

        application = mockk(relaxed = true)

        // Mock context
        every { application.applicationContext } returns application

        // Create ViewModel (cache is created internally)
        viewModel = SettingsViewModel(application)
        testDispatcher.scheduler.advanceUntilIdle()
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
        clearAllMocks()
    }

    @Test
    fun `initial state has default values`() {
        // When ViewModel is created
        // Then it has default enabled state
        assertTrue(viewModel.notificationsEnabled.value)
        assertTrue(viewModel.morningNotificationsEnabled.value)
        assertTrue(viewModel.nuggetNotificationsEnabled.value)
    }

    @Test
    fun `toggleNotifications updates state`() {
        // When disabling notifications
        viewModel.toggleNotifications(false)
        testDispatcher.scheduler.advanceUntilIdle()

        // Then state is updated
        assertFalse(viewModel.notificationsEnabled.value)
    }

    @Test
    fun `toggleNotifications can be enabled`() {
        // Given notifications are disabled
        viewModel.toggleNotifications(false)
        testDispatcher.scheduler.advanceUntilIdle()

        // When enabling notifications
        viewModel.toggleNotifications(true)
        testDispatcher.scheduler.advanceUntilIdle()

        // Then state is updated
        assertTrue(viewModel.notificationsEnabled.value)
    }

    @Test
    fun `toggleMorningNotifications updates state`() {
        // When toggling morning notifications off
        viewModel.toggleMorningNotifications(false)
        testDispatcher.scheduler.advanceUntilIdle()

        // Then state is updated
        assertFalse(viewModel.morningNotificationsEnabled.value)

        // When toggling back on
        viewModel.toggleMorningNotifications(true)
        testDispatcher.scheduler.advanceUntilIdle()

        // Then state is updated
        assertTrue(viewModel.morningNotificationsEnabled.value)
    }

    @Test
    fun `toggleNuggetNotifications updates state`() {
        // When toggling nugget notifications off
        viewModel.toggleNuggetNotifications(false)
        testDispatcher.scheduler.advanceUntilIdle()

        // Then state is updated
        assertFalse(viewModel.nuggetNotificationsEnabled.value)

        // When toggling back on
        viewModel.toggleNuggetNotifications(true)
        testDispatcher.scheduler.advanceUntilIdle()

        // Then state is updated
        assertTrue(viewModel.nuggetNotificationsEnabled.value)
    }

    @Test
    fun `ViewModel doesn't crash with mock application`() {
        // When creating multiple ViewModels
        val vm1 = SettingsViewModel(application)
        val vm2 = SettingsViewModel(application)
        testDispatcher.scheduler.advanceUntilIdle()

        // Then no crash occurs
        assertTrue(vm1.notificationsEnabled.value)
        assertTrue(vm2.notificationsEnabled.value)
    }
}
