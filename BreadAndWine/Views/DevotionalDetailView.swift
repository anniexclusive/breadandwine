//
//  DevotionalDetailView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// Devotional Detail View
struct DevotionalDetailView: View {
    let devotional: Devotional
    @Environment(\.colorScheme) var colorScheme
    @State private var showingShareSheet = false
    @State private var webViewHeight: CGFloat = 0
    
    private var bannerURL: URL? {
        guard let urlString = devotional.yoastHeadJson?.ogImage?.first?.url else { return nil }
        return URL(string: urlString)
    }
//    @State private var formattedContent = NSAttributedString()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                bannerSection // banner image 
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(devotional.title.rendered)
                            .font(.title2)
                            .bold()
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Text(devotional.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    .padding()
//                }
//                .padding()
//                .background(Color.theme.background)
//                .cornerRadius(12)
//                .padding(.horizontal)
                
                Divider()
                
                if let verse = devotional.acf?.bible_verse {
                    infoBox(title: "Bible verse", value: verse, icon: "book.fill")
                }
                // HTML content section (replaces Text(content.rendered))
                    
                GeometryReader { proxy in
                    HTMLStringView(
                        htmlContent: devotional.content.rendered,
                        contentHeight: $webViewHeight,
                        containerWidth: proxy.size.width  // Pass current width
                    )
                    .frame(height: webViewHeight)
                    .background(ColorTheme.background)
                }
                .frame(height: webViewHeight)
//                DevotionalContentView(htmlContent: devotional.content.rendered ?? "")
                
                if let acf = devotional.acf {
                    VStack(alignment: .leading, spacing: 20) {
                        if let verse = acf.further_study {
                            infoBox(title: "Further study", value: verse, icon: "book.fill")
                        }
                        
                        if let prayer = acf.prayer {
                            infoBox(title: "Prayer", value: prayer, icon: "hands.sparkles.fill")
                        }
                        
                        if let verse = acf.bible_reading_plan {
                            infoBox(title: "Bible reading plan", value: verse, icon: "book.fill")
                        }
                    }
                    
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                } 
                
//                Text(formattedContent.string)
//                    .font(.body)
//                    .foregroundColor(Color.theme.textPrimary)
//                    .lineSpacing(8)
//                    .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(ColorTheme.background)
        .navigationBarTitle(devotional.cleanTitle, displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(ColorTheme.accentPrimary)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [shareContent])
        }
//        .onAppear {
//            formatHTMLContent()
//        }
    }
    
    private var shareContent: String {
        let title = devotional.title.rendered
        let content = devotional.content.rendered.stripHTMLTags().trimmingCharacters(in: .whitespacesAndNewlines)
        // Create URL-safe slug from title
        let titleSlug = title
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "[^-a-z0-9-]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let urlString = "https://breadandwinedevotional.com/devotional/\(titleSlug)/"
        
        return """
        \(title)
        
        \(String(content.prefix(300)))...
        
        Read more: \(urlString)
        """
    }
    
    // MARK: - Banner Section
    private var bannerSection: some View {
        Group {
            if let url = bannerURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        progressView
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipped()
//                            .cornerRadius(12)
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
    }
    
    private var progressView: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .background(Color(.systemGroupedBackground))
    }
        
    private var placeholderImage: some View {
        Image(systemName: "book.closed.fill")
            .resizable()
            .scaledToFit()
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .foregroundColor(.secondary.opacity(0.3))
            .background(Color(.systemGroupedBackground))
    }
    
    private func infoBox(title: String, value: String, icon: String) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(ColorTheme.accentPrimary)
                
                Text(value)
                    .font(.body)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(ColorTheme.background)
            .cornerRadius(8)
        }
    
//    private func formatHTMLContent() {
//        if let htmlContent = devotional.content.rendered, !htmlContent.isEmpty {
//            HTMLStringView(htmlContent: htmlContent)
//                .frame(height: UIScreen.main.bounds.height) // Adjust as needed
//        } else {
//            Text("Error loading content.")
//                .frame(maxWidth: .infinity)
//        }
//    }
}
