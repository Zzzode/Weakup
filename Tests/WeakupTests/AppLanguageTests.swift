import XCTest
@testable import WeakupCore

final class AppLanguageTests: XCTestCase {

    // Enum Cases Tests (AL-001)

    func testAllCases_containsExpectedLanguages() {
        let allCases = AppLanguage.allCases
        XCTAssertEqual(allCases.count, 8, "Should have exactly 8 languages")
        XCTAssertTrue(allCases.contains(.english), "Should contain English")
        XCTAssertTrue(allCases.contains(.chinese), "Should contain Chinese Simplified")
        XCTAssertTrue(allCases.contains(.chineseTraditional), "Should contain Chinese Traditional")
        XCTAssertTrue(allCases.contains(.japanese), "Should contain Japanese")
        XCTAssertTrue(allCases.contains(.korean), "Should contain Korean")
        XCTAssertTrue(allCases.contains(.french), "Should contain French")
        XCTAssertTrue(allCases.contains(.german), "Should contain German")
        XCTAssertTrue(allCases.contains(.spanish), "Should contain Spanish")
    }

    func testAllCases_orderIsConsistent() {
        let cases = AppLanguage.allCases
        XCTAssertEqual(cases[0], .english)
        XCTAssertEqual(cases[1], .chinese)
        XCTAssertEqual(cases[2], .chineseTraditional)
        XCTAssertEqual(cases[3], .japanese)
        XCTAssertEqual(cases[4], .korean)
        XCTAssertEqual(cases[5], .french)
        XCTAssertEqual(cases[6], .german)
        XCTAssertEqual(cases[7], .spanish)
    }

    // Raw Value Tests (AL-002 to AL-009)

    func testRawValue_english() {
        XCTAssertEqual(AppLanguage.english.rawValue, "en")
    }

    func testRawValue_chinese() {
        XCTAssertEqual(AppLanguage.chinese.rawValue, "zh-Hans")
    }

    func testRawValue_chineseTraditional() {
        XCTAssertEqual(AppLanguage.chineseTraditional.rawValue, "zh-Hant")
    }

    func testRawValue_japanese() {
        XCTAssertEqual(AppLanguage.japanese.rawValue, "ja")
    }

    func testRawValue_korean() {
        XCTAssertEqual(AppLanguage.korean.rawValue, "ko")
    }

    func testRawValue_french() {
        XCTAssertEqual(AppLanguage.french.rawValue, "fr")
    }

    func testRawValue_german() {
        XCTAssertEqual(AppLanguage.german.rawValue, "de")
    }

    func testRawValue_spanish() {
        XCTAssertEqual(AppLanguage.spanish.rawValue, "es")
    }

    func testRawValue_allAreUnique() {
        let rawValues = AppLanguage.allCases.map { $0.rawValue }
        let uniqueRawValues = Set(rawValues)
        XCTAssertEqual(rawValues.count, uniqueRawValues.count, "All raw values should be unique")
    }

    func testRawValue_allAreValidLocaleIdentifiers() {
        for language in AppLanguage.allCases {
            let rawValue = language.rawValue
            XCTAssertFalse(rawValue.isEmpty, "Raw value should not be empty for \(language)")
            XCTAssertTrue(rawValue.count >= 2, "Raw value should be at least 2 characters for \(language)")
        }
    }

    // Identifiable Tests (AL-010)

    func testId_matchesRawValue() {
        for language in AppLanguage.allCases {
            XCTAssertEqual(language.id, language.rawValue, "ID should match raw value for \(language)")
        }
    }

    func testId_conformsToIdentifiable() {
        let language: any Identifiable = AppLanguage.english
        XCTAssertNotNil(language.id)
    }

    // Display Name Tests (AL-011 to AL-013)

    func testDisplayName_english() {
        XCTAssertEqual(AppLanguage.english.displayName, "English")
    }

    func testDisplayName_chinese() {
        XCTAssertEqual(AppLanguage.chinese.displayName, "简体中文")
    }

    func testDisplayName_chineseTraditional() {
        XCTAssertEqual(AppLanguage.chineseTraditional.displayName, "繁體中文")
    }

    func testDisplayName_japanese() {
        XCTAssertEqual(AppLanguage.japanese.displayName, "日本語")
    }

    func testDisplayName_korean() {
        XCTAssertEqual(AppLanguage.korean.displayName, "한국어")
    }

    func testDisplayName_french() {
        XCTAssertEqual(AppLanguage.french.displayName, "Francais")
    }

    func testDisplayName_german() {
        XCTAssertEqual(AppLanguage.german.displayName, "Deutsch")
    }

    func testDisplayName_spanish() {
        XCTAssertEqual(AppLanguage.spanish.displayName, "Espanol")
    }

    func testDisplayName_allLanguagesHaveDisplayNames() {
        for language in AppLanguage.allCases {
            XCTAssertFalse(language.displayName.isEmpty, "Display name should not be empty for \(language)")
        }
    }

    func testDisplayName_allAreUnique() {
        let displayNames = AppLanguage.allCases.map { $0.displayName }
        let uniqueDisplayNames = Set(displayNames)
        XCTAssertEqual(displayNames.count, uniqueDisplayNames.count, "All display names should be unique")
    }

