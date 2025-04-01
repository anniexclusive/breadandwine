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
            List(viewModel.devotionals) { devotional in
                NavigationLink(destination: DevotionalDetailView(devotional: devotional)) {
                    DevotionalRow(devotional: devotional) // No more generic error
                }
            }
            .navigationTitle("Bread & Wine")
            .onAppear {
                viewModel.fetchDevotionals()
            }
        }
    }
}
