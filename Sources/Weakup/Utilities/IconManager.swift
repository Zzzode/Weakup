import AppKit
import SwiftUI

// MARK: - Icon Style

enum IconStyle: String, CaseIterable, Identifiable {
    case power = "power"
    case bolt = "bolt"
    case cup = "cup"
    case moon = "moon"
    case eye = "eye"

    var id: String { rawValue }

    var localizationKey: String {
        "icon_\(rawValue)"
    }

    /// SF Symbol name for inactive state
    var inactiveSymbol: String {
        switch self {
        case .power: return "power.circle"
        case .bolt: return "bolt.circle"
        case .cup: return "cup.and.saucer"
        case .moon: return "moon.zzz"
        case .eye: return "eye"
        }
    }

    /// SF Symbol name for active state
    var activeSymbol: String {
        switch self {
        case .power: return "power.circle.fill"
        case .bolt: return "bolt.circle.fill"
        case .cup: return "cup.and.saucer.fill"
        case .moon: return "moon.zzz.fill"
        case .eye: return "eye.fill"
        }
    }
}

// MARK: - Icon Manager

@MainActor
final class IconManager: ObservableObject {
    static let shared = IconManager()

    @Published var currentStyle: IconStyle {
        didSet {
            UserDefaults.standard.set(currentStyle.rawValue, forKey: userDefaultsKey)
            onIconChanged?()
        }
    }

    var onIconChanged: (() -> Void)?

    private let userDefaultsKey = "WeakupIconStyle"

    private init() {
        if let savedStyle = UserDefaults.standard.string(forKey: userDefaultsKey),
           let style = IconStyle(rawValue: savedStyle) {
            currentStyle = style
        } else {
            currentStyle = .power
        }
    }

    func image(for style: IconStyle, isActive: Bool) -> NSImage? {
        let symbolName = isActive ? style.activeSymbol : style.inactiveSymbol
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        return NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
            .withSymbolConfiguration(config)
    }

    func currentImage(isActive: Bool) -> NSImage? {
        image(for: currentStyle, isActive: isActive)
    }
}
