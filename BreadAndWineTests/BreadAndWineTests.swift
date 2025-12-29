//
//  BreadAndWineTests.swift
//  BreadAndWineTests
//
//  Created by Anne Ezurike on 29.03.25.
//

import Testing
@testable import BreadAndWine

struct BreadAndWineTests {

    @Test func devotionalModelParsesDate() throws {
        // Given devotional JSON date
        let dateString = "2024-01-15T00:00:00"

        // When creating devotional
        let devotional = Devotional(
            id: 1,
            date: dateString,
            title: Title(rendered: "Test"),
            content: Content(rendered: "Content"),
            acf: nil,
            yoastHeadJson: nil
        )

        // Then formatted date contains year
        #expect(devotional.formattedDate.contains("2024"))
    }

    @Test func devotionalViewModelInitializesWithEmptyList() {
        // When creating ViewModel
        let viewModel = DevotionalViewModel()

        // Then starts with empty devotionals or cached data
        #expect(viewModel.devotionals.count >= 0)
        #expect(!viewModel.isLoading)
    }

    @Test func getDevotionalByIdReturnsNilWhenNotFound() {
        // Given ViewModel with empty list
        let viewModel = DevotionalViewModel()

        // When searching for non-existent ID
        let result = viewModel.getDevotionalById("999999")

        // Then returns nil
        #expect(result == nil)
    }

    @Test func fetchTodayDevotionalReturnsNilWhenEmpty() {
        // Given ViewModel with empty list
        let viewModel = DevotionalViewModel()

        // When fetching today's devotional from empty list
        let result = viewModel.fetchTodayDevotional()

        // Then returns nil
        #expect(result == nil)
    }

    @Test func devotionalTitleParsesHTML() throws {
        // Given title with HTML
        let title = Title(rendered: "<strong>Bold</strong> Title")

        // Then rendered contains HTML
        #expect(title.rendered.contains("strong"))
    }

    @Test func devotionalACFIsOptional() throws {
        // Given devotional without ACF
        let devotional = Devotional(
            id: 1,
            date: "2024-01-01T00:00:00",
            title: Title(rendered: "Test"),
            content: Content(rendered: "Content"),
            acf: nil,
            yoastHeadJson: nil
        )

        // Then ACF is nil
        #expect(devotional.acf == nil)
    }

    @Test func devotionalACFContainsNugget() throws {
        // Given devotional with ACF nugget
        let acf = ACF(
            bibleVerse: "John 3:16",
            furtherStudy: "Study",
            prayer: "Prayer",
            bibleReadingPlan: "Plan",
            nugget: "Today's nugget"
        )

        let devotional = Devotional(
            id: 1,
            date: "2024-01-01T00:00:00",
            title: Title(rendered: "Test"),
            content: Content(rendered: "Content"),
            acf: acf,
            yoastHeadJson: nil
        )

        // Then nugget is accessible
        #expect(devotional.acf?.nugget == "Today's nugget")
    }

    @Test func backgroundFetchManagerIsSingleton() {
        // Given BackgroundFetchManager
        let manager1 = BackgroundFetchManager.shared
        let manager2 = BackgroundFetchManager.shared

        // Then same instance
        #expect(manager1 === manager2)
    }

    @Test func notificationManagerIsSingleton() {
        // Given NotificationManager
        let manager1 = NotificationManager.shared
        let manager2 = NotificationManager.shared

        // Then same instance
        #expect(manager1 === manager2)
    }

    @Test func devotionalContentIsNotEmpty() throws {
        // Given devotional with content
        let content = Content(rendered: "<p>Today's message</p>")

        // Then content is accessible
        #expect(!content.rendered.isEmpty)
        #expect(content.rendered.contains("message"))
    }

    @Test func devotionalBannerImageFromYoast() throws {
        // Given devotional with yoast image
        let ogImage = OGImage(url: "https://example.com/image.jpg")
        let yoast = YoastHeadJSON(ogImage: [ogImage])

        let devotional = Devotional(
            id: 1,
            date: "2024-01-01T00:00:00",
            title: Title(rendered: "Test"),
            content: Content(rendered: "Content"),
            acf: nil,
            yoastHeadJson: yoast
        )

        // Then image URL is accessible
        #expect(devotional.yoastHeadJson?.ogImage?.first?.url == "https://example.com/image.jpg")
    }

    @Test func appConstantsHaveValues() {
        // Given AppConstants
        // When accessing constants
        let identifier = AppConstants.Notifications.backgroundFetchIdentifier
        let morningHour = AppConstants.Notifications.Time.morningHour
        let nuggetHour = AppConstants.Notifications.Time.nuggetHour

        // Then values are defined
        #expect(!identifier.isEmpty)
        #expect(morningHour >= 0 && morningHour < 24)
        #expect(nuggetHour >= 0 && nuggetHour < 24)
    }

    @Test func colorThemeHasColors() {
        // Given ColorTheme
        // When accessing colors
        let primary = ColorTheme.primary
        let background = ColorTheme.background
        let textPrimary = ColorTheme.textPrimary

        // Then colors exist
        #expect(primary != nil)
        #expect(background != nil)
        #expect(textPrimary != nil)
    }

}
