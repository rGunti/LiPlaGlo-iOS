//
//  RootScreen.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 10/07/2025.
//
import SwiftUI

struct RootScreen: View {
    @State private var updateCompletedVersion: String? = nil

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
        }
        .id(DbManager.instance.reloadToken)
        .inAppSafari()
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
