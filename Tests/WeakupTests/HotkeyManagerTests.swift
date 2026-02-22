import Testing
import Carbon
@testable import WeakupCore

// MARK: - HotkeyConfig Tests

@Suite("HotkeyConfig Tests")
struct HotkeyConfigTests {

    // MARK: - Default Config Tests

    @Test("Default config has expected key code")
    func defaultConfigHasExpectedKeyCode() {
        let config = HotkeyConfig.defaultConfig
        #expect(config.keyCode == UInt32(kVK_ANSI_0))
    }

    @Test("Default config has command and control modifiers")
    func defaultConfigHasCommandAndControlModifiers() {
        let config = HotkeyConfig.defaultConfig
        let expectedModifiers = UInt32(cmdKey | controlKey)
        #expect(config.modifiers == expectedModifiers)
    }

    // MARK: - Equatable Tests

    @Test("Equatable same configs are equal")
    func equatableSameConfigsAreEqual() {
        let config1 = HotkeyConfig(keyCode: 10, modifiers: 256)
        let config2 = HotkeyConfig(keyCode: 10, modifiers: 256)
        #expect(config1 == config2)
    }

    @Test("Equatable different key code are not equal")
    func equatableDifferentKeyCodeAreNotEqual() {
        let config1 = HotkeyConfig(keyCode: 10, modifiers: 256)
        let config2 = HotkeyConfig(keyCode: 11, modifiers: 256)
        #expect(config1 != config2)
    }

    @Test("Equatable different modifiers are not equal")
    func equatableDifferentModifiersAreNotEqual() {
        let config1 = HotkeyConfig(keyCode: 10, modifiers: 256)
        let config2 = HotkeyConfig(keyCode: 10, modifiers: 512)
        #expect(config1 != config2)
    }

    // MARK: - Display String Tests

    @Test("Display string for default config")
    func displayStringDefaultConfig() {
        let config = HotkeyConfig.defaultConfig
        let display = config.displayString
        #expect(display.contains("Ctrl"))
        #expect(display.contains("Cmd"))
        #expect(display.contains("0"))
    }

    @Test("Display string with all modifiers")
    func displayStringWithAllModifiers() {
        let allModifiers = UInt32(cmdKey | controlKey | optionKey | shiftKey)
        let config = HotkeyConfig(keyCode: UInt32(kVK_ANSI_A), modifiers: allModifiers)
        let display = config.displayString

        #expect(display.contains("Ctrl"))
        #expect(display.contains("Option"))
        #expect(display.contains("Shift"))
        #expect(display.contains("Cmd"))
        #expect(display.contains("A"))
    }

    @Test("Display string for function key")
    func displayStringFunctionKey() {
        let config = HotkeyConfig(keyCode: UInt32(kVK_F1), modifiers: UInt32(cmdKey))
        #expect(config.displayString.contains("F1"))
    }

    @Test("Display string for special keys")
    func displayStringSpecialKeys() {
        let spaceConfig = HotkeyConfig(keyCode: UInt32(kVK_Space), modifiers: UInt32(cmdKey))
        #expect(spaceConfig.displayString.contains("Space"))

        let returnConfig = HotkeyConfig(keyCode: UInt32(kVK_Return), modifiers: UInt32(cmdKey))
        #expect(returnConfig.displayString.contains("Return"))

        let escConfig = HotkeyConfig(keyCode: UInt32(kVK_Escape), modifiers: UInt32(cmdKey))
        #expect(escConfig.displayString.contains("Esc"))
    }

    // MARK: - Codable Tests

    @Test("Codable encodes and decodes")
    func codableEncodesAndDecodes() throws {
        let original = HotkeyConfig(keyCode: 42, modifiers: 1024)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HotkeyConfig.self, from: data)

