import AppKit
import SwiftUI

// Icon Style

public enum IconStyle: String, CaseIterable, Identifiable, Sendable {
    case power
    case bolt
    case cup
    case moon
    case eye

    public var id: String {
        rawValue
    }

    public var localizationKey: String {
        "icon_\(rawValue)"
    }

    /// SF Symbol name for inactive state
    public var inactiveSymbol: String {
        switch self {
        case .power: "power.circle"
        case .bolt: "bolt.circle"
        case .cup: "cup.and.saucer"
        case .moon: "moon.zzz"
        case .eye: "eye"
        }
    }

    /// SF Symbol name for active state
    public var activeSymbol: String {
        switch self {
        case .power: "power.circle.fill"
        case .bolt: "bolt.circle.fill"
        case .cup: "cup.and.saucer.fill"
        case .moon: "moon.zzz.fill"
        case .eye: "eye.fill"
        }
    }
}

// Icon Manager

@MainActor
public final class IconManager: ObservableObject {
    public static let shared = IconManager()

    @Published public var currentStyle: IconStyle {
        didSet {
            UserDefaults.standard.set(currentStyle.rawValue, forKey: UserDefaultsKeys.iconStyle)
            Logger.preferenceChanged(key: UserDefaultsKeys.iconStyle, value: currentStyle.rawValue)
            onIconChanged?()
        }
    }

    public var onIconChanged: (() -> Void)?

    private init() {
        let savedStyle = UserDefaults.standard.string(forKey: UserDefaultsKeys.iconStyle)
        if let savedStyle, let style = IconStyle(rawValue: savedStyle) {
            self.currentStyle = style
        } else {
            self.currentStyle = .power
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
