//
//  TranslatedText.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 14/07/2025.
//

import SwiftUI

struct TranslatedText: View {
    private let value: String
    
    init(_ key: String) {
        value = getTranslatedString(key)
    }
    
    var body: some View {
        Text(value)
    }
}

#Preview {
    TranslatedText("language")
}
