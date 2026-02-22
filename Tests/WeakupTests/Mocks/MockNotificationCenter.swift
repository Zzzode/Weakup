import Foundation
import UserNotifications

/// Mock UNUserNotificationCenter for testing notification functionality
/// Provides isolated notification handling that doesn't affect the system
class MockNotificationCenter {

    // MARK: - State

    /// Pending notification requests
    private(set) var pendingRequests: [UNNotificationRequest] = []

    /// Delivered notifications
    private(set) var deliveredNotifications: [UNNotification] = []

    /// Whether authorization is granted
    var authorizationGranted = true

    /// Current authorization status
    var authorizationStatus: UNAuthorizationStatus = .authorized

    /// Authorization options that were requested
    private(set) var requestedAuthorizationOptions: UNAuthorizationOptions?

    // MARK: - Tracking

    /// Number of times authorization was requested
    private(set) var authorizationRequestCount = 0

    /// Number of notifications scheduled
    private(set) var scheduleCount = 0

    /// Number of notifications removed
    private(set) var removeCount = 0

    /// History of operations for verification
    private(set) var operationHistory: [Operation] = []

    enum Operation: Equatable {
        case requestAuthorization(options: UNAuthorizationOptions)
        case add(identifier: String)
        case removePending(identifiers: [String])
        case removeDelivered(identifiers: [String])
        case removeAllPending
        case removeAllDelivered
        case getNotificationSettings
        case getPendingRequests
        case getDeliveredNotifications
    }

    // MARK: - Mock Implementation

    func add(_ request: UNNotificationRequest, completion: ((Error?) -> Void)? = nil) {
        scheduleCount += 1
        pendingRequests.append(request)
        operationHistory.append(.add(identifier: request.identifier))
        completion?(nil)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removeCount += identifiers.count
        pendingRequests.removeAll { identifiers.contains($0.identifier) }
        operationHistory.append(.removePending(identifiers: identifiers))
    }

    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        removeCount += identifiers.count
        operationHistory.append(.removeDelivered(identifiers: identifiers))
    }

    func removeAllPendingNotificationRequests() {
        removeCount += pendingRequests.count
        pendingRequests.removeAll()
        operationHistory.append(.removeAllPending)
    }

    func removeAllDeliveredNotifications() {
        deliveredNotifications.removeAll()
        operationHistory.append(.removeAllDelivered)
    }

    func requestAuthorization(
        options: UNAuthorizationOptions,
        completionHandler: @escaping (Bool, Error?) -> Void
    ) {
        authorizationRequestCount += 1
        requestedAuthorizationOptions = options
        operationHistory.append(.requestAuthorization(options: options))
        completionHandler(authorizationGranted, nil)
    }

    func getNotificationSettings(completionHandler: @escaping (MockNotificationSettings) -> Void) {
        operationHistory.append(.getNotificationSettings)
        let settings = MockNotificationSettings(authorizationStatus: authorizationStatus)
        completionHandler(settings)
    }

    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        operationHistory.append(.getPendingRequests)
        completionHandler(pendingRequests)
    }

    func getDeliveredNotifications(completionHandler: @escaping ([UNNotification]) -> Void) {
        operationHistory.append(.getDeliveredNotifications)
        completionHandler(deliveredNotifications)
    }

    // MARK: - Test Helpers

    /// Reset all state and counters
    func reset() {
        pendingRequests.removeAll()
        deliveredNotifications.removeAll()
        authorizationGranted = true
        authorizationStatus = .authorized
        requestedAuthorizationOptions = nil
        authorizationRequestCount = 0
        scheduleCount = 0
        removeCount = 0
        operationHistory.removeAll()
    }

    /// Check if a notification with the given identifier is pending
    func hasPendingNotification(withIdentifier identifier: String) -> Bool {
        return pendingRequests.contains { $0.identifier == identifier }
    }

    /// Get a pending notification by identifier
    func getPendingNotification(withIdentifier identifier: String) -> UNNotificationRequest? {
        return pendingRequests.first { $0.identifier == identifier }
    }

    /// Simulate delivering a pending notification
    func simulateDelivery(identifier: String) {
        guard let request = pendingRequests.first(where: { $0.identifier == identifier }) else {
            return
        }
        pendingRequests.removeAll { $0.identifier == identifier }
        // Note: We can't create actual UNNotification objects in tests
        // This is a simplified simulation
    }

    /// Get all pending notification identifiers
    var pendingIdentifiers: [String] {
        return pendingRequests.map { $0.identifier }
    }
}

// MARK: - Mock Notification Settings

/// Mock notification settings for testing
struct MockNotificationSettings {
    let authorizationStatus: UNAuthorizationStatus

    init(authorizationStatus: UNAuthorizationStatus = .authorized) {
        self.authorizationStatus = authorizationStatus
    }
}

// MARK: - Mock Notification Content Builder

/// Helper for creating mock notification content in tests
enum MockNotificationContentBuilder {

    static func timerExpiredContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "TIMER_EXPIRED"
        return content
    }

    static func createRequest(
        identifier: String,
        content: UNNotificationContent,
        trigger: UNNotificationTrigger? = nil
    ) -> UNNotificationRequest {
        return UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
    }

    static func timeIntervalTrigger(seconds: TimeInterval, repeats: Bool = false) -> UNTimeIntervalNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: repeats)
    }
}
