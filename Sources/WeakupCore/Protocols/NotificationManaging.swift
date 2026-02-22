import Foundation

// Notification Managing Protocol

/// Protocol defining the notification management interface.
///
/// This protocol abstracts notification functionality to enable dependency injection
/// and testability. The main implementation is `NotificationManager`, while tests
/// can use mock implementations.
///
/// ## Usage
///
/// ```swift
/// // In production code
/// let viewModel = CaffeineViewModel(notificationManager: NotificationManager.shared)
///
/// // In tests
/// let mockNotifications = MockNotificationManager()
/// let viewModel = CaffeineViewModel(notificationManager: mockNotifications)
/// ```
@MainActor
public protocol NotificationManaging: AnyObject {
    /// Whether notifications are enabled by the user.
    var notificationsEnabled: Bool { get set }

    /// Whether the app has notification authorization from the system.
    var isAuthorized: Bool { get }

    /// Callback invoked when user requests timer restart from notification.
    var onRestartRequested: (() -> Void)? { get set }

    /// Requests notification authorization from the user.
    func requestAuthorization()

    /// Schedules a notification for timer expiry.
    func scheduleTimerExpiryNotification()

    /// Cancels any pending timer expiry notifications.
    func cancelPendingNotifications()
}
