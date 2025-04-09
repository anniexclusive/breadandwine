//
//  SettingsView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 04.04.25.
//

// NotificationSettingsView.swift
import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    @State private var morningEnabled = UserDefaults.standard.bool(forKey: "morningNotificationsEnabled")
    @State private var nuggetEnabled = UserDefaults.standard.bool(forKey: "nuggetNotificationsEnabled")
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Push Notifications")) {
                Toggle("Enable All Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { newValue in
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            // Turn off all notifications
                            morningEnabled = false
                            nuggetEnabled = false
                            NotificationManager.shared.toggleAllNotifications(false)
                        }
                    }
                
                if notificationsEnabled {
                    VStack(alignment: .leading, spacing: 20) {
                        Toggle("Morning Reminder", isOn: $morningEnabled)
                            .onChange(of: morningEnabled) { newValue in
                                NotificationManager.shared.toggleMorningNotifications(newValue)
                            }
                        
                        Toggle("Daily Nugget", isOn: $nuggetEnabled)
                            .onChange(of: nuggetEnabled) { newValue in
                                NotificationManager.shared.toggleNuggetNotifications(newValue)
                            }
                    }
                }
            }
            
            Section(header: Text("About Notifications"), footer: Text("You can manage notification permissions in the Settings app.")) {
                Button("Open System Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
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
        .onAppear {
            checkNotificationStatus()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Notification Permission"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func checkNotificationStatus() {
        NotificationManager.shared.checkNotificationSettings { enabled in
            self.notificationsEnabled = enabled
            self.morningEnabled = UserDefaults.standard.bool(forKey: "morningNotificationsEnabled")
            self.nuggetEnabled = UserDefaults.standard.bool(forKey: "nuggetNotificationsEnabled")
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .denied:
                    // User previously denied - prompt to go to settings
                    self.notificationsEnabled = false
                    self.alertMessage = "Notifications are disabled. Please enable them in the Settings app."
                    self.showAlert = true
                    
                case .notDetermined:
                    // Request permission
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async {
                            self.notificationsEnabled = granted
                            if granted {
                                UIApplication.shared.registerForRemoteNotifications()
                                NotificationManager.shared.scheduleNotifications()
                            } else {
                                self.alertMessage = "You've declined notification permissions. You can enable them in the Settings app."
                                self.showAlert = true
                            }
                        }
                    }
                    
                case .authorized, .provisional, .ephemeral:
                    // Already authorized - enable and schedule notifications
                    NotificationManager.shared.toggleAllNotifications(true)
                    
                @unknown default:
                    break
                }
            }
        }
    }
}

// Preview provider
struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
