import Foundation

// MARK: - UserDefaults Keys

/// Centralized UserDefaults key management for the Weakup application.
/// All keys follow the "Weakup" prefix convention for namespace isolation.
public enum UserDefaultsKeys {

    // MARK: - CaffeineViewModel Keys

    /// Whether sound feedback is enabled when toggling sleep prevention.
    public static let soundEnabled = "WeakupSoundEnabled"

    /// Whether timer mode is currently enabled.
    public static let timerMode = "WeakupTimerMode"

    /// The duration in seconds for timer mode.
    public static let timerDuration = "WeakupTimerDuration"

    /// Whether to show countdown in the menu bar.
    public static let showCountdownInMenuBar = "WeakupShowCountdownInMenuBar"

    // MARK: - Notification Keys

    /// Whether notifications are enabled for timer expiry.
    public static let notificationsEnabled = "WeakupNotificationsEnabled"

    // MARK: - Appearance Keys

    /// The current app language (stored as AppLanguage.rawValue).
    public static let language = "WeakupLanguage"

    /// The current theme (stored as AppTheme.rawValue).
    public static let theme = "WeakupTheme"

    /// The current icon style (stored as IconStyle.rawValue).
    public static let iconStyle = "WeakupIconStyle"

    // MARK: - Hotkey Keys

    /// The hotkey configuration (stored as JSON-encoded HotkeyConfig).
    public static let hotkeyConfig = "WeakupHotkeyConfig"

    /// Whether to override detected hotkey conflicts.
    public static let hotkeyOverrideConflicts = "WeakupOverrideConflicts"

    // MARK: - History Keys

    /// The activity history (stored as JSON-encoded [ActivitySession]).
    public static let activityHistory = "WeakupActivityHistory"

    // MARK: - Utility

    /// All UserDefaults keys used by the application.
    /// Useful for cleanup during testing or app reset.
    public static let all: [String] = [
        soundEnabled,
        timerMode,
        timerDuration,
        showCountdownInMenuBar,
        notificationsEnabled,
        language,
        theme,
        iconStyle,
        hotkeyConfig,
        hotkeyOverrideConflicts,
        activityHistory
    ]

    /// Removes all Weakup-related keys from the given UserDefaults instance.
    /// - Parameter defaults: The UserDefaults instance to clean.
    public static func removeAll(from defaults: UserDefaults = .standard) {
        for key in all {
            defaults.removeObject(forKey: key)
        }
    }
}
