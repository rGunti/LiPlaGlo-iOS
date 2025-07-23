//
//  LicensePlatePreview.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 15/07/2025.
//

import SwiftUI

struct LicensePlatePreview: View {
    private static let plateDefaultFont: String = "HelveticaNeue-CondensedBold"
    private static let plateDefaultColor: Color = .primary
    private static let plateDefaultBackgroundColor: Color = .secondary
    
    let plateText: String
    let plateFont: String?
    let plateTextColor: Color?
    let plateBackgroundColor: Color?
    let plateBorderColor: Color?
    let plateBorderWidth: CGFloat?
    let plateTextSize: CGFloat?
    
    init(plateText: String, plateFont: String?, plateTextColor: Color?, plateBackgroundColor: Color?, plateBorderColor: Color?, plateBorderWidth: CGFloat?, plateTextSize: CGFloat?) {
        self.plateText = plateText
        self.plateFont = plateFont
        self.plateTextColor = plateTextColor
        self.plateBackgroundColor = plateBackgroundColor
        self.plateBorderColor = plateBorderColor
        self.plateBorderWidth = plateBorderWidth
        self.plateTextSize = plateTextSize
    }
    
    init(fromCountry country: Country, withCustomText customText: String? = nil) {
        plateText = customText ?? country.genericPreview ?? "???"
        plateFont = country.defaultFont
        plateTextColor = nil
        plateBackgroundColor = nil
        plateBorderColor = nil
        plateBorderWidth = nil
        plateTextSize = nil
    }
    
    init(fromPlateVariant variant: PlateVariant, andCountry country: Country, withTextSize textSize: CGFloat? = nil, withBorderSize borderSize: CGFloat? = nil) {
        plateText = variant.preview
        plateFont = variant.previewFont ?? country.defaultFont
        if let textColor = variant.previewTextColor {
            plateTextColor = Color(hex: textColor)
        } else {
            plateTextColor = nil
        }
        if let backgroundColor = variant.previewBackgroundColor {
            plateBackgroundColor = Color(hex: backgroundColor)
        } else {
            plateBackgroundColor = nil
        }
        if let borderColor = variant.previewBorderColor {
            plateBorderColor = Color(hex: borderColor)
        } else {
            plateBorderColor = nil
        }
        plateBorderWidth = borderSize
        plateTextSize = textSize
    }
    
    var body: some View {
        let base = ZStack {
            if let plateBackgroundColor = plateBackgroundColor {
                Color(plateBackgroundColor)
            }
            Text(plateText)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(plateTextColor ?? LicensePlatePreview.plateDefaultColor)
                .backgroundStyle(plateBackgroundColor ?? LicensePlatePreview.plateDefaultBackgroundColor)
                .font(.custom(plateFont ?? LicensePlatePreview.plateDefaultFont, size: plateTextSize ?? 64))
                .padding()
        }
        if let borderColor = plateBorderColor {
            base.border(borderColor, width: plateBorderWidth ?? 4)
        } else {
            base
        }
    }
}

#Preview {
//    LicensePlatePreview(
//        plateText: "XX·123 456",
//        plateFont: "Swiss License Plate",
//        plateTextColor: Color(red: 1, green: 0, blue: 0),
//        plateBackgroundColor: Color(red: 0, green: 1, blue: 0),
//        plateBorderColor: Color(red: 0, green: 0, blue: 1),
//        plateBorderWidth: 4,
//        plateTextSize: nil
//    )
    
    LicensePlatePreview(fromCountry: Country(id: "XX", name: "example_country", flagEmoji: "xx", defaultFont: nil, genericPreview: "XX·123 456", description: "raw:**Hello** _World_", vanityPlatesPossible: true, vanityPlatesDescription: "raw: **Some** _Text_", hidden: false))
}
