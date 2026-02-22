import Foundation

// Language Management

/// Represents the supported languages in the application.
///
/// Each case corresponds to a localization bundle (`.lproj` folder) containing
/// translated strings. The raw value matches the locale identifier used by the system.
///
/// ## Supported Languages
///
/// - English (en)
/// - Chinese Simplified (zh-Hans)
/// - Chinese Traditional (zh-Hant)
/// - Japanese (ja)
/// - Korean (ko)
/// - French (fr)
/// - German (de)
/// - Spanish (es)
public enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case japanese = "ja"
    case korean = "ko"
    case french = "fr"
    case german = "de"
    case spanish = "es"

    /// The unique identifier for this language (same as raw value).
    public var id: String {
        rawValue
    }

    /// The display name of the language in its native script.
    public var displayName: String {
        switch self {
        case .english: "English"
        case .chinese: "简体中文"
        case .chineseTraditional: "繁體中文"
        case .japanese: "日本語"
        case .korean: "한국어"
        case .french: "Francais"
        case .german: "Deutsch"
        case .spanish: "Espanol"
        }
    }

    /// The bundle containing localized resources for this language.
    ///
    /// Returns the main bundle if the language-specific bundle cannot be found.
    public var bundle: Bundle {
        let bundle = Bundle.main
        if let path = bundle.path(forResource: rawValue, ofType: "lproj") {
            return Bundle(path: path) ?? bundle
        }
        return bundle
    }
}

// Localization Manager

/// Manages localization and provides access to localized strings.
///
/// `L10n` is a singleton that handles language selection, persistence, and string lookup.
/// It supports real-time language switching without requiring an app restart.
///
/// ## Usage
///
/// ```swift
/// // Get localized strings
/// let title = L10n.shared.appName
/// let status = L10n.shared.statusOn
///
/// // Change language
/// L10n.shared.setLanguage(.chinese)
///
/// // Get arbitrary string by key
/// let custom = L10n.shared.string(forKey: "custom_key")
/// ```
///
/// ## Fallback Behavior
///
/// If a string is not found in the current language:
/// 1. Falls back to English translation
/// 2. If still not found, returns a readable version of the key (underscores replaced with spaces)
///
/// ## Thread Safety
///
/// This class is marked with `@MainActor` and all access must be from the main thread.
@MainActor
public class L10n: ObservableObject {
    /// The shared singleton instance.
    public static let shared = L10n()

    /// The currently selected language.
    ///
    /// Observe this property to react to language changes in SwiftUI views.
    @Published public var currentLanguage: AppLanguage = .english

    private init() {
        loadLanguage()
    }

    private func loadLanguage() {
        let savedLanguage = UserDefaults.standard.string(forKey: UserDefaultsKeys.language)
        if let savedLanguage, let language = AppLanguage(rawValue: savedLanguage) {
            currentLanguage = language
        } else {
            // Detect system language
            let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            let regionCode = Locale.current.region?.identifier ?? ""

            if systemLang == "zh" {
                // Distinguish between Simplified and Traditional Chinese
                if regionCode == "TW" || regionCode == "HK" || regionCode == "MO" {
                    currentLanguage = .chineseTraditional
                } else {
                    currentLanguage = .chinese
                }
            } else if systemLang == "ja" {
                currentLanguage = .japanese
            } else if systemLang == "ko" {
                currentLanguage = .korean
            } else if systemLang == "fr" {
                currentLanguage = .french
            } else if systemLang == "de" {
                currentLanguage = .german
            } else if systemLang == "es" {
                currentLanguage = .spanish
            } else {
                currentLanguage = .english
            }
        }
    }

    /// Sets the current language and persists the selection.
    ///
    /// - Parameter language: The language to switch to.
    ///
    /// The change takes effect immediately and is persisted to UserDefaults.
    /// SwiftUI views observing `currentLanguage` will update automatically.
    public func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: UserDefaultsKeys.language)
        UserDefaults.standard.synchronize()
        Logger.preferenceChanged(key: UserDefaultsKeys.language, value: language.rawValue)
    }

    /// Returns a localized string for the given key.
    ///
    /// - Parameters:
    ///   - key: The key identifying the string in the Localizable.strings file.
    ///   - comment: An optional comment for translators (not used at runtime).
    /// - Returns: The localized string, or a fallback if not found.
    ///
    /// ## Fallback Behavior
    ///
    /// 1. Looks up the key in the current language's bundle
    /// 2. If not found and current language is not English, tries English bundle
    /// 3. If still not found, returns the key with underscores replaced by spaces
    public func string(forKey key: String, comment: String = "") -> String {
        let bundle = currentLanguage.bundle
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: comment)

        // If the key wasn't found (returns the key itself), try English fallback
        if localizedString == key, currentLanguage != .english {
            let englishBundle = AppLanguage.english.bundle
            let fallbackString = NSLocalizedString(key, bundle: englishBundle, comment: comment)
            if fallbackString != key {
                return fallbackString
            }
        }

        // If still not found, return a readable version of the key
        if localizedString == key {
            return key.replacingOccurrences(of: "_", with: " ").capitalized
        }

        return localizedString
    }
}

