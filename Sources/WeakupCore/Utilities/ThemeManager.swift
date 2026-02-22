import AppKit
import SwiftUI

// Theme Options

public enum AppTheme: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    public var id: String {
        rawValue
    }

    public var localizationKey: String {
        switch self {
        case .system: "theme_system"
        case .light: "theme_light"
        case .dark: "theme_dark"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

// Theme Manager

@MainActor
public final class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()

    @Published public var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: UserDefaultsKeys.theme)
            Logger.preferenceChanged(key: UserDefaultsKeys.theme, value: currentTheme.rawValue)
            applyTheme()
        }
    }

    private init() {
        let savedTheme = UserDefaults.standard.string(forKey: UserDefaultsKeys.theme)
        if let savedTheme, let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }

    public var effectiveColorScheme: ColorScheme? {
        currentTheme.colorScheme
    }

    private func applyTheme() {
        // For menu bar apps, the appearance is typically inherited from the system
        // This method can be extended if needed for custom window appearances
        objectWillChange.send()
    }
}
