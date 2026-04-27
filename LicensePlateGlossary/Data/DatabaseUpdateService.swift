//
//  DatabaseUpdateService.swift
//  LicensePlateGlossary
//
//  Created by Raphael Guntersweiler on 27/04/2026.
//

import Foundation

struct GitHubRelease: Decodable {
    let tagName: String
    let name: String?
    let htmlUrl: String
    let assets: [GitHubAsset]
    let body: String?

    var dbAsset: GitHubAsset? { assets.first { $0.name == "liplaglo.db" } }
    var version: String { tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName }
    var releasePageURL: URL? { URL(string: htmlUrl) }
    var displayName: String { (name?.isEmpty == false ? name : nil) ?? tagName }

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case htmlUrl = "html_url"
        case assets
        case body
    }
}

struct GitHubAsset: Decodable {
    let name: String
    let browserDownloadUrl: String

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadUrl = "browser_download_url"
    }
}

enum DatabaseUpdateService {
    private static let apiURL = URL(string: "https://api.github.com/repos/rGunti/LiPlaGlo-Db/releases/latest")!
    private static let logger = AppLogger.logger(for: "DatabaseUpdateService")

    /// Returns the release if it is a non-major eligible update over `currentVersion`, otherwise nil.
    static func checkForUpdate(currentVersion: String) async throws -> GitHubRelease? {
        let (data, _) = try await URLSession.shared.data(from: apiURL)
        let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
        guard isUpdateEligible(current: currentVersion, available: release.version) else { return nil }
        return release
    }

    /// Downloads the DB asset to a temporary file and returns its URL.
    static func downloadDatabase(from url: URL) async throws -> URL {
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        let dest = FileManager.default.temporaryDirectory
            .appendingPathComponent("liplaglo_update.db")
        try? FileManager.default.removeItem(at: dest)
        try FileManager.default.moveItem(at: tempURL, to: dest)
        return dest
    }

    /// Moves the downloaded DB into Application Support and reloads DbManager.
    static func installDatabase(from tempURL: URL) throws {
        let destURL = try userDatabaseURL()
        try? FileManager.default.removeItem(at: destURL)
        try FileManager.default.copyItem(at: tempURL, to: destURL)
        try? FileManager.default.removeItem(at: tempURL)
        DbManager.instance.reloadDatabase()
        let newVersion = DbManager.instance.getDatabaseVersion().version
        NotificationCenter.default.post(name: .databaseDidUpdate, object: newVersion)
        logger.info("Database installed from \(tempURL.path) to \(destURL.path)")
    }

    /// True if a user-downloaded DB is active in Application Support.
    static func isUserDatabaseInstalled() -> Bool {
        guard let supportDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        else { return false }
        return FileManager.default.fileExists(
            atPath: supportDir.appendingPathComponent("liplaglo.db").path
        )
    }

    /// Removes the user-downloaded DB and reloads DbManager (falls back to bundle).
    static func removeUserDatabase() throws {
        guard let supportDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        else { throw DatabaseUpdateError.noApplicationSupportDirectory }
        let path = supportDir.appendingPathComponent("liplaglo.db")
        try FileManager.default.removeItem(at: path)
        DbManager.instance.reloadDatabase()
        logger.info("User database removed, reverted to bundled DB")
    }

    // MARK: - Version logic

    /// True when `available` is newer than `current` and is NOT a major-version bump.
    static func isUpdateEligible(current: String, available: String) -> Bool {
        let cur = parseVersion(current)
        let avail = parseVersion(available)
        guard versionGreaterThan(avail, cur) else { return false }
        let curMajor = cur.first ?? 0
        let availMajor = avail.first ?? 0
        return availMajor == curMajor  // block major version bumps
    }

    private static func versionGreaterThan(_ a: [Int], _ b: [Int]) -> Bool {
        let len = max(a.count, b.count)
        for i in 0..<len {
            let av = i < a.count ? a[i] : 0
            let bv = i < b.count ? b[i] : 0
            if av != bv { return av > bv }
        }
        return false
    }

    // MARK: - Helpers

    private static func userDatabaseURL() throws -> URL {
        guard let supportDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        else {
            throw DatabaseUpdateError.noApplicationSupportDirectory
        }
        try FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        return supportDir.appendingPathComponent("liplaglo.db")
    }

    private static func parseVersion(_ version: String) -> [Int] {
        version.split(separator: ".").map { Int($0) ?? 0 }
    }
}

extension Notification.Name {
    static let databaseDidUpdate = Notification.Name("databaseDidUpdate")
}

enum DatabaseUpdateError: LocalizedError {
    case noApplicationSupportDirectory

    var errorDescription: String? {
        switch self {
        case .noApplicationSupportDirectory:
            return "Could not locate Application Support directory."
        }
    }
}