// Localized String Accessors

/// Convenience accessors for all localized strings used in the application.
///
/// These properties provide type-safe access to localized strings without
/// needing to remember string keys.
extension L10n {
    // MARK: App

    public var appName: String {
        string(forKey: "app_name")
    }

    /// Menu
    public var menuSettings: String {
        string(forKey: "menu_settings")
    }

    public var menuQuit: String {
        string(forKey: "menu_quit")
    }

    /// Status
    public var statusOn: String {
        string(forKey: "status_on")
    }

    public var statusOff: String {
        string(forKey: "status_off")
    }

    public var statusPreventingSleep: String {
        string(forKey: "status_preventing")
    }

    public var statusSleepEnabled: String {
        string(forKey: "status_sleep_enabled")
    }

    /// Settings
    public var timerMode: String {
        string(forKey: "timer_mode")
    }

    public var soundFeedback: String {
        string(forKey: "sound_feedback")
    }

    public var theme: String {
        string(forKey: "theme")
    }

    public var themeSystem: String {
        string(forKey: "theme_system")
    }

    public var themeLight: String {
        string(forKey: "theme_light")
    }

    public var themeDark: String {
        string(forKey: "theme_dark")
    }

    public var iconStyle: String {
        string(forKey: "icon_style")
    }

    public var showCountdownInMenuBar: String {
        string(forKey: "show_countdown_in_menu_bar")
    }

    public var duration: String {
        string(forKey: "duration")
    }

    public var durationOff: String {
        string(forKey: "duration_off")
    }

    public var duration15m: String {
        string(forKey: "duration_15m")
    }

    public var duration30m: String {
        string(forKey: "duration_30m")
    }

    public var duration1h: String {
        string(forKey: "duration_1h")
    }

    public var duration2h: String {
        string(forKey: "duration_2h")
    }

    public var duration3h: String {
        string(forKey: "duration_3h")
    }

    public var durationCustom: String {
        string(forKey: "duration_custom")
    }

    public var customDurationTitle: String {
        string(forKey: "custom_duration_title")
    }

    public var hours: String {
        string(forKey: "hours")
    }

    public var minutes: String {
        string(forKey: "minutes")
    }

    public var set: String {
        string(forKey: "set")
    }

    public var cancel: String {
        string(forKey: "cancel")
    }

    public var maxDurationHint: String {
        string(forKey: "max_duration_hint")
    }

    /// Actions
    public var turnOn: String {
        string(forKey: "turn_on")
    }

    public var turnOff: String {
        string(forKey: "turn_off")
    }

    /// Startup
    public var launchAtLogin: String {
        string(forKey: "launch_at_login")
    }

    public var launchAtLoginError: String {
        string(forKey: "launch_at_login_error")
    }

    public var launchAtLoginPermissionDenied: String {
        string(forKey: "launch_at_login_permission_denied")
    }

    public var launchAtLoginNotSupported: String {
        string(forKey: "launch_at_login_not_supported")
    }

    public var launchAtLoginEnableFailed: String {
        string(forKey: "launch_at_login_enable_failed")
    }

    public var launchAtLoginDisableFailed: String {
        string(forKey: "launch_at_login_disable_failed")
    }

    /// Notifications
    public var notifications: String {
        string(forKey: "notifications")
    }

    public var notificationTimerExpiredTitle: String {
        string(forKey: "notification_timer_expired_title")
    }

    public var notificationTimerExpiredBody: String {
        string(forKey: "notification_timer_expired_body")
    }

    public var notificationActionRestart: String {
        string(forKey: "notification_action_restart")
    }

    public var notificationActionDismiss: String {
        string(forKey: "notification_action_dismiss")
    }

    /// History
    public var historyTitle: String {
        string(forKey: "history_title")
    }

    public var historyToday: String {
        string(forKey: "history_today")
    }

    public var historyThisWeek: String {
        string(forKey: "history_this_week")
    }

    public var historyTotal: String {
        string(forKey: "history_total")
    }

    public var historyAverage: String {
        string(forKey: "history_average")
    }

    public var historySessions: String {
        string(forKey: "history_sessions")
    }

    public var historyPerSession: String {
        string(forKey: "history_per_session")
    }

    public var historyRecentSessions: String {
        string(forKey: "history_recent_sessions")
    }

    public var historyClear: String {
        string(forKey: "history_clear")
    }

    public var historyClearConfirmTitle: String {
        string(forKey: "history_clear_confirm_title")
    }

    public var historyClearConfirmMessage: String {
        string(forKey: "history_clear_confirm_message")
    }

    public var historyNoSessions: String {
        string(forKey: "history_no_sessions")
    }

    public var historyTimerMode: String {
        string(forKey: "history_timer_mode")
    }

