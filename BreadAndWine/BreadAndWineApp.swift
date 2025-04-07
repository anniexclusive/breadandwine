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
            .animation(.easeInOut(duration: 0.3), value: showSplash)
            .onAppear {
                // Hide splash after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showSplash = false
                }
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
}
