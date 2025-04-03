//
//  DevotionalDetailView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// Devotional Detail View
struct DevotionalDetailView: View {
    let devotional: Devotional
//    @State private var formattedContent = NSAttributedString()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.theme.accent)
                    
                    VStack(alignment: .leading) {
                        Text(devotional.title.rendered)
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Text(devotional.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
                .padding()
                .background(Color.theme.background)
                .cornerRadius(12)
                .padding(.horizontal)
                
                Divider()
                
                // HTML content section (replaces Text(content.rendered))
                if let htmlContent = devotional.content.rendered, !htmlContent.isEmpty {
                    HTMLWebView(html: htmlContent)
                        .frame(height: UIScreen.main.bounds.height) // Adjust as needed
                } else {
                    Text("Error loading content.")
                        .frame(maxWidth: .infinity)
                }
                
//                Text(formattedContent.string)
//                    .font(.body)
//                    .foregroundColor(Color.theme.textPrimary)
//                    .lineSpacing(8)
//                    .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(Color.theme.background)
        .navigationBarTitle(devotional.cleanTitle, displayMode: .inline)
//        .onAppear {
//            formatHTMLContent()
//        }
    } 

    
//    private func formatHTMLContent() {
//        if let htmlContent = devotional.content.rendered, !htmlContent.isEmpty {
//                        HTMLWebView(html: htmlContent)
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    } else {
//                        Text("Error loading content.")
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    }
//    }
}
