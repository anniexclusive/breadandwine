//
//  NewsEntry.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//


// Model for news entry
struct NewsEntry: Identifiable, Codable {
    let id: Int
    let title: String
    let date: String
    let content: String  // HTML content
    let excerpt: String
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "post_title"
        case date = "post_date"
        case content = "post_content"
        case excerpt = "post_excerpt"
        case imageUrl = "featured_image"
    }
}