//
//  LicensePlateGlossaryTests.swift
//  LicensePlateGlossaryTests
//
//  Created by Raphael Guntersweiler on 10/07/2025.
//

import Testing
@testable import LicensePlateGlossary

struct DbManagerTests {

    let db = DbManager.instance

    // MARK: - Database Version

    @Test func databaseVersionIsNotError() {
        let version = db.getDatabaseVersion()
        #expect(version.id != "ERR")
        #expect(version.version != "ERR")
        #expect(!version.version.isEmpty)
    }

    // MARK: - Languages

    @Test func languagesReturnsNonEmptyList() {
        let languages = db.getLanguages()
        #expect(!languages.isEmpty)
    }

    @Test func languagesIncludesEnglish() {
        let languages = db.getLanguages()
        #expect(languages.contains { $0.id == "en" })
    }

    @Test func languagesAreOrderedById() {
        let languages = db.getLanguages()
        let ids = languages.map(\.id)
        #expect(ids == ids.sorted())
    }

    // MARK: - Countries

    @Test func countriesReturnsNonEmptyList() {
        let countries = db.getCountries()
        #expect(!countries.isEmpty)
    }

    @Test func hiddenCountriesAreExcludedByDefault() {
        let visible = db.getCountries(includeHidden: false)
        let all = db.getCountries(includeHidden: true)
        #expect(visible.count <= all.count)
    }

    @Test func visibleCountriesContainNoHiddenEntries() {
        let visible = db.getCountries(includeHidden: false)
        #expect(visible.allSatisfy { !$0.hidden })
    }

    @Test func countriesAreOrderedById() {
        let countries = db.getCountries()
        let ids = countries.map(\.id)
        #expect(ids == ids.sorted())
    }

    @Test func getKnownCountryReturnsResult() {
        let country = db.getCountry("D")
        #expect(country != nil)
        #expect(country?.id == "D")
    }

    @Test func getUnknownCountryReturnsNil() {
        let country = db.getCountry("INVALID_XXXX")
        #expect(country == nil)
    }

    // MARK: - Plate Variants

    @Test func plateVariantsReturnedForKnownCountry() {
        let variants = db.getPlateVariantsForCountry("D")
        #expect(!variants.isEmpty)
    }

    @Test func plateVariantsAreEmptyForUnknownCountry() {
        let variants = db.getPlateVariantsForCountry("INVALID_XXXX")
        #expect(variants.isEmpty)
    }

    @Test func plateVariantsAreOrderedByOrderThenId() {
        let variants = db.getPlateVariantsForCountry("D")
        let pairs = zip(variants, variants.dropFirst())
        for (a, b) in pairs {
            if let orderA = a.order, let orderB = b.order {
                #expect(orderA <= orderB || (orderA == orderB && a.id <= b.id))
            }
        }
    }

    @Test func plateVariantsAllBelongToRequestedCountry() {
        let variants = db.getPlateVariantsForCountry("D")
        #expect(variants.allSatisfy { $0.countryId == "D" })
    }

    // MARK: - Plate Identifiers

    @Test func identifierTypesReturnedForKnownCountry() {
        let types = db.getIdentifierTypes(forCountry: "D")
        #expect(!types.isEmpty)
    }

    @Test func identifierTypesAreEmptyForUnknownCountry() {
        let types = db.getIdentifierTypes(forCountry: "INVALID_XXXX")
        #expect(types.isEmpty)
    }

    @Test func identifiersReturnedForKnownCountry() {
        let identifiers = db.getIdentifiers(forCountry: "D")
        #expect(!identifiers.isEmpty)
    }

    @Test func identifiersAreEmptyForUnknownCountry() {
        let identifiers = db.getIdentifiers(forCountry: "INVALID_XXXX")
        #expect(identifiers.isEmpty)
    }

    @Test func identifiersByTypeIsSubsetOfAllIdentifiers() {
        let types = db.getIdentifierTypes(forCountry: "D")
        guard let firstType = types.first else { return }

        let all = db.getIdentifiers(forCountry: "D")
        let byType = db.getIdentifiers(forCountry: "D", ofType: firstType.id)

        let allIds = Set(all.map(\.id))
        #expect(byType.allSatisfy { allIds.contains($0.id) })
    }

    @Test func identifiersByTypeOnlyContainMatchingType() {
        let types = db.getIdentifierTypes(forCountry: "D")
        guard let firstType = types.first else { return }

        let byType = db.getIdentifiers(forCountry: "D", ofType: firstType.id)
        #expect(byType.allSatisfy { $0.typeId == firstType.id })
    }

    // MARK: - Translations

    @Test func translatedStringEntryFoundForKnownKey() {
        guard let country = db.getCountry("D") else { return }
        let entry = db.getTranslatedStringEntry(fromKey: country.name, forLanguage: "en")
        #expect(entry != nil)
        #expect(entry?.languageKey == "en")
        #expect(entry?.stringKey == country.name)
    }

    @Test func translatedStringEntryNilForUnknownKey() {
        let entry = db.getTranslatedStringEntry(fromKey: "nonexistent.key.xyz", forLanguage: "en")
        #expect(entry == nil)
    }

    @Test func translatedStringReturnsValueForKnownKey() {
        guard let country = db.getCountry("D") else { return }
        let result = db.getTranslatedString(fromKey: country.name)
        #expect(result != country.name)
        #expect(!result.isEmpty)
    }

    @Test func translatedStringReturnsKeyForUnknownKey() {
        let unknownKey = "nonexistent.key.xyz"
        let result = db.getTranslatedString(fromKey: unknownKey)
        #expect(result == unknownKey)
    }

    @Test func allTranslatedStringsIncludesEnglishForKnownKey() {
        guard let country = db.getCountry("D") else { return }
        let entries = db.getAllTranslatedStrings(fromKey: country.name)
        #expect(!entries.isEmpty)
        #expect(entries.contains { $0.languageKey == "en" })
    }

    @Test func allTranslatedStringsAreOrderedByLanguageKey() {
        guard let country = db.getCountry("D") else { return }
        let entries = db.getAllTranslatedStrings(fromKey: country.name)
        let keys = entries.map(\.languageKey)
        #expect(keys == keys.sorted())
    }

    @Test func allTranslatedStringsEmptyForUnknownKey() {
        let entries = db.getAllTranslatedStrings(fromKey: "nonexistent.key.xyz")
        #expect(entries.isEmpty)
    }

    // MARK: - Country Links

    @Test func countryLinksReturnedForKnownCountry() {
        // "CH" has country links in the database; "D" has none
        let links = db.getLinksForCountry("CH", forLanguage: "en")
        #expect(!links.isEmpty)
    }

    @Test func countryLinksAreEmptyForUnknownCountry() {
        let links = db.getLinksForCountry("INVALID_XXXX", forLanguage: "en")
        #expect(links.isEmpty)
    }

    @Test func countryLinksAllBelongToRequestedCountry() {
        let links = db.getLinksForCountry("CH", forLanguage: "en")
        #expect(links.allSatisfy { $0.countryId == "CH" })
    }

    @Test func countryLinksAreLanguageFiltered() {
        let links = db.getLinksForCountry("CH", forLanguage: "en")
        #expect(links.allSatisfy { $0.linkLanguage == nil || $0.linkLanguage == "en" })
    }
}
