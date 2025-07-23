//
//  PlateVariantDetails.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 16/07/2025.
//

import SwiftUI

struct PlateVariantDetails: View {
    let plateVariant: PlateVariant
    let country: Country
    
    var body: some View {
        List {
            Section("Plate Preview") {
                LicensePlatePreview(fromPlateVariant: plateVariant, andCountry: country)
            }
            
            if let description = plateVariant.description {
                Section("Description") {
                    Text(getTranslatedStringWithFormatting(description))
                }
            }
        }
        .navigationTitle(getTranslatedString(plateVariant.title))
    }
}

#Preview {
    let country = Country(
        id: "XX",
        name: "country_xx",
        flagEmoji: "🏳️",
        defaultFont: "Swiss License Plates",
        genericPreview: "XX·123 456",
        description: "raw:**Hello** _World_",
        vanityPlatesPossible: true,
        vanityPlatesDescription: "raw: **Some** _Text_",
        hidden: false
    )
    let variant = PlateVariant(
        id: -1,
        countryId: "XX",
        title: "standard_license_plate",
        preview: "XX·123 456",
        previewFont: nil,
        previewTextColor: "000000",
        previewBackgroundColor: "ffffff",
        previewBorderColor: "000000",
        inUse: true,
        description: "raw:**Hello** _World_\n## Test\n\nSource from [Wikipedia](https://wikipedia.org)",
        order: nil
    )
    
    PlateVariantDetails(
        plateVariant: variant,
        country: country
    )
}
