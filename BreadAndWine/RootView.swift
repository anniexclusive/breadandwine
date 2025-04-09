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
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedCategory: MenuItem?
    
    @State private var selectedDevotionalId: String? = nil
    @State private var navigateToDevotional = false
    
    private var menuButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                if horizontalSizeClass == .regular {
                    columnVisibility = columnVisibility == .all ? .detailOnly : .all
                } else {
                    showMenu.toggle()
                }
            }
        } label: {
            Image(systemName: "line.horizontal.3")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeTintColor)
        }
    }
    
    var body: some View {
        if horizontalSizeClass == .regular {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }
        
    private var iPadLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            UnifiedMenuView(selectedCategory: $selectedCategory, showMenu: .constant(false), columnVisibility: $columnVisibility)
                .navigationSplitViewColumnWidth(ideal: 320)
                .toolbar(.hidden, for: .navigationBar)
        } detail: {
            NavigationStack {
                switch selectedCategory {
                case .settings:
                    SettingsView()
                default:
                    mainContentView
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .navigationSplitViewStyle(.prominentDetail) // Prevents default sidebar toggle behavior
        .toolbarRole(.editor) // Avoids SwiftUI auto-inserting its own buttons
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                menuButton
            }
        }
        .accentColor(themeTintColor)
    }
        
    private var iPhoneLayout: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                switch selectedCategory {
                case .settings:
                    SettingsView()
                default:
                    mainContentView
                        .disabled(showMenu)
                        .blur(radius: showMenu ? 2 : 0)
                }
                
                Color.black.opacity(showMenu ? 0.4 : 0)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showMenu = false } }
                
                if showMenu {
                    UnifiedMenuView(selectedCategory: $selectedCategory, showMenu: $showMenu, columnVisibility: $columnVisibility)
                        .frame(width: UIScreen.main.bounds.width * 0.65)
                        .transition(.move(edge: .leading))
                }
            }
            .toolbar {
                if !showMenu {
                    ToolbarItem(placement: .navigationBarLeading) {
                        menuButton
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.startLocation.x < 20 && gesture.translation.width > 0 {
                            withAnimation { showMenu = true }
                        }
                        if showMenu && gesture.translation.width < -100 {
                            withAnimation { showMenu = false }
                        }
                    }
            )
        }
        .accentColor(themeTintColor)
        .navigationViewStyle(.stack)
    }
        
    private var mainContentView: some View {
        TabView(selection: $selectedTab) {
            DevotionalListView(viewModel: viewModel)
                .tabItem {
                    Label("Devotionals", systemImage: "book.fill")
                }
                .tag(0)
                .navigationDestination(isPresented: $navigateToDevotional) {
                    if let id = selectedDevotionalId,
                       let devotional = viewModel.getDevotionalById(id) {
                        DevotionalDetailView(devotional: devotional)
                    } else if let todayDevotional = viewModel.fetchTodayDevotional() {
                        DevotionalDetailView(devotional: todayDevotional)
                    } else {
                        Text("Devotional not available")
                    }
                }
            
            NuggetsListView(viewModel: viewModel)
                .tabItem {
                    Label("Nuggets", systemImage: "lightbulb.fill")
                }
                .tag(1)
        }
        .toolbarBackground(themeBackgroundColor, for: .navigationBar)
        .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
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
