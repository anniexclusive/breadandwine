//
//  BreadAndWineApp.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 29.03.25.
//

import SwiftUI
import AVKit

@main
struct BreadAndWineApp: App {
    @State private var showSplash = true
    @AppStorage("lastUpdateCheck") private var lastUpdateCheck: Double = 0
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    RootView() // Your existing main view
                }
            }
            .animation(.easeInOut(duration: AppConstants.Timing.splashAnimationDuration), value: showSplash)
            .onAppear {
                // Hide splash screen after configured duration
                DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Timing.splashScreenDuration) {
                    showSplash = false
                }
                checkForUpdates()
            }
        }
    }
    
    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .spokenAudio,
            options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers]
        )
    }
    
    private func checkForUpdates() {
        let currentTime = Date().timeIntervalSince1970

        if currentTime - lastUpdateCheck > AppConstants.Timing.updateCheckInterval {
            // Trigger updates
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("RefreshDevotionalContent"), object: nil)
                lastUpdateCheck = currentTime
            }
        }
    }
}