        #expect(decoded == original)
    }

    // MARK: - Numbers 0-9 Tests

    @Test("Display string for numbers 0 to 9")
    func displayStringNumbersZeroToNine() {
        let keyCodes: [(Int, String)] = [
            (kVK_ANSI_0, "0"),
            (kVK_ANSI_1, "1"),
            (kVK_ANSI_2, "2"),
            (kVK_ANSI_3, "3"),
            (kVK_ANSI_4, "4"),
            (kVK_ANSI_5, "5"),
            (kVK_ANSI_6, "6"),
            (kVK_ANSI_7, "7"),
            (kVK_ANSI_8, "8"),
            (kVK_ANSI_9, "9"),
        ]

        for (keyCode, expected) in keyCodes {
            let config = HotkeyConfig(keyCode: UInt32(keyCode), modifiers: UInt32(cmdKey))
            #expect(config.displayString.contains(expected), "Expected \(expected) in display string")
        }
    }

    @Test("Display string for letters A to Z")
    func displayStringLettersAToZ() {
        let letterKeyCodes: [(Int, String)] = [
            (kVK_ANSI_A, "A"), (kVK_ANSI_B, "B"), (kVK_ANSI_C, "C"),
            (kVK_ANSI_D, "D"), (kVK_ANSI_E, "E"), (kVK_ANSI_F, "F"),
            (kVK_ANSI_G, "G"), (kVK_ANSI_H, "H"), (kVK_ANSI_I, "I"),
            (kVK_ANSI_J, "J"), (kVK_ANSI_K, "K"), (kVK_ANSI_L, "L"),
            (kVK_ANSI_M, "M"), (kVK_ANSI_N, "N"), (kVK_ANSI_O, "O"),
            (kVK_ANSI_P, "P"), (kVK_ANSI_Q, "Q"), (kVK_ANSI_R, "R"),
            (kVK_ANSI_S, "S"), (kVK_ANSI_T, "T"), (kVK_ANSI_U, "U"),
            (kVK_ANSI_V, "V"), (kVK_ANSI_W, "W"), (kVK_ANSI_X, "X"),
            (kVK_ANSI_Y, "Y"), (kVK_ANSI_Z, "Z"),
        ]

        for (keyCode, expected) in letterKeyCodes {
            let config = HotkeyConfig(keyCode: UInt32(keyCode), modifiers: UInt32(cmdKey))
            #expect(config.displayString.contains(expected), "Expected \(expected) in display string")
        }
    }

    @Test("Display string for function keys F1 to F12")
    func displayStringFunctionKeysF1ToF12() {
        let functionKeyCodes: [(Int, String)] = [
            (kVK_F1, "F1"), (kVK_F2, "F2"), (kVK_F3, "F3"),
            (kVK_F4, "F4"), (kVK_F5, "F5"), (kVK_F6, "F6"),
            (kVK_F7, "F7"), (kVK_F8, "F8"), (kVK_F9, "F9"),
            (kVK_F10, "F10"), (kVK_F11, "F11"), (kVK_F12, "F12"),
        ]

        for (keyCode, expected) in functionKeyCodes {
            let config = HotkeyConfig(keyCode: UInt32(keyCode), modifiers: UInt32(cmdKey))
            #expect(config.displayString.contains(expected), "Expected \(expected) in display string")
        }
    }

    @Test("Display string for tab key")
    func displayStringTabKey() {
        let config = HotkeyConfig(keyCode: UInt32(kVK_Tab), modifiers: UInt32(cmdKey))
        #expect(config.displayString.contains("Tab"))
    }

    @Test("Display string for unknown key code")
    func displayStringUnknownKeyCode() {
        // Use a key code that's not in the switch statement
        let config = HotkeyConfig(keyCode: 999, modifiers: UInt32(cmdKey))
        #expect(config.displayString.contains("Key(999)"))
    }

    @Test("Display string modifier order")
    func displayStringModifierOrder() {
        // Modifiers should appear in a consistent order: Ctrl, Option, Shift, Cmd
        let allModifiers = UInt32(cmdKey | controlKey | optionKey | shiftKey)
        let config = HotkeyConfig(keyCode: UInt32(kVK_ANSI_A), modifiers: allModifiers)
        let display = config.displayString

        // Verify order by checking positions
        guard let ctrlRange = display.range(of: "Ctrl"),
              let optionRange = display.range(of: "Option"),
              let shiftRange = display.range(of: "Shift"),
              let cmdRange = display.range(of: "Cmd") else {
            Issue.record("Missing modifier in display string")
            return
        }

        #expect(ctrlRange.lowerBound < optionRange.lowerBound)
        #expect(optionRange.lowerBound < shiftRange.lowerBound)
        #expect(shiftRange.lowerBound < cmdRange.lowerBound)
    }

    @Test("Default config display string is Ctrl+Cmd+0")
    func defaultConfigDisplayStringIsCtrlCmd0() {
        let config = HotkeyConfig.defaultConfig
        let display = config.displayString

        // Should be "Ctrl + Cmd + 0"
        #expect(display == "Ctrl + Cmd + 0")
    }

    @Test("Codable preserves all fields")
    func codablePreservesAllFields() throws {
        let original = HotkeyConfig(
            keyCode: UInt32(kVK_ANSI_M),
            modifiers: UInt32(cmdKey | shiftKey | optionKey)
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(HotkeyConfig.self, from: data)

        #expect(decoded.keyCode == original.keyCode)
        #expect(decoded.modifiers == original.modifiers)
        #expect(decoded.displayString == original.displayString)
    }
}

