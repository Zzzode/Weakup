import Foundation

// Language Management

public enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case japanese = "ja"
    case korean = "ko"
    case french = "fr"
    case german = "de"
    case spanish = "es"

    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "简体中文"
        case .chineseTraditional: return "繁體中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .french: return "Francais"
        case .german: return "Deutsch"
        case .spanish: return "Espanol"
        }
    }

    public var bundle: Bundle {
        let bundle = Bundle.main
        if let path = bundle.path(forResource: rawValue, ofType: "lproj") {
            return Bundle(path: path) ?? bundle
        }
        return bundle
    }
}

@MainActor
public class L10n: ObservableObject {
    public static let shared = L10n()

    @Published public var currentLanguage: AppLanguage = .english

    private let userDefaultsKey = "WeakupLanguage"

    private init() {
        loadLanguage()
    }

    private func loadLanguage() {
        if let savedLanguage = UserDefaults.standard.string(forKey: userDefaultsKey),
           let language = AppLanguage(rawValue: savedLanguage) {
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

    public func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }

    public func string(forKey key: String, comment: String = "") -> String {
        let bundle = currentLanguage.bundle
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: comment)

        // If the key wasn't found (returns the key itself), try English fallback
        if localizedString == key && currentLanguage != .english {
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

// Localized Strings

public extension L10n {
    // App
    var appName: String { string(forKey: "app_name") }

    // Menu
    var menuSettings: String { string(forKey: "menu_settings") }
    var menuQuit: String { string(forKey: "menu_quit") }

    // Status
    var statusOn: String { string(forKey: "status_on") }
    var statusOff: String { string(forKey: "status_off") }
    var statusPreventingSleep: String { string(forKey: "status_preventing") }
    var statusSleepEnabled: String { string(forKey: "status_sleep_enabled") }

    // Settings
    var timerMode: String { string(forKey: "timer_mode") }
    var soundFeedback: String { string(forKey: "sound_feedback") }
    var theme: String { string(forKey: "theme") }
    var themeSystem: String { string(forKey: "theme_system") }
    var themeLight: String { string(forKey: "theme_light") }
    var themeDark: String { string(forKey: "theme_dark") }
    var iconStyle: String { string(forKey: "icon_style") }
    var showCountdownInMenuBar: String { string(forKey: "show_countdown_in_menu_bar") }
    var duration: String { string(forKey: "duration") }
    var durationOff: String { string(forKey: "duration_off") }
    var duration15m: String { string(forKey: "duration_15m") }
    var duration30m: String { string(forKey: "duration_30m") }
    var duration1h: String { string(forKey: "duration_1h") }
    var duration2h: String { string(forKey: "duration_2h") }
    var duration3h: String { string(forKey: "duration_3h") }
    var durationCustom: String { string(forKey: "duration_custom") }
    var customDurationTitle: String { string(forKey: "custom_duration_title") }
    var hours: String { string(forKey: "hours") }
    var minutes: String { string(forKey: "minutes") }
    var set: String { string(forKey: "set") }
    var cancel: String { string(forKey: "cancel") }
    var maxDurationHint: String { string(forKey: "max_duration_hint") }

    // Actions
    var turnOn: String { string(forKey: "turn_on") }
    var turnOff: String { string(forKey: "turn_off") }

    // Startup
    var launchAtLogin: String { string(forKey: "launch_at_login") }

    // Notifications
    var notifications: String { string(forKey: "notifications") }
    var notificationTimerExpiredTitle: String { string(forKey: "notification_timer_expired_title") }
    var notificationTimerExpiredBody: String { string(forKey: "notification_timer_expired_body") }
    var notificationActionRestart: String { string(forKey: "notification_action_restart") }
    var notificationActionDismiss: String { string(forKey: "notification_action_dismiss") }

    // History
    var historyTitle: String { string(forKey: "history_title") }
    var historyToday: String { string(forKey: "history_today") }
    var historyThisWeek: String { string(forKey: "history_this_week") }
    var historyTotal: String { string(forKey: "history_total") }
    var historyAverage: String { string(forKey: "history_average") }
    var historySessions: String { string(forKey: "history_sessions") }
    var historyPerSession: String { string(forKey: "history_per_session") }
    var historyRecentSessions: String { string(forKey: "history_recent_sessions") }
    var historyClear: String { string(forKey: "history_clear") }
    var historyClearConfirmTitle: String { string(forKey: "history_clear_confirm_title") }
    var historyClearConfirmMessage: String { string(forKey: "history_clear_confirm_message") }
    var historyNoSessions: String { string(forKey: "history_no_sessions") }
    var historyTimerMode: String { string(forKey: "history_timer_mode") }
    var historyPrivacyNote: String { string(forKey: "history_privacy_note") }

    // Hotkey
    var hotkey: String { string(forKey: "hotkey") }
    var hotkeyCurrent: String { string(forKey: "hotkey_current") }
    var hotkeyRecord: String { string(forKey: "hotkey_record") }
    var hotkeyReset: String { string(forKey: "hotkey_reset") }
    var hotkeyRecording: String { string(forKey: "hotkey_recording") }
    var hotkeyConflictMessage: String { string(forKey: "hotkey_conflict_message") }

    // Hints
    var shortcutHint: String { string(forKey: "shortcut_hint") }
}
