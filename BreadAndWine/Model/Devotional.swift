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
    let title: RenderedField
    let content: RenderedField
    let acf: [String] // Represents empty array (ignore if unused)
    
    // Nested structure for title/content
    struct RenderedField: Decodable {
        let rendered: String
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
