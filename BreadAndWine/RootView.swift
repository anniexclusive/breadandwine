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
    @SceneStorage("selectedCategory") private var selectedCategory: MenuItem?
    
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
                .background(ColorTheme.background)
        } detail: {
            NavigationStack {
                mainContentView
                    .toolbar {
                        ToolbarItem() {
                            menuButton
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
//        .toolbar(.hidden, for: .navigationBar)
        .navigationSplitViewStyle(.balanced)
        .accentColor(themeTintColor)
        .onAppear(perform: setupNavigationBarAppearance)
    }
        
    private var iPhoneLayout: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                mainContentView
                    .disabled(showMenu)
                    .blur(radius: showMenu ? 2 : 0)
                
                Color.black.opacity(showMenu ? 0.4 : 0)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showMenu = false } }
                
                if showMenu {
                    UnifiedMenuView(selectedCategory: $selectedCategory, showMenu: $showMenu, columnVisibility: $columnVisibility)
                        .frame(width: UIScreen.main.bounds.width * 0.75)
                        .transition(.move(edge: .leading))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    menuButton
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
        .onAppear(perform: setupNavigationBarAppearance)
        .navigationViewStyle(.stack)
    }
        
    private var mainContentView: some View {
        TabView(selection: $selectedTab) {
            DevotionalListView(viewModel: viewModel)
                .tabItem {
                    Label("Bread and Wine Devotionals", systemImage: "book.fill")
                }
                .tag(0)
            
            NuggetsListView(viewModel: viewModel)
                .tabItem {
                    Label("Nuggets", systemImage: "info.circle.fill")
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
