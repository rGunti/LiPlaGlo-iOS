//
//  RootScreen.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 10/07/2025.
//
import SwiftUI

struct RootScreen: View {
    @State private var updateCompletedVersion: String? = nil
    @AppStorage("autoCheckOnStartup") private var autoCheckOnStartup = true
    @AppStorage("otaUpdatesEnabled") private var otaUpdatesEnabled = false
    @AppStorage("hasAcceptedGitHubPrivacyPolicy") private var hasAcceptedPrivacyPolicy = false
    @AppStorage("pendingUpdateVersion") private var pendingUpdateVersion = ""

    var body: some View {
        TabView {
            Tab("Search", systemImage: "magnifyingglass") {
                SearchView()
            }
            Tab("Countries", systemImage: "flag") {
                CountryView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
            .badge(pendingUpdateVersion.isEmpty ? 0 : 1)
        }
        .id(DbManager.instance.reloadToken)
        .inAppSafari()
        .task {
            guard autoCheckOnStartup && otaUpdatesEnabled && hasAcceptedPrivacyPolicy else { return }
            let current = DbManager.instance.getDatabaseVersion().version
            if let release = try? await DatabaseUpdateService.checkForUpdate(currentVersion: current) {
                pendingUpdateVersion = release.version
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .databaseDidUpdate)) { note in
            updateCompletedVersion = note.object as? String
        }
        .alert("Database Updated", isPresented: .init(
            get: { updateCompletedVersion != nil },
            set: { if !$0 { updateCompletedVersion = nil } }
        )) {
            Button("OK", role: .cancel) { updateCompletedVersion = nil }
        } message: {
            if let v = updateCompletedVersion {
                Text("Database successfully updated to \(v).")
            }
        }
    }
}
