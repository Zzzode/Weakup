import AppKit
import Carbon

// Hotkey Conflict Information

/// Information about a detected keyboard shortcut conflict.
///
/// When a user attempts to set a hotkey that conflicts with a known system
/// or application shortcut, a `HotkeyConflict` is created to describe the conflict.
public struct HotkeyConflict: Equatable, Sendable {
    public let conflictingApp: String
    public let description: String
    public let severity: ConflictSeverity
    public let suggestion: String?

    public enum ConflictSeverity: Int, Sendable {
        case low = 0 // May conflict with less common shortcuts
        case medium = 1 // Conflicts with common app shortcuts
        case high = 2 // Conflicts with system shortcuts
    }

    public init(
        conflictingApp: String, description: String, severity: ConflictSeverity,
        suggestion: String? = nil
    ) {
        self.conflictingApp = conflictingApp
        self.description = description
        self.severity = severity
        self.suggestion = suggestion
    }
}

// Known System Shortcut

private struct KnownShortcut {
    let keyCode: UInt32
    let modifiers: UInt32
    let app: String
    let description: String
    let severity: HotkeyConflict.ConflictSeverity
}

// Hotkey Configuration

public struct HotkeyConfig: Codable, Equatable, Sendable {
    public var keyCode: UInt32
    public var modifiers: UInt32

    public static let defaultConfig = HotkeyConfig(
        keyCode: UInt32(kVK_ANSI_0), // 0 key
        modifiers: UInt32(cmdKey | controlKey)
    )

    public var displayString: String {
        var parts: [String] = []

        if modifiers & UInt32(controlKey) != 0 { parts.append("Ctrl") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("Option") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("Shift") }
        if modifiers & UInt32(cmdKey) != 0 { parts.append("Cmd") }

        let keyName = keyCodeToString(keyCode)
        parts.append(keyName)

        return parts.joined(separator: " + ")
    }

    private static let keyCodeMap: [Int: String] = [
        kVK_ANSI_0: "0",
        kVK_ANSI_1: "1",
        kVK_ANSI_2: "2",
        kVK_ANSI_3: "3",
        kVK_ANSI_4: "4",
        kVK_ANSI_5: "5",
        kVK_ANSI_6: "6",
        kVK_ANSI_7: "7",
        kVK_ANSI_8: "8",
        kVK_ANSI_9: "9",
        kVK_ANSI_A: "A",
        kVK_ANSI_B: "B",
        kVK_ANSI_C: "C",
        kVK_ANSI_D: "D",
        kVK_ANSI_E: "E",
        kVK_ANSI_F: "F",
        kVK_ANSI_G: "G",
        kVK_ANSI_H: "H",
        kVK_ANSI_I: "I",
        kVK_ANSI_J: "J",
        kVK_ANSI_K: "K",
        kVK_ANSI_L: "L",
        kVK_ANSI_M: "M",
        kVK_ANSI_N: "N",
        kVK_ANSI_O: "O",
        kVK_ANSI_P: "P",
        kVK_ANSI_Q: "Q",
        kVK_ANSI_R: "R",
        kVK_ANSI_S: "S",
        kVK_ANSI_T: "T",
        kVK_ANSI_U: "U",
        kVK_ANSI_V: "V",
        kVK_ANSI_W: "W",
        kVK_ANSI_X: "X",
        kVK_ANSI_Y: "Y",
        kVK_ANSI_Z: "Z",
        kVK_Space: "Space",
        kVK_Return: "Return",
        kVK_Tab: "Tab",
        kVK_Escape: "Esc",
        kVK_F1: "F1",
        kVK_F2: "F2",
        kVK_F3: "F3",
        kVK_F4: "F4",
        kVK_F5: "F5",
        kVK_F6: "F6",
        kVK_F7: "F7",
        kVK_F8: "F8",
        kVK_F9: "F9",
        kVK_F10: "F10",
        kVK_F11: "F11",
        kVK_F12: "F12"
    ]

    private func keyCodeToString(_ code: UInt32) -> String {
        HotkeyConfig.keyCodeMap[Int(code)] ?? "Key(\(code))"
    }
}

// Hotkey Manager

@MainActor
public final class HotkeyManager: ObservableObject {
    public static let shared = HotkeyManager()

    @Published public var currentConfig: HotkeyConfig {
        didSet {
            saveConfig()
            checkForConflicts()
            reregisterHotkey()
        }
    }

