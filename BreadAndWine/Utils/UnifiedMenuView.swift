//
//  MenuView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 03.04.25.
//
import SwiftUI

struct UnifiedMenuView: View {
    @Binding var selectedCategory: MenuItem?
    @Binding var showMenu: Bool
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Binding var columnVisibility: NavigationSplitViewVisibility
    
    private enum URLs {
        static let archives = "https://breadandwinedevotional.com/devotional/"
        static let social = "https://www.facebook.com/flarumuokwuta/"
        static let youtube = "https://www.youtube.com/@flarumuokwuta/streams"
        static let appStore = "itms-apps://apple.com/app/idYOUR_APP_ID"
        static let privacy = "https://breadandwinedevotional.com/privacy-policy"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Common Header
            HStack {
                Image("app-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, sizeClass == .regular ? 40 : 20)
            .padding(.horizontal)
            .background(ColorTheme.background.opacity(sizeClass == .regular ? 1 : 0))
            
            // Content based on device type
            if UIDevice.current.userInterfaceIdiom == .pad {
                ipadMenuContent
            } else {
                phoneMenuContent
            }
        }
        .background(ColorTheme.background)
//        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - iPad Layout
    private var ipadMenuContent: some View {
        List(selection: $selectedCategory) {
            Section(header: sectionHeader("Daily Devotion")) {
                NavigationLink(value: MenuItem.devotions) {
                    MenuRow(
                        title: "Bread and Wine",
                        icon: "book.fill",
                        isSelected: selectedCategory == .devotions
                    )
                }
                // Add Archives as URL button
                ipadMenuButton(
                    title: "Archives",
                    icon: "archivebox.fill",
                    url: URLs.archives
                )
            }
            
            socialSection
            liveStreamSection
            otherSection
        }
        .listStyle(.sidebar)
    }
    
    // New iPad-specific URL button builder
    private func ipadMenuButton(title: String, icon: String, url: String) -> some View {
        Button {
            openURL(url)
        } label: {
            MenuRow(title: title, icon: icon, isSelected: false)
        }
    }
    
    // MARK: - iPhone Layout
    private var phoneMenuContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Section(header: sectionHeader("Daily Devotional")) {
                    menuButton(title: "Bread and Wine", icon: "book.fill") {
                        selectedCategory = .devotions
                    }
                    menuButton(title: "Archives", icon: "archivebox.fill") {
                        openURL(URLs.archives)
                    }
                }
                
                socialSection
                liveStreamSection
                otherSection
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Reusable Components
    private func menuButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            if sizeClass != .regular { showMenu = false }
        }) {
            MenuRow(title: title, icon: icon)
        }
    }
    
    private var socialSection: some View {
        Section(header: sectionHeader("Social Handle")) {
            menuButton(title: "Firstlove Social", icon: "person.2.fill") {
                openURL(URLs.social)
            }
        }
    }
    
    private var liveStreamSection: some View {
        Section(header: sectionHeader("Live Stream")) {
            menuButton(title: "YouTube", icon: "play.rectangle.fill") {
                openURL(URLs.youtube)
            }
        }
    }
    
    private var otherSection: some View {
        Section(header: sectionHeader("Other")) {
            menuButton(title: "Rate & Update", icon: "star.fill") {
                openURL(URLs.appStore)
            }
            menuButton(title: "Feedback", icon: "envelope.fill") {
                openURL("mailto:feedback@example.com")
            }
            menuButton(title: "Privacy Policy", icon: "lock.fill") {
                openURL(URLs.privacy)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.vertical, 8)
            .padding(.top, 15)
    }
    
    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url)
    }
}

struct MenuRow: View {
    let title: String
    let icon: String
    var isSelected: Bool = false
    
    var body: some View {
        HStack(spacing: 5) {
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
