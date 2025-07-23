//
//  Entities.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 23/07/2025.
//

import SQLite


struct DbTables {
    private init() { }
    
    static let countries = Table("countries")
    static let countryLinks = Table("country_links")
    static let i18n = Table("i18n")
    static let languages = Table("languages")
    static let plateVariants = Table("plate_variants")
    static let regionalIdentifier = Table("regional_identifier")
    static let regionalIdentifierType = Table("regional_identifier_type")
}

struct DbViews {
    private init() { }
    
    static let untranslatedStrings = View("v_untranslated_strings")
}

struct I18nEntry: Codable {
    static let colStringKey = Expression<String>("string_key")
    static let colLanguageKey = Expression<String>("language_key")
    static let colValue = Expression<String>("value")

    let stringKey: String
    let languageKey: String
    let value: String
    
    init(stringKey: String, languageKey: String, value: String) {
        self.stringKey = stringKey
        self.languageKey = languageKey
        self.value = value
    }
    
    init(fromRow row: Row) {
        self.stringKey = row[I18nEntry.colStringKey]
        self.languageKey = row[I18nEntry.colLanguageKey]
        self.value = row[I18nEntry.colValue]
    }
    
    static func generateInsertStatement(forStringKey stringKey: String, andLanguageKey languageKey: String, withValue value: String) -> String {
        return DbTables.i18n.insert(
            colStringKey <- stringKey,
            colLanguageKey <- languageKey,
            colValue <- value
        ).description
    }
}

struct I18nLanguage: Codable {
    static let colId = Expression<String>("id")
    static let colNativeLanguageName = Expression<String>("native_language_name")
    static let colEnglishLanguageName = Expression<String>("english_language_name")
    
    let id: String
    let nativeLanguageName: String
    let englishLanguageName: String
    
    init(id: String, nativeLanguageName: String, englishLanguageName: String) {
        self.id = id
        self.nativeLanguageName = nativeLanguageName
        self.englishLanguageName = englishLanguageName
    }
    
    init(fromRow row: Row) {
        self.id = row[I18nLanguage.colId]
        self.nativeLanguageName = row[I18nLanguage.colNativeLanguageName]
        self.englishLanguageName = row[I18nLanguage.colEnglishLanguageName]
    }
}

struct UntranslatedString: Codable {
    static let colStringKey = Expression<String>("string_key")
    static let colMissingLanguages = Expression<String>("missing_languages")
    
    let stringKey: String
    let missingLanguages: [String]
    
    init(stringKey: String, missingLanguages: [String]) {
        self.stringKey = stringKey
        self.missingLanguages = missingLanguages
    }
    
    init(fromRow row: Row) {
        self.stringKey = row[UntranslatedString.colStringKey]
        let missingLanguages = row[UntranslatedString.colMissingLanguages]
        self.missingLanguages = missingLanguages.components(separatedBy: ",")
    }
}

struct Country: Codable {
    static let colId = Expression<String>("id")
    static let colName = Expression<String>("name")
    static let colFlagEmoji = Expression<String?>("flag_emoji")
    static let colDefaultFont = Expression<String?>("license_plate_font")
    static let colGenericPreview = Expression<String?>("generic_preview")
    static let colDescription = Expression<String?>("description")
    static let colVanityPlatesPossible = Expression<Bool?>("vanity_plates_possible")
    static let colVanityPlatesDescription = Expression<String?>("vanity_plates_description")
    static let colHidden = Expression<Bool>("hidden")

    let id: String
    let name: String
    let flagEmoji: String?
    let defaultFont: String?
    let genericPreview: String?
    let description: String?
    let vanityPlatesPossible: Bool?
    let vanityPlatesDescription: String?
    let hidden: Bool
    
    init(id: String, name: String, flagEmoji: String?, defaultFont: String?, genericPreview: String?, description: String?, vanityPlatesPossible: Bool?, vanityPlatesDescription: String?, hidden: Bool) {
        self.id = id
        self.name = name
        self.flagEmoji = flagEmoji
        self.defaultFont = defaultFont
        self.genericPreview = genericPreview
        self.description = description
        self.vanityPlatesPossible = vanityPlatesPossible
        self.vanityPlatesDescription = vanityPlatesDescription
        self.hidden = hidden
    }
    
    init(fromRow row: Row) {
        self.id = row[Country.colId]
        self.name = row[Country.colName]
        self.flagEmoji = row[Country.colFlagEmoji]
        self.defaultFont = row[Country.colDefaultFont]
        self.genericPreview = row[Country.colGenericPreview]
        self.description = row[Country.colDescription]
        self.vanityPlatesPossible = row[Country.colVanityPlatesPossible]
        self.vanityPlatesDescription = row[Country.colVanityPlatesDescription]
        self.hidden = row[Country.colHidden]
    }
}

