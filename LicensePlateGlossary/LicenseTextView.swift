//
//  LicenseTextView.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 02/08/2025.
//

import SwiftUI

struct LicenseTextView: View {
    let title: String
    let url: URL?
    let bodyText: String
    
    init(title: String, url: URL?, bodyText: String) {
        self.title = title
        self.url = url
        self.bodyText = bodyText
    }
    
    init(title: String, url: URL?, withBodyTextFrom bodyFile: String) {
        self.title = title
        self.url = url
        
        let bodyTextFileLink = Bundle.main.path(forResource: bodyFile, ofType: "")
        if let textFileLink = bodyTextFileLink {
            do {
                let content = try String(contentsOfFile: textFileLink, encoding: .utf8)
                self.bodyText = content
            } catch {
                self.bodyText = "Failed to read \(bodyFile)"
            }
        } else {
            self.bodyText = "Failed to read \(bodyFile) (invalid path)"
        }
    }
    
    var body: some View {
        NavigationLink {
            List {
                if let itemUrl = url {
                    Link(destination: itemUrl) {
                        Label("Visit project page", systemImage: "link")
                    }
                }
                
                Text(LocalizedStringKey(bodyText))
                    .font(.footnote)
            }.navigationTitle(title)
        } label: {
            Label(title, systemImage: "text.document")
        }
    }
}

#Preview {
    LicenseTextView(
        title: "Example Project",
        url: URL(string: "https://example.com")!,
        withBodyTextFrom: "swift-toolchain-sqlite.txt"
    )
}
