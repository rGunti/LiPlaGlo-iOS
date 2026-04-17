//
//  MissingTranslationDetails.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 23/07/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct MissingTranslationDetails: View {
    @State private var isKeyCopied: Bool = false
    @State private var isMessageCopied: Bool = false
    @State private var isInsertSqlCopied: Bool = false
    
    let string: UntranslatedString
    let entries: [String: I18nEntry]
    let languages: [I18nLanguage]
    
    init(string: UntranslatedString, languages: [I18nLanguage]) {
        self.string = string
        
        let entries = DbManager.instance.getAllTranslatedStrings(fromKey: string.stringKey)
        let indexedEntries = [String: I18nEntry]()
        self.entries = entries.reduce(into: indexedEntries) { result, item in
            result[item.languageKey] = item
        }
        self.languages = languages
    }
    
    var body: some View {
        List {
            KeyValueRow(key: "String key", value: string.stringKey)
                .onTapGesture(count: 2) {
                    UIPasteboard.general.setValue(
                        string.stringKey,
                        forPasteboardType: UTType.plainText.identifier)
                    self.isKeyCopied = true
                }
                .alert("Copied key to clipboard", isPresented: $isKeyCopied) {}

            ForEach(self.languages, id: \.id) { language in
                Section("\(language.id) – \(language.nativeLanguageName) (\(language.englishLanguageName))") {
                    let translatedText = self.entries[language.id]
                    
                    if let text = translatedText {
                        Text(text.value)
                        Button("Copy text") {
                            UIPasteboard.general.setValue(
                                text.value,
                                forPasteboardType: UTType.plainText.identifier
                            )
                            self.isMessageCopied = true
                        }.alert("Copied message to clipboard", isPresented: $isMessageCopied) {}
                    } else {
                        Text("missing translation")
                            .italic()
                        Button("Copy Insert Statement") {
                            let statement = I18nEntry.generateInsertStatement(forStringKey: string.stringKey, andLanguageKey: language.id, withValue: "TODO")
                            UIPasteboard.general.setValue(
                                statement,
                                forPasteboardType: UTType.plainText.identifier
                            )
                            self.isInsertSqlCopied = true
                        }
                            .alert("Copied Insert Statement to clipboard", isPresented: $isInsertSqlCopied) {}
                    }
                }
            }
        }
        .navigationTitle(string.stringKey)
    }
}

#Preview {
    MissingTranslationDetails(
        string: UntranslatedString(
            stringKey: "sample",
            missingLanguages: ["en", "de"]
        ),
        languages: [
            I18nLanguage(id: "en", nativeLanguageName: "English", englishLanguageName: "English"),
            I18nLanguage(id: "de", nativeLanguageName: "Deutsch", englishLanguageName: "German"),
        ]
    )
}
