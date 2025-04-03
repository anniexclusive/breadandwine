//
//  HTMLWebView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 02.04.25.
//


import SwiftUI
import WebKit

struct HTMLWebView: UIViewRepresentable {
    let html: String
    
    private let htmlStyling = """
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Helvetica, Arial;
            font-size: 40px;
            color: #0A1E3C;
            line-height: calc(40px + 18px);
            padding: 0 46px;
            margin: 0;
        }
        img {
            max-width: 100%;
            height: auto;
        }
        blockquote {
          background: #f9f9f9;
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
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let styledHTML = htmlStyling + html
        uiView.loadHTMLString(styledHTML, baseURL: URL(string: "https://breadandwinedevotional.com/"))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
