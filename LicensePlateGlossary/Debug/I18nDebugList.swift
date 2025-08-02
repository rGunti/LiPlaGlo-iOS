//
//  I18nDebugList.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 23/07/2025.
//

import SwiftUI

struct I18nDebugList: View {
    let languages: [String: I18nLanguage]
    let missingTranslations: [UntranslatedString]
    
    init() {
        self.missingTranslations = DbManager.instance.getMissingTranslations()
        let languages = DbManager.instance.getLanguages()
        let languageDict = [String: I18nLanguage]()
        self.languages = languages.reduce(into: languageDict) { result, item in
            result[item.id] = item
        }
    }
    
    var body: some View {
        List {
            Section("Missing translations") {
                if missingTranslations.count > 0 {
                    ForEach(missingTranslations, id: \.stringKey) { translation in
                        MissingTranslationItem(
                            string: translation,
                            availableLanguages: languages
                        )
                    }
                } else {
                    Label(
                        "Good news! No missing translations found.",
                        systemImage: "hand.thumbsup"
                    )
                }
            }
        }
        .navigationTitle("Translations")
    }
}

#Preview {
    I18nDebugList()
}
