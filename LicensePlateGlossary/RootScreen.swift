//
//  RootScreen.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 10/07/2025.
//
import SwiftUI

struct RootScreen: View {
    var body: some View {
        TabView {
            Tab("Countries", systemImage: "flag") {
                CountryView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
    }
}
