//
//  SafariSheet.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 16/04/2026.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

private let excludedHosts: Set<String> = [
    "maps.apple.com",
    "maps.apple"
]

private struct InAppSafariModifier: ViewModifier {
    @State private var safariURL: URL?

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                guard (url.scheme == "http" || url.scheme == "https"),
                      !excludedHosts.contains(url.host ?? "") else {
                    return .systemAction
                }
                safariURL = url
                return .handled
            })
            .sheet(isPresented: Binding(
                get: { safariURL != nil },
                set: { if !$0 { safariURL = nil } }
            )) {
                if let url = safariURL {
                    SafariView(url: url)
                }
            }
    }
}

extension View {
    func inAppSafari() -> some View {
        modifier(InAppSafariModifier())
    }
}
