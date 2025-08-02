//
//  RegionalIdentifierGroup.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 22/07/2025.
//

import SwiftUI

struct RegionalIdentifierList: View {
    let type: PlateIdentifierType
    let identifiers: [PlateIdentifier]
    let country: Country
    let plateFont: String
    
    @State var searchResults: [PlateIdentifier] = []
    @State var searchQuery: String = ""
    
    init(type: PlateIdentifierType, country: Country) {
        self.type = type
        self.country = country
        self.identifiers = DbManager.instance.getIdentifiers(forCountry: type.countryId, ofType: type.id)
        self.plateFont = country.defaultFont ?? "HelveticaNeue-CondensedBold"
    }

    var isSearching: Bool {
        return !searchQuery.isEmpty
    }
    
    var body: some View {
        List {
            ForEach(isSearching ? searchResults : identifiers, id: \.id) { identifier in
                NavigationLink {
                    RegionalIdentifierDetails(country: country, regionalIdentifierType: type, regionalIdentifier: identifier)
                } label: {
                    GeometryReader { geo in
                        HStack(alignment: .firstTextBaseline) {
                            Text(
                                identifier.identifier
                            )
                            .font(.custom(self.plateFont, size: 20))
                            .frame(
                                width: geo.size.width * 0.2,
                                height: geo.size.height)
                            Text(getTranslatedStringWithFormatting(identifier.name))
                                .frame(
                                    width: geo.size.width * 0.8,
                                    height: geo.size.height,
                                    alignment: .leading)
                        }
                    }
                }
            }
        }
        .navigationTitle(getTranslatedString(type.name))
        .searchable(
            text: $searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search by identifier or name"
         )
        .textInputAutocapitalization(.never)
        .onChange(of: searchQuery) {
            self.fetchSearchResults(for: searchQuery)
        }
        .overlay {
            if isSearching && searchResults.isEmpty {
                Text(
                    "Couldn't find any matching \(getTranslatedString(type.name))"
                )
            }
        }
    }

    private func fetchSearchResults(for query: String) {
        searchResults = identifiers.filter { product in
            product.identifier
                .lowercased()
                .contains(searchQuery)
            || getTranslatedString(product.name)
                .lowercased()
                .contains(searchQuery)
        }
    }
}

#Preview {
    RegionalIdentifierList(
        type: PlateIdentifierType(
            id: 9999999,
            countryId: "XX",
            name: "cantons"
        ),
        country: Country(
            id: "XX",
            name: "country_xx",
            flagEmoji: "🏳️",
            defaultFont: "Swiss License Plates",
            //genericPreview: "AB : CD 1234"
            genericPreview: "XX·123 456",
            description: "raw:**Hello** _World_",
            vanityPlatesPossible: true,
            vanityPlatesDescription: "raw: **Some** _Text_",
            hidden: false
        )
    )
}
