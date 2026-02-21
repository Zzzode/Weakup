import SwiftUI
import AppKit

// Theme Options

public enum AppTheme: String, CaseIterable, Identifiable, Sendable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    public var id: String { rawValue }

    public var localizationKey: String {
        switch self {
        case .system: return "theme_system"
        case .light: return "theme_light"
        case .dark: return "theme_dark"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// Theme Manager

@MainActor
public final class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()

    @Published public var currentTheme: AppTheme {
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

    public var effectiveColorScheme: ColorScheme? {
        currentTheme.colorScheme
    }

    private func applyTheme() {
        // For menu bar apps, the appearance is typically inherited from the system
        // This method can be extended if needed for custom window appearances
        objectWillChange.send()
    }
}
