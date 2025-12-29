//
//  NotificationManager.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 09.04.25.
//


// NotificationManager.swift
import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()

    private let morningIdentifier = AppConstants.Notifications.morningIdentifier
    private let nuggetIdentifier = AppConstants.Notifications.nuggetIdentifier
    
    private init() {}
    
    // MARK: - Notification Scheduling
    
    func scheduleNotifications() {
        checkNotificationSettings { [weak self] enabled in
            guard let self = self, enabled else { return }

            // Only schedule if user hasn't disabled in app settings
            if UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.morningNotificationsEnabled) {
                self.scheduleMorningReminder()
            }

            if UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.nuggetNotificationsEnabled) {
                self.scheduleDailyNugget()
            }
        }
    }
    
    func checkNotificationSettings(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let enabled = settings.authorizationStatus == .authorized
            UserDefaults.standard.set(enabled, forKey: AppConstants.UserDefaultsKeys.notificationsEnabled)

            // Initialize default values if not set
            if UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.morningNotificationsEnabled) == nil {
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.morningNotificationsEnabled)
            }

            if UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.nuggetNotificationsEnabled) == nil {
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.nuggetNotificationsEnabled)
            }
            
            DispatchQueue.main.async {
                completion(enabled)
            }
        }
    }
    
    // Schedule morning reminder
    func scheduleMorningReminder() {
        let content = UNMutableNotificationContent()
        content.title = AppConstants.Notifications.Messages.morningTitle
        content.body = AppConstants.Notifications.Messages.morningBody
        content.sound = .default
        content.userInfo = ["notificationType": "morning"]

        // Create morning trigger
        var dateComponents = DateComponents()
        dateComponents.hour = AppConstants.Notifications.Time.morningHour
        dateComponents.minute = AppConstants.Notifications.Time.morningMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(identifier: morningIdentifier, content: content, trigger: trigger)
        
        // Add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling morning notification: \(error)")
            }
        }
    }
    
    // Schedule daily nugget
    func scheduleDailyNugget() {
        // Get today's devotional content first to extract the nugget
        print("Attempting to schedule nugget notification...")
        if let todayDevotional = DevotionalViewModel.shared.fetchTodayDevotional() {
            print("Devotional found:", todayDevotional)

            let content = UNMutableNotificationContent()
            content.title = AppConstants.Notifications.Messages.nuggetTitle

            if let nugget = todayDevotional.acf?.nugget {
                print("nugget is: \(nugget)")
                content.body = nugget
            } else {
                // Fallback if no nugget is available
                content.body = AppConstants.Notifications.Messages.nuggetFallback
                print("nugget not found")
            }

            content.sound = UNNotificationSound.default

            // Create nugget trigger
            var dateComponents = DateComponents()
            dateComponents.hour = AppConstants.Notifications.Time.nuggetHour
            dateComponents.minute = AppConstants.Notifications.Time.nuggetMinute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Create request
            let request = UNNotificationRequest(identifier: self.nuggetIdentifier, content: content, trigger: trigger)
            
            // Add request to notification center
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling nugget notification: \(error)")
                }
            }
        } else {
            print("No devotional found for today")
        }
    }
    
    // MARK: - Background Refreshing
    
    func refreshNuggetNotificationContent() {
        // This could be called from background fetch
        APIService.shared.fetchDevotionals { [weak self] result in
            guard let self = self, case .success(let devotionals) = result else { return }
            
            let today = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = AppConstants.DateFormat.display
            let todayString = formatter.string(from: today)
            
            let devotional = devotionals.first { devotional in
                devotional.date.starts(with: todayString)
            }
            
            // Update the scheduled notification with fresh content
            self.updateNuggetNotification(with: devotional)
            
            
        }
    }

    private func updateNuggetNotification(with devotional: Devotional?) {
        let content = UNMutableNotificationContent()
        content.title = AppConstants.Notifications.Messages.nuggetTitle
        content.body = devotional?.acf?.nugget ?? ""
        content.sound = .default
        content.userInfo = [
            "notificationType": "nugget",
            "devotionalId": devotional?.id ?? 0
        ]

        // Create nugget trigger (keeping the same time)
        var dateComponents = DateComponents()
        dateComponents.hour = AppConstants.Notifications.Time.nuggetHour
        dateComponents.minute = AppConstants.Notifications.Time.nuggetMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request with same identifier to replace existing notification
        let request = UNNotificationRequest(identifier: nuggetIdentifier, content: content, trigger: trigger)
        
        // Remove existing and add updated notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [nuggetIdentifier])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error updating nugget notification: \(error)")
            }
        }
    }
    
    // MARK: - Notification Response Handling
    
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        guard let notificationType = userInfo["notificationType"] as? String else {
            return
        }
        
        switch notificationType {
        case "morning":
            // Navigate to main devotional
            NotificationCenter.default.post(name: .openDevotionalView, object: nil)
            
        case "nugget":
            if let devotionalId = userInfo["devotionalId"] as? String {
                // Navigate to specific nugget list with this devotional highlighted
                NotificationCenter.default.post(name: .openNuggetsList, object: devotionalId)
            } else {
                // Navigate to general nuggets list
                NotificationCenter.default.post(name: .openNuggetsList, object: nil)
            }
            
        default:
            print("Unknown notification type")
        }
    }
    
    // MARK: - Toggle Notifications
    
    func toggleMorningNotifications(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: AppConstants.UserDefaultsKeys.morningNotificationsEnabled)
        
        if enabled {
            scheduleMorningReminder()
        } else {
            // Remove scheduled notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [morningIdentifier])
        }
    }
    
    func toggleNuggetNotifications(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: AppConstants.UserDefaultsKeys.nuggetNotificationsEnabled)
        
        if enabled {
            scheduleDailyNugget()
        } else {
            // Remove scheduled notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [nuggetIdentifier])
        }
    }
    
    func toggleAllNotifications(_ enabled: Bool) {
        toggleMorningNotifications(enabled)
        toggleNuggetNotifications(enabled)
    }
}

// Custom Notification Center names
extension Notification.Name {
    static let openDevotionalView = Notification.Name("openDevotionalView")
    static let openNuggetsList = Notification.Name("openNuggetsList")
}
