//
//  DatabaseUpdateView.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 27/04/2026.
//
import SwiftUI

struct DatabaseUpdateView: View {
    @State private var dbVersion = DbManager.instance.getDatabaseVersion()
    @State private var dbBuildDate = DbManager.instance.getDatabaseBuildDate()
    @State private var availableUpdate: GitHubRelease? = nil
    @State private var isCheckingForUpdates = false
    @State private var isDownloading = false
    @State private var updateError: String? = nil
    @State private var isUserDbActive = DatabaseUpdateService.isUserDatabaseInstalled()
    @State private var showRollbackConfirm = false
    @AppStorage("otaUpdatesEnabled") private var otaUpdatesEnabled = false
    @AppStorage("hasAcceptedGitHubPrivacyPolicy") private var hasAcceptedPrivacyPolicy = false
    @AppStorage("autoCheckOnStartup") private var autoCheckOnStartup = true
    @AppStorage("pendingUpdateVersion") private var pendingUpdateVersion = ""
    @State private var showPrivacyConsent = false

    var body: some View {
        List {
            Section("Installed") {
                KeyValueRow(
                    key: "Version",
                    value: dbVersion.version,
                    systemImage: "cylinder"
                )
                if let date = dbBuildDate {
                    KeyValueRow(
                        key: String(localized: "Last updated at"),
                        value: date.formatted(date: .abbreviated, time: .omitted),
                        systemImage: "calendar"
                    )
                }
                if isUserDbActive {
                    Button {
                        showRollbackConfirm = true
                    } label: {
                        Label("Revert to bundled database", systemImage: "arrow.uturn.backward.circle")
                    }
                }
            }

            Section {
                Toggle("Check for Database Updates online", isOn: Binding(
                    get: { otaUpdatesEnabled },
                    set: { newValue in
                        if newValue && !hasAcceptedPrivacyPolicy {
                            showPrivacyConsent = true
                        } else {
                            otaUpdatesEnabled = newValue
                            if !newValue {
                                hasAcceptedPrivacyPolicy = false
                            }
                        }
                    }
                ))
                
                if otaUpdatesEnabled {
                    Toggle("Check for Updates on Startup", isOn: $autoCheckOnStartup)
                        .disabled(!hasAcceptedPrivacyPolicy)
                }
            } header: {
                Text("Updates")
            } footer: {
                Text("Database updates add new countries, plate variants, and regional identifiers, keeping the information in this app accurate and up to date.")
            }

            if otaUpdatesEnabled {
                Section("Available Update") {
                    if isCheckingForUpdates {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 4)
                            Text("Checking for updates…")
                                .foregroundStyle(.secondary)
                        }
                    } else if isDownloading {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 4)
                            Text("Downloading…")
                                .foregroundStyle(.secondary)
                        }
                    } else if let update = availableUpdate {
                        if let notes = update.body, !notes.isEmpty {
                            ReleaseNotesView(markdown: notes)
                        }
                        Button {
                            Task { await downloadUpdate() }
                        } label: {
                            Label("Update to \(update.tagName)", systemImage: "arrow.down.circle")
                        }
                        if let url = update.releasePageURL {
                            Link(destination: url) {
                                Label("View release on GitHub", systemImage: "safari")
                            }
                        }
                    } else {
                        Label("Database is up to date.", systemImage: "checkmark.circle")
                            .foregroundStyle(.secondary)
                    }
                    if let error = updateError {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }

