//
//  MenuView 2.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 04.04.25.
//


import SwiftUI

struct IpadMenuView: View {
    @Binding var selectedCategory: MenuItem?
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image("app-logo")
                    .resizable()
                    .scaledToFit()  // Changed from scaledToFill for better aspect ratio
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .frame(maxWidth: .infinity)  // This makes the HStack take full width
//            .padding(.top, 40)
            .padding(.bottom, 20)
            .padding(.horizontal)
            .background(ColorTheme.background)
            
            List(selection: $selectedCategory) {
                Section(header: sectionHeader("Daily Devotion")) {
                    NavigationLink(value: MenuItem.devotions) {
                        MenuRow(
                            title: "Bread and Wine",
                            icon: "book.fill",
                            isSelected: selectedCategory == .devotions
                        )
                    }
                }
                
                Section(header: sectionHeader("Social Handle")) {
                    IpadMenuButton(
                        title: "Firstlove Social",
                        icon: "person.2.fill",
                        action: { openURL("https://www.facebook.com/flarumuokwuta/") }
                    )
                }
                
                Section(header: sectionHeader("Live Stream")) {
                    IpadMenuButton(
                        title: "YouTube",
                        icon: "play.rectangle.fill",
                        action: { openURL("https://www.youtube.com/@flarumuokwuta/streams") }
                    )
                }
                
                Section(header: sectionHeader("Other")) {
                    IpadMenuButton(
                        title: "Rate & Update",
                        icon: "star.fill",
                        action: { openURL("itms-apps://apple.com/app/idYOUR_APP_ID") }
                    )
                    
                    IpadMenuButton(
                        title: "Feedback",
                        icon: "envelope.fill",
                        action: { openURL("mailto:feedback@example.com") }
                    )
                    
                    IpadMenuButton(
                        title: "Privacy Policy",
                        icon: "lock.fill",
                        action: { openURL("https://breadandwinedevotional.com/privacy-policy") }
                    )
                }
            }
            .listStyle(.sidebar)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.vertical, 8)
    }
    
    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url)
        if sizeClass == .compact {
            columnVisibility = .detailOnly
        }
    }
}

struct MenuRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(isSelected ? .accentColor : .blue)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .primary : .secondary)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

struct IpadMenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
    }
}
