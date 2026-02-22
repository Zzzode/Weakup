import Foundation
@testable import WeakupCore

// Timer Duration Fixtures

enum TestTimerDurations {
    // Use centralized constants from AppConstants
    static var off: TimeInterval { AppConstants.TimerPresets.off }
    static var fifteenMinutes: TimeInterval { AppConstants.TimerPresets.fifteenMinutes }
    static var thirtyMinutes: TimeInterval { AppConstants.TimerPresets.thirtyMinutes }
    static var oneHour: TimeInterval { AppConstants.TimerPresets.oneHour }
    static var twoHours: TimeInterval { AppConstants.TimerPresets.twoHours }
    static var threeHours: TimeInterval { AppConstants.TimerPresets.threeHours }

    // Test-specific values
    static let custom: TimeInterval = 5400 // 1.5 hours
    static let veryShort: TimeInterval = 5 // For quick tests
    static let negative: TimeInterval = -100 // Invalid value

    static var allValid: [TimeInterval] { AppConstants.TimerPresets.all }

    static let presets: [(name: String, value: TimeInterval)] = [
        ("Off", AppConstants.TimerPresets.off),
        ("15 minutes", AppConstants.TimerPresets.fifteenMinutes),
        ("30 minutes", AppConstants.TimerPresets.thirtyMinutes),
        ("1 hour", AppConstants.TimerPresets.oneHour),
        ("2 hours", AppConstants.TimerPresets.twoHours),
        ("3 hours", AppConstants.TimerPresets.threeHours)
    ]
}

// Localization Test Data

@MainActor
enum LocalizationTestData {
    static var allLanguages: [AppLanguage] { AppLanguage.allCases }

    static let requiredKeys: [String] = [
        "app_name",
        "menu_settings",
        "menu_quit",
        "status_on",
        "status_off",
        "status_preventing",
        "status_sleep_enabled",
        "timer_mode",
        "sound_feedback",
        "theme",
        "theme_system",
        "theme_light",
        "theme_dark",
        "icon_style",
        "show_countdown_in_menu_bar",
        "duration",
        "duration_off",
        "duration_15m",
        "duration_30m",
        "duration_1h",
        "duration_2h",
        "duration_3h",
        "turn_on",
        "turn_off",
        "launch_at_login",
        "notifications",
        "hotkey",
        "shortcut_hint",
        // Hotkey conflict keys (Dev5)
        "hotkey_conflict_system",
        "hotkey_conflict_app",
        "hotkey_conflict_possible",
        "hotkey_conflict_suggestion_high",
        "hotkey_conflict_suggestion_medium",
        "hotkey_conflict_suggestion_low"
    ]

    // New keys added by Dev5 for hotkey conflict detection
    static let hotkeyConflictKeys: [String] = [
        "hotkey_conflict_system",
        "hotkey_conflict_app",
        "hotkey_conflict_possible",
        "hotkey_conflict_suggestion_high",
        "hotkey_conflict_suggestion_medium",
        "hotkey_conflict_suggestion_low"
    ]

    static var languageDisplayNames: [AppLanguage: String] {
        [
            .english: "English",
            .chinese: "简体中文",
            .chineseTraditional: "繁體中文",
            .japanese: "日本語",
            .korean: "한국어",
            .french: "Francais",
            .german: "Deutsch",
            .spanish: "Espanol"
        ]
    }
}

// Activity Session Fixtures

enum ActivitySessionFixtures {
    /// Create an active session (no end time)
    static func activeSession(startedSecondsAgo: TimeInterval = 0) -> ActivitySession {
        ActivitySession(
            startTime: Date().addingTimeInterval(-startedSecondsAgo),
            wasTimerMode: false
        )
    }

    /// Create a completed session with specified duration
    static func completedSession(duration: TimeInterval = 3600) -> ActivitySession {
        var session = ActivitySession(startTime: Date().addingTimeInterval(-duration))
        session.end()
        return session
    }

    /// Create a timer mode session
    static func timerSession(duration: TimeInterval = 1800, active: Bool = true) -> ActivitySession {
        var session = ActivitySession(
            startTime: Date(),
            wasTimerMode: true,
            timerDuration: duration
        )
        if !active {
            session.end()
        }
        return session
    }

    /// Create multiple sessions for history testing
    static func sessionHistory(count: Int) -> [ActivitySession] {
        return (0..<count).map { index in
            var session = ActivitySession(
                startTime: Date().addingTimeInterval(Double(-index * 3600)),
                wasTimerMode: index % 2 == 0,
                timerDuration: index % 2 == 0 ? 1800 : nil
            )
            session.end()
            return session
        }
    }
}