            Section {
                Link(destination: URL(string: "https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement")!) {
                    Label("GitHub Privacy Policy", systemImage: "hand.raised")
                }
            } footer: {
                Text("Database updates are fetched from GitHub. GitHub's privacy policy applies when checking for or downloading updates.")
            }
        }
        .navigationTitle("Database")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Revert to bundled database?",
            isPresented: $showRollbackConfirm,
            titleVisibility: .visible
        ) {
            Button("Revert", role: .destructive) { rollbackDatabase() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The downloaded database will be deleted. You can download it again at any time.")
        }
        .alert("GitHub Privacy Policy", isPresented: $showPrivacyConsent) {
            Button("Accept & Enable") {
                hasAcceptedPrivacyPolicy = true
                otaUpdatesEnabled = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Checking for and downloading database updates connects to GitHub. GitHub's privacy policy applies. See the link below for details.")
        }
        .onAppear {
            pendingUpdateVersion = ""
        }
        .task(id: otaUpdatesEnabled) {
            guard otaUpdatesEnabled else { return }
            isCheckingForUpdates = true
            defer { isCheckingForUpdates = false }
            availableUpdate = try? await DatabaseUpdateService.checkForUpdate(
                currentVersion: dbVersion.version
            )
        }
    }

    private func rollbackDatabase() {
        do {
            try DatabaseUpdateService.removeUserDatabase()
            dbVersion = DbManager.instance.getDatabaseVersion()
            dbBuildDate = DbManager.instance.getDatabaseBuildDate()
            isUserDbActive = false
            updateError = nil
        } catch {
            updateError = error.localizedDescription
        }
    }

    private func downloadUpdate() async {
        guard let release = availableUpdate, let asset = release.dbAsset else { return }
        guard let downloadURL = URL(string: asset.browserDownloadUrl) else { return }
        isDownloading = true
        updateError = nil
        defer { isDownloading = false }
        do {
            let tempURL = try await DatabaseUpdateService.downloadDatabase(from: downloadURL)
            try DatabaseUpdateService.installDatabase(from: tempURL)
            isUserDbActive = true
            availableUpdate = nil
        } catch {
            updateError = error.localizedDescription
        }
    }
}

// MARK: - Release Notes Renderer

private struct ReleaseNotesView: View {
    let markdown: String

    private enum Block: Identifiable {
        case heading(level: Int, text: String)
        case bullet(indent: Int, text: String)
        case orderedItem(number: String, text: String)
        case divider
        case spacer
        case paragraph(text: String)

        var id: String {
            switch self {
            case .heading(let l, let t): return "h\(l):\(t)"
            case .bullet(let i, let t): return "b\(i):\(t)"
            case .orderedItem(let n, let t): return "o\(n):\(t)"
            case .divider: return "div:\(UUID())"
            case .spacer: return "sp:\(UUID())"
            case .paragraph(let t): return "p:\(t)"
            }
        }
    }

    private var blocks: [Block] {
        let lines = markdown
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n")

        var result: [Block] = []
        var prevWasEmpty = true

        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !prevWasEmpty { result.append(.spacer) }
                prevWasEmpty = true
                continue
            }
            prevWasEmpty = false

            // Headings
            if line.hasPrefix("### ") {
                result.append(.heading(level: 3, text: String(line.dropFirst(4))))
            } else if line.hasPrefix("## ") {
                result.append(.heading(level: 2, text: String(line.dropFirst(3))))
            } else if line.hasPrefix("# ") {
                result.append(.heading(level: 1, text: String(line.dropFirst(2))))
            }
            // Dividers
            else if line == "---" || line == "***" || line == "___" {
                result.append(.divider)
            }
            // Bullets (with optional indent)
            else if let match = line.firstMatch(of: /^(\s*)[*\-+] (.+)$/) {
                let indent = match.output.1.count / 2
                result.append(.bullet(indent: indent, text: String(match.output.2)))
            }
            // Ordered list
            else if let match = line.firstMatch(of: /^(\d+)[.)]\s+(.+)$/) {
                result.append(.orderedItem(number: String(match.output.1) + ".", text: String(match.output.2)))
            }
            // Paragraph
            else {
                result.append(.paragraph(text: line))
            }
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Patch Notes")
                .font(.headline)
                .padding(.top, 4)
                .padding(.bottom, 2)
            ForEach(blocks) { block in
                blockView(for: block)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func blockView(for block: Block) -> some View {
        switch block {
        case .heading(let level, let text):
            Text(LocalizedStringKey(text))
                .font(level == 1 ? .headline : level == 2 ? .subheadline : .callout)
                .fontWeight(.bold)
                .padding(.top, level <= 2 ? 8 : 4)
                .padding(.bottom, 2)
        case .bullet(let indent, let text):
            HStack(alignment: .top, spacing: 6) {
                Text(indent > 0 ? "◦" : "•")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.leading, CGFloat(indent) * 12)
                Text(LocalizedStringKey(text))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 1)
        case .orderedItem(let number, let text):
            HStack(alignment: .top, spacing: 6) {
                Text(number)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 20, alignment: .trailing)
                Text(LocalizedStringKey(text))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 1)
        case .divider:
            Divider()
                .padding(.vertical, 6)
        case .spacer:
            Color.clear.frame(height: 8)
        case .paragraph(let text):
            Text(LocalizedStringKey(text))
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.vertical, 1)
        }
    }
}

#Preview {
    NavigationStack {
        DatabaseUpdateView()
    }
}
