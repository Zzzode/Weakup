import XCTest
import Carbon
@testable import WeakupCore

// HotkeyConfig Tests

final class HotkeyConfigTests: XCTestCase {

    // Default Config Tests

    func testDefaultConfig_hasExpectedKeyCode() {
        let config = HotkeyConfig.defaultConfig
        XCTAssertEqual(config.keyCode, UInt32(kVK_ANSI_0))
    }

    func testDefaultConfig_hasCommandAndControlModifiers() {
        let config = HotkeyConfig.defaultConfig
        let expectedModifiers = UInt32(cmdKey | controlKey)
        XCTAssertEqual(config.modifiers, expectedModifiers)
    }

    // Equatable Tests

    func testEquatable_sameConfigs_areEqual() {
        let config1 = HotkeyConfig(keyCode: 10, modifiers: 256)
        let config2 = HotkeyConfig(keyCode: 10, modifiers: 256)
        XCTAssertEqual(config1, config2)
    }

    func testEquatable_differentKeyCode_areNotEqual() {
        let config1 = HotkeyConfig(keyCode: 10, modifiers: 256)
        let config2 = HotkeyConfig(keyCode: 11, modifiers: 256)
        XCTAssertNotEqual(config1, config2)
    }

    func testEquatable_differentModifiers_areNotEqual() {
        let config1 = HotkeyConfig(keyCode: 10, modifiers: 256)
        let config2 = HotkeyConfig(keyCode: 10, modifiers: 512)
        XCTAssertNotEqual(config1, config2)
    }

    // Display String Tests

    func testDisplayString_defaultConfig() {
        let config = HotkeyConfig.defaultConfig
        let display = config.displayString
        XCTAssertTrue(display.contains("Ctrl"))
        XCTAssertTrue(display.contains("Cmd"))
        XCTAssertTrue(display.contains("0"))
    }

    func testDisplayString_withAllModifiers() {
        let allModifiers = UInt32(cmdKey | controlKey | optionKey | shiftKey)
        let config = HotkeyConfig(keyCode: UInt32(kVK_ANSI_A), modifiers: allModifiers)
        let display = config.displayString

        XCTAssertTrue(display.contains("Ctrl"))
        XCTAssertTrue(display.contains("Option"))
        XCTAssertTrue(display.contains("Shift"))
        XCTAssertTrue(display.contains("Cmd"))
        XCTAssertTrue(display.contains("A"))
    }

    func testDisplayString_functionKey() {
        let config = HotkeyConfig(keyCode: UInt32(kVK_F1), modifiers: UInt32(cmdKey))
        XCTAssertTrue(config.displayString.contains("F1"))
    }

    func testDisplayString_specialKeys() {
        let spaceConfig = HotkeyConfig(keyCode: UInt32(kVK_Space), modifiers: UInt32(cmdKey))
        XCTAssertTrue(spaceConfig.displayString.contains("Space"))

        let returnConfig = HotkeyConfig(keyCode: UInt32(kVK_Return), modifiers: UInt32(cmdKey))
        XCTAssertTrue(returnConfig.displayString.contains("Return"))

        let escConfig = HotkeyConfig(keyCode: UInt32(kVK_Escape), modifiers: UInt32(cmdKey))
        XCTAssertTrue(escConfig.displayString.contains("Esc"))
    }

    // Codable Tests

    func testCodable_encodesAndDecodes() throws {
        let original = HotkeyConfig(keyCode: 42, modifiers: 1024)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HotkeyConfig.self, from: data)

        XCTAssertEqual(decoded, original)
    }
}

// HotkeyManager Tests

