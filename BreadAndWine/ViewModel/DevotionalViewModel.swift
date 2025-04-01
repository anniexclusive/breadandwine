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
    
    func fetchDevotionals() {
        guard let url = URL(string: "https://breadandwinedevotional.com/wp-json/wp/v2/devotional") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            
            do {
                let decodedDevotionals = try JSONDecoder().decode([Devotional].self, from: data)
                DispatchQueue.main.async {
                    self.devotionals = decodedDevotionals
                }
            } catch {
                print("Decoding error: \(error)")
                // For debugging: Print raw JSON
                print(String(data: data, encoding: .utf8) ?? "Invalid data")
            }
        }.resume()
    }
}
