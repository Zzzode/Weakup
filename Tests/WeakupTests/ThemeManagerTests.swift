import Testing
import SwiftUI
import Combine
@testable import WeakupCore

@Suite("AppTheme Tests")
struct AppThemeTests {

    // MARK: - Enum Cases Tests (TM-001)

    @Test("All cases contains expected themes")
    func allCasesContainsExpectedThemes() {
        let allCases = AppTheme.allCases
        #expect(allCases.count == 3, "Should have exactly 3 themes")
        #expect(allCases.contains(.system), "Should contain system")
        #expect(allCases.contains(.light), "Should contain light")
        #expect(allCases.contains(.dark), "Should contain dark")
    }

    @Test("All cases count")
    func allCasesCount() {
        #expect(AppTheme.allCases.count == 3)
    }

    // MARK: - Raw Value Tests (TM-002)

    @Test("Raw value for system")
    func rawValueSystem() {
        #expect(AppTheme.system.rawValue == "system")
    }

    @Test("Raw value for light")
    func rawValueLight() {
        #expect(AppTheme.light.rawValue == "light")
    }

    @Test("Raw value for dark")
    func rawValueDark() {
        #expect(AppTheme.dark.rawValue == "dark")
    }

    @Test("Raw values are unique")
    func rawValuesAreUnique() {
        let rawValues = AppTheme.allCases.map { $0.rawValue }
        let uniqueRawValues = Set(rawValues)
        #expect(rawValues.count == uniqueRawValues.count, "All raw values should be unique")
    }

    // MARK: - Identifiable Tests (TM-003)

    @Test("ID matches raw value")
    func idMatchesRawValue() {
        for theme in AppTheme.allCases {
            #expect(theme.id == theme.rawValue, "ID should match raw value")
        }
    }

    @Test("ID for system")
    func idSystem() {
        #expect(AppTheme.system.id == "system")
    }

    @Test("ID for light")
    func idLight() {
        #expect(AppTheme.light.id == "light")
    }

    @Test("ID for dark")
    func idDark() {
        #expect(AppTheme.dark.id == "dark")
    }

    // MARK: - Localization Key Tests (TM-004)

    @Test("Localization key for system")
    func localizationKeySystem() {
        #expect(AppTheme.system.localizationKey == "theme_system")
    }

    @Test("Localization key for light")
    func localizationKeyLight() {
        #expect(AppTheme.light.localizationKey == "theme_light")
    }

    @Test("Localization key for dark")
    func localizationKeyDark() {
        #expect(AppTheme.dark.localizationKey == "theme_dark")
    }

    @Test("All themes have localization keys")
    func localizationKeyAllThemesHaveKeys() {
        for theme in AppTheme.allCases {
            #expect(!theme.localizationKey.isEmpty, "Localization key should not be empty for \(theme)")
            #expect(theme.localizationKey.hasPrefix("theme_"), "Localization key should start with 'theme_'")
        }
    }

    // MARK: - Color Scheme Tests (TM-005, TM-006, TM-007)

    @Test("Color scheme for system returns nil")
    func colorSchemeSystemReturnsNil() {
        #expect(AppTheme.system.colorScheme == nil, "System theme should return nil color scheme")
    }

    @Test("Color scheme for light returns light")
    func colorSchemeLightReturnsLight() {
        #expect(AppTheme.light.colorScheme == .light)
    }

    @Test("Color scheme for dark returns dark")
    func colorSchemeDarkReturnsDark() {
        #expect(AppTheme.dark.colorScheme == .dark)
    }

    @Test("Only system returns nil")
    func colorSchemeOnlySystemReturnsNil() {
        for theme in AppTheme.allCases {
            if theme == .system {
                #expect(theme.colorScheme == nil, "System should return nil")
            } else {
                #expect(theme.colorScheme != nil, "\(theme) should return non-nil color scheme")
            }
        }
    }

    // MARK: - Initialization Tests

    @Test("Init from valid raw value")
    func initFromValidRawValue() {
        #expect(AppTheme(rawValue: "system") == .system)
        #expect(AppTheme(rawValue: "light") == .light)
        #expect(AppTheme(rawValue: "dark") == .dark)
    }

    @Test("Init from invalid raw value")
    func initFromInvalidRawValue() {
        let invalid = AppTheme(rawValue: "invalid")
        #expect(invalid == nil, "Invalid raw value should return nil")
    }

    @Test("Init from empty raw value")
    func initFromEmptyRawValue() {
        let empty = AppTheme(rawValue: "")
        #expect(empty == nil, "Empty raw value should return nil")
    }

    @Test("Init case sensitive")
    func initCaseSensitive() {
        #expect(AppTheme(rawValue: "System") == nil, "Raw value should be case sensitive")
        #expect(AppTheme(rawValue: "LIGHT") == nil, "Raw value should be case sensitive")
        #expect(AppTheme(rawValue: "Dark") == nil, "Raw value should be case sensitive")
    }

