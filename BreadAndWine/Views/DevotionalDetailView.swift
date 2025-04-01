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
                Text(devotional.cleanTitle)
                    .font(.title)
                
                Text(devotional.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(formattedContent.string)
                    .font(.body)
                    .lineSpacing(8)
            }
            .padding()
        }
        .onAppear {
            formatHTMLContent()
        }
        .navigationBarTitleDisplayMode(.inline)
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
