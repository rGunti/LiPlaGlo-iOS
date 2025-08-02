//
//  LicenseView.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 02/08/2025.
//

import SwiftUI

struct LicenseView: View {
    var body: some View {
        List {
            Text("""
                This software would not have been possible without the work of others.
                Find below a list of projects that are used within this app.
                
                Thanks to all these projects!
                """)

            Section("Data") {
                Text("""
                    The data provided in this app is sourced from the following sources (if not stated otherwise).
                    """)

                
                LicenseTextView(
                    title: "Wikipedia",
                    url: URL(string: "https://wikipedia.org")!,
                    bodyText:
                        """
                        Text snippets were sourced from the relevant Wikipedia articles to provide a small text description for how countries implement their vehicle registration procedures or how vanity plates can be acquired.
                        """
                )
                LicenseTextView(
                    title: "openpotato/kfz-kennzeichen",
                    url: URL(string: "https://github.com/openpotato/kfz-kennzeichen/tree/main")!,
                    withBodyTextFrom: "openpotato-kfz-kennzeichen.txt"
                )
            }
            
            Section("Software") {
                Text("""
                    This app was built with software components built by other developers and provided to others free of charge.
                    """)
                LicenseTextView(
                    title: "SQLite.swift",
                    url: URL(string: "https://github.com/stephencelis/SQLite.swift")!,
                    withBodyTextFrom: "SQLite.txt"
                )
                LicenseTextView(
                    title: "swift-toolchain-sqlite",
                    url: URL(string: "https://github.com/swiftlang/swift-toolchain-sqlite")!,
                    withBodyTextFrom: "swift-toolchain-sqlite.txt"
                )
            }
        }.navigationTitle("Licenses & Attribution")
    }
}

#Preview {
    LicenseView()
}
