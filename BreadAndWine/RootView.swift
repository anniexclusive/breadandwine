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
    @Environment(\.colorScheme) var colorScheme
    
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
                .toolbarBackground(themeBackgroundColor, for: .navigationBar)
                .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
                
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
                                .foregroundColor(themeTintColor)
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
        .accentColor(themeTintColor) // Set global tint
        .onAppear(perform: setupNavigationBarAppearance)
//        .navigationViewStyle(.stack)
    }
    
    private var themeBackgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
        
    private var themeTintColor: Color {
        colorScheme == .dark ? .white : .black
    }
        
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set background color
        appearance.backgroundColor = UIColor(themeBackgroundColor)
        
        // Set title color
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(themeTintColor),
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        
        // Apply to all navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

//            NewsListView()
//                .tabItem {
//                    Label("News", systemImage: "newspaper.fill")
//                }
