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
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.devotionalapp.nuggetFetch",
                                        using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleBackgroundFetch() {
        let request = BGAppRefreshTaskRequest(identifier: "com.devotionalapp.nuggetFetch")
        
        // Schedule the task to run before 2 PM
        // Calculate next fetch time (e.g., 1:45 PM today or tomorrow)
        let now = Date()
        var targetComponents = Calendar.current.dateComponents([.year, .month, .day], from: now)
        targetComponents.hour = 9
        targetComponents.minute = 45
        
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
