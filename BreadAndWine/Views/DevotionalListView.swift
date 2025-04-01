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
    @StateObject private var viewModel = DevotionalViewModel()
    @State private var selectedDevotional: DevotionalEntry? = nil
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.devotionals.isEmpty {
                    ProgressView("Loading devotionals...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage, viewModel.devotionals.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Unable to load devotionals")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            viewModel.loadDevotionals()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.devotionals) { devotional in
                            DevotionalRow(devotional: devotional)
                                .onTapGesture {
                                    selectedDevotional = devotional
                                }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .refreshable {
                        viewModel.refreshData()
                    }
                }
            }
            .navigationTitle("Daily Devotionals")
            .sheet(item: $selectedDevotional) { devotional in
                DevotionalDetailView(devotional: devotional)
            }
        }
        .onAppear {
            if viewModel.devotionals.isEmpty {
                viewModel.loadDevotionals()
            }
        }
    }
}
