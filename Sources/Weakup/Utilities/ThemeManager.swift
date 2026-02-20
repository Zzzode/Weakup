import SwiftUI
import AppKit

// MARK: - Theme Options

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .system: return "theme_system"
        case .light: return "theme_light"
        case .dark: return "theme_dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Theme Manager

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: userDefaultsKey)
            applyTheme()
        }
    }

    private let userDefaultsKey = "WeakupTheme"

    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: userDefaultsKey),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        } else {
            currentTheme = .system
        }
    }

    var effectiveColorScheme: ColorScheme? {
        currentTheme.colorScheme
    }

    private func applyTheme() {
        // For menu bar apps, the appearance is typically inherited from the system
        // This method can be extended if needed for custom window appearances
        objectWillChange.send()
    }
}
