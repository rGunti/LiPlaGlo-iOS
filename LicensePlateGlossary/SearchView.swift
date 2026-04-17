//
//  SearchView.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 26/12/2025.
//
import Foundation
import SwiftUI

struct SearchView: View {
    let countries = DbManager.instance.getCountries()
    
    @State private var selectedCountry: String = ""
    @State private var prefix: String = ""
    @State private var searchText: String = ""
    @State private var searchResults: [PlateIdentifier] = []
    @State private var allIdentifiers: [PlateIdentifier] = []
    @State private var hasSearched: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Search Filters")) {
                    Picker("Country", selection: $selectedCountry) {
                        ForEach(countries, id: \.id) { country in
                            Text("\(country.flagEmoji.map { $0 + " " } ?? "")\(country.id) · \(getTranslatedString(country.name))")
                        }
                    }
                    TextField("Prefix", text: $prefix)
                        .accessibilityLabel("Search by identifier")
                    TextField("Name", text: $searchText)
                        .accessibilityLabel("Search by name")
                    Button(action: { performSearch() }) {
                        Text("Search")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowInsets(EdgeInsets())
                }
                Section(header: Text("Results")) {
                    if hasSearched {
                        if searchResults.isEmpty {
                            Text("No results found.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(searchResults, id: \.identifier) { identifier in
                                VStack(alignment: .leading) {
                                    Text(identifier.identifier)
                                    TranslatedText(identifier.name)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .onAppear {
                if selectedCountry.isEmpty && !countries.isEmpty {
                    selectedCountry = countries[0].id
                }
                if !selectedCountry.isEmpty {
                    allIdentifiers = DbManager.instance.getIdentifiers(forCountry: selectedCountry)
                }
            }
            .onChange(of: selectedCountry) { oldValue, newValue in
                allIdentifiers = DbManager.instance.getIdentifiers(forCountry: newValue)
                searchResults = []
                hasSearched = false
                prefix = ""
                searchText = ""
            }
        }
    }
    
    private func performSearch() {
        hasSearched = true
        var filtered = allIdentifiers
        
        if !prefix.isEmpty {
            filtered = filtered.filter { $0.identifier.lowercased().starts(with: prefix.lowercased()) }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { identifier in
                identifier.identifier.lowercased().contains(searchText.lowercased()) ||
                getTranslatedString(identifier.name).lowercased().contains(searchText.lowercased())
            }
        }
        
        searchResults = filtered
    }
}

#Preview {
    SearchView()
}

