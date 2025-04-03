//
//  DevotionalListView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// MARK: - Views

// Devotional List View
struct DevotionalListView: View {
    @StateObject var viewModel = DevotionalViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.devotionals) { devotional in
                    NavigationLink(destination: DevotionalDetailView(devotional: devotional)) {
                        DevotionalRow(devotional: devotional)
                            .padding(.vertical, 8)
                    }
                    .listRowBackground(ColorTheme.background)
                }
            }
            .navigationTitle("Bread & Wine")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchDevotionals()
            }
            .background(ColorTheme.background)
        }
        .accentColor(ColorTheme.accentPrimary)
        .onAppear {
            // Navigation bar appearance customization
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(ColorTheme.background)
            appearance.titleTextAttributes = [.foregroundColor: UIColor(ColorTheme.textPrimary)]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
