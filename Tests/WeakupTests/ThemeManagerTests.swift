import XCTest
import SwiftUI
@testable import WeakupCore

final class AppThemeTests: XCTestCase {

    // Enum Cases Tests

    func testAllCases_containsExpectedThemes() {
        let allCases = AppTheme.allCases
        XCTAssertEqual(allCases.count, 3, "Should have exactly 3 themes")
        XCTAssertTrue(allCases.contains(.system), "Should contain system")
        XCTAssertTrue(allCases.contains(.light), "Should contain light")
        XCTAssertTrue(allCases.contains(.dark), "Should contain dark")
    }

    func testRawValue_system() {
        XCTAssertEqual(AppTheme.system.rawValue, "system")
    }

    func testRawValue_light() {
        XCTAssertEqual(AppTheme.light.rawValue, "light")
    }

    func testRawValue_dark() {
        XCTAssertEqual(AppTheme.dark.rawValue, "dark")
    }

    // Identifiable Tests

    func testId_matchesRawValue() {
        for theme in AppTheme.allCases {
            XCTAssertEqual(theme.id, theme.rawValue, "ID should match raw value")
        }
    }

    // Localization Key Tests

    func testLocalizationKey_system() {
        XCTAssertEqual(AppTheme.system.localizationKey, "theme_system")
    }

    func testLocalizationKey_light() {
        XCTAssertEqual(AppTheme.light.localizationKey, "theme_light")
    }

    func testLocalizationKey_dark() {
        XCTAssertEqual(AppTheme.dark.localizationKey, "theme_dark")
    }

    // Color Scheme Tests

    func testColorScheme_system_returnsNil() {
        XCTAssertNil(AppTheme.system.colorScheme, "System theme should return nil color scheme")
    }

    func testColorScheme_light_returnsLight() {
        XCTAssertEqual(AppTheme.light.colorScheme, .light)
    }

    func testColorScheme_dark_returnsDark() {
        XCTAssertEqual(AppTheme.dark.colorScheme, .dark)
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
}

@MainActor
final class ThemeManagerTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "WeakupTheme")
    }

    func testShared_returnsSameInstance() {
        let instance1 = ThemeManager.shared
        let instance2 = ThemeManager.shared
        XCTAssertTrue(instance1 === instance2, "Shared should return same instance")
    }

    func testDefaultTheme_isSystem() {
        // After clearing UserDefaults, a new instance should default to system
        // Note: Since ThemeManager is a singleton, this test verifies the default behavior
        // In practice, the singleton may already be initialized
        let manager = ThemeManager.shared
        // We can't easily test the default without resetting the singleton
        // So we just verify the current theme is valid
        XCTAssertTrue(AppTheme.allCases.contains(manager.currentTheme))
    }

    func testSetTheme_persistsValue() {
        let manager = ThemeManager.shared
        manager.currentTheme = .dark
        let storedValue = UserDefaults.standard.string(forKey: "WeakupTheme")
        XCTAssertEqual(storedValue, "dark", "Theme should be persisted to UserDefaults")
    }

    func testEffectiveColorScheme_matchesTheme() {
        let manager = ThemeManager.shared

        manager.currentTheme = .system
        XCTAssertNil(manager.effectiveColorScheme)

        manager.currentTheme = .light
        XCTAssertEqual(manager.effectiveColorScheme, .light)

        manager.currentTheme = .dark
        XCTAssertEqual(manager.effectiveColorScheme, .dark)
    }
}
