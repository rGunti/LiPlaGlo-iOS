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
    let dbVersion = DbManager.instance.getDatabaseVersion()
    let dbBuildDate = DbManager.instance.getDatabaseBuildDate()
    
    var body: some View {
        NavigationStack {
            List {
                Section("About this app") {
                    KeyValueRow(
                        key: "App Version",
                        value: "Ver. \(appVersion) (\(appBuild))",
                        systemImage: "app"
                    )
                    KeyValueRow(
                        key: "Database Version",
                        value: dbVersion.version,
                        systemImage: "cylinder"
                    )
                    if let date = dbBuildDate {
                        KeyValueRow(
                            key: String(localized: "Last updated at"),
                            value: date.formatted(date: .long, time: .omitted),
                            systemImage: "calendar"
                        )
                    }
                    Text("© \(currentYear), Raphael Guntersweiler")
                    Text("The information provided in this app is purely for informational purposes only and does not claim to be accurate, complete, or up-to-date. **THIS APP DOES NOT CONTAIN LEGAL ADVISE!**\n\nMost information is sourced from aggregation sites like Wikipedia and is provided under their respective license.\n\nPlease note that I am not affiliated with any of the organizations or brands mentioned in this app.")
                    NavigationLink {
                        LicenseView()
                    } label: {
                        Label(
                            "Licenses & Attribution",
                            systemImage: "pencil.and.list.clipboard"
                        )
                    }
                }

                Section("Generative AI") {
                    Text("Parts of this app were developed with the assistance of generative AI tools. This app does not feature any AI tools itself.")
                    NavigationLink {
                        AIDisclosureView()
                    } label: {
                        Label(
                            "About Use of AI",
                            systemImage: "sparkles"
                        )
                    }
                }

#if DEBUG
                Section("Debug") {
                    KeyValueRow(
                        key: "Language",
                        value: Locale.current.language.languageCode?.identifier ?? "n/a",
                        systemImage: "globe")
                    NavigationLink {
                        I18nDebugList()
                    } label: {
                        Label("Translations", systemImage: "character.bubble")
                    }
                }
#endif
            }.navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
