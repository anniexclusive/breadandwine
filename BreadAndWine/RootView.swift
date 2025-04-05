//
//  DevotionalApp.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// Main App with Tab View
struct RootView: View {
    @State private var showMenu = false
    @State private var selectedTab = 0
    @StateObject private var viewModel = DevotionalViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                // Main Content
                TabView(selection: $selectedTab) {
                    DevotionalListView(viewModel: viewModel)
                        .tabItem {
                            Label("Devotionals", systemImage: "book.fill")
                        }
                        .tag(0)
                    
                    NuggetsListView(viewModel: viewModel)
                        .tabItem {
                            Label("Nuggets", systemImage: "info.circle.fill")
                        }
                        .tag(1)
                } 
                .blur(radius: showMenu ? 2 : 0)
                
                // Side Menu
                if showMenu {
                    MenuView(showMenu: $showMenu, selectedTab: $selectedTab)
                        .frame(width: UIScreen.main.bounds.width * 0.6)
                        .transition(.move(edge: .leading))
                }
            }
            .toolbar {
                if !showMenu {
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
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.startLocation.x < 20 && gesture.translation.width > 0 {
                            withAnimation {
                                showMenu = true
                            }
                        }
                        if showMenu && gesture.translation.width < -100 {
                            withAnimation {
                                showMenu = false
                            }
                        }
                    }
            )
            .overlay(
                Group {
                    if showMenu {
                        Color.black.opacity(0.001)
                            .onTapGesture {
                                withAnimation {
                                    showMenu = false
                                }
                            }
                            .ignoresSafeArea()
                    }
                }
            )
        }
//        .navigationViewStyle(.stack)
    }
}

//            NewsListView()
//                .tabItem {
//                    Label("News", systemImage: "newspaper.fill")
//                }
