import Foundation
@testable import WeakupCore

// MARK: - Mock Notification Manager

/// A mock implementation of `NotificationManaging` for testing.
///
/// This mock records all method calls and allows tests to verify notification
/// behavior without requiring actual system notification permissions.
///
/// ## Usage
///
/// ```swift
/// let mock = MockNotificationManager()
/// let viewModel = await CaffeineViewModel(notificationManager: mock)
///
/// // Trigger timer expiry...
///
/// XCTAssertTrue(mock.scheduleTimerExpiryNotificationCalled)
/// XCTAssertEqual(mock.scheduleTimerExpiryNotificationCallCount, 1)
/// ```
@MainActor
public final class MockNotificationManager: NotificationManaging {

    // MARK: - Properties

    public var notificationsEnabled: Bool = true
    public var isAuthorized: Bool = true
    public var onRestartRequested: (() -> Void)?

    // MARK: - Call Tracking

    /// Whether `requestAuthorization()` was called.
    public private(set) var requestAuthorizationCalled = false

    /// Number of times `requestAuthorization()` was called.
    public private(set) var requestAuthorizationCallCount = 0

    /// Whether `scheduleTimerExpiryNotification()` was called.
    public private(set) var scheduleTimerExpiryNotificationCalled = false

    /// Number of times `scheduleTimerExpiryNotification()` was called.
    public private(set) var scheduleTimerExpiryNotificationCallCount = 0

    /// Whether `cancelPendingNotifications()` was called.
    public private(set) var cancelPendingNotificationsCalled = false

    /// Number of times `cancelPendingNotifications()` was called.
    public private(set) var cancelPendingNotificationsCallCount = 0

    // MARK: - Initialization

    public init(
        notificationsEnabled: Bool = true,
        isAuthorized: Bool = true
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.isAuthorized = isAuthorized
    }

    // MARK: - NotificationManaging

    public func requestAuthorization() {
        requestAuthorizationCalled = true
        requestAuthorizationCallCount += 1
    }

    public func scheduleTimerExpiryNotification() {
        scheduleTimerExpiryNotificationCalled = true
        scheduleTimerExpiryNotificationCallCount += 1
    }

    public func cancelPendingNotifications() {
        cancelPendingNotificationsCalled = true
        cancelPendingNotificationsCallCount += 1
    }

    // MARK: - Test Helpers

    /// Resets all call tracking state.
    public func reset() {
        requestAuthorizationCalled = false
        requestAuthorizationCallCount = 0
        scheduleTimerExpiryNotificationCalled = false
        scheduleTimerExpiryNotificationCallCount = 0
        cancelPendingNotificationsCalled = false
        cancelPendingNotificationsCallCount = 0
    }

    /// Simulates the user tapping "Restart" on a notification.
    public func simulateRestartAction() {
        onRestartRequested?()
    }
}
