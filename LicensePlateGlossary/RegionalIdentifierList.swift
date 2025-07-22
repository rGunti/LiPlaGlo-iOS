//
//  RegionalIdentifierGroup.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 22/07/2025.
//

import SwiftUI

struct RegionalIdentifierList: View {
    let type: RegionalIdentifierType
    let identifiers: [RegionalIdentifier]
    let country: Country
    let plateFont: String
    
    init(type: RegionalIdentifierType, country: Country) {
        self.type = type
        self.country = country
        self.identifiers = DbManager.instance.getRegionalIdentifiers(forCountry: type.countryId, ofType: type.id)
        self.plateFont = country.defaultFont ?? "HelveticaNeue-CondensedBold"
    }
    
    var body: some View {
        ForEach(identifiers, id: \.id) { identifier in
            NavigationLink {
                Text("not implemented")
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
}

#Preview {
    RegionalIdentifierGroup(
        type: RegionalIdentifierType(
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
            vanityPlatesDescription: "raw: **Some** _Text_"
        )
    )
}
