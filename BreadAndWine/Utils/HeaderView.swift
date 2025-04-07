//
//  HeaderView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 07.04.25.
//


import SwiftUI

// MARK: - Shared Components

struct HeaderView: View {
    var topPadding: CGFloat = 0
    var bottomPadding: CGFloat = 0
    
    var body: some View {
        HStack {
            Image("app-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
    }
}