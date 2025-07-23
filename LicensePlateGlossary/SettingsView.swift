//
//  SettingsScreen.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 10/07/2025.
//
import SwiftUI

struct SettingsView: View {
    let currentYear = Calendar.current.component(.year, from: Date()).description
    let appVersion = getAppVersion()
    let appBuild = getBuildNumber()
    
    var body: some View {
        NavigationStack {
            List {
                Section("About this app") {
                    KeyValueRow(
                        key: "App Version",
                        value: "Ver. \(appVersion) (\(appBuild))"
                    )
                    Text("© \(currentYear), Raphael Guntersweiler")
                    Text("The information provided in this app is purely for informational purposes only and does not claim to be accurate, complete, or up-to-date. **THIS APP DOES NOT CONTAIN LEGAL ADVISE!**\n\nMost information is sourced from aggregation sites like Wikipedia and is provided under their respective license.\n\nPlease note that I am not affiliated with any of the organizations or brands mentioned in this app.")
                }
                
                Section("Debug") {
                    KeyValueRow(
                        key: "Language",
                        value: Locale.current.language.languageCode?.identifier ?? "n/a")
                    NavigationLink {
                        I18nDebugList()
                    } label: {
                        Text("Translations")
                    }
                }
            }.navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
