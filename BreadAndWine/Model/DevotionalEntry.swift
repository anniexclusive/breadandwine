//
//  DevotionalEntry.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//


import Foundation
import SwiftUI

// Model for devotional entry
struct DevotionalEntry: Identifiable, Codable {
    let id: Int
    let title: TitleRendered
    let date: String
    let content: ContentRendered
    let excerpt: ExcerptRendered
    
    // Simplified access without computed properties
    var titleText: String { title.rendered }
    var contentText: String { content.rendered }
    var excerptText: String { excerpt.rendered }

    struct TitleRendered: Codable {
        let rendered: String
    }
    
    struct ContentRendered: Codable {
        let rendered: String
    }
    
    struct ExcerptRendered: Codable {
        let rendered: String
    }
}
