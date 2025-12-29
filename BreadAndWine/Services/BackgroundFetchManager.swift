//
//  BackgroundFetchManager.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 09.04.25.
//

import UIKit
import BackgroundTasks

class BackgroundFetchManager {
    static let shared = BackgroundFetchManager()
    
    private init() {}
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: AppConstants.Notifications.backgroundFetchIdentifier,
                                        using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    func scheduleBackgroundFetch() {
        let request = BGAppRefreshTaskRequest(identifier: AppConstants.Notifications.backgroundFetchIdentifier)
        
        // Schedule the task to run before nugget notification time
        // Calculate next fetch time (e.g., 9:45 AM today or tomorrow)
        let now = Date()
        var targetComponents = Calendar.current.dateComponents([.year, .month, .day], from: now)
        targetComponents.hour = AppConstants.Notifications.Time.backgroundFetchHour
        targetComponents.minute = AppConstants.Notifications.Time.backgroundFetchMinute
        
        var targetDate = Calendar.current.date(from: targetComponents)!
        
        // If it's already past the target time today, schedule for tomorrow
        if targetDate < now {
            targetDate = Calendar.current.date(byAdding: .day, value: 1, to: targetDate)!
        }
        
        // Set the earliest begin date
        request.earliestBeginDate = targetDate
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule nugget fetch: \(error.localizedDescription)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        
        // Schedule a new background refresh task
        scheduleBackgroundFetch()
        
        // Fetch and update the nugget content for today's notification
        NotificationManager.shared.refreshNuggetNotificationContent()
        
        // Inform the system that the background task is complete
        task.setTaskCompleted(success: true)
    }
}
