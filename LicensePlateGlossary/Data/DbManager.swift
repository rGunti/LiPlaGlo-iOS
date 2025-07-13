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
    
    func getCountries() -> [Country] {
        var countries: [Country] = []
        do {
            for countryRow in try dbConnection.prepare(DbTables.countries.order(Country.colId)) {
                let country = Country(id: countryRow[Country.colId],
                                      name: countryRow[Country.colName],
                                      flagEmoji: countryRow[Country.colFlagEmoji],
                                      defaultFont: countryRow[Country.colDefaultFont],
                                      genericPreview: countryRow[Country.colGenericPreview]
                )
                countries.append(country)
            }
        } catch {
            print("Error when getting countries", error)
        }
        return countries
    }
    
    func getLinksForCountry(_ countryId: String) -> [CountryLink] {
        var links: [CountryLink] = []
        do {
            for linkRow in try dbConnection.prepare(DbTables.countryLinks
                .filter(CountryLink.colCountryId == countryId)
                .order(CountryLink.colId)) {
                links.append(CountryLink.fromQueryRow(linkRow))
            }
        } catch {
            print("Error when getting countries", error)
        }
        return links
    }
}

struct DbTables {
    private init() { }
    
    static let countries = Table("countries")
    static let countryLinks = Table("country_links")
}

struct Country: Codable {
    static let colId = Expression<String>("id")
    static let colName = Expression<String>("name")
    static let colFlagEmoji = Expression<String?>("flag_emoji")
    static let colDefaultFont = Expression<String?>("license_plate_font")
    static let colGenericPreview = Expression<String?>("generic_preview")

    let id: String
    let name: String
    let flagEmoji: String?
    let defaultFont: String?
    let genericPreview: String?
}

struct CountryLink: Codable {
    static let colId = Expression<Int>("id")
    static let colCountryId = Expression<String>("country_id")
    static let colLabel = Expression<String?>("label")
    static let colLink = Expression<String>("link")

    let id: Int
    let countryId: String
    let label: String?
    let link: String
    
    static func fromQueryRow(_ row: Row) -> CountryLink {
        return CountryLink(
            id: row[CountryLink.colId],
            countryId: row[CountryLink.colCountryId],
            label: row[CountryLink.colLabel],
            link: row[CountryLink.colLink]
        )
    }
}
