//
//  I18nUtilsTests.swift
//  LicensePlateGlossaryTests
//

import Testing
import SwiftUI
@testable import LicensePlateGlossary

struct I18nUtilsTests {

    // MARK: - raw: prefix

    @Test func rawPrefixIsStripped() {
        #expect(getTranslatedString("raw:Hello") == "Hello")
    }

    @Test func rawPrefixPreservesColonsInContent() {
        #expect(getTranslatedString("raw:Hello:World") == "Hello:World")
    }

    @Test func rawPrefixWithMultipleColonsPreservesAll() {
        #expect(getTranslatedString("raw:a:b:c") == "a:b:c")
    }

    @Test func rawPrefixOnlyStripsLeadingMarker() {
        // "raw:" inside the value must not be stripped
        #expect(getTranslatedString("raw:raw:nested") == "raw:nested")
    }

    @Test func rawPrefixWithEmptyValueReturnsEmptyString() {
        #expect(getTranslatedString("raw:") == "")
    }

    @Test func nonRawUnknownKeyReturnsSelf() {
        let key = "nonexistent.key.xyz"
        #expect(getTranslatedString(key) == key)
    }

    @Test func nonRawKnownKeyReturnsTranslation() {
        guard let country = DbManager.instance.getCountry("D") else { return }
        let result = getTranslatedString(country.name)
        #expect(result != country.name)
        #expect(!result.isEmpty)
    }

    // MARK: - getCurrentLanguage

    @Test func currentLanguageWithFallbackNeverReturnsEmpty() {
        #expect(!getCurrentLanguage(withFallback: "en").isEmpty)
    }

    @Test func currentLanguageWithFallbackUsesProvidedFallback() {
        // If the system returns nil, the fallback must be used.
        // We can only verify the contract: result is always non-empty.
        let result = getCurrentLanguage(withFallback: "zz")
        #expect(!result.isEmpty)
    }

    @Test func currentLanguageReturnsNonNilOnSimulator() {
        // Simulators always have a configured locale, so this should be set.
        #expect(getCurrentLanguage() != nil)
    }

    @Test func defaultFallbackLanguageIsEnglish() {
        #expect(defaultFallbackLanguage == "en")
    }

    // MARK: - getTranslatedStringWithFormatting

    @Test func formattingWrapperMatchesPlainTranslationForRawKey() {
        let plain = getTranslatedString("raw:Hello")
        let formatted = getTranslatedStringWithFormatting("raw:Hello")
        #expect(formatted == LocalizedStringKey(plain))
    }

    @Test func formattingWrapperMatchesPlainTranslationForKnownKey() {
        guard let country = DbManager.instance.getCountry("D") else { return }
        let plain = getTranslatedString(country.name)
        let formatted = getTranslatedStringWithFormatting(country.name)
        #expect(formatted == LocalizedStringKey(plain))
    }

    @Test func formattingWrapperMatchesPlainTranslationForUnknownKey() {
        let key = "nonexistent.key.xyz"
        let plain = getTranslatedString(key)
        let formatted = getTranslatedStringWithFormatting(key)
        #expect(formatted == LocalizedStringKey(plain))
    }
}
