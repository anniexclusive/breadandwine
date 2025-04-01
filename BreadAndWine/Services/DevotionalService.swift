//
//  DevotionalService.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 29.03.25.
//
import SwiftUI


// API Service
class DevotionalService: ObservableObject {
    @Published var devotional: Devotional?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiUrlString = "https://breadandwinedevotional.com/wp-json/wp/v2/devotional/"
    
    func fetchDailyDevotional() {
        guard let url = URL(string: apiUrlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    let devotionals = try JSONDecoder().decode([Devotional].self, from: data)
                    self?.devotional = devotionals.first
                } catch {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
