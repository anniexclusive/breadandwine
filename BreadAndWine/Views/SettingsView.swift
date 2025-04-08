//
//  SettingsView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 04.04.25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @State private var isNotificationsEnabled = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Daily Devotional Reminder", isOn: $isNotificationsEnabled)
                        .onChange(of: isNotificationsEnabled) { newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                scheduleNotification()
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Devotional"
        content.body = "Your daily devotional is ready to read!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 6
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyDevotionalReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