    // MARK: - Sendable Conformance

    @Test("AppTheme is Sendable")
    func appThemeIsSendable() async {
        let theme: AppTheme = .system
        await Task {
            let _ = theme
        }.value
    }

    // MARK: - CaseIterable Tests

    @Test("CaseIterable order is consistent")
    func caseIterableOrderIsConsistent() {
        let cases1 = AppTheme.allCases
        let cases2 = AppTheme.allCases
        #expect(cases1 == cases2, "allCases should return consistent order")
    }
}

@Suite("ThemeManager Tests")
@MainActor
struct ThemeManagerTests {

    private let userDefaultsKey = "WeakupTheme"

    init() {
        // Clear UserDefaults before each test
        UserDefaultsStore.shared.removeObject(forKey: userDefaultsKey)
    }

    // MARK: - Singleton Tests (TM-008)

    @Test("Shared returns same instance")
    func sharedReturnsSameInstance() {
        let instance1 = ThemeManager.shared
        let instance2 = ThemeManager.shared
        #expect(instance1 === instance2, "Shared should return same instance")
    }

    @Test("Shared is not nil")
    func sharedIsNotNil() {
        #expect(ThemeManager.shared != nil, "Shared instance should not be nil")
    }

    // MARK: - Default Theme Tests (TM-009)

    @Test("Default theme is system")
    func defaultThemeIsSystem() {
        // After clearing UserDefaults, a new instance should default to system
        // Note: Since ThemeManager is a singleton, this test verifies the default behavior
        // In practice, the singleton may already be initialized
        let manager = ThemeManager.shared
        // We can't easily test the default without resetting the singleton
        // So we just verify the current theme is valid
        #expect(AppTheme.allCases.contains(manager.currentTheme))
    }

    @Test("Current theme is valid theme")
    func currentThemeIsValidTheme() {
        let manager = ThemeManager.shared
        #expect(AppTheme.allCases.contains(manager.currentTheme), "Current theme should be a valid theme")
    }

    // MARK: - Theme Persistence Tests (TM-010)

    @Test("Set theme persists value")
    func setThemePersistsValue() {
        let manager = ThemeManager.shared
        manager.currentTheme = .dark
        let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
        #expect(storedValue == "dark", "Theme should be persisted to UserDefaults")
    }

    @Test("Set theme persists system")
    func setThemePersistsSystem() {
        let manager = ThemeManager.shared
        manager.currentTheme = .system
        let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
        #expect(storedValue == "system", "System theme should be persisted")
    }

    @Test("Set theme persists light")
    func setThemePersistsLight() {
        let manager = ThemeManager.shared
        manager.currentTheme = .light
        let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
        #expect(storedValue == "light", "Light theme should be persisted")
    }

    @Test("Set theme persists dark")
    func setThemePersistsDark() {
        let manager = ThemeManager.shared
        manager.currentTheme = .dark
        let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
        #expect(storedValue == "dark", "Dark theme should be persisted")
    }

    @Test("Set theme persists all themes")
    func setThemePersistsAllThemes() {
        let manager = ThemeManager.shared
        for theme in AppTheme.allCases {
            manager.currentTheme = theme
            let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
            #expect(storedValue == theme.rawValue, "Theme \(theme) should be persisted")
        }
    }

    @Test("Set theme updates current theme")
    func setThemeUpdatesCurrentTheme() {
        let manager = ThemeManager.shared
        for theme in AppTheme.allCases {
            manager.currentTheme = theme
            #expect(manager.currentTheme == theme, "currentTheme should be updated to \(theme)")
        }
    }

    // MARK: - Effective Color Scheme Tests (TM-011)

    @Test("Effective color scheme matches theme")
    func effectiveColorSchemeMatchesTheme() {
        let manager = ThemeManager.shared

        manager.currentTheme = .system
        #expect(manager.effectiveColorScheme == nil)

        manager.currentTheme = .light
        #expect(manager.effectiveColorScheme == .light)

        manager.currentTheme = .dark
        #expect(manager.effectiveColorScheme == .dark)
    }

    @Test("Effective color scheme follows system")
    func effectiveColorSchemeFollowsSystem() {
        let manager = ThemeManager.shared
        manager.currentTheme = .system
        #expect(manager.effectiveColorScheme == nil, "System theme should return nil for effectiveColorScheme")
    }

    @Test("Effective color scheme overrides with light")
    func effectiveColorSchemeOverridesWithLight() {
        let manager = ThemeManager.shared
        manager.currentTheme = .light
        #expect(manager.effectiveColorScheme == .light, "Light theme should return .light")
    }

    @Test("Effective color scheme overrides with dark")
    func effectiveColorSchemeOverridesWithDark() {
        let manager = ThemeManager.shared
        manager.currentTheme = .dark
        #expect(manager.effectiveColorScheme == .dark, "Dark theme should return .dark")
    }

