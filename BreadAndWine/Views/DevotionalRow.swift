//
//  DevotionalRow.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// Devotional Row for List
struct DevotionalRow: View {
    let devotional: Devotional
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail Image (Replace with actual image URL when available)
            Image(systemName: "book.closed.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .padding(10)
                .background(Color.theme.accent)
                .cornerRadius(10)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(devotional.cleanTitle)
                    .font(.headline)
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(2)
                
                Text(devotional.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(Color.theme.textSecondary)
            }
            .padding(.vertical, 8)
        }
    }
}
