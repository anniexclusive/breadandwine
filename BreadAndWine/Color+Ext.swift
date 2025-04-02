//
//  ColorTheme.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 01.04.25.
//


import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let textPrimary = Color("TextPrimary")
    let textSecondary = Color("TextSecondary")
}

// Create these color assets in your Assets.xcassets:
// - AccentColor (Dark Blue: #0A1E3C)
// - BackgroundColor (Off-White: #F8F9FA)
// - TextPrimary (Dark Gray: #2D2D2D)
// - TextSecondary (Gray: #6C757D)