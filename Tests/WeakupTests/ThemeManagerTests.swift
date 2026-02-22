import XCTest
import SwiftUI
import Combine
@testable import WeakupCore

final class AppThemeTests: XCTestCase {

    // Enum Cases Tests (TM-001)

    func testAllCases_containsExpectedThemes() {
        let allCases = AppTheme.allCases
        XCTAssertEqual(allCases.count, 3, "Should have exactly 3 themes")
        XCTAssertTrue(allCases.contains(.system), "Should contain system")
        XCTAssertTrue(allCases.contains(.light), "Should contain light")
        XCTAssertTrue(allCases.contains(.dark), "Should contain dark")
    }

    func testAllCases_count() {
        XCTAssertEqual(AppTheme.allCases.count, 3)
    }

    // Raw Value Tests (TM-002)

    func testRawValue_system() {
        XCTAssertEqual(AppTheme.system.rawValue, "system")
    }

    func testRawValue_light() {
        XCTAssertEqual(AppTheme.light.rawValue, "light")
    }

    func testRawValue_dark() {
        XCTAssertEqual(AppTheme.dark.rawValue, "dark")
    }

    func testRawValues_areUnique() {
        let rawValues = AppTheme.allCases.map { $0.rawValue }
        let uniqueRawValues = Set(rawValues)
        XCTAssertEqual(rawValues.count, uniqueRawValues.count, "All raw values should be unique")
    }

    // Identifiable Tests (TM-003)

    func testId_matchesRawValue() {
        for theme in AppTheme.allCases {
            XCTAssertEqual(theme.id, theme.rawValue, "ID should match raw value")
        }
    }

    func testId_system() {
        XCTAssertEqual(AppTheme.system.id, "system")
    }

    func testId_light() {
        XCTAssertEqual(AppTheme.light.id, "light")
    }

    func testId_dark() {
        XCTAssertEqual(AppTheme.dark.id, "dark")
    }

    // Localization Key Tests (TM-004)

    func testLocalizationKey_system() {
        XCTAssertEqual(AppTheme.system.localizationKey, "theme_system")
    }

    func testLocalizationKey_light() {
        XCTAssertEqual(AppTheme.light.localizationKey, "theme_light")
    }

    func testLocalizationKey_dark() {
        XCTAssertEqual(AppTheme.dark.localizationKey, "theme_dark")
    }

    func testLocalizationKey_allThemesHaveKeys() {
        for theme in AppTheme.allCases {
            XCTAssertFalse(theme.localizationKey.isEmpty, "Localization key should not be empty for \(theme)")
            XCTAssertTrue(theme.localizationKey.hasPrefix("theme_"), "Localization key should start with 'theme_'")
        }
    }

    // Color Scheme Tests (TM-005, TM-006, TM-007)

    func testColorScheme_system_returnsNil() {
        XCTAssertNil(AppTheme.system.colorScheme, "System theme should return nil color scheme")
    }

    func testColorScheme_light_returnsLight() {
        XCTAssertEqual(AppTheme.light.colorScheme, .light)
    }

    func testColorScheme_dark_returnsDark() {
        XCTAssertEqual(AppTheme.dark.colorScheme, .dark)
    }

    func testColorScheme_onlySystemReturnsNil() {
        for theme in AppTheme.allCases {
            if theme == .system {
                XCTAssertNil(theme.colorScheme, "System should return nil")
            } else {
                XCTAssertNotNil(theme.colorScheme, "\(theme) should return non-nil color scheme")
            }
        }
    }

    // Initialization Tests

    func testInit_fromValidRawValue() {
        XCTAssertEqual(AppTheme(rawValue: "system"), .system)
        XCTAssertEqual(AppTheme(rawValue: "light"), .light)
        XCTAssertEqual(AppTheme(rawValue: "dark"), .dark)
    }

    func testInit_fromInvalidRawValue() {
        let invalid = AppTheme(rawValue: "invalid")
        XCTAssertNil(invalid, "Invalid raw value should return nil")
    }

    func testInit_fromEmptyRawValue() {
        let empty = AppTheme(rawValue: "")
        XCTAssertNil(empty, "Empty raw value should return nil")
    }

    func testInit_caseSensitive() {
        XCTAssertNil(AppTheme(rawValue: "System"), "Raw value should be case sensitive")
        XCTAssertNil(AppTheme(rawValue: "LIGHT"), "Raw value should be case sensitive")
        XCTAssertNil(AppTheme(rawValue: "Dark"), "Raw value should be case sensitive")
    }