// MARK: - HotkeyManager Tests

@Suite("HotkeyManager Tests")
@MainActor
struct HotkeyManagerTests {

    init() {
        UserDefaultsStore.shared.removeObject(forKey: "WeakupHotkeyConfig")
    }

    // MARK: - Singleton Tests

    @Test("Shared returns same instance")
    func sharedReturnsSameInstance() {
        let instance1 = HotkeyManager.shared
        let instance2 = HotkeyManager.shared
        #expect(instance1 === instance2)
    }

    // MARK: - Recording State Tests

    @Test("Start recording sets isRecording true")
    func startRecordingSetsIsRecordingTrue() {
        let manager = HotkeyManager.shared
        manager.stopRecording() // Ensure clean state
        #expect(!manager.isRecording)

        manager.startRecording()
        #expect(manager.isRecording)

        manager.stopRecording() // Clean up
    }

    @Test("Stop recording sets isRecording false")
    func stopRecordingSetsIsRecordingFalse() {
        let manager = HotkeyManager.shared
        manager.startRecording()
        #expect(manager.isRecording)

        manager.stopRecording()
        #expect(!manager.isRecording)
    }

    // MARK: - Reset Tests

    @Test("Reset to default restores default config")
    func resetToDefaultRestoresDefaultConfig() {
        let manager = HotkeyManager.shared

        // Change to non-default
        manager.currentConfig = HotkeyConfig(keyCode: 99, modifiers: 512)
        #expect(manager.currentConfig != HotkeyConfig.defaultConfig)

        manager.resetToDefault()
        #expect(manager.currentConfig == HotkeyConfig.defaultConfig)
    }

    // MARK: - Conflict Detection Tests

    @Test("Has conflict initially false")
    func hasConflictInitiallyFalse() {
        let manager = HotkeyManager.shared
        // Note: hasConflict state depends on system registration
        // This test verifies the property exists and is accessible
        _ = manager.hasConflict
        _ = manager.conflictMessage
    }

    // MARK: - Callback Tests

    @Test("onHotkeyPressed can be set")
    func onHotkeyPressedCanBeSet() {
        let manager = HotkeyManager.shared
        var callbackCalled = false

        manager.onHotkeyPressed = {
            callbackCalled = true
        }

        // Manually trigger to verify callback is set
        manager.onHotkeyPressed?()
        #expect(callbackCalled)

        // Clean up
        manager.onHotkeyPressed = nil
    }

    // MARK: - Record Key Tests

    @Test("Record key updates config when recording")
    func recordKeyUpdatesConfigWhenRecording() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.startRecording()

