//
//  Devotional.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 29.03.25.
//


import Foundation
import SwiftUI

// Devotional Model
struct Devotional: Codable, Identifiable {
    let id: Int
    let title: RenderedText
    let content: RenderedText
    let date: String
    
    struct RenderedText: Codable {
        let rendered: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, date
    }
}