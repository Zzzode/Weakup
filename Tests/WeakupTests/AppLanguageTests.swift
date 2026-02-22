import Testing
@testable import WeakupCore

@Suite("AppLanguage Tests")
struct AppLanguageTests {

    // Enum Cases Tests (AL-001)

    @Test("All cases contains expected languages")
    func allCasesContainsExpectedLanguages() {
        let allCases = AppLanguage.allCases
        #expect(allCases.count == 8, "Should have exactly 8 languages")
        #expect(allCases.contains(.english), "Should contain English")
        #expect(allCases.contains(.chinese), "Should contain Chinese Simplified")
        #expect(allCases.contains(.chineseTraditional), "Should contain Chinese Traditional")
        #expect(allCases.contains(.japanese), "Should contain Japanese")
        #expect(allCases.contains(.korean), "Should contain Korean")
        #expect(allCases.contains(.french), "Should contain French")
        #expect(allCases.contains(.german), "Should contain German")
        #expect(allCases.contains(.spanish), "Should contain Spanish")
    }

    @Test("All cases order is consistent")
    func allCasesOrderIsConsistent() {
        let cases = AppLanguage.allCases
        #expect(cases[0] == .english)
        #expect(cases[1] == .chinese)
        #expect(cases[2] == .chineseTraditional)
        #expect(cases[3] == .japanese)
        #expect(cases[4] == .korean)
        #expect(cases[5] == .french)
        #expect(cases[6] == .german)
        #expect(cases[7] == .spanish)
    }

    // Raw Value Tests (AL-002 to AL-009)

    @Test("Raw value for English")
    func rawValueEnglish() {
        #expect(AppLanguage.english.rawValue == "en")
    }

    @Test("Raw value for Chinese")
    func rawValueChinese() {
        #expect(AppLanguage.chinese.rawValue == "zh-Hans")
    }

    @Test("Raw value for Chinese Traditional")
    func rawValueChineseTraditional() {
        #expect(AppLanguage.chineseTraditional.rawValue == "zh-Hant")
    }

    @Test("Raw value for Japanese")
    func rawValueJapanese() {
        #expect(AppLanguage.japanese.rawValue == "ja")
    }

    @Test("Raw value for Korean")
    func rawValueKorean() {
        #expect(AppLanguage.korean.rawValue == "ko")
    }

    @Test("Raw value for French")
    func rawValueFrench() {
        #expect(AppLanguage.french.rawValue == "fr")
    }

    @Test("Raw value for German")
    func rawValueGerman() {
        #expect(AppLanguage.german.rawValue == "de")
    }

    @Test("Raw value for Spanish")
    func rawValueSpanish() {
        #expect(AppLanguage.spanish.rawValue == "es")
    }

    @Test("All raw values are unique")
    func rawValueAllAreUnique() {
        let rawValues = AppLanguage.allCases.map { $0.rawValue }
        let uniqueRawValues = Set(rawValues)
        #expect(rawValues.count == uniqueRawValues.count, "All raw values should be unique")
    }

    @Test("All raw values are valid locale identifiers")
    func rawValueAllAreValidLocaleIdentifiers() {
        for language in AppLanguage.allCases {
            let rawValue = language.rawValue
            #expect(!rawValue.isEmpty, "Raw value should not be empty for \(language)")
            #expect(rawValue.count >= 2, "Raw value should be at least 2 characters for \(language)")
        }
    }

    // Identifiable Tests (AL-010)

    @Test("ID matches raw value")
    func idMatchesRawValue() {
        for language in AppLanguage.allCases {
            #expect(language.id == language.rawValue, "ID should match raw value for \(language)")
        }
    }

    @Test("Conforms to Identifiable")
    func idConformsToIdentifiable() {
        let language: any Identifiable = AppLanguage.english
        #expect(language.id != nil)
    }

    // Display Name Tests (AL-011 to AL-013)

    @Test("Display name for English")
    func displayNameEnglish() {
        #expect(AppLanguage.english.displayName == "English")
    }

    @Test("Display name for Chinese")
    func displayNameChinese() {
        #expect(AppLanguage.chinese.displayName == "简体中文")
    }

    @Test("Display name for Chinese Traditional")
    func displayNameChineseTraditional() {
        #expect(AppLanguage.chineseTraditional.displayName == "繁體中文")
    }

    @Test("Display name for Japanese")
    func displayNameJapanese() {
        #expect(AppLanguage.japanese.displayName == "日本語")
    }

    @Test("Display name for Korean")
    func displayNameKorean() {
        #expect(AppLanguage.korean.displayName == "한국어")
    }

    @Test("Display name for French")
    func displayNameFrench() {
        #expect(AppLanguage.french.displayName == "Francais")
    }

    @Test("Display name for German")
    func displayNameGerman() {
        #expect(AppLanguage.german.displayName == "Deutsch")
    }

    @Test("Display name for Spanish")
    func displayNameSpanish() {
        #expect(AppLanguage.spanish.displayName == "Espanol")
    }

    @Test("All languages have display names")
    func displayNameAllLanguagesHaveDisplayNames() {
        for language in AppLanguage.allCases {
            #expect(!language.displayName.isEmpty, "Display name should not be empty for \(language)")
        }
    }

    @Test("All display names are unique")
    func displayNameAllAreUnique() {
        let displayNames = AppLanguage.allCases.map { $0.displayName }
        let uniqueDisplayNames = Set(displayNames)
        #expect(displayNames.count == uniqueDisplayNames.count, "All display names should be unique")
    }

