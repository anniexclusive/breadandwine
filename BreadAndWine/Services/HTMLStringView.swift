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
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Add CSS for better styling, including dark mode support
        let css = """
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                font-size: 16px;
                line-height: 1.5;
                margin: 0;
                padding: 10px;
                color: black;
            }
            
            @media (prefers-color-scheme: dark) {
                body {
                    color: white;
                    background-color: black;
                }
                a {
                    color: #0A84FF;
                }
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
        </style>
        """
        
        let htmlWithCSS = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            \(css)
        </head>
        <body>
            \(htmlContent)
        </body>
        </html>
        """
        
        uiView.loadHTMLString(htmlWithCSS, baseURL: nil)
    }
}
