//
//  AIDisclosureView.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 16/04/2026.
//

import SwiftUI

struct AIDisclosureView: View {
    var body: some View {
        List {
            Section("App Development") {
                Text("""
                    Parts of this app were developed with the assistance of \
                    generative AI tools, including code generation, refactoring, \
                    and planning.
                    """)
            }

            Section("Data Aggregation") {
                Text("""
                    Generative AI tools were used to assist in aggregating and \
                    summarising information presented in this app. All \
                    AI-assisted content was subjected to manual human review \
                    before inclusion.
                    """)
                Text("""
                    As noted in the About section, the information provided is \
                    for informational purposes only and is offered on a \
                    best-effort basis. It may not be fully accurate, complete, \
                    or up-to-date.
                    """)
                    .foregroundStyle(.secondary)
            }

        }.navigationTitle("About Use of AI")
    }
}

#Preview {
    AIDisclosureView()
}
