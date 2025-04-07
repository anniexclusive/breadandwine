//
//  PlaybackControlView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 07.04.25.
//
import SwiftUI

struct PlaybackControlView: View {
    let isSpeaking: Bool
    let isDisabled: Bool
    let onPlayPause: () -> Void
    
    var body: some View {
        Button(action: onPlayPause) {
            Image(systemName: isSpeaking ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(isDisabled ? ColorTheme.textSecondary : ColorTheme.accentPrimary)
        }
        .disabled(isDisabled)
        .buttonStyle(.plain) // Add this for iPad
        .accessibilityLabel(isSpeaking ? "Pause audio" : "Play audio")
    }
}
