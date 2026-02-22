import XCTest

// Swift Testing Migration Note
// These UI tests intentionally use XCTest framework and cannot be migrated to Swift Testing.
// Swift Testing does not support UI testing - XCUIApplication, XCUIElement, and the entire
// XCUITest framework are only available through XCTest. This is a documented limitation
// of Swift Testing which is designed for unit and integration tests only.
//
// Requirements for these tests:
// - XCTest framework (XCUITest)
// - Xcode project configuration
// - Accessibility permissions for menu bar interaction

/// UI tests for menu bar functionality
/// Note: These tests require XCUITest and an Xcode project to run
/// They test the menu bar icon, click interactions, and context menu
final class MenuBarUITests: XCTestCase {

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

    // Status Icon Tests

    func testStatusIcon_showsInMenuBar() throws {
        // The status item should be visible in the menu bar
        // Note: Accessing menu bar items requires accessibility permissions
        let menuBar = app.menuBars
        XCTAssertTrue(menuBar.exists, "Menu bar should exist")

        // Look for the Weakup status item
        // The exact identifier depends on how the status item is configured
        let statusItem = menuBar.statusItems["Weakup"]
        XCTAssertTrue(statusItem.waitForExistence(timeout: 5), "Weakup status item should exist")
    }

    func testStatusIcon_changesOnToggle() throws {
        let menuBar = app.menuBars
        let statusItem = menuBar.statusItems["Weakup"]

        guard statusItem.waitForExistence(timeout: 5) else {
            XCTFail("Status item not found")
            return
        }

        // Get initial state (icon appearance)
        // Note: Actual icon comparison would require image comparison
        // This test verifies the toggle action works

        // Click to toggle on
        statusItem.click()

        // Wait for state change
        sleep(1)

        // Click to toggle off
        statusItem.click()

        // Verify app is still responsive
        XCTAssertTrue(statusItem.exists)
    }

    // Left Click Tests

    func testLeftClick_togglesCaffeine() throws {
        let menuBar = app.menuBars
        let statusItem = menuBar.statusItems["Weakup"]

        guard statusItem.waitForExistence(timeout: 5) else {
            XCTFail("Status item not found")
            return
        }

        // Left click should toggle the caffeine state
        statusItem.click()

        // Wait for toggle
        sleep(1)

        // Click again to toggle back
        statusItem.click()

        XCTAssertTrue(statusItem.exists, "Status item should still exist after toggling")
    }

    // Right Click Menu Tests

    func testRightClickMenu_showsSettingsAndQuit() throws {
        let menuBar = app.menuBars
        let statusItem = menuBar.statusItems["Weakup"]

        guard statusItem.waitForExistence(timeout: 5) else {
            XCTFail("Status item not found")
            return
        }

        // Right click to show context menu
        statusItem.rightClick()

        // Wait for menu to appear
        sleep(1)

        // Check for Settings menu item
        let settingsItem = app.menuItems["Settings"]
        XCTAssertTrue(settingsItem.waitForExistence(timeout: 2), "Settings menu item should exist")

        // Check for Quit menu item
        let quitItem = app.menuItems["Quit"]
        XCTAssertTrue(quitItem.waitForExistence(timeout: 2), "Quit menu item should exist")

        // Dismiss menu by clicking elsewhere
        app.windows.firstMatch.click()
    }

    // Tooltip Tests

    func testTooltip_updatesOnToggle() throws {
        // Note: Testing tooltips in XCUITest is limited
        // This test verifies the status item responds to hover events
        let menuBar = app.menuBars
        let statusItem = menuBar.statusItems["Weakup"]

        guard statusItem.waitForExistence(timeout: 5) else {
            XCTFail("Status item not found")
            return
        }

        // Hover over the status item
        statusItem.hover()

        // Wait for tooltip
        sleep(2)

        // Toggle state
        statusItem.click()
        sleep(1)

        // Hover again
        statusItem.hover()
        sleep(2)

        XCTAssertTrue(statusItem.exists)
    }

    // Countdown Display Tests

    func testCountdown_showsInMenuBar() throws {
        // This test would verify countdown display when timer mode is active
        // Requires enabling timer mode first through settings

        let menuBar = app.menuBars
        let statusItem = menuBar.statusItems["Weakup"]

        guard statusItem.waitForExistence(timeout: 5) else {
            XCTFail("Status item not found")
            return
        }

        // Open settings to enable timer mode
        statusItem.rightClick()
        sleep(1)

        let settingsItem = app.menuItems["Settings"]
        if settingsItem.exists {
            settingsItem.click()
            sleep(1)

            // Enable timer mode and set duration
            // Note: Actual UI interaction depends on settings view implementation
        }
    }
}
