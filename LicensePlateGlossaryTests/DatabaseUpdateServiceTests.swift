//
//  DatabaseUpdateServiceTests.swift
//  LicensePlateGlossaryTests
//

import Testing
@testable import LicensePlateGlossary

struct DatabaseUpdateServiceTests {

    // MARK: - isUpdateEligible

    @Test func noUpdateWhenVersionsMatch() {
        #expect(DatabaseUpdateService.isUpdateEligible(current: "1.3.0", available: "1.3.0") == false)
    }

    @Test func noUpdateWhenCurrentIsNewer() {
        #expect(DatabaseUpdateService.isUpdateEligible(current: "1.4.0", available: "1.3.0") == false)
    }

    @Test func updateAvailableForMinorBump() {
        #expect(DatabaseUpdateService.isUpdateEligible(current: "1.3.0", available: "1.4.0") == true)
    }

    @Test func updateAvailableForPatchBump() {
        #expect(DatabaseUpdateService.isUpdateEligible(current: "1.3.0", available: "1.3.1") == true)
    }

    @Test func noUpdateForMajorBump() {
        #expect(DatabaseUpdateService.isUpdateEligible(current: "1.3.0", available: "2.0.0") == false)
    }

    @Test func noUpdateForMajorBumpWithSameMinor() {
        #expect(DatabaseUpdateService.isUpdateEligible(current: "1.9.9", available: "2.0.0") == false)
    }

    @Test func updateEligibleWithTwoComponentVersions() {
        #expect(DatabaseUpdateService.isUpdateEligible(current: "1.3", available: "1.4") == true)
    }

    @Test func noUpdateForMajorBumpTwoComponents() {
        #expect(DatabaseUpdateService.isUpdateEligible(current: "1.3", available: "2.0") == false)
    }

    // MARK: - GitHubRelease.version (v-prefix stripping)

    @Test func versionStripsVPrefix() {
        let release = makeRelease(tagName: "v1.4.0")
        #expect(release.version == "1.4.0")
    }

    @Test func versionWithoutPrefixUnchanged() {
        let release = makeRelease(tagName: "1.4.0")
        #expect(release.version == "1.4.0")
    }

    // MARK: - GitHubRelease.dbAsset

    @Test func dbAssetSelectedByName() {
        let release = makeRelease(assets: [
            GitHubAsset(name: "checksums.txt", browserDownloadUrl: "https://example.com/checksums.txt"),
            GitHubAsset(name: "liplaglo.db", browserDownloadUrl: "https://example.com/liplaglo.db"),
        ])
        #expect(release.dbAsset?.name == "liplaglo.db")
        #expect(release.dbAsset?.browserDownloadUrl == "https://example.com/liplaglo.db")
    }

    @Test func dbAssetNilWhenMissing() {
        let release = makeRelease(assets: [
            GitHubAsset(name: "checksums.txt", browserDownloadUrl: "https://example.com/checksums.txt"),
        ])
        #expect(release.dbAsset == nil)
    }

    @Test func dbAssetNilWhenNoAssets() {
        let release = makeRelease(assets: [])
        #expect(release.dbAsset == nil)
    }

    // MARK: - Helpers

    private func makeRelease(tagName: String = "v1.4.0", assets: [GitHubAsset] = []) -> GitHubRelease {
        GitHubRelease(tagName: tagName, assets: assets)
    }
}