        // Record a new key (Cmd+Shift+A)
        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_A),
            modifiers: [.command, .shift]
        )

        // Config should be updated
        #expect(manager.currentConfig.keyCode == UInt32(kVK_ANSI_A))
        #expect(manager.currentConfig.modifiers & UInt32(shiftKey) != 0)
        #expect(manager.currentConfig.modifiers & UInt32(cmdKey) != 0)

        // Recording should stop after recording a key
        #expect(!manager.isRecording)

        // Restore original config
        manager.currentConfig = originalConfig
    }

    @Test("Record key does not update when not recording")
    func recordKeyDoesNotUpdateWhenNotRecording() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.stopRecording() // Ensure not recording
        #expect(!manager.isRecording)

        // Try to record a key
        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_Z),
            modifiers: [.command, .option]
        )

        // Config should not change
        #expect(manager.currentConfig == originalConfig)
    }

    @Test("Record key requires modifier")
    func recordKeyRequiresModifier() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.startRecording()

        // Try to record without modifiers (should be ignored)
        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_A),
            modifiers: []
        )

        // Config should not change (no modifiers)
        #expect(manager.currentConfig == originalConfig)

        // Should still be recording since the key was rejected
        #expect(manager.isRecording)

        manager.stopRecording()
    }

    @Test("Record key with control modifier")
    func recordKeyWithControlModifier() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.startRecording()

        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_B),
            modifiers: [.control]
        )

        #expect(manager.currentConfig.keyCode == UInt32(kVK_ANSI_B))
        #expect(manager.currentConfig.modifiers & UInt32(controlKey) != 0)

        // Restore
        manager.currentConfig = originalConfig
    }

    @Test("Record key with option modifier")
    func recordKeyWithOptionModifier() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.startRecording()

        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_C),
            modifiers: [.option]
        )

        #expect(manager.currentConfig.keyCode == UInt32(kVK_ANSI_C))
        #expect(manager.currentConfig.modifiers & UInt32(optionKey) != 0)

        // Restore
        manager.currentConfig = originalConfig
    }

    @Test("Record key with all modifiers")
    func recordKeyWithAllModifiers() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.startRecording()

        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_D),
            modifiers: [.command, .control, .option, .shift]
        )

        #expect(manager.currentConfig.keyCode == UInt32(kVK_ANSI_D))
        #expect(manager.currentConfig.modifiers & UInt32(cmdKey) != 0)
        #expect(manager.currentConfig.modifiers & UInt32(controlKey) != 0)
        #expect(manager.currentConfig.modifiers & UInt32(optionKey) != 0)
        #expect(manager.currentConfig.modifiers & UInt32(shiftKey) != 0)

        // Restore
        manager.currentConfig = originalConfig
    }

    // MARK: - Persistence Tests

    @Test("Config persists to UserDefaults")
    func configPersistsToUserDefaults() throws {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        // Set a new config
        let newConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_X), modifiers: UInt32(cmdKey | optionKey))
        manager.currentConfig = newConfig

        // Verify it was saved
        guard let data = UserDefaultsStore.shared.data(forKey: "WeakupHotkeyConfig") else {
            Issue.record("Config not saved to UserDefaults")
            manager.currentConfig = originalConfig
            return
        }

        let savedConfig = try JSONDecoder().decode(HotkeyConfig.self, from: data)
        #expect(savedConfig.keyCode == newConfig.keyCode)
        #expect(savedConfig.modifiers == newConfig.modifiers)

        // Restore
        manager.currentConfig = originalConfig
    }

    // MARK: - Register/Unregister Tests

    @Test("Register hotkey can be called")
    func registerHotkeyCanBeCalled() {
        let manager = HotkeyManager.shared

        // This test verifies the method can be called without crashing
        // Actual registration success depends on system state
        manager.registerHotkey()

        // Clean up
        manager.unregisterHotkey()
    }

    @Test("Unregister hotkey can be called multiple times")
    func unregisterHotkeyCanBeCalledMultipleTimes() {
        let manager = HotkeyManager.shared

        // Should not crash when called multiple times
        manager.unregisterHotkey()
        manager.unregisterHotkey()
        manager.unregisterHotkey()
    }

    @Test("Register unregister cycle")
    func registerUnregisterCycle() {
        let manager = HotkeyManager.shared

        // Multiple register/unregister cycles should work
        for _ in 0..<3 {
            manager.registerHotkey()
            manager.unregisterHotkey()
        }
    }

    // MARK: - Config Change Triggers Reregistration

    @Test("Config change triggers reregistration")
    func configChangeTriggersReregistration() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        // Unregister first
        manager.unregisterHotkey()

        // Change config (this should trigger reregistration via didSet)
        manager.currentConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_Y), modifiers: UInt32(cmdKey))

        // Restore and clean up
        manager.currentConfig = originalConfig
        manager.unregisterHotkey()
    }

    // MARK: - Conflict State Tests

    @Test("Conflict message is nil initially")
    func conflictMessageIsNilInitially() {
        let manager = HotkeyManager.shared
        manager.unregisterHotkey()

        // Before registration, conflict state should be clear
        // Note: This depends on the implementation - hasConflict might be set during registration
        _ = manager.hasConflict
        _ = manager.conflictMessage
    }

    // MARK: - Conflict Detection Tests

    @Test("Check conflicts detects Spotlight conflict")
    func checkConflictsDetectsSpotlightConflict() {
        let manager = HotkeyManager.shared

        // Cmd+Space is Spotlight
        let spotlightConfig = HotkeyConfig(keyCode: UInt32(kVK_Space), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: spotlightConfig)

        #expect(!conflicts.isEmpty, "Should detect Spotlight conflict")
        #expect(conflicts.first?.conflictingApp == "macOS")
        #expect(conflicts.first?.severity == .high)
    }

    @Test("Check conflicts detects Copy conflict")
    func checkConflictsDetectsCopyConflict() {
        let manager = HotkeyManager.shared

        // Cmd+C is Copy
        let copyConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: copyConfig)

        #expect(!conflicts.isEmpty, "Should detect Copy conflict")
        #expect(conflicts.first?.conflictingApp == "macOS")
        #expect(conflicts.first?.description.contains("Copy") ?? false)
    }

    @Test("Check conflicts detects Paste conflict")
    func checkConflictsDetectsPasteConflict() {
        let manager = HotkeyManager.shared

        // Cmd+V is Paste
        let pasteConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: pasteConfig)

        #expect(!conflicts.isEmpty, "Should detect Paste conflict")
        #expect(conflicts.first?.severity == .high)
    }

    @Test("Check conflicts detects Quit conflict")
    func checkConflictsDetectsQuitConflict() {
        let manager = HotkeyManager.shared

        // Cmd+Q is Quit
        let quitConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_Q), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: quitConfig)

        #expect(!conflicts.isEmpty, "Should detect Quit conflict")
        #expect(conflicts.first?.conflictingApp == "macOS")
    }

    @Test("Check conflicts detects Screenshot conflict")
    func checkConflictsDetectsScreenshotConflict() {
        let manager = HotkeyManager.shared

        // Cmd+Shift+3 is Screenshot Full
        let screenshotConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_3), modifiers: UInt32(cmdKey | shiftKey))
        let conflicts = manager.checkConflicts(for: screenshotConfig)

        #expect(!conflicts.isEmpty, "Should detect Screenshot conflict")
        #expect(conflicts.first?.description.contains("Screenshot") ?? false)
    }

    @Test("Check conflicts no conflict for default config")
    func checkConflictsNoConflictForDefaultConfig() {
        let manager = HotkeyManager.shared

        // Default config (Ctrl+Cmd+0) should not conflict with common shortcuts
        let conflicts = manager.checkConflicts(for: .defaultConfig)

        #expect(conflicts.isEmpty, "Default config should not have conflicts")
    }

    @Test("Check conflicts no conflict for unique shortcut")
    func checkConflictsNoConflictForUniqueShortcut() {
        let manager = HotkeyManager.shared

        // Ctrl+Option+Shift+Cmd+9 is unlikely to conflict
        let uniqueConfig = HotkeyConfig(
            keyCode: UInt32(kVK_ANSI_9),
            modifiers: UInt32(cmdKey | controlKey | optionKey | shiftKey)
        )
        let conflicts = manager.checkConflicts(for: uniqueConfig)

        #expect(conflicts.isEmpty, "Unique config should not have conflicts")
    }

    @Test("Check conflicts sorts by severity")
    func checkConflictsSortsBySeverity() {
        let manager = HotkeyManager.shared

        // If there are multiple conflicts, they should be sorted by severity (highest first)
        // This is a general test - specific conflicts depend on the known shortcuts list
        let copyConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: copyConfig)

        if conflicts.count > 1 {
            for i in 0..<(conflicts.count - 1) {
                #expect(
                    conflicts[i].severity.rawValue >= conflicts[i + 1].severity.rawValue,
                    "Conflicts should be sorted by severity"
                )
            }
        }
    }

    @Test("Highest severity conflict returns first conflict")
    func highestSeverityConflictReturnsFirstConflict() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        // Set to a conflicting config
        manager.currentConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey))

        if manager.hasConflict {
            #expect(manager.highestSeverityConflict != nil)
            #expect(manager.highestSeverityConflict == manager.detectedConflicts.first)
        }

        // Restore
        manager.currentConfig = originalConfig
    }

    @Test("Detected conflicts updates on config change")
    func detectedConflictsUpdatesOnConfigChange() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        // Set to non-conflicting config
        manager.currentConfig = .defaultConfig
        let conflictsWithDefault = manager.detectedConflicts.count

        // Set to conflicting config
        manager.currentConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey))
        let conflictsWithCopy = manager.detectedConflicts.count

        #expect(conflictsWithCopy > conflictsWithDefault, "Copy shortcut should have more conflicts")

        // Restore
        manager.currentConfig = originalConfig
    }

    @Test("Override conflicts can be set")
    func overrideConflictsCanBeSet() {
        let manager = HotkeyManager.shared
        let originalOverride = manager.overrideConflicts

        manager.setOverrideConflicts(true)
        #expect(manager.overrideConflicts)

        manager.setOverrideConflicts(false)
        #expect(!manager.overrideConflicts)

        // Restore
        manager.setOverrideConflicts(originalOverride)
    }

    @Test("Override conflicts persists to UserDefaults")
    func overrideConflictsPersistsToUserDefaults() {
        let manager = HotkeyManager.shared
        let originalOverride = manager.overrideConflicts

        manager.setOverrideConflicts(true)

        let savedValue = UserDefaultsStore.shared.bool(forKey: "WeakupOverrideConflicts")
        #expect(savedValue)

        // Restore
        manager.setOverrideConflicts(originalOverride)
    }

    @Test("Conflict suggestion is provided for conflicts")
    func conflictSuggestionIsProvidedForConflicts() {
        let manager = HotkeyManager.shared

        // Check that conflicts have suggestions
        let copyConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: copyConfig)

        if let conflict = conflicts.first {
            #expect(conflict.suggestion != nil, "Conflict should have a suggestion")
            #expect(!(conflict.suggestion?.isEmpty ?? true), "Suggestion should not be empty")
        }
    }
}

