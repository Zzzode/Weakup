import Foundation
import UserNotifications

// Notification Manager

@MainActor
public final class NotificationManager: NSObject, ObservableObject {
    public static let shared = NotificationManager()

    @Published public var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }

    @Published public var isAuthorized = false

    private enum Keys {
        static let notificationsEnabled = "WeakupNotificationsEnabled"
    }

    private enum NotificationIdentifier {
        static let timerExpired = "com.weakup.timer.expired"
    }

    private enum ActionIdentifier {
        static let restart = "RESTART_TIMER"
        static let dismiss = "DISMISS"
    }

    private enum CategoryIdentifier {
        static let timerExpired = "TIMER_EXPIRED"
    }

    // Callback for restart action
    public var onRestartRequested: (() -> Void)?

    private override init() {
        self.notificationsEnabled = UserDefaults.standard.object(forKey: Keys.notificationsEnabled) as? Bool ?? true
        super.init()
        setupNotificationCategories()
        checkAuthorizationStatus()
    }

    // Public Methods

    public func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            Task { @MainActor [weak self] in
                self?.isAuthorized = granted
                if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                }
            }
        }
    }

    public func scheduleTimerExpiryNotification() {
        guard notificationsEnabled && isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = L10n.shared.string(forKey: "notification_timer_expired_title")
        content.body = L10n.shared.string(forKey: "notification_timer_expired_body")
        content.sound = .default
        content.categoryIdentifier = CategoryIdentifier.timerExpired

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.timerExpired,
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    public func cancelPendingNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.timerExpired]
        )
    }

    // Private Methods

    private func setupNotificationCategories() {
        let restartAction = UNNotificationAction(
            identifier: ActionIdentifier.restart,
            title: L10n.shared.string(forKey: "notification_action_restart"),
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: ActionIdentifier.dismiss,
            title: L10n.shared.string(forKey: "notification_action_dismiss"),
            options: []
        )

        let timerCategory = UNNotificationCategory(
            identifier: CategoryIdentifier.timerExpired,
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
            case ActionIdentifier.restart:
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
