import Foundation
import UserNotifications

// Notification Manager

/// Manages system notifications for the Weakup application.
///
/// `NotificationManager` handles requesting notification permissions, scheduling
/// notifications when timers expire, and responding to notification actions.
///
/// ## Features
///
/// - Timer expiry notifications with restart/dismiss actions
/// - Permission management and authorization status tracking
/// - Foreground notification display
///
/// ## Usage
///
/// ```swift
/// // Request permissions (typically on first launch)
/// NotificationManager.shared.requestAuthorization()
///
/// // Schedule a notification
/// NotificationManager.shared.scheduleTimerExpiryNotification()
///
/// // Handle restart action
/// NotificationManager.shared.onRestartRequested = {
///     // Restart the timer
/// }
/// ```
///
/// ## Thread Safety
///
/// This class is marked with `@MainActor` and all public methods must be called from the main thread.
@MainActor
public final class NotificationManager: NSObject, ObservableObject, NotificationManaging {
    /// The shared singleton instance.
    public static let shared = NotificationManager()

    /// Controls whether notifications are enabled.
    ///
    /// When disabled, no notifications will be scheduled even if authorized.
    /// The value is persisted to UserDefaults.
    @Published public var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: UserDefaultsKeys.notificationsEnabled)
            Logger.preferenceChanged(key: UserDefaultsKeys.notificationsEnabled, value: notificationsEnabled)
        }
    }

    /// Indicates whether the app has notification authorization.
    ///
    /// This is updated when `requestAuthorization()` is called or when
    /// the manager checks the current authorization status.
    @Published public var isAuthorized = false

    /// Callback invoked when the user taps the "Restart" action on a notification.
    ///
    /// Set this callback to handle timer restart requests from notifications.
    public var onRestartRequested: (() -> Void)?

    /// Indicates whether we're running in a test environment.
    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
            NSClassFromString("XCTestCase") != nil
    }

    override private init() {
        self.notificationsEnabled = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.notificationsEnabled) as? Bool ?? true
        super.init()

        // Skip notification setup in test environment to avoid crashes
        guard !Self.isRunningTests else { return }

        setupNotificationCategories()
        checkAuthorizationStatus()
    }

    // Public Methods

    /// Requests notification authorization from the user.
    ///
    /// Displays a system prompt asking for permission to show notifications.
    /// Updates `isAuthorized` based on the user's response.
    public func requestAuthorization() {
        guard !Self.isRunningTests else { return }

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            Task { @MainActor [weak self] in
                self?.isAuthorized = granted
                Logger.notificationAuthorizationStatus(granted: granted)
                if let error {
                    Logger.error("Notification authorization error", error: error, category: .notifications)
                }
            }
        }
    }

    /// Schedules a notification for timer expiry.
    ///
    /// The notification includes "Restart" and "Dismiss" actions. It is delivered
    /// immediately (no trigger delay).
    ///
    /// - Note: Does nothing if notifications are disabled or not authorized.
    public func scheduleTimerExpiryNotification() {
        guard !Self.isRunningTests else { return }
        guard notificationsEnabled, isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = L10n.shared.string(forKey: "notification_timer_expired_title")
        content.body = L10n.shared.string(forKey: "notification_timer_expired_body")
        content.sound = .default
        content.categoryIdentifier = AppConstants.Notifications.timerExpiredCategory

        let request = UNNotificationRequest(
            identifier: AppConstants.Notifications.timerExpiredIdentifier,
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                Logger.error("Failed to schedule notification", error: error, category: .notifications)
            } else {
                Logger.notificationScheduled(identifier: AppConstants.Notifications.timerExpiredIdentifier)
            }
        }
    }

    /// Cancels any pending timer expiry notifications.
    ///
    /// Call this when the user manually stops the timer before it expires.
    public func cancelPendingNotifications() {
        guard !Self.isRunningTests else { return }

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [AppConstants.Notifications.timerExpiredIdentifier]
        )
    }

    // Private Methods

    private func setupNotificationCategories() {
        let restartAction = UNNotificationAction(
            identifier: AppConstants.Notifications.restartAction,
            title: L10n.shared.string(forKey: "notification_action_restart"),
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: AppConstants.Notifications.dismissAction,
            title: L10n.shared.string(forKey: "notification_action_dismiss"),
            options: []
        )

        let timerCategory = UNNotificationCategory(
            identifier: AppConstants.Notifications.timerExpiredCategory,
            actions: [restartAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([timerCategory])
        UNUserNotificationCenter.current().delegate = self
    }

    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            let authorized = settings.authorizationStatus == .authorized
            Task { @MainActor [weak self] in
                self?.isAuthorized = authorized
            }
        }
    }
}

// UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionId = response.actionIdentifier
        Task { @MainActor [weak self] in
            switch actionId {
            case AppConstants.Notifications.restartAction:
                self?.onRestartRequested?()
            case UNNotificationDefaultActionIdentifier:
                // User tapped the notification itself
                break
            default:
                break
            }
        }
        completionHandler()
    }

    nonisolated public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
}
