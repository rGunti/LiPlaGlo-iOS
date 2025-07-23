//
//  DbManager.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 12/07/2025.
//

import Foundation
import SQLite

class DbManager {
    private static let dbFilePath = Bundle.main.path(forResource: "lpg", ofType: "sqlite")!;
    static let instance = DbManager()
    
    let dbConnection: Connection
    
    private init() {
        do {
            dbConnection = try DbManager.openDatabase()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private static func openDatabase() throws -> Connection {
        let db = try Connection(dbFilePath, readonly: true)
        return db
    }
    
    func getLanguages() -> [I18nLanguage] {
        var languages: [I18nLanguage] = []
        do {
            for languageRow in try dbConnection.prepare(DbTables.languages.order(I18nLanguage.colId)) {
                languages.append(I18nLanguage(fromRow: languageRow))
            }
        } catch {
            print("Error when getting languages", error)
        }
        return languages
    }
    
    func getMissingTranslations() -> [UntranslatedString] {
        var translations: [UntranslatedString] = []
        do {
            for translationRow in try dbConnection.prepare(DbViews.untranslatedStrings.order(UntranslatedString.colStringKey)) {
                translations.append(UntranslatedString(fromRow: translationRow))
            }
        } catch {
            print("Error when getting missing translations", error)
        }
        return translations
    }
    
    func getTranslatedStringEntry(fromKey key: String, forLanguage language: String) -> I18nEntry? {
        do {
            for row in try dbConnection.prepare(DbTables.i18n
                .filter(I18nEntry.colStringKey == key && I18nEntry.colLanguageKey == language)
                .limit(1)) {
                return I18nEntry(fromRow: row)
            }
        } catch {
            print("Error when getting i18n string", error)
        }
        return nil
    }
    
    func getTranslatedString(fromKey key: String) -> String {
        if let entry = getTranslatedStringEntry(fromKey: key, forLanguage: getCurrentLanguage(withFallback: defaultFallbackLanguage)) {
            return entry.value
        } else if let fallbackEntry = getTranslatedStringEntry(fromKey: key, forLanguage: defaultFallbackLanguage) {
            return fallbackEntry.value
        } else {
            return key
        }
    }
    
    func getAllTranslatedStrings(fromKey key: String) -> [I18nEntry] {
        var entries: [I18nEntry] = []
        do {
            for row in try dbConnection.prepare(DbTables.i18n
                .filter(I18nEntry.colStringKey == key)
                .order(I18nEntry.colLanguageKey)) {
                entries.append(I18nEntry(fromRow: row))
            }
        } catch {
            print("Error when getting all translated strings for key \"\(key)\"", error)
        }
        return entries
    }
    
    func getCountries() -> [Country] {
        var countries: [Country] = []
        do {
            for countryRow in try dbConnection.prepare(DbTables.countries.order(Country.colId)) {
                countries.append(Country(fromRow: countryRow))
            }
        } catch {
            print("Error when getting countries", error)
        }
        return countries
    }
    
    func getLinksForCountry(_ countryId: String, forLanguage language: String) -> [CountryLink] {
        var links: [CountryLink] = []
        do {
            for linkRow in try dbConnection.prepare(DbTables.countryLinks
                .filter(CountryLink.colCountryId == countryId && (CountryLink.colLinkLanguage == nil || CountryLink.colLinkLanguage == language))
                .order(CountryLink.colId)) {
                links.append(CountryLink(fromRow: linkRow))
            }
        } catch {
            print("Error when getting country links", error)
        }
        return links
    }
    
    func getPlateVariantsForCountry(_ countryId: String) -> [PlateVariant] {
        var variants: [PlateVariant] = []
        do {
            for variantRow in try dbConnection.prepare(DbTables.plateVariants
                .filter(PlateVariant.colCountryId == countryId)
                .order([PlateVariant.colOrder, PlateVariant.colId])) {
                variants.append(PlateVariant(fromRow: variantRow))
            }
        } catch {
            print("Error when getting plate variants", error)
        }
        return variants
    }
    
    func getRegionalIdentifierTypes(forCountry countryId: String) -> [RegionalIdentifierType] {
        var types: [RegionalIdentifierType] = []
        do {
            for typeRow in try dbConnection.prepare(DbTables.regionalIdentifierType
                .filter(RegionalIdentifierType.colCountryId == countryId)
                .order([RegionalIdentifier.colId])) {
                types.append(RegionalIdentifierType(fromRow: typeRow))
            }
        } catch {
            print("Error when getting regional identifier types")
        }
        return types
    }
    
    func getRegionalIdentifiers(forCountry countryId: String) -> [RegionalIdentifier] {
        var identifiers: [RegionalIdentifier] = []
        do {
            for ident in try dbConnection.prepare(DbTables.regionalIdentifier
                .filter(RegionalIdentifier.colCountryId == countryId)
                .order([RegionalIdentifier.colIdentifier])) {
                identifiers.append(RegionalIdentifier(fromRow: ident))
            }
        } catch {
            print("Error when getting regional identifiers for country %s", countryId)
        }
        return identifiers
    }
    
    func getRegionalIdentifiers(forCountry countryId: String, ofType typeId: Int) -> [RegionalIdentifier] {
        var identifiers: [RegionalIdentifier] = []
        do {
            for ident in try dbConnection.prepare(DbTables.regionalIdentifier
                .filter(RegionalIdentifier.colCountryId == countryId && RegionalIdentifier.colTypeId == typeId)
                .order([RegionalIdentifier.colIdentifier])) {
                identifiers.append(RegionalIdentifier(fromRow: ident))
            }
        } catch {
            print("Error when getting regional identifiers for country %s and type %d", countryId, typeId)
        }
        return identifiers
    }
}
