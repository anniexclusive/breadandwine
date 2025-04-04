//
//  HTMLText.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 03.04.25.
//
import SwiftUI


struct HTMLText: View {
    let html: String
    
    var body: some View {
        Text(html.renderedHTML)
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension String {
    var renderedHTML: AttributedString {
        do {
            let data = Data(self.utf8)
            let attributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            return AttributedString(attributedString)
        } catch {
            return AttributedString("Error rendering content")
        }
    }
}
