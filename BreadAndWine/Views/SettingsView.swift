//
//  SettingsView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 04.04.25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    let aboutContent = """
    This is settings page
"""
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "book.closed.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(ColorTheme.accentPrimary)
                
                VStack(alignment: .leading) {
                    Text("About Bread and Wine Devotional")
                        .font(.title2)
                        .bold()
                        .foregroundColor(ColorTheme.textPrimary)
                }
            }
            .padding()
            .background(ColorTheme.background)
            .cornerRadius(12)
            .padding(.horizontal)
            
            Divider()
            
            HTMLWebView(html: aboutContent)
                .frame(maxWidth: .infinity, minHeight: 600)
        }
        
        
    }
}
