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
    let acf: ACF?
    let yoastHeadJson: YoastHeadJSON?  // New Yoast SEO data
    
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
    struct ACF: Codable {
        let bible_reading_plan: String?
        let bible_verse: String?
        let prayer: String?
        let further_study: String?
        // Add other ACF keys as needed
    }
    
    // Yoast SEO Data
    struct YoastHeadJSON: Codable {
        let ogImage: [OGImage]?  // Array of Open Graph images
        
        struct OGImage: Codable {
            let url: String?     // Image URL
        }
        
        // Map JSON snake_case to camelCase
        enum CodingKeys: String, CodingKey {
            case ogImage = "og_image"
        }
    }
    // Top-level coding keys
    enum CodingKeys: String, CodingKey {
        case id, title, content, date, acf
        case yoastHeadJson = "yoast_head_json"
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
