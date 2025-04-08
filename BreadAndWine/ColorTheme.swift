//
//  ColorTheme.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 01.04.25.
//


import SwiftUI

// ColorTheme.swift
import SwiftUI

import SwiftUI

struct ColorTheme {
    static let background = Color(light: .white, dark: Color(red: 0.1, green: 0.1, blue: 0.1))
    static let textPrimary = Color(light: .black, dark: .white)
    static let textSecondary = Color(light: Color(red: 0.4, green: 0.4, blue: 0.4), dark: Color(red: 0.8, green: 0.8, blue: 0.8))
    static let cardBackground = Color(light: .white, dark: Color(red: 0.2, green: 0.2, blue: 0.2))
    static let accentPrimary = Color(light: Color(red: 0.2, green: 0.4, blue: 0.8), dark: Color(red: 0.4, green: 0.6, blue: 1.0))
    static let navBar = Color(light: Color(red: 0.45, green: 0.55, blue: 0.82), dark: Color(red: 0.1, green: 0.1, blue: 0.1))
}

extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(dark) : UIColor(light)
        })
    }
}

// Create these color assets in your Assets.xcassets:
// - AccentColor (Dark Blue: #0A1E3C)
// - BackgroundColor (Off-White: #F8F9FA)
// - TextPrimary (Dark Gray: #2D2D2D)
// - TextSecondary (Gray: #6C757D)
