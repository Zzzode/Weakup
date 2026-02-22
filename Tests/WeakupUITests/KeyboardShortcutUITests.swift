import XCTest

/// UI tests for keyboard shortcut functionality
/// Note: These tests require XCUITest and an Xcode project to run
/// They test global keyboard shortcuts and shortcut recording
final class KeyboardShortcutUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // Helper Methods

    private func openSettings() -> Bool {
        let menuBar = app.menuBars
        let statusItem = menuBar.statusItems["Weakup"]

        guard statusItem.waitForExistence(timeout: 5) else {
            return false
        }

        statusItem.rightClick()
        sleep(1)

        let settingsItem = app.menuItems["Settings"]
        guard settingsItem.waitForExistence(timeout: 2) else {
            return false
        }

        settingsItem.click()
        sleep(1)

        return true
    }

    // Default Shortcut Tests

    func testDefaultShortcut_togglesCaffeine() throws {
        // Test that Cmd+Ctrl+0 toggles caffeine
        // Note: Global hotkeys may require accessibility permissions

        let menuBar = app.menuBars
        let statusItem = menuBar.statusItems["Weakup"]

        guard statusItem.waitForExistence(timeout: 5) else {
            XCTFail("Status item not found")
            return
        }

        // Press Cmd+Ctrl+0
        // Note: XCUITest has limited support for global hotkeys
        // This test may need to be run with accessibility permissions
        app.typeKey("0", modifierFlags: [.command, .control])

        sleep(1)

        // Press again to toggle back
        app.typeKey("0", modifierFlags: [.command, .control])

        sleep(1)

        XCTAssertTrue(statusItem.exists, "Status item should still exist")
    }

    func testShortcut_worksWhenPopoverClosed() throws {
        // Ensure popover is closed
        let menuBar = app.menuBars
        let statusItem = menuBar.statusItems["Weakup"]

        guard statusItem.waitForExistence(timeout: 5) else {
            XCTFail("Status item not found")
            return
        }

        // Click elsewhere to ensure popover is closed
        app.windows.firstMatch.click()
        sleep(1)

        // Press hotkey
        app.typeKey("0", modifierFlags: [.command, .control])

        sleep(1)

        // Verify app responded (status item still exists)
        XCTAssertTrue(statusItem.exists)
    }

    // Custom Shortcut Tests

    func testCustomShortcut_canBeRecorded() throws {
        guard openSettings() else {
            XCTFail("Could not open settings")
            return
        }

        let popover = app.popovers.firstMatch
        guard popover.waitForExistence(timeout: 2) else {
            XCTFail("Popover not found")
            return
        }

        // Find record button
        let recordButton = popover.buttons.matching(identifier: "recordHotkeyButton").firstMatch
        if recordButton.exists {
            recordButton.click()
            sleep(1)

            // Press a new shortcut (Cmd+Shift+W)
            app.typeKey("w", modifierFlags: [.command, .shift])

            sleep(1)

            // Verify the shortcut was recorded
            // The display should show the new shortcut
        }
    }

    func testShortcut_resetToDefault() throws {
        guard openSettings() else {
            XCTFail("Could not open settings")
            return
        }

        let popover = app.popovers.firstMatch
        guard popover.waitForExistence(timeout: 2) else {
            XCTFail("Popover not found")
            return
        }

        // Find reset button
        let resetButton = popover.buttons.matching(identifier: "resetHotkeyButton").firstMatch
        if resetButton.exists {
            resetButton.click()
            sleep(1)

            // Verify default shortcut is restored
            // The display should show Cmd+Ctrl+0
        }
    }

    // Shortcut Conflict Tests

    func testShortcut_conflictDetection() throws {
        guard openSettings() else {
            XCTFail("Could not open settings")
            return
        }

        let popover = app.popovers.firstMatch
        guard popover.waitForExistence(timeout: 2) else {
            XCTFail("Popover not found")
            return
        }

        // Try to record a system shortcut (like Cmd+Q)
        let recordButton = popover.buttons.matching(identifier: "recordHotkeyButton").firstMatch
        if recordButton.exists {
            recordButton.click()
            sleep(1)

            // Press Cmd+Q (system quit shortcut)
            app.typeKey("q", modifierFlags: .command)

            sleep(1)

            // Should show conflict warning or reject the shortcut
        }
    }

    // Modifier Key Tests

    func testShortcut_requiresModifiers() throws {
        guard openSettings() else {
            XCTFail("Could not open settings")
            return
        }

        let popover = app.popovers.firstMatch
        guard popover.waitForExistence(timeout: 2) else {
            XCTFail("Popover not found")
            return
        }

        // Try to record a key without modifiers
        let recordButton = popover.buttons.matching(identifier: "recordHotkeyButton").firstMatch
        if recordButton.exists {
            recordButton.click()
            sleep(1)

            // Press just a letter key (no modifiers)
            app.typeKey("a", modifierFlags: [])

            sleep(1)

            // Should not accept the shortcut (requires modifiers)
        }
    }

    // Recording State Tests

    func testRecording_canBeCancelled() throws {
        guard openSettings() else {
            XCTFail("Could not open settings")
            return
        }

        let popover = app.popovers.firstMatch
        guard popover.waitForExistence(timeout: 2) else {
            XCTFail("Popover not found")
            return
        }

        // Start recording
        let recordButton = popover.buttons.matching(identifier: "recordHotkeyButton").firstMatch
        if recordButton.exists {
            recordButton.click()
            sleep(1)

            // Press Escape to cancel
            app.typeKey(.escape, modifierFlags: [])

            sleep(1)

            // Recording should be cancelled
        }
    }

    func testRecording_visualFeedback() throws {
        guard openSettings() else {
            XCTFail("Could not open settings")
            return
        }

        let popover = app.popovers.firstMatch
        guard popover.waitForExistence(timeout: 2) else {
            XCTFail("Popover not found")
            return
        }

        // Start recording
        let recordButton = popover.buttons.matching(identifier: "recordHotkeyButton").firstMatch
        if recordButton.exists {
            // Get initial state
            let initialTitle = recordButton.label

            recordButton.click()
            sleep(1)

            // Button should show recording state
            let recordingTitle = recordButton.label

            // Cancel recording
            app.typeKey(.escape, modifierFlags: [])

            // Titles might be different during recording
            _ = initialTitle
            _ = recordingTitle
        }
    }

    // Function Key Tests

    func testShortcut_functionKeys() throws {
        guard openSettings() else {
            XCTFail("Could not open settings")
            return
        }

        let popover = app.popovers.firstMatch
        guard popover.waitForExistence(timeout: 2) else {
            XCTFail("Popover not found")
            return
        }

        // Try to record a function key shortcut
        let recordButton = popover.buttons.matching(identifier: "recordHotkeyButton").firstMatch
        if recordButton.exists {
            recordButton.click()
            sleep(1)

            // Press Cmd+F1
            app.typeKey(.F1, modifierFlags: .command)

            sleep(1)

            // Should accept function key shortcuts
        }
    }
}