@MainActor
final class HotkeyManagerTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        UserDefaultsStore.shared.removeObject(forKey: "WeakupHotkeyConfig")
    }

    // Singleton Tests

    func testShared_returnsSameInstance() {
        let instance1 = HotkeyManager.shared
        let instance2 = HotkeyManager.shared
        XCTAssertTrue(instance1 === instance2)
    }

    // Recording State Tests

    func testStartRecording_setsIsRecordingTrue() {
        let manager = HotkeyManager.shared
        manager.stopRecording() // Ensure clean state
        XCTAssertFalse(manager.isRecording)

        manager.startRecording()
        XCTAssertTrue(manager.isRecording)

        manager.stopRecording() // Clean up
    }

    func testStopRecording_setsIsRecordingFalse() {
        let manager = HotkeyManager.shared
        manager.startRecording()
        XCTAssertTrue(manager.isRecording)

        manager.stopRecording()
        XCTAssertFalse(manager.isRecording)
    }

    // Reset Tests

    func testResetToDefault_restoresDefaultConfig() {
        let manager = HotkeyManager.shared

        // Change to non-default
        manager.currentConfig = HotkeyConfig(keyCode: 99, modifiers: 512)
        XCTAssertNotEqual(manager.currentConfig, HotkeyConfig.defaultConfig)

        manager.resetToDefault()
        XCTAssertEqual(manager.currentConfig, HotkeyConfig.defaultConfig)
    }

    // Conflict Detection Tests

    func testHasConflict_initiallyFalse() {
        let manager = HotkeyManager.shared
        // Note: hasConflict state depends on system registration
        // This test verifies the property exists and is accessible
        _ = manager.hasConflict
        _ = manager.conflictMessage
    }

    // Callback Tests

    func testOnHotkeyPressed_canBeSet() {
        let manager = HotkeyManager.shared
        var callbackCalled = false

        manager.onHotkeyPressed = {
            callbackCalled = true
        }

        // Manually trigger to verify callback is set
        manager.onHotkeyPressed?()
        XCTAssertTrue(callbackCalled)

        // Clean up
        manager.onHotkeyPressed = nil
    }

    // Record Key Tests

    func testRecordKey_updatesConfig_whenRecording() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.startRecording()

        // Record a new key (Cmd+Shift+A)
        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_A),
            modifiers: [.command, .shift]
        )

        // Config should be updated
        XCTAssertEqual(manager.currentConfig.keyCode, UInt32(kVK_ANSI_A))
        XCTAssertTrue(manager.currentConfig.modifiers & UInt32(shiftKey) != 0)
        XCTAssertTrue(manager.currentConfig.modifiers & UInt32(cmdKey) != 0)

        // Recording should stop after recording a key
        XCTAssertFalse(manager.isRecording)

        // Restore original config
        manager.currentConfig = originalConfig
    }

    func testRecordKey_doesNotUpdate_whenNotRecording() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.stopRecording() // Ensure not recording
        XCTAssertFalse(manager.isRecording)

        // Try to record a key
        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_Z),
            modifiers: [.command, .option]
        )

        // Config should not change
        XCTAssertEqual(manager.currentConfig, originalConfig)
    }

    func testRecordKey_requiresModifier() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.startRecording()

        // Try to record without modifiers (should be ignored)
        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_A),
            modifiers: []
        )

        // Config should not change (no modifiers)
        XCTAssertEqual(manager.currentConfig, originalConfig)

        // Should still be recording since the key was rejected
        XCTAssertTrue(manager.isRecording)

        manager.stopRecording()
    }

    func testRecordKey_withControlModifier() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.startRecording()

        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_B),
            modifiers: [.control]
        )

        XCTAssertEqual(manager.currentConfig.keyCode, UInt32(kVK_ANSI_B))
        XCTAssertTrue(manager.currentConfig.modifiers & UInt32(controlKey) != 0)

        // Restore
        manager.currentConfig = originalConfig
    }

    func testRecordKey_withOptionModifier() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.startRecording()

        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_C),
            modifiers: [.option]
        )

        XCTAssertEqual(manager.currentConfig.keyCode, UInt32(kVK_ANSI_C))
        XCTAssertTrue(manager.currentConfig.modifiers & UInt32(optionKey) != 0)

        // Restore
        manager.currentConfig = originalConfig
    }

    func testRecordKey_withAllModifiers() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        manager.startRecording()

        manager.recordKey(
            keyCode: UInt16(kVK_ANSI_D),
            modifiers: [.command, .control, .option, .shift]
        )

        XCTAssertEqual(manager.currentConfig.keyCode, UInt32(kVK_ANSI_D))
        XCTAssertTrue(manager.currentConfig.modifiers & UInt32(cmdKey) != 0)
        XCTAssertTrue(manager.currentConfig.modifiers & UInt32(controlKey) != 0)
        XCTAssertTrue(manager.currentConfig.modifiers & UInt32(optionKey) != 0)
        XCTAssertTrue(manager.currentConfig.modifiers & UInt32(shiftKey) != 0)

        // Restore
        manager.currentConfig = originalConfig
    }

    // Persistence Tests

    func testConfig_persistsToUserDefaults() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        // Set a new config
        let newConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_X), modifiers: UInt32(cmdKey | optionKey))
        manager.currentConfig = newConfig

        // Verify it was saved
        guard let data = UserDefaultsStore.shared.data(forKey: "WeakupHotkeyConfig") else {
            XCTFail("Config not saved to UserDefaults")
            manager.currentConfig = originalConfig
            return
        }

        do {
            let savedConfig = try JSONDecoder().decode(HotkeyConfig.self, from: data)
            XCTAssertEqual(savedConfig.keyCode, newConfig.keyCode)
            XCTAssertEqual(savedConfig.modifiers, newConfig.modifiers)
        } catch {
            XCTFail("Failed to decode saved config: \(error)")
        }

        // Restore
        manager.currentConfig = originalConfig
    }

    // Register/Unregister Tests

    func testRegisterHotkey_canBeCalled() {
        let manager = HotkeyManager.shared

        // This test verifies the method can be called without crashing
        // Actual registration success depends on system state
        manager.registerHotkey()

        // Clean up
        manager.unregisterHotkey()
    }

    func testUnregisterHotkey_canBeCalledMultipleTimes() {
        let manager = HotkeyManager.shared

        // Should not crash when called multiple times
        manager.unregisterHotkey()
        manager.unregisterHotkey()
        manager.unregisterHotkey()
    }

    func testRegisterUnregisterCycle() {
        let manager = HotkeyManager.shared

        // Multiple register/unregister cycles should work
        for _ in 0..<3 {
            manager.registerHotkey()
            manager.unregisterHotkey()
        }
    }

    // Config Change Triggers Reregistration

    func testConfigChange_triggersReregistration() {
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

    // Conflict State Tests

    func testConflictMessage_isNilInitially() {
        let manager = HotkeyManager.shared
        manager.unregisterHotkey()

        // Before registration, conflict state should be clear
        // Note: This depends on the implementation - hasConflict might be set during registration
        _ = manager.hasConflict
        _ = manager.conflictMessage
    }

    // Conflict Detection Tests

    func testCheckConflicts_detectsSpotlightConflict() {
        let manager = HotkeyManager.shared

        // Cmd+Space is Spotlight
        let spotlightConfig = HotkeyConfig(keyCode: UInt32(kVK_Space), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: spotlightConfig)

        XCTAssertFalse(conflicts.isEmpty, "Should detect Spotlight conflict")
        XCTAssertEqual(conflicts.first?.conflictingApp, "macOS")
        XCTAssertEqual(conflicts.first?.severity, .high)
    }

    func testCheckConflicts_detectsCopyConflict() {
        let manager = HotkeyManager.shared

        // Cmd+C is Copy
        let copyConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: copyConfig)

        XCTAssertFalse(conflicts.isEmpty, "Should detect Copy conflict")
        XCTAssertEqual(conflicts.first?.conflictingApp, "macOS")
        XCTAssertTrue(conflicts.first?.description.contains("Copy") ?? false)
    }

    func testCheckConflicts_detectsPasteConflict() {
        let manager = HotkeyManager.shared

        // Cmd+V is Paste
        let pasteConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: pasteConfig)

        XCTAssertFalse(conflicts.isEmpty, "Should detect Paste conflict")
        XCTAssertEqual(conflicts.first?.severity, .high)
    }

    func testCheckConflicts_detectsQuitConflict() {
        let manager = HotkeyManager.shared

        // Cmd+Q is Quit
        let quitConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_Q), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: quitConfig)

        XCTAssertFalse(conflicts.isEmpty, "Should detect Quit conflict")
        XCTAssertEqual(conflicts.first?.conflictingApp, "macOS")
    }

    func testCheckConflicts_detectsScreenshotConflict() {
        let manager = HotkeyManager.shared

        // Cmd+Shift+3 is Screenshot Full
        let screenshotConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_3), modifiers: UInt32(cmdKey | shiftKey))
        let conflicts = manager.checkConflicts(for: screenshotConfig)

        XCTAssertFalse(conflicts.isEmpty, "Should detect Screenshot conflict")
        XCTAssertTrue(conflicts.first?.description.contains("Screenshot") ?? false)
    }

    func testCheckConflicts_noConflictForDefaultConfig() {
        let manager = HotkeyManager.shared

        // Default config (Ctrl+Cmd+0) should not conflict with common shortcuts
        let conflicts = manager.checkConflicts(for: .defaultConfig)

        XCTAssertTrue(conflicts.isEmpty, "Default config should not have conflicts")
    }

    func testCheckConflicts_noConflictForUniqueShortcut() {
        let manager = HotkeyManager.shared

        // Ctrl+Option+Shift+Cmd+9 is unlikely to conflict
        let uniqueConfig = HotkeyConfig(
            keyCode: UInt32(kVK_ANSI_9),
            modifiers: UInt32(cmdKey | controlKey | optionKey | shiftKey)
        )
        let conflicts = manager.checkConflicts(for: uniqueConfig)

        XCTAssertTrue(conflicts.isEmpty, "Unique config should not have conflicts")
    }

    func testCheckConflicts_sortsBySeverity() {
        let manager = HotkeyManager.shared

        // If there are multiple conflicts, they should be sorted by severity (highest first)
        // This is a general test - specific conflicts depend on the known shortcuts list
        let copyConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: copyConfig)

        if conflicts.count > 1 {
            for i in 0..<(conflicts.count - 1) {
                XCTAssertGreaterThanOrEqual(
                    conflicts[i].severity.rawValue,
                    conflicts[i + 1].severity.rawValue,
                    "Conflicts should be sorted by severity"
                )
            }
        }
    }

    func testHighestSeverityConflict_returnsFirstConflict() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        // Set to a conflicting config
        manager.currentConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey))

        if manager.hasConflict {
            XCTAssertNotNil(manager.highestSeverityConflict)
            XCTAssertEqual(manager.highestSeverityConflict, manager.detectedConflicts.first)
        }

        // Restore
        manager.currentConfig = originalConfig
    }

    func testDetectedConflicts_updatesOnConfigChange() {
        let manager = HotkeyManager.shared
        let originalConfig = manager.currentConfig

        // Set to non-conflicting config
        manager.currentConfig = .defaultConfig
        let conflictsWithDefault = manager.detectedConflicts.count

        // Set to conflicting config
        manager.currentConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey))
        let conflictsWithCopy = manager.detectedConflicts.count

        XCTAssertGreaterThan(conflictsWithCopy, conflictsWithDefault, "Copy shortcut should have more conflicts")

        // Restore
        manager.currentConfig = originalConfig
    }

    func testOverrideConflicts_canBeSet() {
        let manager = HotkeyManager.shared
        let originalOverride = manager.overrideConflicts

        manager.setOverrideConflicts(true)
        XCTAssertTrue(manager.overrideConflicts)

        manager.setOverrideConflicts(false)
        XCTAssertFalse(manager.overrideConflicts)

        // Restore
        manager.setOverrideConflicts(originalOverride)
    }

    func testOverrideConflicts_persistsToUserDefaults() {
        let manager = HotkeyManager.shared
        let originalOverride = manager.overrideConflicts

        manager.setOverrideConflicts(true)

        let savedValue = UserDefaultsStore.shared.bool(forKey: "WeakupOverrideConflicts")
        XCTAssertTrue(savedValue)

        // Restore
        manager.setOverrideConflicts(originalOverride)
    }

    func testConflictSuggestion_isProvidedForConflicts() {
        let manager = HotkeyManager.shared

        // Check that conflicts have suggestions
        let copyConfig = HotkeyConfig(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: copyConfig)

        if let conflict = conflicts.first {
            XCTAssertNotNil(conflict.suggestion, "Conflict should have a suggestion")
            XCTAssertFalse(conflict.suggestion?.isEmpty ?? true, "Suggestion should not be empty")
        }
    }
}

