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
    @Environment(\.colorScheme) var colorScheme
    
    var thumbnailURL: String? {
        devotional.yoastHeadJson?.ogImage?.first?.url
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if let urlString = thumbnailURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 60, height: 60)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        Image(systemName: "book.closed.fill")
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Placeholder when no image is available
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
            }
            // Thumbnail Image (Replace with actual image URL when available)
//            Image(systemName: "book.closed.fill")
//                .resizable()
//                .scaledToFill()
//                .frame(width: 60, height: 60)
//                .padding(10)
//                .background(Color.theme.accent)
//                .cornerRadius(10)
//                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(devotional.cleanTitle)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                    .lineLimit(2)
                
                Text(devotional.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textSecondary)
            }
            .padding(.vertical, 8)
        }
    }
}

