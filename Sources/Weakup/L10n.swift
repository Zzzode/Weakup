import Foundation

// MARK: - Language Management

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh-Hans"

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        }
    }

    var bundle: Bundle {
        let bundle = Bundle.main
        if let path = bundle.path(forResource: rawValue, ofType: "lproj") {
            return Bundle(path: path) ?? bundle
        }
        return bundle
    }
}

@MainActor
class L10n: ObservableObject {
    static let shared = L10n()

    @Published var currentLanguage: AppLanguage = .english

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

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }

    func string(forKey key: String, comment: String = "") -> String {
        let bundle = currentLanguage.bundle
        return NSLocalizedString(key, bundle: bundle, comment: comment)
    }
}

// MARK: - Localized Strings

extension L10n {
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
    var duration: String { string(forKey: "duration") }
    var durationOff: String { string(forKey: "duration_off") }
    var duration15m: String { string(forKey: "duration_15m") }
    var duration30m: String { string(forKey: "duration_30m") }
    var duration1h: String { string(forKey: "duration_1h") }
    var duration2h: String { string(forKey: "duration_2h") }
    var duration3h: String { string(forKey: "duration_3h") }

    // Actions
    var turnOn: String { string(forKey: "turn_on") }
    var turnOff: String { string(forKey: "turn_off") }

    // Hints
    var shortcutHint: String { string(forKey: "shortcut_hint") }
}
