//
//  MissingTranslationItem.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 23/07/2025.
//

import SwiftUI

struct MissingTranslationItem: View {
    let string: UntranslatedString
    let availableLanguages: [String: I18nLanguage]
    
    let missingLanguages: [I18nLanguage]
    
    init(string: UntranslatedString, availableLanguages: [String: I18nLanguage]) {
        self.string = string
        self.availableLanguages = availableLanguages
        
        self.missingLanguages = string.missingLanguages.map {
            availableLanguages[$0]!
        }
    }
    
    var body: some View {
        NavigationLink {
            MissingTranslationDetails(
                string: string,
                languages: Array(availableLanguages.values)
            )
        } label: {
            VStack(alignment: .leading) {
                Text("\(string.stringKey) (\(missingLanguages.count))")
                    .font(.headline)
                ForEach(missingLanguages, id: \.id) { language in
                    Text("\(language.id) – \(language.nativeLanguageName) (\(language.englishLanguageName))")
                        .font(.subheadline)
                        .lineLimit(1)
                        .padding(.leading, 10)
                }
            }
        }
    }
}

#Preview {
    MissingTranslationItem(
        string: UntranslatedString(
            stringKey: "sample",
            missingLanguages: ["en", "de"]
        ),
        availableLanguages: [
            "en": I18nLanguage(id: "en", nativeLanguageName: "English", englishLanguageName: "English"),
            "de": I18nLanguage(id: "de", nativeLanguageName: "Deutsch", englishLanguageName: "German"),
        ]
    )
}
