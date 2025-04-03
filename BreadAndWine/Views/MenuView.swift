//
//  MenuView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 03.04.25.
//
import SwiftUI

struct MenuView: View {
    @Binding var showMenu: Bool
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading) {
                Text("Navigation")
                    .font(.title2.bold())
                    .padding(.bottom, 8)
                Divider()
            }
            .padding(.top, 40)
            .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Daily Devotional Section
                    Section(header: sectionHeader("Daily Devotional")) {
                        MenuButton(
                            title: "Bread and Wine",
                            icon: "book.fill",
                            action: {
                                selectedTab = 0
                                showMenu = false
                            }
                        )
                    }
                    
                    // Social Handle Section
                    Section(header: sectionHeader("Social Handle")) {
                        MenuButton(
                            title: "Firstlove Social",
                            icon: "person.2.fill",
                            action: {
                                openURL("https://www.facebook.com/flarumuokwuta/")
                            }
                        )
                    }
                    
                    // Live Stream Section
                    Section(header: sectionHeader("Live Stream")) {
                        MenuButton(
                            title: "YouTube",
                            icon: "play.rectangle.fill",
                            action: {
                                openURL("https://www.youtube.com/@flarumuokwuta/streams")
                            }
                        )
                    }
                    
                    // Other Section
                    Section(header: sectionHeader("Other")) {
                        MenuButton(
                            title: "Rate & Update",
                            icon: "star.fill",
                            action: {
                                openURL("itms-apps://apple.com/app/idYOUR_APP_ID")
                            }
                        )
                        
                        MenuButton(
                            title: "Feedback",
                            icon: "envelope.fill",
                            action: {
                                openURL("mailto:feedback@example.com")
                            }
                        )
                        
                        MenuButton(
                            title: "Privacy Policy",
                            icon: "lock.fill",
                            action: {
                                openURL("https://breadandwinedevotional.com/privacy-policy")
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
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
        showMenu = false
    }
}

struct MenuButton: View {
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
