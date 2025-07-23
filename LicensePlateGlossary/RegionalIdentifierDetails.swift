//
//  RegionalIdentifierDetails.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 22/07/2025.
//

import SwiftUI

struct RegionalIdentifierDetails: View {
    let country: Country
    let regionalIdentifierType: RegionalIdentifierType
    let regionalIdentifier: RegionalIdentifier
    
    init(country: Country, regionalIdentifierType: RegionalIdentifierType, regionalIdentifier: RegionalIdentifier) {
        self.country = country
        self.regionalIdentifierType = regionalIdentifierType
        self.regionalIdentifier = regionalIdentifier
    }
    
    var body: some View {
        List {
            LicensePlatePreview(
                fromCountry: self.country,
                withCustomText: self.regionalIdentifier.identifier
            )
            
            Section {
                Button {
                    openSearchQueryOnMaps(query: getTranslatedString(regionalIdentifier.name))
                } label: {
                    Label("Search on Maps", systemImage: "map")
                }
            }
        }
        .navigationTitle(getTranslatedString(regionalIdentifier.name))
    }
}

#Preview {
    RegionalIdentifierDetails(
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
        ),
        regionalIdentifierType: RegionalIdentifierType(
            id: 9999999,
            countryId: "XX",
            name: "cantons"
        ),
        regionalIdentifier: RegionalIdentifier(
            id: 9999999,
            countryId: "XX",
            typeId: 9999999,
            identifier: "YY",
            name: "raw:Sample Canton",
            description: "raw:Some **Text**"
        )
    )
}
