//
//  DevotionalApp.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// Main App with Tab View
struct DevotionalApp: View {
    @State private var showMenu = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                // Main Content
                TabView(selection: $selectedTab) {
                    DevotionalListView()
                        .tabItem {
                            Label("Devotionals", systemImage: "book.fill")
                        }
                        .tag(0)
                    
                    AboutView()
                        .tabItem {
                            Label("About", systemImage: "info.circle.fill")
                        }
                        .tag(1)
                }
                .disabled(showMenu)
                .blur(radius: showMenu ? 2 : 0)
                
                // Side Menu
                if showMenu {
                    MenuView(showMenu: $showMenu, selectedTab: $selectedTab)
                        .frame(width: UIScreen.main.bounds.width * 0.7)
                        .transition(.move(edge: .leading))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            showMenu.toggle()
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3")
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.startLocation.x < 20 && gesture.translation.width > 0 {
                            withAnimation {
                                showMenu = true
                            }
                        }
                    }
            )
        }
    }
}

//            NewsListView()
//                .tabItem {
//                    Label("News", systemImage: "newspaper.fill")
//                }