    func testDisplayName_nativeLanguageNames() {
        // Verify display names are in native language format
        XCTAssertTrue(AppLanguage.chinese.displayName.contains("中文"), "Chinese should contain native characters")
        XCTAssertTrue(AppLanguage.chineseTraditional.displayName.contains("中文"), "Traditional Chinese should contain native characters")
        XCTAssertTrue(AppLanguage.japanese.displayName.contains("日本"), "Japanese should contain native characters")
        XCTAssertTrue(AppLanguage.korean.displayName.contains("한국"), "Korean should contain native characters")
    }

    // Bundle Tests (AL-014)

    func testBundle_returnsBundle() {
        for language in AppLanguage.allCases {
            let bundle = language.bundle
            XCTAssertNotNil(bundle, "Bundle should not be nil for \(language)")
        }
    }

    func testBundle_returnsBundleType() {
        for language in AppLanguage.allCases {
            let bundle = language.bundle
            XCTAssertFalse(bundle.bundlePath.isEmpty, "Bundle path should not be empty for \(language)")
        }
    }

    func testBundle_fallsBackToMainBundle() {
        // When lproj doesn't exist, should fall back to main bundle
        for language in AppLanguage.allCases {
            let bundle = language.bundle
            // Bundle should never be nil (falls back to main bundle)
            XCTAssertNotNil(bundle)
        }
    }

    // Initialization Tests (AL-015, AL-016)

    func testInit_fromValidRawValue() {
        XCTAssertEqual(AppLanguage(rawValue: "en"), .english)
        XCTAssertEqual(AppLanguage(rawValue: "zh-Hans"), .chinese)
        XCTAssertEqual(AppLanguage(rawValue: "zh-Hant"), .chineseTraditional)
        XCTAssertEqual(AppLanguage(rawValue: "ja"), .japanese)
        XCTAssertEqual(AppLanguage(rawValue: "ko"), .korean)
        XCTAssertEqual(AppLanguage(rawValue: "fr"), .french)
        XCTAssertEqual(AppLanguage(rawValue: "de"), .german)
        XCTAssertEqual(AppLanguage(rawValue: "es"), .spanish)
    }

    func testInit_fromInvalidRawValue() {
        XCTAssertNil(AppLanguage(rawValue: "invalid"), "Invalid raw value should return nil")
        XCTAssertNil(AppLanguage(rawValue: ""), "Empty raw value should return nil")
        XCTAssertNil(AppLanguage(rawValue: "EN"), "Case-sensitive: uppercase should return nil")
        XCTAssertNil(AppLanguage(rawValue: "english"), "Full name should return nil")
        XCTAssertNil(AppLanguage(rawValue: "zh"), "Partial code should return nil")
        XCTAssertNil(AppLanguage(rawValue: "pt"), "Unsupported language should return nil")
        XCTAssertNil(AppLanguage(rawValue: "ru"), "Unsupported language should return nil")
    }

    func testInit_caseSensitivity() {
        // Raw values are case-sensitive
        XCTAssertNil(AppLanguage(rawValue: "EN"))
        XCTAssertNil(AppLanguage(rawValue: "ZH-HANS"))
        XCTAssertNil(AppLanguage(rawValue: "Zh-Hans"))
        XCTAssertNotNil(AppLanguage(rawValue: "en"))
        XCTAssertNotNil(AppLanguage(rawValue: "zh-Hans"))
    }

    // CaseIterable Conformance Tests

    func testCaseIterable_conformance() {
        let allCases = AppLanguage.allCases
        XCTAssertEqual(allCases.count, 8)
    }

    func testCaseIterable_canIterate() {
        var count = 0
        for _ in AppLanguage.allCases {
            count += 1
        }
        XCTAssertEqual(count, 8)
    }

    // Equatable Tests

    func testEquatable_sameLanguage() {
        XCTAssertEqual(AppLanguage.english, AppLanguage.english)
        XCTAssertEqual(AppLanguage.chinese, AppLanguage.chinese)
    }

    func testEquatable_differentLanguage() {
        XCTAssertNotEqual(AppLanguage.english, AppLanguage.chinese)
        XCTAssertNotEqual(AppLanguage.chinese, AppLanguage.chineseTraditional)
        XCTAssertNotEqual(AppLanguage.japanese, AppLanguage.korean)
    }

    // Hashable Tests

    func testHashable_canBeUsedInSet() {
        var languageSet: Set<AppLanguage> = []
        languageSet.insert(.english)
        languageSet.insert(.chinese)
        languageSet.insert(.english) // Duplicate

        XCTAssertEqual(languageSet.count, 2)
        XCTAssertTrue(languageSet.contains(.english))
        XCTAssertTrue(languageSet.contains(.chinese))
    }

    func testHashable_canBeUsedAsDictionaryKey() {
        var languageDict: [AppLanguage: String] = [:]
        languageDict[.english] = "Hello"
        languageDict[.chinese] = "你好"

        XCTAssertEqual(languageDict[.english], "Hello")
        XCTAssertEqual(languageDict[.chinese], "你好")
    }

    // String Convertible Tests

    func testStringConvertible_description() {
        // AppLanguage should have meaningful string representation via rawValue
        for language in AppLanguage.allCases {
            let description = String(describing: language)
            XCTAssertFalse(description.isEmpty)
        }
    }

    // Edge Cases

    func testEdgeCase_allLanguagesCanBeCompared() {
        let sorted = AppLanguage.allCases.sorted { $0.rawValue < $1.rawValue }
        XCTAssertEqual(sorted.count, 8)
    }

    func testEdgeCase_languageCanBeOptional() {
        let optionalLanguage: AppLanguage? = .english
        XCTAssertNotNil(optionalLanguage)
        XCTAssertEqual(optionalLanguage, .english)
    }
}