    @Published public var isRecording = false
    @Published public var hasConflict = false
    @Published public var conflictMessage: String?
    @Published public var detectedConflicts: [HotkeyConflict] = []
    @Published public var overrideConflicts = false

    public var onHotkeyPressed: (() -> Void)?

    private var hotkeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let hotkeyID = EventHotKeyID(
        signature: AppConstants.Hotkey.signature,
        id: AppConstants.Hotkey.id
    )

    /// Known system and common app shortcuts
    private let knownShortcuts: [KnownShortcut] = [
        // macOS System Shortcuts (High severity)
        KnownShortcut(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Spotlight Search",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(cmdKey | optionKey),
            app: "macOS",
            description: "Finder Search",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_Tab),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "App Switcher",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_Q),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Quit App",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_W),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Close Window",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_H),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Hide App",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_M),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Minimize Window",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_C),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Copy",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_V),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Paste",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_X),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Cut",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_Z),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Undo",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_A),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Select All",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_S),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Save",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_N),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "New",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_O),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Open",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_P),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Print",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_F),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Find",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_Comma),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "Preferences",
            severity: .high
        ),

        // Mission Control / Spaces (High severity)
        KnownShortcut(
            keyCode: UInt32(kVK_UpArrow),
            modifiers: UInt32(controlKey),
            app: "Mission Control",
            description: "Mission Control",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_DownArrow),
            modifiers: UInt32(controlKey),
            app: "Mission Control",
            description: "App Windows",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_LeftArrow),
            modifiers: UInt32(controlKey),
            app: "Mission Control",
            description: "Move Left Space",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_RightArrow),
            modifiers: UInt32(controlKey),
            app: "Mission Control",
            description: "Move Right Space",
            severity: .high
        ),

        // Screenshot shortcuts (High severity)
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_3),
            modifiers: UInt32(cmdKey | shiftKey),
            app: "macOS",
            description: "Screenshot Full",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_4),
            modifiers: UInt32(cmdKey | shiftKey),
            app: "macOS",
            description: "Screenshot Selection",
            severity: .high
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_5),
            modifiers: UInt32(cmdKey | shiftKey),
            app: "macOS",
            description: "Screenshot Options",
            severity: .high
        ),

        // Common App Shortcuts (Medium severity)
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_T),
            modifiers: UInt32(cmdKey),
            app: "Browsers/Terminals",
            description: "New Tab",
            severity: .medium
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_R),
            modifiers: UInt32(cmdKey),
            app: "Browsers",
            description: "Refresh",
            severity: .medium
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_L),
            modifiers: UInt32(cmdKey),
            app: "Browsers",
            description: "Address Bar",
            severity: .medium
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_B),
            modifiers: UInt32(cmdKey),
            app: "Browsers",
            description: "Bookmarks",
            severity: .medium
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_D),
            modifiers: UInt32(cmdKey),
            app: "Browsers",
            description: "Bookmark Page",
            severity: .medium
        ),

        // Developer Tools (Medium severity)
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_I),
            modifiers: UInt32(cmdKey | optionKey),
            app: "Browsers",
            description: "Developer Tools",
            severity: .medium
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_B),
            modifiers: UInt32(cmdKey),
            app: "Xcode",
            description: "Build",
            severity: .medium
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_R),
            modifiers: UInt32(cmdKey),
            app: "Xcode",
            description: "Run",
            severity: .medium
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_ANSI_U),
            modifiers: UInt32(cmdKey),
            app: "Xcode",
            description: "Test",
            severity: .medium
        ),

        // Accessibility (High severity)
        KnownShortcut(
            keyCode: UInt32(kVK_F5),
            modifiers: UInt32(cmdKey),
            app: "macOS",
            description: "VoiceOver",
            severity: .high
        ),

        // Function keys with modifiers (Low severity - less common)
        KnownShortcut(
            keyCode: UInt32(kVK_F11),
            modifiers: 0,
            app: "macOS",
            description: "Show Desktop",
            severity: .low
        ),
        KnownShortcut(
            keyCode: UInt32(kVK_F12),
            modifiers: 0,
            app: "macOS",
            description: "Dashboard/Notification",
            severity: .low
        )
    ]

    private init() {
        self.currentConfig = Self.loadConfig()
        self.overrideConflicts = UserDefaults.standard.bool(
            forKey: UserDefaultsKeys.hotkeyOverrideConflicts
        )
        checkForConflicts()
    }

    // Public Methods

    public func registerHotkey() {
        unregisterHotkey()

        // Install event handler
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed)
        )

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData -> OSStatus in
                guard let userData else { return noErr }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                Task { @MainActor in
                    manager.onHotkeyPressed?()
                }
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )

        guard status == noErr else {
            hasConflict = true
            conflictMessage = "Failed to install event handler"
            return
        }

        // Register the hotkey
        let registerStatus = RegisterEventHotKey(
            currentConfig.keyCode,
            currentConfig.modifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )

        if registerStatus != noErr {
            hasConflict = true
            conflictMessage = L10n.shared.hotkeyConflictMessage
        } else {
            hasConflict = false
            conflictMessage = nil
        }
    }

    public func unregisterHotkey() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }

    public func startRecording() {
        isRecording = true
    }

    public func stopRecording() {
        isRecording = false
    }

    public func recordKey(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        guard isRecording else { return }

        var carbonModifiers: UInt32 = 0
        if modifiers.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
        if modifiers.contains(.control) { carbonModifiers |= UInt32(controlKey) }
        if modifiers.contains(.option) { carbonModifiers |= UInt32(optionKey) }
        if modifiers.contains(.shift) { carbonModifiers |= UInt32(shiftKey) }

        // Require at least one modifier
        guard carbonModifiers != 0 else { return }

        currentConfig = HotkeyConfig(keyCode: UInt32(keyCode), modifiers: carbonModifiers)
        stopRecording()
    }

    public func resetToDefault() {
        currentConfig = .defaultConfig
    }

    public func setOverrideConflicts(_ override: Bool) {
        overrideConflicts = override
        UserDefaults.standard.set(override, forKey: UserDefaultsKeys.hotkeyOverrideConflicts)
        if override {
            // Re-register hotkey when user chooses to override conflicts
            reregisterHotkey()
        }
    }

    /// Check a specific hotkey config for conflicts without setting it
    public func checkConflicts(for config: HotkeyConfig) -> [HotkeyConflict] {
        var conflicts: [HotkeyConflict] = []

        for shortcut in knownShortcuts {
            if shortcut.keyCode == config.keyCode, shortcut.modifiers == config.modifiers {
                let suggestion = generateSuggestion(for: shortcut)
                let conflict = HotkeyConflict(
                    conflictingApp: shortcut.app,
                    description: shortcut.description,
                    severity: shortcut.severity,
                    suggestion: suggestion
                )
                conflicts.append(conflict)
            }
        }

        // Sort by severity (highest first)
        return conflicts.sorted { $0.severity.rawValue > $1.severity.rawValue }
    }

    /// Get the highest severity conflict for the current config
    public var highestSeverityConflict: HotkeyConflict? {
        detectedConflicts.first
    }

    // Private Methods

    private func reregisterHotkey() {
        registerHotkey()
    }

    private func checkForConflicts() {
        detectedConflicts = checkConflicts(for: currentConfig)
        hasConflict = !detectedConflicts.isEmpty

        if let highestConflict = detectedConflicts.first {
            conflictMessage = formatConflictMessage(highestConflict)
        } else {
            conflictMessage = nil
        }
    }

    private func formatConflictMessage(_ conflict: HotkeyConflict) -> String {
        let l10n = L10n.shared
        switch conflict.severity {
        case .high:
            return l10n.hotkeyConflictSystem(
                app: conflict.conflictingApp, action: conflict.description
            )
        case .medium:
            return l10n.hotkeyConflictApp(
                app: conflict.conflictingApp, action: conflict.description
            )
        case .low:
            return l10n.hotkeyConflictPossible(
                app: conflict.conflictingApp, action: conflict.description
            )
        }
    }

    private func generateSuggestion(for shortcut: KnownShortcut) -> String {
        let l10n = L10n.shared
        switch shortcut.severity {
        case .high:
            return l10n.hotkeyConflictSuggestionHigh
        case .medium:
            return l10n.hotkeyConflictSuggestionMedium
        case .low:
            return l10n.hotkeyConflictSuggestionLow
        }
    }

    private func saveConfig() {
        if let data = try? JSONEncoder().encode(currentConfig) {
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.hotkeyConfig)
        }
    }

    private static func loadConfig() -> HotkeyConfig {
        let storedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.hotkeyConfig)
        let decodedConfig = storedData.flatMap { try? JSONDecoder().decode(HotkeyConfig.self, from: $0) }
        guard let config = decodedConfig else {
            return .defaultConfig
        }
        return config
    }
}
