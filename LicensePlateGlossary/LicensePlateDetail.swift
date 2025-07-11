//
//  LicensePlateDetail.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 10/07/2025.
//

import SwiftUI

struct LicensePlateDetail: View {
    private var item: GenericLicensePlateRecord
    @State private var showSafari = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Pattern") {
                    Text(self.item.pattern)
                        .font(.custom("Swiss License Plates", size: 48))
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if !self.item.inUse {
                    Section("Not in use") {
                        Text("This license plate is no longer in use")
                    }
                }

                if let remarks = self.item.remarks {
                    Section("Remarks") {
                        Text(remarks)
                    }
                }
                if let links = self.item.links {
                    Section("Links") {
                        ForEach(links, id: \.self.url) { item in
                            Link(item.text ?? item.url, destination: URL(string: item.url)!)
                        }
                    }
                }
            }.navigationTitle(self.item.title)
        }
    }
    
    init(item: GenericLicensePlateRecord) {
        self.item = item
    }
}

#Preview {
    LicensePlateDetail(
        item: GenericLicensePlateRecord(identifier: "XX", title: "Demo", remarks: "Some remarks that I used to now", inUse: false, pattern: "XX 000 000", links: [LicensePlateLink(text: "example.com", url: "https://example.com/some-link"), LicensePlateLink(text: nil, url: "https://example.com/unlabelled")])
    )
}
