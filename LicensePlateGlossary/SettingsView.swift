//
//  SettingsScreen.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 10/07/2025.
//
import SwiftUI

struct SettingsView: View {
    @State private var isSettingsViewPresented: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section("About this app") {
                    Text("Version 0.0\n© 2025 Raphael Guntersweiler")
                }
            }.navigationTitle("Settings")
        }
    }
}
