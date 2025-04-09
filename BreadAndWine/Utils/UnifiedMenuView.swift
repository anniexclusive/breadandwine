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
    @State private var showAboutAlert = false
    
    private enum URLs {
        static let archives = "https://breadandwinedevotional.com/devotional/"
        static let social = "https://www.facebook.com/flarumuokwuta/"
        static let youtube = "https://www.youtube.com/@flarumuokwuta/streams"
        static let appStore = "itms-apps://apple.com/app/idYOUR_APP_ID"
        static let privacy = "https://breadandwinedevotional.com/privacy-policy"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Content based on device type
            if UIDevice.current.userInterfaceIdiom == .pad {
                ipadMenuContent
            } else {
                logoArea
                phoneMenuContent
            }
        }
        .background(ColorTheme.background)
//        .edgesIgnoringSafeArea(.trailing)
    }
    
    private var logoArea: some View {
        HStack {
            Image("app-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, sizeClass == .regular ? 40 : 10)
        .padding(.bottom, sizeClass == .regular ? 0 : 20)
//        .padding(.horizontal)
    }
    
    // MARK: - iPad Layout
    private var ipadMenuContent: some View {
        List(selection: $selectedCategory) {
            logoArea
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
            Section {
                aboutButton
            }
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        .listStyle(.sidebar)
        .alert("About App", isPresented: $showAboutAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("""
                Bread and Wine Devotional \(Bundle.main.appVersion)
                
                © \(Calendar.current.component(.year, from: Date())) First Love Ministries. 
                All rights reserved.
                
                Contact: info@example.com
                """)
            }
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
            VStack(alignment: .leading, spacing: 15) {
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
                aboutButton
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            .padding(.top, 7)
        }
        .alert("About", isPresented: $showAboutAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("""
                Bread and Wine Devotional \(Bundle.main.appVersion)
                
                © \(Calendar.current.component(.year, from: Date())) Firstlove Assembly. 
                All rights reserved.
                
                Contact: info@example.com
                """)
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
                openURL("mailto:info@breadandwinedevotional.com")
            }
            menuButton(title: "Privacy Policy", icon: "lock.fill") {
                openURL(URLs.privacy)
            }
            menuButton(title: "Settings", icon: "gearshape.fill") {
                selectedCategory = .settings
            }
        }
    }
    
    // MARK: - Helper Functions
    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.vertical, 8)
            .padding(.top, 7)
    }
    
    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url)
    }
    
    private var aboutButton: some View {
        Button {
            showAboutAlert = true
        } label: {
            Text("About")
                .font(.system(size: 16, weight: .medium))
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .background(Color.clear)
                .foregroundColor(ColorTheme.accentPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ColorTheme.textPrimary, lineWidth: 1)
                )
        }
        .padding(.vertical, 6)
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
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

// Add this extension for version number
extension Bundle {
    var appVersion: String {
        return (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }
}
