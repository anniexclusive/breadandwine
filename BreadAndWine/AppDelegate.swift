//
//  AppDelegate.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 09.04.25.
//


// AppDelegate.swift
import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set up notifications
        setupNotifications(application)
        
        return true
    }
    
    func setupNotifications(_ application: UIApplication) {
        // Set messaging delegate
        Messaging.messaging().delegate = self
        
        // Request authorization
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                    // Schedule local notifications
                    NotificationManager.shared.scheduleNotifications()
                } else {
                    print("User denied notification permission: \(String(describing: error))")
                    // Store this state to update UI accordingly
                    UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                }
            }
        )
    }
    
    // MARK: - Remote Notifications Handling
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Called when a notification is delivered to a foreground app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Received notification in foreground: \(userInfo)")
        
        // Show the notification even when app is in foreground
        completionHandler([.banner, .badge, .sound])
    }
    
    // Called when user taps on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification tap
        NotificationManager.shared.handleNotificationResponse(response)
        
        completionHandler()
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("Firebase token: \(token)")
        
        // Store directly in Firebase
        DeviceManager.shared.saveDeviceToken(token)
    }
}
