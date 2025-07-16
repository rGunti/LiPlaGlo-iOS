//
//  I18nUtils.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 14/07/2025.
//
import SwiftUI

let defaultFallbackLanguage: String = "en"

func getCurrentLanguage() -> String? {
    return Locale.current.language.languageCode?.identifier
}

func getCurrentLanguage(withFallback fallback: String) -> String {
    return getCurrentLanguage() ?? fallback
}

func getTranslatedString(_ key: String) -> String {
    if key.starts(with: "raw:") {
        return String(key.split(separator: ":").dropFirst().joined(separator: ":"))
    }
    return DbManager.instance.getTranslatedString(fromKey: key)
}

func getTranslatedStringWithFormatting(_ key: String) -> LocalizedStringKey {
    return LocalizedStringKey(getTranslatedString(key))
}