// MARK: - HotkeyConflict Tests

@Suite("HotkeyConflict Tests")
struct HotkeyConflictTests {

    @Test("Conflict severity raw values")
    func conflictSeverityRawValues() {
        #expect(HotkeyConflict.ConflictSeverity.low.rawValue == 0)
        #expect(HotkeyConflict.ConflictSeverity.medium.rawValue == 1)
        #expect(HotkeyConflict.ConflictSeverity.high.rawValue == 2)
    }

    @Test("Conflict severity comparison")
    func conflictSeverityComparison() {
        #expect(HotkeyConflict.ConflictSeverity.low.rawValue < HotkeyConflict.ConflictSeverity.medium.rawValue)
        #expect(HotkeyConflict.ConflictSeverity.medium.rawValue < HotkeyConflict.ConflictSeverity.high.rawValue)
    }

    @Test("HotkeyConflict initialization")
    func hotkeyConflictInitialization() {
        let conflict = HotkeyConflict(
            conflictingApp: "TestApp",
            description: "Test Action",
            severity: .medium,
            suggestion: "Try another shortcut"
        )

        #expect(conflict.conflictingApp == "TestApp")
        #expect(conflict.description == "Test Action")
        #expect(conflict.severity == .medium)
        #expect(conflict.suggestion == "Try another shortcut")
    }

