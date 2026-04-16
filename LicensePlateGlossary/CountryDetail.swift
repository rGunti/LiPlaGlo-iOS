//
//  CountryDetail.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 12/07/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct CountryDetail: View {
    let country: Country
    let links: [CountryLink]
    let plateVariants: [PlateVariant]
    let identifierTypes: [PlateIdentifierType]

    init(country: Country) {
        self.country = country
        self.links = DbManager.instance.getLinksForCountry(country.id, forLanguage: getCurrentLanguage(withFallback: defaultFallbackLanguage))
        self.plateVariants = DbManager.instance.getPlateVariantsForCountry(country.id)
        self.identifierTypes =
            DbManager.instance.getIdentifierTypes(forCountry: country.id)
    }
    
    var body: some View {
        List {
            if country.genericPreview != nil {
                Section("Generic License Plate Layout") {
                    LicensePlatePreview(
                        fromCountry: country,
                        withPlateTextSize: 45
                    )
                }
            }
            
            if let description = country.description {
                Section("Description") {
                    Text(getTranslatedStringWithFormatting(description))
                }
            }

            if let vanityPlatesPossible = country.vanityPlatesPossible {
                Section("Vanity Plates") {
                    if vanityPlatesPossible, let vanityPlatesDescription = country.vanityPlatesDescription {
                        Text(getTranslatedStringWithFormatting(vanityPlatesDescription))
                    } else if vanityPlatesPossible {
                        Text("Vanity plates are available for this country.")
                    } else {
                        Text("Vanity plates are not available for this country.")
                    }
                }
            }
            
            if identifierTypes.count > 0 {
                Section("Plate Identifiers") {
                    ForEach(identifierTypes, id: \.id) { identifierType in
                        NavigationLink {
                            RegionalIdentifierList(
                                type: identifierType,
                                country: country
                            )
                        } label: {
                            Text(getTranslatedString(identifierType.name))
                        }
                    }
                }
            }

            if plateVariants.count > 0 {
                Section("Plate Variants") {
                    ForEach(plateVariants, id: \.id) { variant in
                        NavigationLink {
                            PlateVariantDetails(plateVariant: variant, country: country)
                        } label: {
                            HStack(alignment: .center) {
                                LicensePlatePreview(
                                    fromPlateVariant: variant,
                                    andCountry: country,
                                    withTextSize: 20,
                                    withBorderSize: 2
                                )
                                .frame(maxWidth: .infinity)
                                Text(getTranslatedStringWithFormatting(variant.title))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
            
            if links.count > 0 {
                Section("Links") {
                    ForEach(links, id: \.link) { link in
                        let label = link.label.map { getTranslatedString($0) } ?? link.link
                        if let url = URL(string: link.link) {
                            Link(destination: url) {
                                Label(label, systemImage: "link")
                            }
                        } else {
                            Label(label, systemImage: "link")
                                .foregroundStyle(.secondary)
                                .disabled(true)
                        }
                    }
                }
            }
        }
        .navigationTitle(getTranslatedString(country.name))
    }
}

#Preview {
    CountryDetail(country: Country(
        id: "XX",
        name: "country_xx",
        flagEmoji: "🏳️",
        //defaultFont: nil,
        defaultFont: "Swiss License Plates",
        //genericPreview: "AB : CD 1234",
        genericPreview: "XX·123 456",
        description: "raw:**Hello** _World_",
        vanityPlatesPossible: true,
        vanityPlatesDescription: "raw: **Some** _Text_",
        hidden: false
    ))
}
