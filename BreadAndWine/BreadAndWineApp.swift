//
//  BreadAndWineApp.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 29.03.25.
//

import SwiftUI

@main
struct BreadAndWineApp: App {
    init() {
            // Initialize NetworkManager with your actual API endpoint
            // Replace this URL with your actual API endpoint
            _ = NetworkManager.shared = NetworkManager(
                baseURL: "https://breadandwinedevotional.com/wp-json/wp/v2",
                timeoutInterval: 30,
                maxRetryCount: 3,
                retryDelay: 2
            )
            
            print("🚀 App initialized with custom NetworkManager")
        }
    
    var body: some Scene {
        WindowGroup {
            DevotionalApp()
        }
    }
}
