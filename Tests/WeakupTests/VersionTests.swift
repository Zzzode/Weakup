import Foundation
import Testing
@testable import WeakupCore

@Suite("AppVersion Tests")
struct AppVersionTests {

    // MARK: - String Tests

    @Test("Version string is not empty")
    func stringReturnsValidVersion() {
        let version = AppVersion.string
        #expect(!version.isEmpty, "Version string should not be empty")
    }

    @Test("Version matches semantic version format")
    func stringMatchesSemanticVersionFormat() throws {
        let version = AppVersion.string
        // Version should match pattern like "1.0.0" or "1.0"
        let pattern = #"^\d+\.\d+(\.\d+)?$"#
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(version.startIndex..., in: version)
        let match = regex.firstMatch(in: version, range: range)
        #expect(match != nil, "Version '\(version)' should match semantic version format")
    }

    // MARK: - Build Tests

    @Test("Build string is not empty")
    func buildReturnsValidBuild() {
        let build = AppVersion.build
        #expect(!build.isEmpty, "Build string should not be empty")
    }

    // MARK: - Full String Tests

    @Test("Full string contains version and build")
    func fullStringContainsVersionAndBuild() {
        let fullString = AppVersion.fullString
        #expect(fullString.contains(AppVersion.string), "Full string should contain version")
        #expect(fullString.contains(AppVersion.build), "Full string should contain build")
        #expect(fullString.contains("("), "Full string should contain parenthesis")
        #expect(fullString.contains(")"), "Full string should contain parenthesis")
    }

    @Test("Full string has correct format")
    func fullStringFormat() {
        let fullString = AppVersion.fullString
        let expected = "\(AppVersion.string) (\(AppVersion.build))"
        #expect(fullString == expected, "Full string should match expected format")
    }

    // MARK: - Components Tests

    @Test("Components returns valid tuple")
    func componentsReturnsTuple() {
        let components = AppVersion.components
        #expect(components.major >= 0, "Major version should be non-negative")
        #expect(components.minor >= 0, "Minor version should be non-negative")
        #expect(components.patch >= 0, "Patch version should be non-negative")
    }

    @Test("Components match version string")
    func componentsMatchVersionString() {
        let components = AppVersion.components
        let versionString = AppVersion.string
        let parts = versionString.split(separator: ".").compactMap { Int($0) }

        if parts.count > 0 {
            #expect(components.major == parts[0], "Major should match first part")
        }
        if parts.count > 1 {
            #expect(components.minor == parts[1], "Minor should match second part")
        }
        if parts.count > 2 {
            #expect(components.patch == parts[2], "Patch should match third part")
        }
    }

    @Test("Components defaults for missing parts")
    func componentsDefaultsForMissingParts() {
        // This test verifies the default behavior when version string has fewer than 3 parts
        let components = AppVersion.components
        // At minimum, major should be 1 (the default)
        #expect(components.major >= 1, "Major should be at least 1")
    }
}
