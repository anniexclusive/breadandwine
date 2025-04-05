//
//  BreadAndWineApp.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 29.03.25.
//

import SwiftUI

@main
struct BreadAndWineApp: App {
   
    
    var body: some Scene {
        WindowGroup {
            if UIDevice.current.userInterfaceIdiom == .pad {
                IpadRootView()
            } else {
                RootView()
            }
        }
    }
}