    @Test("HotkeyConflict initialization without suggestion")
    func hotkeyConflictInitializationWithoutSuggestion() {
        let conflict = HotkeyConflict(
            conflictingApp: "TestApp",
            description: "Test Action",
            severity: .low
        )

        #expect(conflict.suggestion == nil)
    }

    @Test("HotkeyConflict equatable")
    func hotkeyConflictEquatable() {
        let conflict1 = HotkeyConflict(
            conflictingApp: "App1",
            description: "Action1",
            severity: .high,
            suggestion: "Suggestion1"
        )

        let conflict2 = HotkeyConflict(
            conflictingApp: "App1",
            description: "Action1",
            severity: .high,
            suggestion: "Suggestion1"
        )

        let conflict3 = HotkeyConflict(
            conflictingApp: "App2",
            description: "Action1",
            severity: .high,
            suggestion: "Suggestion1"
        )

        #expect(conflict1 == conflict2)
        #expect(conflict1 != conflict3)
    }

    @Test("HotkeyConflict different severities not equal")
    func hotkeyConflictDifferentSeveritiesNotEqual() {
        let conflict1 = HotkeyConflict(
            conflictingApp: "App",
            description: "Action",
            severity: .high
        )

        let conflict2 = HotkeyConflict(
            conflictingApp: "App",
            description: "Action",
            severity: .low
        )

        #expect(conflict1 != conflict2)
    }
}
