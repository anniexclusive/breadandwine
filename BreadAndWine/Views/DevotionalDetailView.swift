//
//  DevotionalDetailView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// Devotional Detail View
struct DevotionalDetailView: View {
    let devotional: DevotionalEntry
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(devotional.titleText)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text(formatDate(devotional.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    HTMLStringView(htmlContent: devotional.contentText)
                        .frame(minHeight: 300)
                }
                .padding(.vertical)
            }
            .navigationTitle("Devotional")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Share the devotional
                        let shareContent = "\(devotional.titleText)\n\n\(removeTags(from: devotional.contentText))"
                        let activityViewController = UIActivityViewController(
                            activityItems: [shareContent], 
                            applicationActivities: nil
                        )
                        
                        // Present the share sheet
                        UIApplication.shared.windows.first?.rootViewController?.present(
                            activityViewController, 
                            animated: true, 
                            completion: nil
                        )
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
    
    private func removeTags(from html: String) -> String {
        // Simple utility to strip HTML tags for sharing
        return html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
