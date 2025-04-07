//
//  HTMLStringView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// MARK: - Helper for HTML Rendering

import WebKit

struct HTMLStringView: UIViewRepresentable {
    let htmlContent: String
    @Binding var contentHeight: CGFloat
    var containerWidth: CGFloat
    @Environment(\.colorScheme) private var colorScheme
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false // Disable internal scrolling
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Only reload if width changes significantly
        if abs(uiView.bounds.width - containerWidth) > 1 {
            uiView.frame.size.width = containerWidth
            loadContent(in: uiView)
        }
    }
    
    private func loadContent(in webView: WKWebView) {
        // Add CSS for better styling, including dark mode support
        let css = """
        <style>
            body {
                width: \(containerWidth - 40)px;
                font-family: -apple-system, BlinkMacSystemFont, Arial, 'Segoe UI', Roboto, Helvetica, sans-serif;
                font-size: 17px;
                line-height: 1.5;
                margin: 0;
                padding: 0 20px;
                color: \(ColorTheme.textPrimary.hexString(for: colorScheme));
                background-color: \(ColorTheme.background.hexString(for: colorScheme));
            }
            
            h1, h2, h3, h4, h5, h6 {
                margin-top: 1em;
                margin-bottom: 0.5em;
            }
            
            p {
                margin-bottom: 1em;
            }
            
            img {
                max-width: 100%;
                height: auto;
            }
                    blockquote {
                      border-left: 10px solid #ccc;
                      margin: 1.5em 10px;
                      padding: 0.5em 10px;
                      quotes: "\\201C""\\201D""\\2018""\\2019";
                    }
                    blockquote:before {
                      color: #ccc;
                      content: open-quote;
                      font-size: 4em;
                      line-height: 0.1em;
                      margin-right: 0.25em;
                      vertical-align: -0.4em;
                    }
                    blockquote p {
                      display: inline;
                    }
        </style>
        """
        
        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=\(containerWidth), initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            \(css)
        </head>
        <body>
            \(htmlContent)
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLStringView
        
        init(_ parent: HTMLStringView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            updateContentHeight(for: webView)
        }
                
        private func updateContentHeight(for webView: WKWebView) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { height, _ in
                guard let height = height as? CGFloat else { return }
                DispatchQueue.main.async {
                    if self.parent.contentHeight != height {
                        self.parent.contentHeight = height
                    }
                }
            }
        }
    }
}

extension Color {
    func hexString(for colorScheme: ColorScheme) -> String {
        let traitCollection = UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
        let resolvedColor = UIColor(self).resolvedColor(with: traitCollection)
        return resolvedColor.hexString ?? "#FFFFFF"
    }
}

extension UIColor {
    var hexString: String? {
        guard let components = cgColor.components, components.count >= 3 else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}
