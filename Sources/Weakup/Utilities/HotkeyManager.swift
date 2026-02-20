import AppKit
import Carbon

// MARK: - Hotkey Configuration

struct HotkeyConfig: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32

    static let defaultConfig = HotkeyConfig(
        keyCode: UInt32(kVK_ANSI_0),  // 0 key
        modifiers: UInt32(cmdKey | controlKey)
    )

    var displayString: String {
        var parts: [String] = []

        if modifiers & UInt32(controlKey) != 0 { parts.append("Ctrl") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("Option") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("Shift") }
        if modifiers & UInt32(cmdKey) != 0 { parts.append("Cmd") }

        let keyName = keyCodeToString(keyCode)
        parts.append(keyName)

        return parts.joined(separator: " + ")
    }

    private func keyCodeToString(_ code: UInt32) -> String {
        switch Int(code) {
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_Space: return "Space"
        case kVK_Return: return "Return"
        case kVK_Tab: return "Tab"
        case kVK_Escape: return "Esc"
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        default: return "Key(\(code))"
        }
    }
}

// MARK: - Hotkey Manager

@MainActor
final class HotkeyManager: ObservableObject {
    static let shared = HotkeyManager()

    @Published var currentConfig: HotkeyConfig {
        didSet {
            saveConfig()
            reregisterHotkey()
        }
    }
    @Published var isRecording = false
    @Published var hasConflict = false
    @Published var conflictMessage: String?

    var onHotkeyPressed: (() -> Void)?

    private var hotkeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let userDefaultsKey = "WeakupHotkeyConfig"
    private let hotkeyID = EventHotKeyID(signature: OSType(0x57454B55), id: 1)  // "WEKU"

    private init() {
        currentConfig = Self.loadConfig()
    }

    // MARK: - Public Methods

    func registerHotkey() {
        unregisterHotkey()

        // Install event handler
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
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

    func unregisterHotkey() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }

    func startRecording() {
        isRecording = true
    }

    func stopRecording() {
        isRecording = false
    }

    func recordKey(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
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

    func resetToDefault() {
        currentConfig = .defaultConfig
    }

    // MARK: - Private Methods

    private func reregisterHotkey() {
        registerHotkey()
    }

    private func saveConfig() {
        if let data = try? JSONEncoder().encode(currentConfig) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    private static func loadConfig() -> HotkeyConfig {
        guard let data = UserDefaults.standard.data(forKey: "WeakupHotkeyConfig"),
              let config = try? JSONDecoder().decode(HotkeyConfig.self, from: data) else {
            return .defaultConfig
        }
        return config
    }
}