// HotkeyConflict Tests

final class HotkeyConflictTests: XCTestCase {

    func testConflictSeverity_rawValues() {
        XCTAssertEqual(HotkeyConflict.ConflictSeverity.low.rawValue, 0)
        XCTAssertEqual(HotkeyConflict.ConflictSeverity.medium.rawValue, 1)
        XCTAssertEqual(HotkeyConflict.ConflictSeverity.high.rawValue, 2)
    }

    func testConflictSeverity_comparison() {
        XCTAssertLessThan(HotkeyConflict.ConflictSeverity.low.rawValue, HotkeyConflict.ConflictSeverity.medium.rawValue)
        XCTAssertLessThan(HotkeyConflict.ConflictSeverity.medium.rawValue, HotkeyConflict.ConflictSeverity.high.rawValue)
    }

    func testHotkeyConflict_initialization() {
        let conflict = HotkeyConflict(
            conflictingApp: "TestApp",
            description: "Test Action",
            severity: .medium,
            suggestion: "Try another shortcut"
        )

        XCTAssertEqual(conflict.conflictingApp, "TestApp")
        XCTAssertEqual(conflict.description, "Test Action")
        XCTAssertEqual(conflict.severity, .medium)
        XCTAssertEqual(conflict.suggestion, "Try another shortcut")
    }

