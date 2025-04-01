//
//  NewsViewModel.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//
import SwiftUI

class NewsViewModel: ObservableObject {
    @Published var news: [NewsEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let networkManager: NetworkManager
    
    // Dependency injection for better testability
    init(networkManager: NetworkManager = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func loadNews() {
        isLoading = true
        errorMessage = nil
        
        networkManager.fetchNews { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.news = response.data
                print("✅ Successfully loaded \(response.data.count) news items")
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print("❌ Failed to load news: \(error.localizedDescription)")
            }
        }
    }
    
    func refreshData() {
        networkManager.clearCache(for: "recent_news")
        loadNews()
    }
}
