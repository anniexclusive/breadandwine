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
    @State private var formattedContent = NSAttributedString()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.theme.accent)
                    
                    VStack(alignment: .leading) {
                        Text(devotional.cleanTitle)
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
                
                Text(formattedContent.string)
                    .font(.body)
                    .foregroundColor(Color.theme.textPrimary)
                    .lineSpacing(8)
                    .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(Color.theme.background)
        .navigationBarTitle(devotional.cleanTitle, displayMode: .inline)
        .onAppear {
            formatHTMLContent()
        }
    } 

    
    private func formatHTMLContent() {
        let data = Data(devotional.content.rendered.utf8)
        if let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        ) {
            formattedContent = attributedString
        }
    }
}
