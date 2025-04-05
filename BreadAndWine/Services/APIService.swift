//
//  DevotionalService.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 05.04.25.
//
import SwiftUI

class APIService {
    static let shared = APIService()
    private let baseURL = "https://breadandwinedevotional.com/wp-json/wp/v2"
    
    func fetchDevotionals(completion: @escaping (Result<[Devotional], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/devotional")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let devotionals = try decoder.decode([Devotional].self, from: data)
                completion(.success(devotionals))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
