import XCTest
@testable import WeakupCore

/// Integration tests for persistence functionality
/// Tests that settings persist correctly across simulated app restarts
@MainActor
final class PersistenceIntegrationTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        // Clear all UserDefaults before each test
        for key in UserDefaultsKeys.all {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    override func tearDown() async throws {
        // Clean up
        for key in UserDefaultsKeys.all {
            UserDefaults.standard.removeObject(forKey: key)
        }
        try await super.tearDown()
    }

    // MARK: - Language Persistence Tests

    func testLanguagePreference_persistsAcrossLaunches() {
        // Set language
        L10n.shared.setLanguage(.japanese)

        // Verify it's stored in UserDefaults
        let storedValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.language)
        XCTAssertEqual(storedValue, "ja")

        // Simulate reading on "restart" - L10n reads from UserDefaults on init
        // Since L10n is a singleton, we verify the stored value matches
        XCTAssertEqual(L10n.shared.currentLanguage, .japanese)
    }

    func testLanguagePreference_allLanguages() {
        for language in AppLanguage.allCases {
            L10n.shared.setLanguage(language)

            let storedValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.language)
            XCTAssertEqual(storedValue, language.rawValue,
                           "Language \(language) should persist correctly")
        }
    }

    // MARK: - Timer Settings Persistence Tests

    func testTimerDuration_persistsAcrossLaunches() {
        let viewModel = CaffeineViewModel()
        viewModel.setTimerDuration(1800) // 30 minutes

        // Verify stored
        let storedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.timerDuration)
        XCTAssertEqual(storedValue, 1800)

        // Create new view model (simulating restart)
        let newViewModel = CaffeineViewModel()
        XCTAssertEqual(newViewModel.timerDuration, 1800, "Duration should persist")
    }

    func testTimerMode_persistsAcrossLaunches() {
        let viewModel = CaffeineViewModel()
        viewModel.setTimerMode(true)

        // Verify stored
        let storedValue = UserDefaults.standard.bool(forKey: UserDefaultsKeys.timerMode)
        XCTAssertTrue(storedValue)

        // Create new view model
        let newViewModel = CaffeineViewModel()
        XCTAssertTrue(newViewModel.timerMode, "Timer mode should persist")
    }

    func testTimerSettings_combinedPersistence() {
        let viewModel = CaffeineViewModel()
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(3600) // 1 hour

        // Create new view model
        let newViewModel = CaffeineViewModel()
        XCTAssertTrue(newViewModel.timerMode)
        XCTAssertEqual(newViewModel.timerDuration, 3600)
    }

    // MARK: - Sound Settings Persistence Tests

    func testSoundEnabled_persistsAcrossLaunches() {
        let viewModel = CaffeineViewModel()
        viewModel.soundEnabled = false

        // Verify stored
        let storedValue = UserDefaults.standard.bool(forKey: UserDefaultsKeys.soundEnabled)
        XCTAssertFalse(storedValue)

        // Create new view model
        let newViewModel = CaffeineViewModel()
        XCTAssertFalse(newViewModel.soundEnabled, "Sound setting should persist")
    }

    func testSoundEnabled_togglePersistence() {
        let viewModel = CaffeineViewModel()

        // Toggle multiple times
        viewModel.soundEnabled = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: UserDefaultsKeys.soundEnabled))

        viewModel.soundEnabled = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: UserDefaultsKeys.soundEnabled))

        viewModel.soundEnabled = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: UserDefaultsKeys.soundEnabled))
    }

    // MARK: - Icon Style Persistence Tests

    func testIconStyle_persistsAcrossLaunches() {
        IconManager.shared.currentStyle = .bolt

        // Verify stored
        let storedValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.iconStyle)
        XCTAssertEqual(storedValue, "bolt")

        // Verify current style
        XCTAssertEqual(IconManager.shared.currentStyle, .bolt)
    }

    func testIconStyle_allStyles() {
        for style in IconStyle.allCases {
            IconManager.shared.currentStyle = style

            let storedValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.iconStyle)
            XCTAssertEqual(storedValue, style.rawValue,
                           "Icon style \(style) should persist correctly")
        }
    }

    // MARK: - Theme Persistence Tests

    func testTheme_persistsAcrossLaunches() {
        ThemeManager.shared.currentTheme = .dark

        // Verify stored
        let storedValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.theme)
        XCTAssertEqual(storedValue, "dark")

        // Verify current theme
        XCTAssertEqual(ThemeManager.shared.currentTheme, .dark)
    }

    func testTheme_allThemes() {
        for theme in AppTheme.allCases {
            ThemeManager.shared.currentTheme = theme

            let storedValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.theme)
            XCTAssertEqual(storedValue, theme.rawValue,
                           "Theme \(theme) should persist correctly")
        }
    }

    // MARK: - Hotkey Persistence Tests

    func testHotkeyConfig_persistsAcrossLaunches() {
        let customConfig = HotkeyConfig(keyCode: 0, modifiers: 256) // A with Cmd
        HotkeyManager.shared.currentConfig = customConfig

        // Verify stored
        let storedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.hotkeyConfig)
        XCTAssertNotNil(storedData, "Hotkey config should be stored as data")

        // Verify current config
        XCTAssertEqual(HotkeyManager.shared.currentConfig.keyCode, customConfig.keyCode)
        XCTAssertEqual(HotkeyManager.shared.currentConfig.modifiers, customConfig.modifiers)
    }

    func testHotkeyConfig_resetToDefault() {
        // Set custom config
        let customConfig = HotkeyConfig(keyCode: 1, modifiers: 512)
        HotkeyManager.shared.currentConfig = customConfig

        // Reset
        HotkeyManager.shared.resetToDefault()

        // Verify default is restored
        let defaultConfig = HotkeyConfig.defaultConfig
        XCTAssertEqual(HotkeyManager.shared.currentConfig.keyCode, defaultConfig.keyCode)
        XCTAssertEqual(HotkeyManager.shared.currentConfig.modifiers, defaultConfig.modifiers)
    }

    // MARK: - Notifications Persistence Tests

    func testNotificationsEnabled_persistsAcrossLaunches() {
        NotificationManager.shared.notificationsEnabled = false

        // Verify stored
        let storedValue = UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        XCTAssertFalse(storedValue)

        // Verify current value
        XCTAssertFalse(NotificationManager.shared.notificationsEnabled)
    }

    // MARK: - Menu Bar Countdown Persistence Tests

    func testShowCountdownInMenuBar_persistsAcrossLaunches() {
        let viewModel = CaffeineViewModel()
        viewModel.showCountdownInMenuBar = true

        // Verify stored
        let storedValue = UserDefaults.standard.bool(forKey: UserDefaultsKeys.showCountdownInMenuBar)
        XCTAssertTrue(storedValue)

        // Create new view model
        let newViewModel = CaffeineViewModel()
        XCTAssertTrue(newViewModel.showCountdownInMenuBar, "Menu bar countdown setting should persist")
    }

    // MARK: - Combined Settings Tests

    func testAllSettings_persistTogether() {
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
        XCTAssertTrue(UserDefaults.standard.bool(forKey: UserDefaultsKeys.timerMode))
        XCTAssertEqual(UserDefaults.standard.double(forKey: UserDefaultsKeys.timerDuration), 1800)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: UserDefaultsKeys.soundEnabled))
        XCTAssertTrue(UserDefaults.standard.bool(forKey: UserDefaultsKeys.showCountdownInMenuBar))
        XCTAssertEqual(UserDefaults.standard.string(forKey: UserDefaultsKeys.language), "ko")
        XCTAssertEqual(UserDefaults.standard.string(forKey: UserDefaultsKeys.iconStyle), "cup")
        XCTAssertEqual(UserDefaults.standard.string(forKey: UserDefaultsKeys.theme), "light")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationsEnabled))
    }

    // MARK: - Default Values Tests

    func testDefaultValues_whenNoStoredData() {
        // Ensure no stored data
        for key in UserDefaultsKeys.all {
            UserDefaults.standard.removeObject(forKey: key)
        }

        // Create fresh view model
        let viewModel = CaffeineViewModel()

        // Verify defaults
        XCTAssertFalse(viewModel.isActive)
        XCTAssertFalse(viewModel.timerMode)
        XCTAssertEqual(viewModel.timerDuration, 0)
        XCTAssertEqual(viewModel.timeRemaining, 0)
        // soundEnabled default is true
        XCTAssertTrue(viewModel.soundEnabled)
    }

    // MARK: - Data Migration Tests

    func testInvalidStoredData_handledGracefully() {
        // Store invalid data
        UserDefaults.standard.set("invalid", forKey: UserDefaultsKeys.timerDuration)
        UserDefaults.standard.set("invalid", forKey: UserDefaultsKeys.timerMode)

        // Create view model - should not crash
        let viewModel = CaffeineViewModel()

        // Should have default values
        XCTAssertEqual(viewModel.timerDuration, 0)
        XCTAssertFalse(viewModel.timerMode)
    }
}
