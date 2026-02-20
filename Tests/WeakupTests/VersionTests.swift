import XCTest
@testable import WeakupCore

final class AppVersionTests: XCTestCase {

    // MARK: - String Tests

    func testString_returnsValidVersion() {
        let version = AppVersion.string
        XCTAssertFalse(version.isEmpty, "Version string should not be empty")
    }

    func testString_matchesSemanticVersionFormat() {
        let version = AppVersion.string
        // Version should match pattern like "1.0.0" or "1.0"
        let pattern = #"^\d+\.\d+(\.\d+)?$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(version.startIndex..., in: version)
        let match = regex?.firstMatch(in: version, range: range)
        XCTAssertNotNil(match, "Version '\(version)' should match semantic version format")
    }

    // MARK: - Build Tests

    func testBuild_returnsValidBuild() {
        let build = AppVersion.build
        XCTAssertFalse(build.isEmpty, "Build string should not be empty")
    }

    // MARK: - Full String Tests

    func testFullString_containsVersionAndBuild() {
        let fullString = AppVersion.fullString
        XCTAssertTrue(fullString.contains(AppVersion.string), "Full string should contain version")
        XCTAssertTrue(fullString.contains(AppVersion.build), "Full string should contain build")
        XCTAssertTrue(fullString.contains("("), "Full string should contain parenthesis")
        XCTAssertTrue(fullString.contains(")"), "Full string should contain parenthesis")
    }

    func testFullString_format() {
        let fullString = AppVersion.fullString
        let expected = "\(AppVersion.string) (\(AppVersion.build))"
        XCTAssertEqual(fullString, expected, "Full string should match expected format")
    }

    // MARK: - Components Tests

    func testComponents_returnsTuple() {
        let components = AppVersion.components
        XCTAssertGreaterThanOrEqual(components.major, 0, "Major version should be non-negative")
        XCTAssertGreaterThanOrEqual(components.minor, 0, "Minor version should be non-negative")
        XCTAssertGreaterThanOrEqual(components.patch, 0, "Patch version should be non-negative")
    }

    func testComponents_matchVersionString() {
        let components = AppVersion.components
        let versionString = AppVersion.string
        let parts = versionString.split(separator: ".").compactMap { Int($0) }

        if parts.count > 0 {
            XCTAssertEqual(components.major, parts[0], "Major should match first part")
        }
        if parts.count > 1 {
            XCTAssertEqual(components.minor, parts[1], "Minor should match second part")
        }
        if parts.count > 2 {
            XCTAssertEqual(components.patch, parts[2], "Patch should match third part")
        }
    }

    func testComponents_defaultsForMissingParts() {
        // This test verifies the default behavior when version string has fewer than 3 parts
        let components = AppVersion.components
        // At minimum, major should be 1 (the default)
        XCTAssertGreaterThanOrEqual(components.major, 1, "Major should be at least 1")
    }
}