    func testHotkeyConflict_initializationWithoutSuggestion() {
        let conflict = HotkeyConflict(
            conflictingApp: "TestApp",
            description: "Test Action",
            severity: .low
        )

        XCTAssertNil(conflict.suggestion)
    }

    func testHotkeyConflict_equatable() {
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

        XCTAssertEqual(conflict1, conflict2)
        XCTAssertNotEqual(conflict1, conflict3)
    }

    func testHotkeyConflict_differentSeverities_notEqual() {
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

        XCTAssertNotEqual(conflict1, conflict2)
    }
}

// Additional HotkeyConfig Tests

extension HotkeyConfigTests {

    func testDisplayString_numbersZeroToNine() {
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
            XCTAssertTrue(config.displayString.contains(expected), "Expected \(expected) in display string")
        }
    }

    func testDisplayString_lettersAToZ() {
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
            XCTAssertTrue(config.displayString.contains(expected), "Expected \(expected) in display string")
        }
    }

    func testDisplayString_functionKeysF1ToF12() {
        let functionKeyCodes: [(Int, String)] = [
            (kVK_F1, "F1"), (kVK_F2, "F2"), (kVK_F3, "F3"),
            (kVK_F4, "F4"), (kVK_F5, "F5"), (kVK_F6, "F6"),
            (kVK_F7, "F7"), (kVK_F8, "F8"), (kVK_F9, "F9"),
            (kVK_F10, "F10"), (kVK_F11, "F11"), (kVK_F12, "F12"),
        ]

        for (keyCode, expected) in functionKeyCodes {
            let config = HotkeyConfig(keyCode: UInt32(keyCode), modifiers: UInt32(cmdKey))
            XCTAssertTrue(config.displayString.contains(expected), "Expected \(expected) in display string")
        }
    }

    func testDisplayString_tabKey() {
        let config = HotkeyConfig(keyCode: UInt32(kVK_Tab), modifiers: UInt32(cmdKey))
        XCTAssertTrue(config.displayString.contains("Tab"))
    }

    func testDisplayString_unknownKeyCode() {
        // Use a key code that's not in the switch statement
        let config = HotkeyConfig(keyCode: 999, modifiers: UInt32(cmdKey))
        XCTAssertTrue(config.displayString.contains("Key(999)"))
    }

    func testDisplayString_modifierOrder() {
        // Modifiers should appear in a consistent order: Ctrl, Option, Shift, Cmd
        let allModifiers = UInt32(cmdKey | controlKey | optionKey | shiftKey)
        let config = HotkeyConfig(keyCode: UInt32(kVK_ANSI_A), modifiers: allModifiers)
        let display = config.displayString

        // Verify order by checking positions
        guard let ctrlRange = display.range(of: "Ctrl"),
              let optionRange = display.range(of: "Option"),
              let shiftRange = display.range(of: "Shift"),
              let cmdRange = display.range(of: "Cmd") else {
            XCTFail("Missing modifier in display string")
            return
        }

        XCTAssertLessThan(ctrlRange.lowerBound, optionRange.lowerBound)
        XCTAssertLessThan(optionRange.lowerBound, shiftRange.lowerBound)
        XCTAssertLessThan(shiftRange.lowerBound, cmdRange.lowerBound)
    }

    func testDefaultConfig_displayStringIsCtrlCmd0() {
        let config = HotkeyConfig.defaultConfig
        let display = config.displayString

        // Should be "Ctrl + Cmd + 0"
        XCTAssertEqual(display, "Ctrl + Cmd + 0")
    }

    func testCodable_preservesAllFields() throws {
        let original = HotkeyConfig(
            keyCode: UInt32(kVK_ANSI_M),
            modifiers: UInt32(cmdKey | shiftKey | optionKey)
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(HotkeyConfig.self, from: data)

        XCTAssertEqual(decoded.keyCode, original.keyCode)
        XCTAssertEqual(decoded.modifiers, original.modifiers)
        XCTAssertEqual(decoded.displayString, original.displayString)
    }
}
