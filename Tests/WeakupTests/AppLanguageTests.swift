import XCTest
@testable import WeakupCore

final class AppLanguageTests: XCTestCase {

    // Enum Cases Tests

    func testAllCases_containsExpectedLanguages() {
        let allCases = AppLanguage.allCases
        XCTAssertEqual(allCases.count, 2, "Should have exactly 2 languages")
        XCTAssertTrue(allCases.contains(.english), "Should contain English")
        XCTAssertTrue(allCases.contains(.chinese), "Should contain Chinese")
    }

    func testRawValue_english() {
        XCTAssertEqual(AppLanguage.english.rawValue, "en")
    }

    func testRawValue_chinese() {
        XCTAssertEqual(AppLanguage.chinese.rawValue, "zh-Hans")
    }

    // Identifiable Tests

    func testId_matchesRawValue() {
        for language in AppLanguage.allCases {
            XCTAssertEqual(language.id, language.rawValue, "ID should match raw value")
        }
    }

    // Display Name Tests

    func testDisplayName_english() {
        XCTAssertEqual(AppLanguage.english.displayName, "English")
    }

    func testDisplayName_chinese() {
        XCTAssertEqual(AppLanguage.chinese.displayName, "中文")
    }

    func testDisplayName_allLanguagesHaveDisplayNames() {
        for language in AppLanguage.allCases {
            XCTAssertFalse(language.displayName.isEmpty, "Display name should not be empty for \(language)")
        }
    }

    // Bundle Tests

    func testBundle_returnsBundle() {
        for language in AppLanguage.allCases {
            let bundle = language.bundle
            XCTAssertNotNil(bundle, "Bundle should not be nil for \(language)")
        }
    }

    // Initialization Tests

    func testInit_fromValidRawValue() {
        let english = AppLanguage(rawValue: "en")
        XCTAssertEqual(english, .english)

        let chinese = AppLanguage(rawValue: "zh-Hans")
        XCTAssertEqual(chinese, .chinese)
    }

    func testInit_fromInvalidRawValue() {
        let invalid = AppLanguage(rawValue: "invalid")
        XCTAssertNil(invalid, "Invalid raw value should return nil")
    }
}
