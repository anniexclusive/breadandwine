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
    
    private let morningIdentifier = "com.devotionalapp.morningReminder"
    private let nuggetIdentifier = "com.devotionalapp.dailyNugget"
    
    private init() {}
    
    // MARK: - Notification Scheduling
    
    func scheduleNotifications() {
        checkNotificationSettings { [weak self] enabled in
            guard let self = self, enabled else { return }
            
            // Only schedule if user hasn't disabled in app settings
            if UserDefaults.standard.bool(forKey: "morningNotificationsEnabled") {
                self.scheduleMorningReminder()
            }
            
            if UserDefaults.standard.bool(forKey: "nuggetNotificationsEnabled") {
                self.scheduleDailyNugget()
            }
        }
    }
    
    func checkNotificationSettings(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let enabled = settings.authorizationStatus == .authorized
            UserDefaults.standard.set(enabled, forKey: "notificationsEnabled")
            
            // Initialize default values if not set
            if UserDefaults.standard.object(forKey: "morningNotificationsEnabled") == nil {
                UserDefaults.standard.set(true, forKey: "morningNotificationsEnabled")
            }
            
            if UserDefaults.standard.object(forKey: "nuggetNotificationsEnabled") == nil {
                UserDefaults.standard.set(true, forKey: "nuggetNotificationsEnabled")
            }
            
            DispatchQueue.main.async {
                completion(enabled)
            }
        }
    }
    
    // Schedule 6 AM morning reminder
    func scheduleMorningReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Morning Devotional"
        content.body = "Refresh your spirit—your devotional awaits!"
        content.sound = .default
        content.userInfo = ["notificationType": "morning"]
        
        // Create 6 AM trigger
        var dateComponents = DateComponents()
        dateComponents.hour = 6
        dateComponents.minute = 0
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
    
    // Schedule 2 PM daily nugget
    func scheduleDailyNugget() {
        // Get today's devotional content first to extract the nugget
        if let todayDevotional = DevotionalViewModel.shared.fetchTodayDevotional() {
            
            let content = UNMutableNotificationContent()
            content.title = "Daily Nugget"
            
            if let nugget = todayDevotional.acf?.nugget {
                content.body = nugget
            } else {
                // Fallback if no nugget is available
                content.body = "Reflect on today's devotional message"
            }
            
            content.sound = UNNotificationSound.default
            
            // Create 2 PM trigger
            var dateComponents = DateComponents()
            dateComponents.hour = 14
            dateComponents.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Create request
            let request = UNNotificationRequest(identifier: self.nuggetIdentifier, content: content, trigger: trigger)
            
            // Add request to notification center
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling nugget notification: \(error)")
                } else {
                    print("Successfully scheduled nugget notification for 2 PM")
                }
            }
        }
    }
    
    // MARK: - Background Refreshing
    
    func refreshNuggetNotificationContent() {
        // Cancel existing nugget notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["nuggetNotification"])
        
        // Fetch fresh devotional data
        let success = DevotionalViewModel.shared.refreshDevotionals
            
//            if success {
//                // Schedule with updated content
//                self.scheduleDailyNugget()
//                print("Successfully refreshed nugget notification content")
//            } else {
//                // If refresh failed, still schedule with whatever data we have
//                self.scheduleDailyNugget()
//                print("Failed to refresh devotional data, scheduled nugget with existing data")
//            }
        }

    private func updateNuggetNotification(with devotional: Devotional) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Nugget"
        content.body = devotional.acf?.nugget ?? "No nugget available"
        content.sound = .default
        content.userInfo = [
            "notificationType": "nugget",
            "devotionalId": devotional.id
        ]
        
        // Create 2 PM trigger (keeping the same time)
        var dateComponents = DateComponents()
        dateComponents.hour = 14
        dateComponents.minute = 0
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
        UserDefaults.standard.set(enabled, forKey: "morningNotificationsEnabled")
        
        if enabled {
            scheduleMorningReminder()
        } else {
            // Remove scheduled notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [morningIdentifier])
        }
    }
    
    func toggleNuggetNotifications(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "nuggetNotificationsEnabled")
        
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
