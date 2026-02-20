import AppKit
import SwiftUI

// MARK: - Icon Style

public enum IconStyle: String, CaseIterable, Identifiable, Sendable {
    case power = "power"
    case bolt = "bolt"
    case cup = "cup"
    case moon = "moon"
    case eye = "eye"

    public var id: String { rawValue }

    public var localizationKey: String {
        "icon_\(rawValue)"
    }

    /// SF Symbol name for inactive state
    public var inactiveSymbol: String {
        switch self {
        case .power: return "power.circle"
        case .bolt: return "bolt.circle"
        case .cup: return "cup.and.saucer"
        case .moon: return "moon.zzz"
        case .eye: return "eye"
        }
    }

    /// SF Symbol name for active state
    public var activeSymbol: String {
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
public final class IconManager: ObservableObject {
    public static let shared = IconManager()

    @Published public var currentStyle: IconStyle {
        didSet {
            UserDefaults.standard.set(currentStyle.rawValue, forKey: userDefaultsKey)
            onIconChanged?()
        }
    }

    public var onIconChanged: (() -> Void)?

    private let userDefaultsKey = "WeakupIconStyle"

    private init() {
        if let savedStyle = UserDefaults.standard.string(forKey: userDefaultsKey),
           let style = IconStyle(rawValue: savedStyle) {
            currentStyle = style
        } else {
            currentStyle = .power
        }
    }

    public func image(for style: IconStyle, isActive: Bool) -> NSImage? {
        let symbolName = isActive ? style.activeSymbol : style.inactiveSymbol
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        return NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
            .withSymbolConfiguration(config)
    }

    public func currentImage(isActive: Bool) -> NSImage? {
        image(for: currentStyle, isActive: isActive)
    }
}
