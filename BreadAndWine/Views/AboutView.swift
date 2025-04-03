//
//  AboutView.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 02.04.25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme
    let aboutContent = """
    <p>Bread and Wine Devotional, is a daily devotional publication of Simeon AFOLABI, the Serving Overseer of FIRSTLOVE ASSEMBLY (formerly Revival Peoples Church), in Nigeria.</p>

<p>When Abram returned from battle, Melchizedek offered him Bread and Wine, and blessed him. This is symbolic. On the one hand it provided the much needed refreshing for battle-weary officers and men; and on the other hand it was an express token of communion and friendship. This encounter between Abram and Melchizedek provides the conceptual framework for this devotional.</p> 

 <p>As believers, we are constantly engaged in spiritual battles (known and unknown; seen and unseen) either over our own lives or those of our loved ones and other interests. We need no less a refreshing from Jesus our High Priest.</p>
<p>At some point Jesus referred to the disciples as friends. This is the same enviable position that every believer has come into. How do we oil the wheel of friendship? Principally, it’s by dining and wining with Him, spiritually.</p>
<p>Dining and wining occurs in an atmosphere of devotion, studying, singing, and praying – and this is what Bread and Wine Devotional is set out to do.</p>
<p>Since January 2005 when the maiden edition of Bread and Wine Devotional (print format) was launched, thousands of people have been enriched through its contents.</p>
<p>The approach over the years is to situate contemporary issues within the provisions of the Word of God. Each entry is well researched to produce inspirational materials that are Bible based. </p>
<p>The goal of the writer is to see what you behold on this blog drive you into a deeper understanding of the way of God.</p>
<p>In the devotional posts contained within this app, you will find materials to strengthen you to press on in the many challenges of your life’s pilgrimage and enough clues to deepen your walk with God.</p>
<p>Bread and Wine Devotional is not designed to be a cure-all spiritual capsule or an all-inclusive material. Rather it is to jump-start you to seek for more of God personally. </p>
<p>Study it daily, and use the leads you find here for prayers and further studies. And remember to share it with others.</p>

 <p>&nbsp;</p>

God bless you.<br/>

Simeon Afolabi
"""
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "book.closed.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(ColorTheme.accentPrimary)
                
                VStack(alignment: .leading) {
                    Text("About Bread and Wine Devotional")
                        .font(.title2)
                        .bold()
                        .foregroundColor(ColorTheme.textPrimary)
                }
            }
            .padding()
            .background(ColorTheme.background)
            .cornerRadius(12)
            .padding(.horizontal)
            
            Divider()
            
            HTMLWebView(html: aboutContent)
                .frame(maxWidth: .infinity, minHeight: 600)
        }
        
        
    }
}
