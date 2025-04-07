//
//  NewsDetailView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// News Detail View
struct NewsDetailView: View {
    let news: NewsEntry
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let imageUrl = news.imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                    
                    Text(news.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text(formatDate(news.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Divider()
                    
//                    HTMLStringView(htmlContent: news.content)
//                        .frame(minHeight: 300)
                }
                .padding(.vertical)
            }
            .navigationTitle("News")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
}
