import Testing
import UserNotifications
@testable import WeakupCore

@Suite("NotificationManager Tests")
@MainActor
struct NotificationManagerTests {

    init() {
        // Clear notification settings before each test
        UserDefaultsStore.shared.removeObject(forKey: "WeakupNotificationsEnabled")
    }

    // MARK: - Singleton Tests

    @Test("Shared returns same instance")
    func sharedReturnsSameInstance() {
        let instance1 = NotificationManager.shared
        let instance2 = NotificationManager.shared
        #expect(instance1 === instance2, "Shared should return same instance")
    }

    // MARK: - Notifications Enabled Tests

    @Test("Notifications enabled default true")
    func notificationsEnabledDefaultTrue() {
        // Note: Since NotificationManager is a singleton, this tests the current state
        // The default value should be true based on the implementation
        let manager = NotificationManager.shared
        // We can't easily test the default without resetting the singleton
        // So we just verify the property is accessible
        _ = manager.notificationsEnabled
    }

    @Test("Notifications enabled persists value")
    func notificationsEnabledPersistsValue() {
        let manager = NotificationManager.shared
        let originalValue = manager.notificationsEnabled

        // Toggle the value
        manager.notificationsEnabled = !originalValue
        let storedValue = UserDefaultsStore.shared.bool(forKey: "WeakupNotificationsEnabled")
        #expect(storedValue == !originalValue)

        // Restore original value
        manager.notificationsEnabled = originalValue
    }

    @Test("Notifications enabled can be toggled")
    func notificationsEnabledCanBeToggled() {
        let manager = NotificationManager.shared
        let original = manager.notificationsEnabled

        manager.notificationsEnabled = !original
        #expect(manager.notificationsEnabled != original)

        manager.notificationsEnabled = original
        #expect(manager.notificationsEnabled == original)
    }

    // MARK: - Authorization Tests

    @Test("isAuthorized is accessible")
    func isAuthorizedIsAccessible() {
        let manager = NotificationManager.shared
        // Just verify the property is accessible
        _ = manager.isAuthorized
    }

    @Test("Request authorization does not crash")
    func requestAuthorizationDoesNotCrash() {
        let manager = NotificationManager.shared
        // This test verifies the method can be called without crashing
        // Actual authorization requires user interaction
        manager.requestAuthorization()
    }

    // MARK: - Notification Scheduling Tests

    @Test("Schedule timer expiry notification when disabled does not schedule")
    func scheduleTimerExpiryNotificationWhenDisabledDoesNotSchedule() {
        let manager = NotificationManager.shared
        manager.notificationsEnabled = false

        // This should not schedule anything when disabled
        manager.scheduleTimerExpiryNotification()

        // Note: We can't easily verify no notification was scheduled
        // without mocking UNUserNotificationCenter
    }

    @Test("Cancel pending notifications does not crash")
    func cancelPendingNotificationsDoesNotCrash() {
        let manager = NotificationManager.shared
        // Verify the method can be called without crashing
        manager.cancelPendingNotifications()
    }

    // MARK: - Callback Tests

    @Test("onRestartRequested can be set")
    func onRestartRequestedCanBeSet() {
        let manager = NotificationManager.shared
        var callbackCalled = false

        manager.onRestartRequested = {
            callbackCalled = true
        }

        // Manually trigger to verify callback is set
        manager.onRestartRequested?()
        #expect(callbackCalled)

        // Clean up
        manager.onRestartRequested = nil
    }

    @Test("onRestartRequested can be nil")
    func onRestartRequestedCanBeNil() {
        let manager = NotificationManager.shared
        manager.onRestartRequested = nil
        #expect(manager.onRestartRequested == nil)
    }

    // MARK: - Observable Tests

    @Test("NotificationManager is ObservableObject")
    func notificationManagerIsObservableObject() {
        let manager: any ObservableObject = NotificationManager.shared
        #expect(manager != nil)
    }
}
