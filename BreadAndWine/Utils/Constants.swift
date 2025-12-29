//
//  Constants.swift
//  BreadAndWine
//
//  Centralized constants for the application
//

import Foundation

enum AppConstants {
    // MARK: - Notification Configuration
    enum Notifications {
        static let morningIdentifier = "com.devotionalapp.morningReminder"
        static let nuggetIdentifier = "com.devotionalapp.dailyNugget"
        static let backgroundFetchIdentifier = "com.devotionalapp.nuggetFetch"

        enum Time {
            static let morningHour = 6
            static let morningMinute = 0

            static let nuggetHour = 10
            static let nuggetMinute = 0

            static let backgroundFetchHour = 9
            static let backgroundFetchMinute = 45
        }

        enum Messages {
            static let morningTitle = "Bread and Wine Devotional"
            static let morningBody = "Refresh your spirit—your devotional awaits!"
            static let nuggetTitle = "Daily Nugget"
            static let nuggetFallback = "Reflect on today's devotional message"
        }
    }

    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let cachedDevotionals = "cachedDevotionals"
        static let notificationsEnabled = "notificationsEnabled"
        static let morningNotificationsEnabled = "morningNotificationsEnabled"
        static let nuggetNotificationsEnabled = "nuggetNotificationsEnabled"
        static let lastUpdateCheck = "lastUpdateCheck"
    }

    // MARK: - Date Formatting
    enum DateFormat {
        static let display = "d MMMM yyyy"
    }

    // MARK: - Timing
    enum Timing {
        static let splashScreenDuration: Double = 3.0
        static let updateCheckInterval: TimeInterval = 86400 // 24 hours
        static let splashAnimationDuration: Double = 0.3
    }

    // MARK: - UI Dimensions
    enum UI {
        static let bannerHeight: CGFloat = 250
        static let logoSize: CGFloat = 60
        static let logoCornerRadius: CGFloat = 8
        static let standardCornerRadius: CGFloat = 8
        static let largeCornerRadius: CGFloat = 12
    }
}