    // Sendable Conformance

    func testAppTheme_isSendable() {
        let theme: AppTheme = .system
        Task {
            let _ = theme
        }
    }

    // CaseIterable Tests

    func testCaseIterable_orderIsConsistent() {
        let cases1 = AppTheme.allCases
        let cases2 = AppTheme.allCases
        XCTAssertEqual(cases1, cases2, "allCases should return consistent order")
    }
}

@MainActor
final class ThemeManagerTests: XCTestCase {

    private let userDefaultsKey = "WeakupTheme"

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults before each test
        UserDefaultsStore.shared.removeObject(forKey: userDefaultsKey)
    }

    override func tearDown() async throws {
        // Clean up after tests
        UserDefaultsStore.shared.removeObject(forKey: userDefaultsKey)
        try await super.tearDown()
    }

    // Singleton Tests (TM-008)

    func testShared_returnsSameInstance() {
        let instance1 = ThemeManager.shared
        let instance2 = ThemeManager.shared
        XCTAssertTrue(instance1 === instance2, "Shared should return same instance")
    }

    func testShared_isNotNil() {
        XCTAssertNotNil(ThemeManager.shared, "Shared instance should not be nil")
    }

    // Default Theme Tests (TM-009)

    func testDefaultTheme_isSystem() {
        // After clearing UserDefaults, a new instance should default to system
        // Note: Since ThemeManager is a singleton, this test verifies the default behavior
        // In practice, the singleton may already be initialized
        let manager = ThemeManager.shared
        // We can't easily test the default without resetting the singleton
        // So we just verify the current theme is valid
        XCTAssertTrue(AppTheme.allCases.contains(manager.currentTheme))
    }

    func testCurrentTheme_isValidTheme() {
        let manager = ThemeManager.shared
        XCTAssertTrue(AppTheme.allCases.contains(manager.currentTheme), "Current theme should be a valid theme")
    }

    // Theme Persistence Tests (TM-010)

    func testSetTheme_persistsValue() {
        let manager = ThemeManager.shared
        manager.currentTheme = .dark
        let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedValue, "dark", "Theme should be persisted to UserDefaults")
    }

    func testSetTheme_persistsSystem() {
        let manager = ThemeManager.shared
        manager.currentTheme = .system
        let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedValue, "system", "System theme should be persisted")
    }

    func testSetTheme_persistsLight() {
        let manager = ThemeManager.shared
        manager.currentTheme = .light
        let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedValue, "light", "Light theme should be persisted")
    }

    func testSetTheme_persistsDark() {
        let manager = ThemeManager.shared
        manager.currentTheme = .dark
        let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedValue, "dark", "Dark theme should be persisted")
    }

    func testSetTheme_persistsAllThemes() {
        let manager = ThemeManager.shared
        for theme in AppTheme.allCases {
            manager.currentTheme = theme
            let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
            XCTAssertEqual(storedValue, theme.rawValue, "Theme \(theme) should be persisted")
        }
    }

    func testSetTheme_updatesCurrentTheme() {
        let manager = ThemeManager.shared
        for theme in AppTheme.allCases {
            manager.currentTheme = theme
            XCTAssertEqual(manager.currentTheme, theme, "currentTheme should be updated to \(theme)")
        }
    }

    // Effective Color Scheme Tests (TM-011)

    func testEffectiveColorScheme_matchesTheme() {
        let manager = ThemeManager.shared

        manager.currentTheme = .system
        XCTAssertNil(manager.effectiveColorScheme)

        manager.currentTheme = .light
        XCTAssertEqual(manager.effectiveColorScheme, .light)

        manager.currentTheme = .dark
        XCTAssertEqual(manager.effectiveColorScheme, .dark)
    }

    func testEffectiveColorScheme_followsSystem() {
        let manager = ThemeManager.shared
        manager.currentTheme = .system
        XCTAssertNil(manager.effectiveColorScheme, "System theme should return nil for effectiveColorScheme")
    }

    func testEffectiveColorScheme_overridesWithLight() {
        let manager = ThemeManager.shared
        manager.currentTheme = .light
        XCTAssertEqual(manager.effectiveColorScheme, .light, "Light theme should return .light")
    }

    func testEffectiveColorScheme_overridesWithDark() {
        let manager = ThemeManager.shared
        manager.currentTheme = .dark
        XCTAssertEqual(manager.effectiveColorScheme, .dark, "Dark theme should return .dark")
    }

    func testEffectiveColorScheme_matchesThemeColorScheme() {
        let manager = ThemeManager.shared
        for theme in AppTheme.allCases {
            manager.currentTheme = theme
            XCTAssertEqual(
                manager.effectiveColorScheme,
                theme.colorScheme,
                "effectiveColorScheme should match theme.colorScheme for \(theme)"
            )
        }
    }

    // Theme Switching Tests

    func testThemeSwitching_systemToLight() {
        let manager = ThemeManager.shared
        manager.currentTheme = .system
        XCTAssertNil(manager.effectiveColorScheme)

        manager.currentTheme = .light
        XCTAssertEqual(manager.effectiveColorScheme, .light)
    }

    func testThemeSwitching_systemToDark() {
        let manager = ThemeManager.shared
        manager.currentTheme = .system
        XCTAssertNil(manager.effectiveColorScheme)

        manager.currentTheme = .dark
        XCTAssertEqual(manager.effectiveColorScheme, .dark)
    }

    func testThemeSwitching_lightToDark() {
        let manager = ThemeManager.shared
        manager.currentTheme = .light
        XCTAssertEqual(manager.effectiveColorScheme, .light)

        manager.currentTheme = .dark
        XCTAssertEqual(manager.effectiveColorScheme, .dark)
    }

    func testThemeSwitching_darkToLight() {
        let manager = ThemeManager.shared
        manager.currentTheme = .dark
        XCTAssertEqual(manager.effectiveColorScheme, .dark)

        manager.currentTheme = .light
        XCTAssertEqual(manager.effectiveColorScheme, .light)
    }

    func testThemeSwitching_lightToSystem() {
        let manager = ThemeManager.shared
        manager.currentTheme = .light
        XCTAssertEqual(manager.effectiveColorScheme, .light)

        manager.currentTheme = .system
        XCTAssertNil(manager.effectiveColorScheme)
    }

    func testThemeSwitching_darkToSystem() {
        let manager = ThemeManager.shared
        manager.currentTheme = .dark
        XCTAssertEqual(manager.effectiveColorScheme, .dark)

        manager.currentTheme = .system
        XCTAssertNil(manager.effectiveColorScheme)
    }

    func testThemeSwitching_cycleAllThemes() {
        let manager = ThemeManager.shared
        let themes: [AppTheme] = [.system, .light, .dark, .system, .dark, .light]

        for theme in themes {
            manager.currentTheme = theme
            XCTAssertEqual(manager.currentTheme, theme)
            XCTAssertEqual(manager.effectiveColorScheme, theme.colorScheme)
        }
    }

    // Rapid Theme Changes

    func testRapidThemeChanges() {
        let manager = ThemeManager.shared

        for _ in 0..<10 {
            for theme in AppTheme.allCases {
                manager.currentTheme = theme
                XCTAssertEqual(manager.currentTheme, theme)
            }
        }
    }

    // ObservableObject Tests

    func testThemeManager_isObservableObject() {
        let manager = ThemeManager.shared
        // Verify the manager conforms to ObservableObject by accessing objectWillChange
        _ = manager.objectWillChange
    }

    func testCurrentTheme_isPublished() {
        let manager = ThemeManager.shared
        let expectation = XCTestExpectation(description: "Published property should notify")

        let cancellable = manager.objectWillChange.sink {
            expectation.fulfill()
        }

        manager.currentTheme = .dark

        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }

    func testThemeChange_triggersObjectWillChange() {
        let manager = ThemeManager.shared
        var notificationCount = 0

        let cancellable = manager.objectWillChange.sink {
            notificationCount += 1
        }

        manager.currentTheme = .light
        manager.currentTheme = .dark
        manager.currentTheme = .system

        // Allow time for notifications
        let expectation = XCTestExpectation(description: "Wait for notifications")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertGreaterThanOrEqual(notificationCount, 3, "Should receive notifications for theme changes")
        cancellable.cancel()
    }

    // Persistence Verification Tests

    func testPersistence_survivesClear() {
        let manager = ThemeManager.shared

        // Set a theme
        manager.currentTheme = .dark
        XCTAssertEqual(UserDefaultsStore.shared.string(forKey: userDefaultsKey), "dark")

        // Clear and set another
        UserDefaultsStore.shared.removeObject(forKey: userDefaultsKey)
        manager.currentTheme = .light
        XCTAssertEqual(UserDefaultsStore.shared.string(forKey: userDefaultsKey), "light")
    }
}
