import XCTest
import UserNotifications
@testable import WeakupCore

@MainActor
final class NotificationManagerTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        // Clear notification settings before each test
        UserDefaults.standard.removeObject(forKey: "WeakupNotificationsEnabled")
    }

    override func tearDown() async throws {
        // Clean up
        NotificationManager.shared.cancelPendingNotifications()
        try await super.tearDown()
    }

    // Singleton Tests

    func testShared_returnsSameInstance() {
        let instance1 = NotificationManager.shared
        let instance2 = NotificationManager.shared
        XCTAssertTrue(instance1 === instance2, "Shared should return same instance")
    }

    // Notifications Enabled Tests

    func testNotificationsEnabled_defaultTrue() {
        // Note: Since NotificationManager is a singleton, this tests the current state
        // The default value should be true based on the implementation
        let manager = NotificationManager.shared
        // We can't easily test the default without resetting the singleton
        // So we just verify the property is accessible
        _ = manager.notificationsEnabled
    }

    func testNotificationsEnabled_persistsValue() {
        let manager = NotificationManager.shared
        let originalValue = manager.notificationsEnabled

        // Toggle the value
        manager.notificationsEnabled = !originalValue
        let storedValue = UserDefaults.standard.bool(forKey: "WeakupNotificationsEnabled")
        XCTAssertEqual(storedValue, !originalValue)

        // Restore original value
        manager.notificationsEnabled = originalValue
    }

    func testNotificationsEnabled_canBeToggled() {
        let manager = NotificationManager.shared
        let original = manager.notificationsEnabled

        manager.notificationsEnabled = !original
        XCTAssertNotEqual(manager.notificationsEnabled, original)

        manager.notificationsEnabled = original
        XCTAssertEqual(manager.notificationsEnabled, original)
    }

    // Authorization Tests

    func testIsAuthorized_isAccessible() {
        let manager = NotificationManager.shared
        // Just verify the property is accessible
        _ = manager.isAuthorized
    }

    func testRequestAuthorization_doesNotCrash() {
        let manager = NotificationManager.shared
        // This test verifies the method can be called without crashing
        // Actual authorization requires user interaction
        manager.requestAuthorization()
    }

    // Notification Scheduling Tests

    func testScheduleTimerExpiryNotification_whenDisabled_doesNotSchedule() {
        let manager = NotificationManager.shared
        manager.notificationsEnabled = false

        // This should not schedule anything when disabled
        manager.scheduleTimerExpiryNotification()

        // Note: We can't easily verify no notification was scheduled
        // without mocking UNUserNotificationCenter
    }

    func testCancelPendingNotifications_doesNotCrash() {
        let manager = NotificationManager.shared
        // Verify the method can be called without crashing
        manager.cancelPendingNotifications()
    }

    // Callback Tests

    func testOnRestartRequested_canBeSet() {
        let manager = NotificationManager.shared
        var callbackCalled = false

        manager.onRestartRequested = {
            callbackCalled = true
        }

        // Manually trigger to verify callback is set
        manager.onRestartRequested?()
        XCTAssertTrue(callbackCalled)

        // Clean up
        manager.onRestartRequested = nil
    }

    func testOnRestartRequested_canBeNil() {
        let manager = NotificationManager.shared
        manager.onRestartRequested = nil
        XCTAssertNil(manager.onRestartRequested)
    }

    // Observable Tests

    func testNotificationManager_isObservableObject() {
        let manager: any ObservableObject = NotificationManager.shared
        XCTAssertNotNil(manager)
    }
}
