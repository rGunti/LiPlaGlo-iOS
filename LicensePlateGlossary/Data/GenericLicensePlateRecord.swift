//
//  GenericLicensePlateRecord.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 10/07/2025.
//

import Foundation
import SwiftData

//@Model
//class GenericLicensePlateRecord {
//    var identifier: String
//    var title: String
//    var remarks: String
//    var inUse: Bool
//    
//    init(identifier: String, title: String, remarks: String = "", inUse: Bool = true) {
//        self.identifier = identifier
//        self.title = title
//        self.remarks = remarks
//        self.inUse = inUse
//    }
//    
//    public func notInUse() -> GenericLicensePlateRecord {
//        self.inUse = false
//        return self
//    }
//    
//}

struct GenericLicensePlateRecord: Codable {
    let identifier: String
    let title: String
    let remarks: String?
    let inUse: Bool
    let pattern: String
    let links: [LicensePlateLink]?
}

struct LicensePlateLink: Codable {
    let text: String?
    let url: String
}

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file).")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file).")
        }
        
        do {
            let loaded = try JSONDecoder().decode(T.self, from: data)
            return loaded
        } catch {
            print("Decoding failed", error)
            fatalError("Decoding failed")
        }
    }
}
