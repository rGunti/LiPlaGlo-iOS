//
//  CH.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 10/07/2025.
//

import SwiftUI

// TODO: Find a storage solution
struct Switzerland {
    public static let countryName: String = String(localized: "Country.CH")
    public static let fileName: String = "ch.data.json"
    public static func getItems() -> [GenericLicensePlateRecord] {
        let items: [GenericLicensePlateRecord] = Bundle.main.decode([GenericLicensePlateRecord].self, from: fileName)
        return items.sorted { ($0.inUse ? 0 : 1, $0.identifier)
            < ($1.inUse ? 0 : 1, $1.identifier) }
    }
    
//    public static var items: [GenericLicensePlateRecord] = [
//        GenericLicensePlateRecord(identifier: "A", title: "Administration", remarks: "Zivile Fahrzeuge des Bundes trugen früher das Schweizerwappen gefolgt von einem «A» (Kürzel für «Administration») und der Nummer mit schwarzen Zeichen auf weissem Grund. Sie trugen auch kein Kantonswappen. Die erste Ziffer der fünfstelligen Nummer stand für das Departement, zu dem das Fahrzeug gehörte. Diese Kontrollschilder werden nicht mehr verwendet. Die Amtsstellen erhalten heute normale Kontrollschilder des Kantons. Einzige Ausnahme bilden die Bereiche Verteidigung und armasuisse innerhalb des VBS, welche die Armeenummern mit Schweizerwappen und weissem «M» auf schwarzem Grund verwenden.", inUse: false),
//        GenericLicensePlateRecord(identifier: "AG", title: "Aargau"),
//        GenericLicensePlateRecord(identifier: "AI", title: "Appenzell Innerrhoden"),
//        GenericLicensePlateRecord(identifier: "AR", title: "Appenzell Ausserrhoden"),
//        GenericLicensePlateRecord(identifier: "BE", title: "Bern"),
//        GenericLicensePlateRecord(identifier: "BL", title: "Basel-Land"),
//        GenericLicensePlateRecord(identifier: "BS", title: "Basel-Stadt"),
//        GenericLicensePlateRecord(identifier: "FR", title: "Fribourg"),
//        GenericLicensePlateRecord(identifier: "GE", title: "Genf"),
//        GenericLicensePlateRecord(identifier: "GL", title: "Glarus"),
//        GenericLicensePlateRecord(identifier: "GR", title: "Graubünden"),
//        GenericLicensePlateRecord(identifier: "JU", title: "Jura"),
//        GenericLicensePlateRecord(identifier: "LU", title: "Luzern"),
//        GenericLicensePlateRecord(identifier: "M", title: "Militär", remarks: "Militärfahrzeuge (Fahrzeuge der Armee und Verwaltungsfahrzeuge des Departementsbereichs Verteidigung), Fahrzeuge des Grenzwachtkorps, der Zolluntersuchungsbehörden, der armasuisse sowie des Nachrichtendienstes des Bundes werden durch das Strassenverkehrs- und Schifffahrtsamt der Armee (SVSAA) mit Militärkontrollschildern immatrikuliert (Art. 28 Abs. 1 VFBF)."),
//        GenericLicensePlateRecord(identifier: "NE", title: "Neuenburg"),
//        GenericLicensePlateRecord(identifier: "NW", title: "Nidwalden"),
//        GenericLicensePlateRecord(identifier: "OW", title: "Obwalden"),
//        GenericLicensePlateRecord(identifier: "P", title: "Post", remarks: "Post, Telegraf und Telefon (PTT) sowie die Schweizerischen Bundesbahnen (SBB) waren bis 1997/98 Teil der Bundesverwaltung, ihre Fahrzeuge trugen das Schweizerwappen gefolgt von einem «P» (Kürzel für «Post») und der Nummer mit schwarzen Zeichen auf weissem, gelbem oder blauem Grund. Die Post und die SBB blieben nach der Verselbständigung vollständig in Bundesbesitz und konnten die P-Schilder vorerst weiterverwenden, hingegen mussten die Fahrzeuge des Telecom-Bereichs, die ab 1. Januar 1998 zur teilprivatisierten Swisscom gehörten, sofort auf kantonale Nummernschilder wechseln.", inUse: false),
//        GenericLicensePlateRecord(identifier: "SG", title: "St. Gallen"),
//        GenericLicensePlateRecord(identifier: "SH", title: "Schaffhausen"),
//        GenericLicensePlateRecord(identifier: "SO", title: "Solothurn"),
//        GenericLicensePlateRecord(identifier: "SZ", title: "Schwyz"),
//        GenericLicensePlateRecord(identifier: "TG", title: "Thurgau"),
//        GenericLicensePlateRecord(identifier: "TI", title: "Tessin"),
//        GenericLicensePlateRecord(identifier: "UR", title: "Uri"),
//        GenericLicensePlateRecord(identifier: "VD", title: "Waadt"),
//        GenericLicensePlateRecord(identifier: "VS", title: "Wallis"),
//        GenericLicensePlateRecord(identifier: "ZG", title: "Zug"),
//        GenericLicensePlateRecord(identifier: "ZH", title: "Zürich")
//    ]
}
