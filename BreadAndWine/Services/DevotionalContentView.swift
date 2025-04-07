//
//  DevotionalContentView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 05.04.25.
//


import SwiftUI

// DevotionalContentView.swift
import SwiftUI

struct DevotionalContentView: View {
    let htmlContent: String
    @State private var attributedContent: AttributedString?
    
    var body: some View {
        Group {
            if let attributedContent = attributedContent {
                Text(attributedContent)
                    .font(.system(size: 16))
                    .padding(.horizontal)
            } else {
                ProgressView()
                    .onAppear { parseHTML() }
            }
        }
    }
    
    private func parseHTML() {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let data = htmlContent.data(using: .utf8),
              let nsAttributedString = try? NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
              ) else {
            return
        }
        
        // Convert to SwiftUI AttributedString
        do {
            let swiftuiString = try AttributedString(nsAttributedString, including: \.swiftUI)
            DispatchQueue.main.async {
                self.attributedContent = swiftuiString
            }
        } catch {
            print("Error converting attributed string: \(error)")
        }
    }
}

// HybridContentView.swift
struct HybridContentView: View {
    let htmlContent: String
    @State private var showWebView = false
    @State private var contentLoaded = false
    
    var body: some View {
        Group {
            if contentLoaded {
                DevotionalContentView(htmlContent: htmlContent)
            } else {
                ProgressView()
                    .onAppear {
                        // Load content with 0.5 second delay if not loaded
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if !self.contentLoaded {
                                self.showWebView = true
                            }
                        }
                    }
            }
        }
    }
}
