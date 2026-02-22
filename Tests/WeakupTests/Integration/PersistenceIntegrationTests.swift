import Foundation
import Testing
@testable import WeakupCore

/// Integration tests for persistence functionality
/// Tests that settings persist correctly across simulated app restarts
@Suite("Persistence Integration Tests", .serialized)
@MainActor
struct PersistenceIntegrationTests {

    init() {
        // Clear all UserDefaults before each test
        for key in UserDefaultsKeys.all {
            UserDefaultsStore.shared.removeObject(forKey: key)
        }
    }

    // Language Persistence Tests

    @Test("Language preference persists across launches")
    func languagePreference_persistsAcrossLaunches() {
        // Set language
        L10n.shared.setLanguage(.japanese)

        // Verify it's stored in UserDefaults
        let storedValue = UserDefaultsStore.shared.string(forKey: UserDefaultsKeys.language)
        #expect(storedValue == "ja")

        // Simulate reading on "restart" - L10n reads from UserDefaults on init
        // Since L10n is a singleton, we verify the stored value matches
        #expect(L10n.shared.currentLanguage == .japanese)
    }

    @Test("Language preference persists for all languages")
    func languagePreference_allLanguages() {
        for language in AppLanguage.allCases {
            L10n.shared.setLanguage(language)

            let storedValue = UserDefaultsStore.shared.string(forKey: UserDefaultsKeys.language)
            #expect(storedValue == language.rawValue,
                    "Language \(language) should persist correctly")
        }
    }

    // Timer Settings Persistence Tests

    @Test("Timer duration persists across launches")
    func timerDuration_persistsAcrossLaunches() {
        let viewModel = CaffeineViewModel()
        viewModel.setTimerDuration(1800) // 30 minutes

        // Verify stored
        let storedValue = UserDefaultsStore.shared.double(forKey: UserDefaultsKeys.timerDuration)
        #expect(storedValue == 1800)

        // Create new view model (simulating restart)
        let newViewModel = CaffeineViewModel()
        #expect(newViewModel.timerDuration == 1800, "Duration should persist")
    }

    @Test("Timer mode persists across launches")
    func timerMode_persistsAcrossLaunches() {
        let viewModel = CaffeineViewModel()
        viewModel.setTimerMode(true)

        // Verify stored
        let storedValue = UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.timerMode)
        #expect(storedValue == true)

        // Create new view model
        let newViewModel = CaffeineViewModel()
        #expect(newViewModel.timerMode, "Timer mode should persist")
    }

    @Test("Timer settings combined persistence")
    func timerSettings_combinedPersistence() {
        let viewModel = CaffeineViewModel()
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(3600) // 1 hour

        // Create new view model
        let newViewModel = CaffeineViewModel()
        #expect(newViewModel.timerMode)
        #expect(newViewModel.timerDuration == 3600)
    }

    // Sound Settings Persistence Tests

    @Test("Sound enabled persists across launches")
    func soundEnabled_persistsAcrossLaunches() {
        let viewModel = CaffeineViewModel()
        viewModel.soundEnabled = false

        // Verify stored
        let storedValue = UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.soundEnabled)
        #expect(storedValue == false)

        // Create new view model
        let newViewModel = CaffeineViewModel()
        #expect(!newViewModel.soundEnabled, "Sound setting should persist")
    }

    @Test("Sound enabled toggle persistence")
    func soundEnabled_togglePersistence() {
        let viewModel = CaffeineViewModel()

        // Toggle multiple times
        viewModel.soundEnabled = true
        #expect(UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.soundEnabled) == true)

        viewModel.soundEnabled = false
        #expect(UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.soundEnabled) == false)

        viewModel.soundEnabled = true
        #expect(UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.soundEnabled) == true)
    }

    // Icon Style Persistence Tests

    @Test("Icon style persists across launches")
    func iconStyle_persistsAcrossLaunches() {
        IconManager.shared.currentStyle = .bolt

        // Verify stored
        let storedValue = UserDefaultsStore.shared.string(forKey: UserDefaultsKeys.iconStyle)
        #expect(storedValue == "bolt")

        // Verify current style
        #expect(IconManager.shared.currentStyle == .bolt)
    }

    @Test("Icon style persists for all styles")
    func iconStyle_allStyles() {
        for style in IconStyle.allCases {
            IconManager.shared.currentStyle = style

            let storedValue = UserDefaultsStore.shared.string(forKey: UserDefaultsKeys.iconStyle)
            #expect(storedValue == style.rawValue,
                    "Icon style \(style) should persist correctly")
        }
    }

    // Theme Persistence Tests

    @Test("Theme persists across launches")
    func theme_persistsAcrossLaunches() {
        ThemeManager.shared.currentTheme = .dark

        // Verify stored
        let storedValue = UserDefaultsStore.shared.string(forKey: UserDefaultsKeys.theme)
        #expect(storedValue == "dark")

        // Verify current theme
        #expect(ThemeManager.shared.currentTheme == .dark)
    }

    @Test("Theme persists for all themes")
    func theme_allThemes() {
        for theme in AppTheme.allCases {
            ThemeManager.shared.currentTheme = theme

            let storedValue = UserDefaultsStore.shared.string(forKey: UserDefaultsKeys.theme)
            #expect(storedValue == theme.rawValue,
                    "Theme \(theme) should persist correctly")
        }
    }

    // Hotkey Persistence Tests

    @Test("Hotkey config persists across launches")
    func hotkeyConfig_persistsAcrossLaunches() {
        let customConfig = HotkeyConfig(keyCode: 0, modifiers: 256) // A with Cmd
        HotkeyManager.shared.currentConfig = customConfig

        // Verify stored
        let storedData = UserDefaultsStore.shared.data(forKey: UserDefaultsKeys.hotkeyConfig)
        #expect(storedData != nil, "Hotkey config should be stored as data")

        // Verify current config
        #expect(HotkeyManager.shared.currentConfig.keyCode == customConfig.keyCode)
        #expect(HotkeyManager.shared.currentConfig.modifiers == customConfig.modifiers)
    }

    @Test("Hotkey config reset to default")
    func hotkeyConfig_resetToDefault() {
        // Set custom config
        let customConfig = HotkeyConfig(keyCode: 1, modifiers: 512)
        HotkeyManager.shared.currentConfig = customConfig

        // Reset
        HotkeyManager.shared.resetToDefault()

        // Verify default is restored
        let defaultConfig = HotkeyConfig.defaultConfig
        #expect(HotkeyManager.shared.currentConfig.keyCode == defaultConfig.keyCode)
        #expect(HotkeyManager.shared.currentConfig.modifiers == defaultConfig.modifiers)
    }

    // Notifications Persistence Tests

    @Test("Notifications enabled persists across launches")
    func notificationsEnabled_persistsAcrossLaunches() {
        NotificationManager.shared.notificationsEnabled = false

        // Verify stored
        let storedValue = UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        #expect(storedValue == false)

        // Verify current value
        #expect(!NotificationManager.shared.notificationsEnabled)
    }

    // Menu Bar Countdown Persistence Tests

    @Test("Show countdown in menu bar persists across launches")
    func showCountdownInMenuBar_persistsAcrossLaunches() {
        let viewModel = CaffeineViewModel()
        viewModel.showCountdownInMenuBar = true

        // Verify stored
        let storedValue = UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.showCountdownInMenuBar)
        #expect(storedValue == true)

        // Create new view model
        let newViewModel = CaffeineViewModel()
        #expect(newViewModel.showCountdownInMenuBar, "Menu bar countdown setting should persist")
    }

    // Combined Settings Tests

    @Test("All settings persist together")
    func allSettings_persistTogether() {
        // Set all settings
        let viewModel = CaffeineViewModel()
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(1800)
        viewModel.soundEnabled = false
        viewModel.showCountdownInMenuBar = true

        L10n.shared.setLanguage(.korean)
        IconManager.shared.currentStyle = .cup
        ThemeManager.shared.currentTheme = .light
        NotificationManager.shared.notificationsEnabled = true

        // Verify all stored
        #expect(UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.timerMode) == true)
        #expect(UserDefaultsStore.shared.double(forKey: UserDefaultsKeys.timerDuration) == 1800)
        #expect(UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.soundEnabled) == false)
        #expect(UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.showCountdownInMenuBar) == true)
        #expect(UserDefaultsStore.shared.string(forKey: UserDefaultsKeys.language) == "ko")
        #expect(UserDefaultsStore.shared.string(forKey: UserDefaultsKeys.iconStyle) == "cup")
        #expect(UserDefaultsStore.shared.string(forKey: UserDefaultsKeys.theme) == "light")
        #expect(UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.notificationsEnabled) == true)
    }

    // Default Values Tests

    @Test("Default values when no stored data")
    func defaultValues_whenNoStoredData() {
        // Ensure no stored data
        for key in UserDefaultsKeys.all {
            UserDefaultsStore.shared.removeObject(forKey: key)
        }

        // Create fresh view model
        let viewModel = CaffeineViewModel()

        // Verify defaults
        #expect(!viewModel.isActive)
        #expect(!viewModel.timerMode)
        #expect(viewModel.timerDuration == 0)
        #expect(viewModel.timeRemaining == 0)
        // soundEnabled default is true
        #expect(viewModel.soundEnabled)
    }

    // Data Migration Tests

    @Test("Invalid stored data handled gracefully")
    func invalidStoredData_handledGracefully() {
        // Store invalid data
        UserDefaultsStore.shared.set("invalid", forKey: UserDefaultsKeys.timerDuration)
        UserDefaultsStore.shared.set("invalid", forKey: UserDefaultsKeys.timerMode)

        // Create view model - should not crash
        let viewModel = CaffeineViewModel()

        // Should have default values
        #expect(viewModel.timerDuration == 0)
        #expect(!viewModel.timerMode)
    }
}
