//
//  NewsListView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// News List View
struct NewsListView: View {
    @StateObject private var viewModel = NewsViewModel()
    @State private var selectedNews: NewsEntry? = nil
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.news.isEmpty {
                    ProgressView("Loading news...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage, viewModel.news.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Unable to load news")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            viewModel.loadNews()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.news) { newsItem in
                            NewsRow(news: newsItem)
                                .onTapGesture {
                                    selectedNews = newsItem
                                }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .refreshable {
                        viewModel.refreshData()
                    }
                }
            }
            .navigationTitle("Recent News")
            .sheet(item: $selectedNews) { newsItem in
                NewsDetailView(news: newsItem)
            }
        }
        .onAppear {
            if viewModel.news.isEmpty {
                viewModel.loadNews()
            }
        }
    }
}
