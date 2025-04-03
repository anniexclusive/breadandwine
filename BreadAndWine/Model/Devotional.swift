//
//  Devotional.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 29.03.25.
//


import Foundation
import SwiftUI

// Devotional Model
struct Devotional: Identifiable, Decodable {
    let id: Int
    let date: String // Date is at the ROOT level, not in acf
    let title: Title
    let content: Content
    let acf: [String] // Represents empty array (ignore if unused)
    
    struct Title: Decodable {
            let rendered: String
        }

        struct Content: Decodable {
            let rendered: String?

            enum CodingKeys: String, CodingKey {
                case rendered
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                rendered = try container.decodeIfPresent(String.self, forKey: .rendered) ?? ""
            }
        }
    
    // Computed property to format the root-level date
    var formattedDate: String {
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = isoFormatter.date(from: self.date) else {
            return self.date // Fallback if parsing fails
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        return displayFormatter.string(from: date)
    }
    
    // Clean HTML from title
    var cleanTitle: String {
        title.rendered
            .replacingOccurrences(of: #"<\/?[^>]+>"#, with: "", options: .regularExpression)
    }
}