    @Test("Display names are in native language")
    func displayNameNativeLanguageNames() {
        // Verify display names are in native language format
        #expect(AppLanguage.chinese.displayName.contains("中文"), "Chinese should contain native characters")
        #expect(AppLanguage.chineseTraditional.displayName.contains("中文"), "Traditional Chinese should contain native characters")
        #expect(AppLanguage.japanese.displayName.contains("日本"), "Japanese should contain native characters")
        #expect(AppLanguage.korean.displayName.contains("한국"), "Korean should contain native characters")
    }

    // Bundle Tests (AL-014)

    @Test("Bundle returns bundle")
    func bundleReturnsBundle() {
        for language in AppLanguage.allCases {
            let bundle = language.bundle
            #expect(bundle != nil, "Bundle should not be nil for \(language)")
        }
    }

    @Test("Bundle returns bundle type")
    func bundleReturnsBundleType() {
        for language in AppLanguage.allCases {
            let bundle = language.bundle
            #expect(!bundle.bundlePath.isEmpty, "Bundle path should not be empty for \(language)")
        }
    }

    @Test("Bundle falls back to main bundle")
    func bundleFallsBackToMainBundle() {
        // When lproj doesn't exist, should fall back to main bundle
        for language in AppLanguage.allCases {
            let bundle = language.bundle
            // Bundle should never be nil (falls back to main bundle)
            #expect(bundle != nil)
        }
    }

    // Initialization Tests (AL-015, AL-016)

    @Test("Init from valid raw value")
    func initFromValidRawValue() {
        #expect(AppLanguage(rawValue: "en") == .english)
        #expect(AppLanguage(rawValue: "zh-Hans") == .chinese)
        #expect(AppLanguage(rawValue: "zh-Hant") == .chineseTraditional)
        #expect(AppLanguage(rawValue: "ja") == .japanese)
        #expect(AppLanguage(rawValue: "ko") == .korean)
        #expect(AppLanguage(rawValue: "fr") == .french)
        #expect(AppLanguage(rawValue: "de") == .german)
        #expect(AppLanguage(rawValue: "es") == .spanish)
    }

    @Test("Init from invalid raw value")
    func initFromInvalidRawValue() {
        #expect(AppLanguage(rawValue: "invalid") == nil, "Invalid raw value should return nil")
        #expect(AppLanguage(rawValue: "") == nil, "Empty raw value should return nil")
        #expect(AppLanguage(rawValue: "EN") == nil, "Case-sensitive: uppercase should return nil")
        #expect(AppLanguage(rawValue: "english") == nil, "Full name should return nil")
        #expect(AppLanguage(rawValue: "zh") == nil, "Partial code should return nil")
        #expect(AppLanguage(rawValue: "pt") == nil, "Unsupported language should return nil")
        #expect(AppLanguage(rawValue: "ru") == nil, "Unsupported language should return nil")
    }

    @Test("Init case sensitivity")
    func initCaseSensitivity() {
        // Raw values are case-sensitive
        #expect(AppLanguage(rawValue: "EN") == nil)
        #expect(AppLanguage(rawValue: "ZH-HANS") == nil)
        #expect(AppLanguage(rawValue: "Zh-Hans") == nil)
        #expect(AppLanguage(rawValue: "en") != nil)
        #expect(AppLanguage(rawValue: "zh-Hans") != nil)
    }

    // CaseIterable Conformance Tests

    @Test("CaseIterable conformance")
    func caseIterableConformance() {
        let allCases = AppLanguage.allCases
        #expect(allCases.count == 8)
    }

    @Test("CaseIterable can iterate")
    func caseIterableCanIterate() {
        var count = 0
        for _ in AppLanguage.allCases {
            count += 1
        }
        #expect(count == 8)
    }

    // Equatable Tests

    @Test("Equatable same language")
    func equatableSameLanguage() {
        #expect(AppLanguage.english == AppLanguage.english)
        #expect(AppLanguage.chinese == AppLanguage.chinese)
    }

    @Test("Equatable different language")
    func equatableDifferentLanguage() {
        #expect(AppLanguage.english != AppLanguage.chinese)
        #expect(AppLanguage.chinese != AppLanguage.chineseTraditional)
        #expect(AppLanguage.japanese != AppLanguage.korean)
    }

    // Hashable Tests

    @Test("Hashable can be used in Set")
    func hashableCanBeUsedInSet() {
        var languageSet: Set<AppLanguage> = []
        languageSet.insert(.english)
        languageSet.insert(.chinese)
        languageSet.insert(.english) // Duplicate

        #expect(languageSet.count == 2)
        #expect(languageSet.contains(.english))
        #expect(languageSet.contains(.chinese))
    }

    @Test("Hashable can be used as dictionary key")
    func hashableCanBeUsedAsDictionaryKey() {
        var languageDict: [AppLanguage: String] = [:]
        languageDict[.english] = "Hello"
        languageDict[.chinese] = "你好"

        #expect(languageDict[.english] == "Hello")
        #expect(languageDict[.chinese] == "你好")
    }

    // String Convertible Tests

    @Test("String convertible description")
    func stringConvertibleDescription() {
        // AppLanguage should have meaningful string representation via rawValue
        for language in AppLanguage.allCases {
            let description = String(describing: language)
            #expect(!description.isEmpty)
        }
    }

    // Edge Cases

    @Test("Edge case: all languages can be compared")
    func edgeCaseAllLanguagesCanBeCompared() {
        let sorted = AppLanguage.allCases.sorted { $0.rawValue < $1.rawValue }
        #expect(sorted.count == 8)
    }

    @Test("Edge case: language can be optional")
    func edgeCaseLanguageCanBeOptional() {
        let optionalLanguage: AppLanguage? = .english
        #expect(optionalLanguage != nil)
        #expect(optionalLanguage == .english)
    }
}
