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
    
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    @State private var plainTextContent = ""
    @State private var isLoadingText = false
    
    private var bannerURL: URL? {
        guard let urlString = devotional.yoastHeadJson?.ogImage?.first?.url else { return nil }
        return URL(string: urlString)
    }
    
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
                    .onTapGesture {
                        // Stop speech when user interacts with content
                        speechSynthesizer.stop()
                    }
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
            ToolbarItem(placement: .primaryAction) {
                PlaybackControlView(
                    isSpeaking: speechSynthesizer.isSpeaking,
                    isDisabled: plainTextContent.isEmpty,
                    onPlayPause: handlePlayPause
                )
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [shareContent])
        }
        .onAppear(perform: loadContent)
        .onDisappear(perform: speechSynthesizer.stop)
//        .onAppear {
//            formatHTMLContent()
//        }
    }
    
    private func loadContent() {
        isLoadingText = true
        DispatchQueue.global(qos: .userInitiated).async {
            let combinedHTML = [
                "Welcome to the bread and wine devotional for",
                devotional.formattedDate,
                ";topic;",
                devotional.title.rendered,
                ";bible verse; ",
                devotional.acf?.bible_verse ?? "",
                devotional.content.rendered,
                ";further study;",
                devotional.acf?.further_study ?? "",
                ";prayer;",
                devotional.acf?.prayer ?? "",
                ";biible reading plan;",
                devotional.acf?.bible_reading_plan ?? "",
                ";thank you for listening..."
            ].joined(separator: ". ")  // Add natural pauses between sections
            
            let text = convertHTMLToPlainText(combinedHTML)
            
            DispatchQueue.main.async {
                plainTextContent = text
                isLoadingText = false
            }
        }
    }
    
    private func handlePlayPause() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.pause()
        } else {
            speechSynthesizer.speak(text: plainTextContent)
        }
    }
    
    private func convertHTMLToPlainText(_ html: String) -> String {
        guard let data = html.data(using: .utf8),
              let attributedString = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
              ) else {
            return html
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "&[^;]+;", with: "", options: .regularExpression)
        }
        
        return attributedString.string
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
