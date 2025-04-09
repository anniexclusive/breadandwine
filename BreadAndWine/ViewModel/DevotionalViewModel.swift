//
//  DevotionalViewModel.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//
import Foundation
import SwiftUI
import Combine

class DevotionalViewModel: ObservableObject {
    @Published var devotionals: [Devotional] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    static let shared = DevotionalViewModel()
    
    private let cacheKey = "cachedDevotionals"
    
    init() {
            loadCachedDevotionals()
            fetchDevotionals()
        }
    
    func refreshDevotionals() {
        fetchDevotionals()
    }
    
    func fetchDevotionals() {
        isLoading = true
        
        APIService.shared.fetchDevotionals { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let devotionals):
                    self?.devotionals = devotionals
                    self?.cacheDevotionals(devotionals)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchTodayDevotional() -> Devotional? {
        // Get today's date in the same format as the devotional dates
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        let todayString = formatter.string(from: today)
        
        // Find the devotional that matches today's date
        // This assumes the date string starts with the yyyy-MM-dd format
        return devotionals.first { devotional in
            devotional.formattedDate.starts(with: todayString)
        }
    }
    
    func getDevotionalById(_ id: String) -> Devotional? {
        return devotionals.first { $0.id == Int(id) }
    }
    
    private func cacheDevotionals(_ devotionals: [Devotional]) {
        if let encoded = try? JSONEncoder().encode(devotionals) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
//        
    private func loadCachedDevotionals() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
            let devotionals = try? JSONDecoder().decode([Devotional].self, from: data) {
            self.devotionals = devotionals
        }
    }
}
