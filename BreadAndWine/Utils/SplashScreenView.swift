//
//  SplashScreenView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 07.04.25.
//


import SwiftUI

struct SplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            ColorTheme.background
                .ignoresSafeArea()
            
            VStack {
                // Logo
                Image("app-logo") // Add your logo to assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // Copyright Footer
            VStack {
                Spacer()
                Text("© 2015 Firstlove Assembly")
                    .font(.system(size: 12))
                    .foregroundColor(ColorTheme.textSecondary)
                    .padding(.bottom, 20)
            }
        }
    }
}
