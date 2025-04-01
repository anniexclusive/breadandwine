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
    @Published var devotionals: [DevotionalEntry] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    func loadDevotionals() {
        isLoading = true
        NetworkManager.shared.fetchDevotionals { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let entries):
                    // Direct assignment (no nested arrays)
                    self?.devotionals = entries
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.errorMessage = "Failed to load devotionals: \(error.localizedDescription)"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    } 
}