    public var historyPrivacyNote: String {
        string(forKey: "history_privacy_note")
    }

    /// Hotkey
    public var hotkey: String {
        string(forKey: "hotkey")
    }

    public var hotkeyCurrent: String {
        string(forKey: "hotkey_current")
    }

    public var hotkeyRecord: String {
        string(forKey: "hotkey_record")
    }

    public var hotkeyReset: String {
        string(forKey: "hotkey_reset")
    }

    public var hotkeyRecording: String {
        string(forKey: "hotkey_recording")
    }

    public var hotkeyConflictMessage: String {
        string(forKey: "hotkey_conflict_message")
    }

    /// Hotkey Conflict Messages
    public func hotkeyConflictSystem(app: String, action: String) -> String {
        String(format: string(forKey: "hotkey_conflict_system"), app, action)
    }

    public func hotkeyConflictApp(app: String, action: String) -> String {
        String(format: string(forKey: "hotkey_conflict_app"), app, action)
    }

    public func hotkeyConflictPossible(app: String, action: String) -> String {
        String(format: string(forKey: "hotkey_conflict_possible"), app, action)
    }

    public var hotkeyConflictSuggestionHigh: String {
        string(forKey: "hotkey_conflict_suggestion_high")
    }

    public var hotkeyConflictSuggestionMedium: String {
        string(forKey: "hotkey_conflict_suggestion_medium")
    }

    public var hotkeyConflictSuggestionLow: String {
        string(forKey: "hotkey_conflict_suggestion_low")
    }

    public var hotkeyOverrideConflict: String {
        string(forKey: "hotkey_override_conflict")
    }

    public var hotkeyConflictWarning: String {
        string(forKey: "hotkey_conflict_warning")
    }

    public var hotkeyNoConflict: String {
        string(forKey: "hotkey_no_conflict")
    }

    /// Hints
    public var shortcutHint: String {
        string(forKey: "shortcut_hint")
    }

    /// History Export/Import
    public var historyExport: String {
        string(forKey: "history_export")
    }

    public var historyImport: String {
        string(forKey: "history_import")
    }

    public var historyExportFormat: String {
        string(forKey: "history_export_format")
    }

    public var historyExportSuccess: String {
        string(forKey: "history_export_success")
    }

    public var historyImportSuccess: String {
        string(forKey: "history_import_success")
    }

    public var historyImportSkipped: String {
        string(forKey: "history_import_skipped")
    }

    public var historyImportError: String {
        string(forKey: "history_import_error")
    }

    public var historySearch: String {
        string(forKey: "history_search")
    }

    public var historyFilter: String {
        string(forKey: "history_filter")
    }

    public var historySort: String {
        string(forKey: "history_sort")
    }

    public var historyDeleteSession: String {
        string(forKey: "history_delete_session")
    }

    public var historyChart: String {
        string(forKey: "history_chart")
    }

    public var historyLast7Days: String {
        string(forKey: "history_last_7_days")
    }

    /// Filter Options
    public var filterAll: String {
        string(forKey: "filter_all")
    }

    public var filterToday: String {
        string(forKey: "filter_today")
    }

    public var filterThisWeek: String {
        string(forKey: "filter_this_week")
    }

    public var filterThisMonth: String {
        string(forKey: "filter_this_month")
    }

    public var filterTimerOnly: String {
        string(forKey: "filter_timer_only")
    }

    public var filterManualOnly: String {
        string(forKey: "filter_manual_only")
    }

    /// Sort Options
    public var sortDateDesc: String {
        string(forKey: "sort_date_desc")
    }

    public var sortDateAsc: String {
        string(forKey: "sort_date_asc")
    }

    public var sortDurationDesc: String {
        string(forKey: "sort_duration_desc")
    }

    public var sortDurationAsc: String {
        string(forKey: "sort_duration_asc")
    }

    /// Onboarding
    public var onboardingWelcome: String {
        string(forKey: "onboarding_welcome")
    }

    public var onboardingWelcomeMessage: String {
        string(forKey: "onboarding_welcome_message")
    }

    public var onboardingFeature1Title: String {
        string(forKey: "onboarding_feature1_title")
    }

    public var onboardingFeature1Desc: String {
        string(forKey: "onboarding_feature1_desc")
    }

    public var onboardingFeature2Title: String {
        string(forKey: "onboarding_feature2_title")
    }

    public var onboardingFeature2Desc: String {
        string(forKey: "onboarding_feature2_desc")
    }

    public var onboardingFeature3Title: String {
        string(forKey: "onboarding_feature3_title")
    }

    public var onboardingFeature3Desc: String {
        string(forKey: "onboarding_feature3_desc")
    }

    public var onboardingGetStarted: String {
        string(forKey: "onboarding_get_started")
    }

    public var onboardingSkip: String {
        string(forKey: "onboarding_skip")
    }

    public var onboardingNext: String {
        string(forKey: "onboarding_next")
    }
}
