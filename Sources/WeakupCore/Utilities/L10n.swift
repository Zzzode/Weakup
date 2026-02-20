import Foundation

// MARK: - Language Management

public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case chinese = "zh-Hans"

    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
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
            if systemLang.hasPrefix("zh") {
                currentLanguage = .chinese
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

// MARK: - Localized Strings

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

    // Hints
    var shortcutHint: String { string(forKey: "shortcut_hint") }
    var hotkeyConflictMessage: String { string(forKey: "hotkey_conflict_message") }
}
