//
//  DevotionalApp.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// Main App with Tab View
struct DevotionalApp: View {
    var body: some View {
        TabView {
            DevotionalListView()
                .tabItem {
                    Label("Devotionals", systemImage: "book.fill")
                }
            
//            NewsListView()
//                .tabItem {
//                    Label("News", systemImage: "newspaper.fill")
//                }
        }
    }
}
