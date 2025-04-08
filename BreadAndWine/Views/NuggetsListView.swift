//
//  NuggetsListView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 04.04.25.
//
import SwiftUI

struct NuggetsListView: View {
    @ObservedObject var viewModel: DevotionalViewModel
    
    var nuggets: [Devotional] {
        viewModel.devotionals.filter { $0.acf?.nugget?.isEmpty == false }
    }
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading && viewModel.devotionals.isEmpty {
                    ProgressView("Loading devotionals...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
                
                ForEach(viewModel.devotionals) { devotional in
                    if let nugget = devotional.acf?.nugget {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(devotional.formattedDate, systemImage: "lightbulb")
                                .font(.headline)
                                .foregroundColor(ColorTheme.accentPrimary)
                            
                            Text(nugget)
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(ColorTheme.background)
                        .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Nuggets")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                viewModel.fetchDevotionals()
            }
            .background(ColorTheme.background)
        }
    }
}
