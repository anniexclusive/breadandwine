//
//  DevotionalRow.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import SwiftUI
// Devotional Row for List
struct DevotionalRow: View {
    let devotional: Devotional
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(devotional.cleanTitle)
                .font(.headline)
            Text(devotional.formattedDate) // Uses root-level formatted date
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
