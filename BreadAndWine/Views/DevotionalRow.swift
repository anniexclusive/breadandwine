//
//  DevotionalRow.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// Devotional Row for List
struct DevotionalRow: View {
    let devotional: DevotionalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(devotional.titleText)
                .font(.headline)
                .lineLimit(2)
            
            Text(formatDate(devotional.date))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(devotional.excerptText)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Convert API date format to a more readable format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
}