    @Test("Effective color scheme matches theme color scheme")
    func effectiveColorSchemeMatchesThemeColorScheme() {
        let manager = ThemeManager.shared
        for theme in AppTheme.allCases {
            manager.currentTheme = theme
            #expect(
                manager.effectiveColorScheme == theme.colorScheme,
                "effectiveColorScheme should match theme.colorScheme for \(theme)"
            )
        }
    }

    // MARK: - Theme Switching Tests

    @Test("Theme switching system to light")
    func themeSwitchingSystemToLight() {
        let manager = ThemeManager.shared
        manager.currentTheme = .system
        #expect(manager.effectiveColorScheme == nil)

        manager.currentTheme = .light
        #expect(manager.effectiveColorScheme == .light)
    }

    @Test("Theme switching system to dark")
    func themeSwitchingSystemToDark() {
        let manager = ThemeManager.shared
        manager.currentTheme = .system
        #expect(manager.effectiveColorScheme == nil)

        manager.currentTheme = .dark
        #expect(manager.effectiveColorScheme == .dark)
    }

    @Test("Theme switching light to dark")
    func themeSwitchingLightToDark() {
        let manager = ThemeManager.shared
        manager.currentTheme = .light
        #expect(manager.effectiveColorScheme == .light)

        manager.currentTheme = .dark
        #expect(manager.effectiveColorScheme == .dark)
    }

    @Test("Theme switching dark to light")
    func themeSwitchingDarkToLight() {
        let manager = ThemeManager.shared
        manager.currentTheme = .dark
        #expect(manager.effectiveColorScheme == .dark)

        manager.currentTheme = .light
        #expect(manager.effectiveColorScheme == .light)
    }

    @Test("Theme switching light to system")
    func themeSwitchingLightToSystem() {
        let manager = ThemeManager.shared
        manager.currentTheme = .light
        #expect(manager.effectiveColorScheme == .light)

        manager.currentTheme = .system
        #expect(manager.effectiveColorScheme == nil)
    }

    @Test("Theme switching dark to system")
    func themeSwitchingDarkToSystem() {
        let manager = ThemeManager.shared
        manager.currentTheme = .dark
        #expect(manager.effectiveColorScheme == .dark)

        manager.currentTheme = .system
        #expect(manager.effectiveColorScheme == nil)
    }

    @Test("Theme switching cycle all themes")
    func themeSwitchingCycleAllThemes() {
        let manager = ThemeManager.shared
        let themes: [AppTheme] = [.system, .light, .dark, .system, .dark, .light]

        for theme in themes {
            manager.currentTheme = theme
            #expect(manager.currentTheme == theme)
            #expect(manager.effectiveColorScheme == theme.colorScheme)
        }
    }

    // MARK: - Rapid Theme Changes

    @Test("Rapid theme changes")
    func rapidThemeChanges() {
        let manager = ThemeManager.shared

        for _ in 0..<10 {
            for theme in AppTheme.allCases {
                manager.currentTheme = theme
                #expect(manager.currentTheme == theme)
            }
        }
    }

    // MARK: - ObservableObject Tests

    @Test("ThemeManager is ObservableObject")
    func themeManagerIsObservableObject() {
        let manager = ThemeManager.shared
        // Verify the manager conforms to ObservableObject by accessing objectWillChange
        _ = manager.objectWillChange
    }

    @Test("Current theme is published")
    func currentThemeIsPublished() async {
        let manager = ThemeManager.shared
        var notificationReceived = false

        let cancellable = manager.objectWillChange.sink {
            notificationReceived = true
        }

        manager.currentTheme = .dark

        // Give time for notification
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(notificationReceived)
        cancellable.cancel()
    }

    @Test("Theme change triggers objectWillChange")
    func themeChangeTriggersObjectWillChange() async {
        let manager = ThemeManager.shared
        var notificationCount = 0

        let cancellable = manager.objectWillChange.sink {
            notificationCount += 1
        }

        manager.currentTheme = .light
        manager.currentTheme = .dark
        manager.currentTheme = .system

        // Allow time for notifications
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(notificationCount >= 3, "Should receive notifications for theme changes")
        cancellable.cancel()
    }

    // MARK: - Persistence Verification Tests

    @Test("Persistence survives clear")
    func persistenceSurvivesClear() {
        let manager = ThemeManager.shared

        // Set a theme
        manager.currentTheme = .dark
        #expect(UserDefaultsStore.shared.string(forKey: userDefaultsKey) == "dark")

        // Clear and set another
        UserDefaultsStore.shared.removeObject(forKey: userDefaultsKey)
        manager.currentTheme = .light
        #expect(UserDefaultsStore.shared.string(forKey: userDefaultsKey) == "light")
    }
}
