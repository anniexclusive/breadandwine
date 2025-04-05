//
//  IpadRootView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 04.04.25.
//
import SwiftUI

struct IpadRootView: View {
    @SceneStorage("selectedCategory") private var selectedCategory: MenuItem?
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    @State private var selectedTab = 0
    @StateObject private var viewModel = DevotionalViewModel()
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            IpadMenuView(
                selectedCategory: $selectedCategory,
                columnVisibility: $columnVisibility
            )
        } detail: {
            NavigationStack {
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
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
