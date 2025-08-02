//
//  DbManager.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 12/07/2025.
//

import Foundation
import SQLite

class DbManager {
    private static let dbFilePath = Bundle.main.path(forResource: "liplaglo", ofType: "db")!;
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
    
    func getCountries(includeHidden: Bool = false) -> [Country] {
        var countries: [Country] = []
        do {
            let query = includeHidden ?
                DbTables.countries.order(Country.colId) :
                DbTables.countries.filter(Country.colHidden == false).order(Country.colId)
            for countryRow in try dbConnection.prepare(query) {
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
    
    func getIdentifierTypes(forCountry countryId: String) -> [PlateIdentifierType] {
        var types: [PlateIdentifierType] = []
        do {
            for typeRow in try dbConnection.prepare(DbTables.plateIdentifierTypes
                .filter(PlateIdentifierType.colCountryId == countryId)
                .order([PlateIdentifier.colId])) {
                types.append(PlateIdentifierType(fromRow: typeRow))
            }
        } catch {
            print("Error when getting regional identifier types")
        }
        return types
    }
    
    func getIdentifiers(forCountry countryId: String) -> [PlateIdentifier] {
        var identifiers: [PlateIdentifier] = []
        do {
            for ident in try dbConnection.prepare(DbTables.plateIdentifiers
                .filter(PlateIdentifier.colCountryId == countryId)
                .order([PlateIdentifier.colIdentifier])) {
                identifiers.append(PlateIdentifier(fromRow: ident))
            }
        } catch {
            print("Error when getting regional identifiers for country %s", countryId)
        }
        return identifiers
    }
    
    func getIdentifiers(forCountry countryId: String, ofType typeId: Int) -> [PlateIdentifier] {
        var identifiers: [PlateIdentifier] = []
        do {
            for ident in try dbConnection.prepare(DbTables.plateIdentifiers
                .filter(PlateIdentifier.colCountryId == countryId && PlateIdentifier.colTypeId == typeId)
                .order([PlateIdentifier.colIdentifier])) {
                identifiers.append(PlateIdentifier(fromRow: ident))
            }
        } catch {
            print("Error when getting regional identifiers for country %s and type %d", countryId, typeId)
        }
        return identifiers
    }
    
    func getDatabaseVersion() -> DbVersion {
        do {
            for ver in try dbConnection.prepare(DbTables.version.limit(1)) {
                return DbVersion(fromRow: ver)
            }
        } catch {
            print("Error when getting database version", error)
        }
        return DbVersion(id: "ERR", version: "ERR")
    }
}
