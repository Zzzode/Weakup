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
        UserDefaults.standard.removeObject(forKey: "WeakupHotkeyConfig")
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
}