struct CountryLink: Codable {
    static let colId = Expression<Int>("id")
    static let colCountryId = Expression<String>("country_id")
    static let colLabel = Expression<String?>("label")
    static let colLink = Expression<String>("link")
    static let colLinkLanguage = Expression<String?>("link_language")

    let id: Int
    let countryId: String
    let label: String?
    let link: String
    let linkLanguage: String?
    
    init(id: Int, countryId: String, label: String?, link: String, linkLanguage: String?) {
        self.id = id
        self.countryId = countryId
        self.label = label
        self.link = link
        self.linkLanguage = linkLanguage
    }
    
    init(fromRow row: Row) {
        self.id = row[CountryLink.colId]
        self.countryId = row[CountryLink.colCountryId]
        self.label = row[CountryLink.colLabel]
        self.link = row[CountryLink.colLink]
        self.linkLanguage = row[CountryLink.colLinkLanguage]
    }
}

struct PlateVariant: Codable {
    static let colId = Expression<Int>("id")
    static let colCountryId = Expression<String>("country_id")
    static let colTitle = Expression<String>("title")
    static let colPreview = Expression<String>("preview")
    static let colPreviewFont = Expression<String?>("preview_font")
    static let colPreviewTextColor = Expression<String?>("preview_text_color")
    static let colPreviewBackgroundColor = Expression<String?>("preview_bg_color")
    static let colPreviewBorderColor = Expression<String?>("preview_border_color")
    static let colInUse = Expression<Bool>("in_use")
    static let colDescription = Expression<String?>("description")
    static let colOrder = Expression<Int?>("order")
    
    let id: Int
    let countryId: String
    let title: String
    let preview: String
    let previewFont: String?
    let previewTextColor: String?
    let previewBackgroundColor: String?
    let previewBorderColor: String?
    let inUse: Bool
    let description: String?
    let order: Int?
    
    init(id: Int, countryId: String, title: String, preview: String, previewFont: String?, previewTextColor: String?, previewBackgroundColor: String?, previewBorderColor: String?, inUse: Bool, description: String?, order: Int?) {
        self.id = id
        self.countryId = countryId
        self.title = title
        self.preview = preview
        self.previewFont = previewFont
        self.previewTextColor = previewTextColor
        self.previewBackgroundColor = previewBackgroundColor
        self.previewBorderColor = previewBorderColor
        self.inUse = inUse
        self.description = description
        self.order = order
    }
    
    init(fromRow row: Row) {
        self.id = row[PlateVariant.colId]
        self.countryId = row[PlateVariant.colCountryId]
        self.title = row[PlateVariant.colTitle]
        self.preview = row[PlateVariant.colPreview]
        self.previewFont = row[PlateVariant.colPreviewFont]
        self.previewTextColor = row[PlateVariant.colPreviewTextColor]
        self.previewBackgroundColor = row[PlateVariant.colPreviewBackgroundColor]
        self.previewBorderColor = row[PlateVariant.colPreviewBorderColor]
        self.inUse = row[PlateVariant.colInUse]
        self.description = row[PlateVariant.colDescription]
        self.order = row[PlateVariant.colOrder]
    }
}

struct RegionalIdentifierType: Codable {
    static let colId = Expression<Int>("id")
    static let colCountryId = Expression<String>("country_id")
    static let colName = Expression<String>("name")
    
    let id: Int
    let countryId: String
    let name: String
    
    init(id: Int, countryId: String, name: String) {
        self.id = id
        self.countryId = countryId
        self.name = name
    }
    
    init(fromRow row: Row) {
        self.id = row[RegionalIdentifierType.colId]
        self.countryId = row[RegionalIdentifierType.colCountryId]
        self.name = row[RegionalIdentifierType.colName]
    }
}

struct RegionalIdentifier: Codable {
    static let colId = Expression<Int>("id")
    static let colCountryId = Expression<String>("country_id")
    static let colTypeId = Expression<Int>("type_id")
    static let colIdentifier = Expression<String>("identifier")
    static let colName = Expression<String>("name")
    static let colDescription = Expression<String?>("description")
    
    let id: Int
    let countryId: String
    let typeId: Int
    let identifier: String
    let name: String
    let description: String?
    
    init(id: Int, countryId: String, typeId: Int, identifier: String, name: String, description: String?) {
        self.id = id
        self.countryId = countryId
        self.typeId = typeId
        self.identifier = identifier
        self.name = name
        self.description = description
    }
    
    init(fromRow row: Row) {
        self.id = row[RegionalIdentifier.colId]
        self.countryId = row[RegionalIdentifier.colCountryId]
        self.typeId = row[RegionalIdentifier.colTypeId]
        self.identifier = row[RegionalIdentifier.colIdentifier]
        self.name = row[RegionalIdentifier.colName]
        self.description = row[RegionalIdentifier.colDescription]
    }
}