// History Filter and Sort Fixtures (Dev3)

enum HistoryFilterFixtures {
    /// Expected filter modes (to be implemented by Dev3)
    static let expectedFilterModes: [String] = [
        "all",
        "today",
        "thisWeek",
        "timerOnly"
    ]

    /// Expected sort orders (to be implemented by Dev3)
    static let expectedSortOrders: [String] = [
        "newest",
        "oldest",
        "longest",
        "shortest"
    ]

    /// Expected export formats (to be implemented by Dev3)
    static let expectedExportFormats: [String] = [
        "json",
        "csv"
    ]
}

// Hotkey Conflict Fixtures (Dev5)

enum HotkeyConflictFixtures {
    /// Common system shortcuts that should trigger conflicts
    static let systemShortcuts: [(keyCode: UInt32, modifiers: UInt32, description: String)] = [
        (0, 256, "Cmd+A (Select All)"),      // Cmd+A
        (6, 256, "Cmd+Z (Undo)"),             // Cmd+Z
        (7, 256, "Cmd+X (Cut)"),              // Cmd+X
        (8, 256, "Cmd+C (Copy)"),             // Cmd+C
        (9, 256, "Cmd+V (Paste)"),            // Cmd+V
        (3, 256, "Cmd+F (Find)"),             // Cmd+F
        (12, 256, "Cmd+Q (Quit)"),            // Cmd+Q
        (13, 256, "Cmd+W (Close Window)"),   // Cmd+W
    ]

    /// Conflict severity levels
    enum ConflictSeverity: String {
        case high = "high"
        case medium = "medium"
        case low = "low"
    }

    /// Test data for conflict detection
    static let conflictTestCases: [(keyCode: UInt32, modifiers: UInt32, expectedSeverity: ConflictSeverity?)] = [
        (29, 4352, nil),           // Cmd+Ctrl+0 (default, no conflict)
        (0, 256, .high),           // Cmd+A (system conflict)
        (12, 256, .high),          // Cmd+Q (system conflict)
        (0, 4352, nil),            // Cmd+Ctrl+A (likely no conflict)
    ]
}

// Icon Style Fixtures

enum IconStyleFixtures {
    static let allStyles: [IconStyle] = IconStyle.allCases

    static let styleSymbols: [(style: IconStyle, inactive: String, active: String)] = [
        (.power, "power.circle", "power.circle.fill"),
        (.bolt, "bolt.circle", "bolt.circle.fill"),
        (.cup, "cup.and.saucer", "cup.and.saucer.fill"),
        (.moon, "moon.zzz", "moon.zzz.fill"),
        (.eye, "eye", "eye.fill")
    ]
}

// Theme Fixtures

enum ThemeFixtures {
    static let allThemes: [AppTheme] = AppTheme.allCases

    static let themeData: [(theme: AppTheme, rawValue: String, locKey: String)] = [
        (.system, "system", "theme_system"),
        (.light, "light", "theme_light"),
        (.dark, "dark", "theme_dark")
    ]
}

// Hotkey Fixtures

enum HotkeyFixtures {
    static let defaultKeyCode: UInt32 = 29 // kVK_ANSI_0

    static let testConfigs: [HotkeyConfig] = [
        HotkeyConfig.defaultConfig,
        HotkeyConfig(keyCode: 0, modifiers: 256),  // A with Cmd
        HotkeyConfig(keyCode: 1, modifiers: 512),  // S with Ctrl
        HotkeyConfig(keyCode: 122, modifiers: 256) // F1 with Cmd
    ]

    static let invalidConfigs: [HotkeyConfig] = [
        HotkeyConfig(keyCode: 0, modifiers: 0), // No modifiers
    ]
}

// UserDefaults Keys (use centralized keys from WeakupCore)

typealias TestUserDefaultsKeys = WeakupCore.UserDefaultsKeys

// Test Utilities

enum TestUtilities {
    /// Wait for a condition with timeout
    static func waitFor(
        timeout: TimeInterval = 5.0,
        interval: TimeInterval = 0.1,
        condition: () -> Bool
    ) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() {
                return true
            }
            Thread.sleep(forTimeInterval: interval)
        }
        return false
    }

    /// Format time interval for display (uses centralized TimeFormatter)
    static func formatTime(_ interval: TimeInterval) -> String {
        TimeFormatter.countdown(interval)
    }

    /// Format duration for display (uses centralized TimeFormatter)
    static func formatDuration(_ interval: TimeInterval) -> String {
        TimeFormatter.duration(interval)
    }
}
