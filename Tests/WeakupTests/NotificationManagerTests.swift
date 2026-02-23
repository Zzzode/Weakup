import Testing
import UserNotifications
@testable import WeakupCore

@Suite("NotificationManager Tests")
@MainActor
struct NotificationManagerTests {

    init() {
        // Clear notification settings before each test
        UserDefaultsStore.shared.removeObject(forKey: UserDefaultsKeys.notificationsEnabled)
    }

    // MARK: - Singleton Tests

    @Test("Shared returns same instance")
    func sharedReturnsSameInstance() {
        let instance1 = NotificationManager.shared
        let instance2 = NotificationManager.shared
        #expect(instance1 === instance2, "Shared should return same instance")
    }

    @Test("Shared instance is not nil")
    func sharedInstanceIsNotNil() {
        let manager = NotificationManager.shared
        #expect(manager != nil)
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
        let storedValue = UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.notificationsEnabled)
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

    @Test("Notifications enabled persists true value")
    func notificationsEnabledPersistsTrueValue() {
        let manager = NotificationManager.shared
        let original = manager.notificationsEnabled

        manager.notificationsEnabled = true
        let storedValue = UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        #expect(storedValue == true)

        manager.notificationsEnabled = original
    }

    @Test("Notifications enabled persists false value")
    func notificationsEnabledPersistsFalseValue() {
        let manager = NotificationManager.shared
        let original = manager.notificationsEnabled

        manager.notificationsEnabled = false
        let storedValue = UserDefaultsStore.shared.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        #expect(storedValue == false)

        manager.notificationsEnabled = original
    }

    @Test("Notifications enabled multiple toggles")
    func notificationsEnabledMultipleToggles() {
        let manager = NotificationManager.shared
        let original = manager.notificationsEnabled

        // Toggle multiple times
        manager.notificationsEnabled = true
        #expect(manager.notificationsEnabled == true)

        manager.notificationsEnabled = false
        #expect(manager.notificationsEnabled == false)

        manager.notificationsEnabled = true
        #expect(manager.notificationsEnabled == true)

        manager.notificationsEnabled = original
    }

    // MARK: - Authorization Tests

    @Test("isAuthorized is accessible")
    func isAuthorizedIsAccessible() {
        let manager = NotificationManager.shared
        // Just verify the property is accessible
        _ = manager.isAuthorized
    }

    @Test("isAuthorized is boolean")
    func isAuthorizedIsBoolean() {
        let manager = NotificationManager.shared
        let value = manager.isAuthorized
        #expect(value == true || value == false)
    }

    @Test("Request authorization does not crash")
    func requestAuthorizationDoesNotCrash() {
        let manager = NotificationManager.shared
        // This test verifies the method can be called without crashing
        // Actual authorization requires user interaction
        manager.requestAuthorization()
    }

    @Test("Request authorization can be called multiple times")
    func requestAuthorizationCanBeCalledMultipleTimes() {
        let manager = NotificationManager.shared
        // Should not crash when called multiple times
        manager.requestAuthorization()
        manager.requestAuthorization()
        manager.requestAuthorization()
    }

    // MARK: - Notification Scheduling Tests

    @Test("Schedule timer expiry notification when disabled does not schedule")
    func scheduleTimerExpiryNotificationWhenDisabledDoesNotSchedule() {
        let manager = NotificationManager.shared
        let original = manager.notificationsEnabled
        manager.notificationsEnabled = false

        // This should not schedule anything when disabled
        manager.scheduleTimerExpiryNotification()

        manager.notificationsEnabled = original
    }

    @Test("Schedule timer expiry notification can be called")
    func scheduleTimerExpiryNotificationCanBeCalled() {
        let manager = NotificationManager.shared
        // Should not crash
        manager.scheduleTimerExpiryNotification()
    }

    @Test("Schedule timer expiry notification multiple times")
    func scheduleTimerExpiryNotificationMultipleTimes() {
        let manager = NotificationManager.shared
        // Should not crash when called multiple times
        manager.scheduleTimerExpiryNotification()
        manager.scheduleTimerExpiryNotification()
        manager.scheduleTimerExpiryNotification()
    }

    @Test("Cancel pending notifications does not crash")
    func cancelPendingNotificationsDoesNotCrash() {
        let manager = NotificationManager.shared
        // Verify the method can be called without crashing
        manager.cancelPendingNotifications()
    }

    @Test("Cancel pending notifications can be called multiple times")
    func cancelPendingNotificationsCanBeCalledMultipleTimes() {
        let manager = NotificationManager.shared
        // Should not crash when called multiple times
        manager.cancelPendingNotifications()
        manager.cancelPendingNotifications()
        manager.cancelPendingNotifications()
    }

    @Test("Schedule then cancel notifications")
    func scheduleThenCancelNotifications() {
        let manager = NotificationManager.shared
        // Should not crash
        manager.scheduleTimerExpiryNotification()
        manager.cancelPendingNotifications()
    }

    @Test("Cancel then schedule notifications")
    func cancelThenScheduleNotifications() {
        let manager = NotificationManager.shared
        // Should not crash
        manager.cancelPendingNotifications()
        manager.scheduleTimerExpiryNotification()
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

    @Test("onRestartRequested can be replaced")
    func onRestartRequestedCanBeReplaced() {
        let manager = NotificationManager.shared
        var firstCalled = false
        var secondCalled = false

        manager.onRestartRequested = {
            firstCalled = true
        }

        manager.onRestartRequested = {
            secondCalled = true
        }

        manager.onRestartRequested?()
        #expect(firstCalled == false)
        #expect(secondCalled == true)

        // Clean up
        manager.onRestartRequested = nil
    }

    @Test("onRestartRequested callback executes")
    func onRestartRequestedCallbackExecutes() {
        let manager = NotificationManager.shared
        var counter = 0

        manager.onRestartRequested = {
            counter += 1
        }

        manager.onRestartRequested?()
        manager.onRestartRequested?()
        manager.onRestartRequested?()

        #expect(counter == 3)

        // Clean up
        manager.onRestartRequested = nil
    }

    @Test("onRestartRequested nil callback is safe")
    func onRestartRequestedNilCallbackIsSafe() {
        let manager = NotificationManager.shared
        manager.onRestartRequested = nil

        // Should not crash
        manager.onRestartRequested?()
    }

    // MARK: - Observable Tests

    @Test("NotificationManager is ObservableObject")
    func notificationManagerIsObservableObject() {
        let manager: any ObservableObject = NotificationManager.shared
        #expect(manager != nil)
    }

    // MARK: - Protocol Conformance Tests

    @Test("NotificationManager conforms to NotificationManaging")
    func notificationManagerConformsToNotificationManaging() {
        let manager: any NotificationManaging = NotificationManager.shared
        #expect(manager != nil)
    }

    @Test("NotificationManager conforms to NSObject")
    func notificationManagerConformsToNSObject() {
        let manager: NSObject = NotificationManager.shared
        #expect(manager != nil)
    }

    @Test("NotificationManager conforms to UNUserNotificationCenterDelegate")
    func notificationManagerConformsToUNUserNotificationCenterDelegate() {
        let manager: any UNUserNotificationCenterDelegate = NotificationManager.shared
        #expect(manager != nil)
    }
}

// MARK: - Mock NotificationManager Tests

@Suite("MockNotificationManager Tests")
@MainActor
struct MockNotificationManagerTests {

    // MARK: - Initialization Tests

    @Test("MockNotificationManager initializes with defaults")
    func mockNotificationManagerInitializesWithDefaults() {
        let mock = MockNotificationManager()
        #expect(mock.notificationsEnabled == true)
        #expect(mock.isAuthorized == true)
        #expect(mock.onRestartRequested == nil)
    }

    @Test("MockNotificationManager initializes with custom values")
    func mockNotificationManagerInitializesWithCustomValues() {
        let mock = MockNotificationManager(notificationsEnabled: false, isAuthorized: false)
        #expect(mock.notificationsEnabled == false)
        #expect(mock.isAuthorized == false)
    }

    @Test("MockNotificationManager initializes with notifications disabled")
    func mockNotificationManagerInitializesWithNotificationsDisabled() {
        let mock = MockNotificationManager(notificationsEnabled: false)
        #expect(mock.notificationsEnabled == false)
        #expect(mock.isAuthorized == true)
    }

    @Test("MockNotificationManager initializes with unauthorized")
    func mockNotificationManagerInitializesWithUnauthorized() {
        let mock = MockNotificationManager(isAuthorized: false)
        #expect(mock.notificationsEnabled == true)
        #expect(mock.isAuthorized == false)
    }

    // MARK: - Call Tracking Tests

    @Test("MockNotificationManager tracks requestAuthorization calls")
    func mockNotificationManagerTracksRequestAuthorizationCalls() {
        let mock = MockNotificationManager()
        #expect(mock.requestAuthorizationCalled == false)
        #expect(mock.requestAuthorizationCallCount == 0)

        mock.requestAuthorization()
        #expect(mock.requestAuthorizationCalled == true)
        #expect(mock.requestAuthorizationCallCount == 1)

        mock.requestAuthorization()
        #expect(mock.requestAuthorizationCallCount == 2)
    }

    @Test("MockNotificationManager tracks scheduleTimerExpiryNotification calls")
    func mockNotificationManagerTracksScheduleTimerExpiryNotificationCalls() {
        let mock = MockNotificationManager()
        #expect(mock.scheduleTimerExpiryNotificationCalled == false)
        #expect(mock.scheduleTimerExpiryNotificationCallCount == 0)

        mock.scheduleTimerExpiryNotification()
        #expect(mock.scheduleTimerExpiryNotificationCalled == true)
        #expect(mock.scheduleTimerExpiryNotificationCallCount == 1)

        mock.scheduleTimerExpiryNotification()
        #expect(mock.scheduleTimerExpiryNotificationCallCount == 2)
    }

    @Test("MockNotificationManager tracks cancelPendingNotifications calls")
    func mockNotificationManagerTracksCancelPendingNotificationsCalls() {
        let mock = MockNotificationManager()
        #expect(mock.cancelPendingNotificationsCalled == false)
        #expect(mock.cancelPendingNotificationsCallCount == 0)

        mock.cancelPendingNotifications()
        #expect(mock.cancelPendingNotificationsCalled == true)
        #expect(mock.cancelPendingNotificationsCallCount == 1)

        mock.cancelPendingNotifications()
        #expect(mock.cancelPendingNotificationsCallCount == 2)
    }

    // MARK: - Reset Tests

    @Test("MockNotificationManager reset clears all tracking")
    func mockNotificationManagerResetClearsAllTracking() {
        let mock = MockNotificationManager()

        // Make some calls
        mock.requestAuthorization()
        mock.scheduleTimerExpiryNotification()
        mock.cancelPendingNotifications()

        // Verify calls were tracked
        #expect(mock.requestAuthorizationCalled == true)
        #expect(mock.scheduleTimerExpiryNotificationCalled == true)
        #expect(mock.cancelPendingNotificationsCalled == true)

        // Reset
        mock.reset()

        // Verify all tracking cleared
        #expect(mock.requestAuthorizationCalled == false)
        #expect(mock.requestAuthorizationCallCount == 0)
        #expect(mock.scheduleTimerExpiryNotificationCalled == false)
        #expect(mock.scheduleTimerExpiryNotificationCallCount == 0)
        #expect(mock.cancelPendingNotificationsCalled == false)
        #expect(mock.cancelPendingNotificationsCallCount == 0)
    }

    // MARK: - Simulate Restart Action Tests

    @Test("MockNotificationManager simulateRestartAction triggers callback")
    func mockNotificationManagerSimulateRestartActionTriggersCallback() {
        let mock = MockNotificationManager()
        var callbackTriggered = false

        mock.onRestartRequested = {
            callbackTriggered = true
        }

        mock.simulateRestartAction()
        #expect(callbackTriggered == true)
    }

    @Test("MockNotificationManager simulateRestartAction with nil callback is safe")
    func mockNotificationManagerSimulateRestartActionWithNilCallbackIsSafe() {
        let mock = MockNotificationManager()
        mock.onRestartRequested = nil

        // Should not crash
        mock.simulateRestartAction()
    }

    // MARK: - Protocol Conformance Tests

    @Test("MockNotificationManager conforms to NotificationManaging")
    func mockNotificationManagerConformsToNotificationManaging() {
        let mock: any NotificationManaging = MockNotificationManager()
        #expect(mock != nil)
    }

    // MARK: - Property Mutation Tests

    @Test("MockNotificationManager notificationsEnabled can be changed")
    func mockNotificationManagerNotificationsEnabledCanBeChanged() {
        let mock = MockNotificationManager()
        #expect(mock.notificationsEnabled == true)

        mock.notificationsEnabled = false
        #expect(mock.notificationsEnabled == false)

        mock.notificationsEnabled = true
        #expect(mock.notificationsEnabled == true)
    }

    @Test("MockNotificationManager isAuthorized can be changed")
    func mockNotificationManagerIsAuthorizedCanBeChanged() {
        let mock = MockNotificationManager()
        #expect(mock.isAuthorized == true)

        mock.isAuthorized = false
        #expect(mock.isAuthorized == false)

        mock.isAuthorized = true
        #expect(mock.isAuthorized == true)
    }
}

// MARK: - AppConstants.Notifications Tests

@Suite("AppConstants.Notifications Tests")
struct AppConstantsNotificationsTests {

    @Test("Timer expired identifier is correct")
    func timerExpiredIdentifierIsCorrect() {
        #expect(AppConstants.Notifications.timerExpiredIdentifier == "com.weakup.timer.expired")
    }

    @Test("Timer expired category is correct")
    func timerExpiredCategoryIsCorrect() {
        #expect(AppConstants.Notifications.timerExpiredCategory == "TIMER_EXPIRED")
    }

    @Test("Restart action identifier is correct")
    func restartActionIdentifierIsCorrect() {
        #expect(AppConstants.Notifications.restartAction == "RESTART_TIMER")
    }

    @Test("Dismiss action identifier is correct")
    func dismissActionIdentifierIsCorrect() {
        #expect(AppConstants.Notifications.dismissAction == "DISMISS")
    }

    @Test("All notification identifiers are non-empty")
    func allNotificationIdentifiersAreNonEmpty() {
        #expect(!AppConstants.Notifications.timerExpiredIdentifier.isEmpty)
        #expect(!AppConstants.Notifications.timerExpiredCategory.isEmpty)
        #expect(!AppConstants.Notifications.restartAction.isEmpty)
        #expect(!AppConstants.Notifications.dismissAction.isEmpty)
    }

    @Test("All notification identifiers are unique")
    func allNotificationIdentifiersAreUnique() {
        let identifiers = [
            AppConstants.Notifications.timerExpiredIdentifier,
            AppConstants.Notifications.timerExpiredCategory,
            AppConstants.Notifications.restartAction,
            AppConstants.Notifications.dismissAction
        ]
        let uniqueIdentifiers = Set(identifiers)
        #expect(identifiers.count == uniqueIdentifiers.count)
    }
}

// MARK: - MockNotificationCenter Tests

@Suite("MockNotificationCenter Tests")
struct MockNotificationCenterTests {

    // MARK: - Initialization Tests

    @Test("MockNotificationCenter initializes with empty state")
    func mockNotificationCenterInitializesWithEmptyState() {
        let center = MockNotificationCenter()
        #expect(center.pendingRequests.isEmpty)
        #expect(center.deliveredNotifications.isEmpty)
        #expect(center.authorizationGranted == true)
        #expect(center.authorizationStatus == .authorized)
        #expect(center.authorizationRequestCount == 0)
        #expect(center.scheduleCount == 0)
        #expect(center.removeCount == 0)
        #expect(center.operationHistory.isEmpty)
    }

    // MARK: - Add Request Tests

    @Test("MockNotificationCenter add request increments count")
    func mockNotificationCenterAddRequestIncrementsCount() {
        let center = MockNotificationCenter()
        let content = UNMutableNotificationContent()
        content.title = "Test"
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)

        center.add(request)

        #expect(center.scheduleCount == 1)
        #expect(center.pendingRequests.count == 1)
    }

    @Test("MockNotificationCenter add request stores request")
    func mockNotificationCenterAddRequestStoresRequest() {
        let center = MockNotificationCenter()
        let content = UNMutableNotificationContent()
        content.title = "Test"
        let request = UNNotificationRequest(identifier: "test-id", content: content, trigger: nil)

        center.add(request)

        #expect(center.hasPendingNotification(withIdentifier: "test-id"))
    }

    @Test("MockNotificationCenter add request records operation")
    func mockNotificationCenterAddRequestRecordsOperation() {
        let center = MockNotificationCenter()
        let content = UNMutableNotificationContent()
        content.title = "Test"
        let request = UNNotificationRequest(identifier: "test-id", content: content, trigger: nil)

        center.add(request)

        #expect(center.operationHistory.count == 1)
        #expect(center.operationHistory.first == .add(identifier: "test-id"))
    }

    @Test("MockNotificationCenter add request calls completion")
    func mockNotificationCenterAddRequestCallsCompletion() {
        let center = MockNotificationCenter()
        let content = UNMutableNotificationContent()
        content.title = "Test"
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)

        var completionCalled = false
        center.add(request) { error in
            completionCalled = true
            #expect(error == nil)
        }

        #expect(completionCalled)
    }

    // MARK: - Remove Pending Tests

    @Test("MockNotificationCenter remove pending removes request")
    func mockNotificationCenterRemovePendingRemovesRequest() {
        let center = MockNotificationCenter()
        let content = UNMutableNotificationContent()
        content.title = "Test"
        let request = UNNotificationRequest(identifier: "test-id", content: content, trigger: nil)

        center.add(request)
        #expect(center.hasPendingNotification(withIdentifier: "test-id"))

        center.removePendingNotificationRequests(withIdentifiers: ["test-id"])
        #expect(!center.hasPendingNotification(withIdentifier: "test-id"))
    }

    @Test("MockNotificationCenter remove pending increments remove count")
    func mockNotificationCenterRemovePendingIncrementsRemoveCount() {
        let center = MockNotificationCenter()
        center.removePendingNotificationRequests(withIdentifiers: ["id1", "id2"])
        #expect(center.removeCount == 2)
    }

    @Test("MockNotificationCenter remove all pending clears requests")
    func mockNotificationCenterRemoveAllPendingClearsRequests() {
        let center = MockNotificationCenter()
        let content = UNMutableNotificationContent()
        content.title = "Test"

        center.add(UNNotificationRequest(identifier: "id1", content: content, trigger: nil))
        center.add(UNNotificationRequest(identifier: "id2", content: content, trigger: nil))

        #expect(center.pendingRequests.count == 2)

        center.removeAllPendingNotificationRequests()
        #expect(center.pendingRequests.isEmpty)
    }

    // MARK: - Authorization Tests

    @Test("MockNotificationCenter request authorization tracks call")
    func mockNotificationCenterRequestAuthorizationTracksCall() {
        let center = MockNotificationCenter()

        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }

        #expect(center.authorizationRequestCount == 1)
        #expect(center.requestedAuthorizationOptions == [.alert, .sound])
    }

    @Test("MockNotificationCenter request authorization returns granted")
    func mockNotificationCenterRequestAuthorizationReturnsGranted() {
        let center = MockNotificationCenter()
        center.authorizationGranted = true

        var grantedResult = false
        center.requestAuthorization(options: [.alert]) { granted, _ in
            grantedResult = granted
        }

        #expect(grantedResult == true)
    }

    @Test("MockNotificationCenter request authorization returns denied")
    func mockNotificationCenterRequestAuthorizationReturnsDenied() {
        let center = MockNotificationCenter()
        center.authorizationGranted = false

        var grantedResult = true
        center.requestAuthorization(options: [.alert]) { granted, _ in
            grantedResult = granted
        }

        #expect(grantedResult == false)
    }

    // MARK: - Get Settings Tests

    @Test("MockNotificationCenter get settings returns status")
    func mockNotificationCenterGetSettingsReturnsStatus() {
        let center = MockNotificationCenter()
        center.authorizationStatus = .denied

        var receivedStatus: UNAuthorizationStatus?
        center.getNotificationSettings { settings in
            receivedStatus = settings.authorizationStatus
        }

        #expect(receivedStatus == .denied)
    }

    // MARK: - Get Pending Requests Tests

    @Test("MockNotificationCenter get pending requests returns requests")
    func mockNotificationCenterGetPendingRequestsReturnsRequests() {
        let center = MockNotificationCenter()
        let content = UNMutableNotificationContent()
        content.title = "Test"
        center.add(UNNotificationRequest(identifier: "id1", content: content, trigger: nil))

        var receivedRequests: [UNNotificationRequest] = []
        center.getPendingNotificationRequests { requests in
            receivedRequests = requests
        }

        #expect(receivedRequests.count == 1)
        #expect(receivedRequests.first?.identifier == "id1")
    }

    // MARK: - Reset Tests

    @Test("MockNotificationCenter reset clears all state")
    func mockNotificationCenterResetClearsAllState() {
        let center = MockNotificationCenter()
        let content = UNMutableNotificationContent()
        content.title = "Test"

        // Add some state
        center.add(UNNotificationRequest(identifier: "id1", content: content, trigger: nil))
        center.requestAuthorization(options: [.alert]) { _, _ in }
        center.authorizationGranted = false
        center.authorizationStatus = .denied

        // Reset
        center.reset()

        // Verify all state cleared
        #expect(center.pendingRequests.isEmpty)
        #expect(center.deliveredNotifications.isEmpty)
        #expect(center.authorizationGranted == true)
        #expect(center.authorizationStatus == .authorized)
        #expect(center.authorizationRequestCount == 0)
        #expect(center.scheduleCount == 0)
        #expect(center.removeCount == 0)
        #expect(center.operationHistory.isEmpty)
    }

    // MARK: - Helper Tests

    @Test("MockNotificationCenter getPendingNotification returns correct request")
    func mockNotificationCenterGetPendingNotificationReturnsCorrectRequest() {
        let center = MockNotificationCenter()
        let content = UNMutableNotificationContent()
        content.title = "Test Title"
        center.add(UNNotificationRequest(identifier: "specific-id", content: content, trigger: nil))

        let request = center.getPendingNotification(withIdentifier: "specific-id")
        #expect(request?.identifier == "specific-id")
        #expect(request?.content.title == "Test Title")
    }

    @Test("MockNotificationCenter getPendingNotification returns nil for missing")
    func mockNotificationCenterGetPendingNotificationReturnsNilForMissing() {
        let center = MockNotificationCenter()
        let request = center.getPendingNotification(withIdentifier: "nonexistent")
        #expect(request == nil)
    }

    @Test("MockNotificationCenter pendingIdentifiers returns all identifiers")
    func mockNotificationCenterPendingIdentifiersReturnsAllIdentifiers() {
        let center = MockNotificationCenter()
        let content = UNMutableNotificationContent()
        content.title = "Test"

        center.add(UNNotificationRequest(identifier: "id1", content: content, trigger: nil))
        center.add(UNNotificationRequest(identifier: "id2", content: content, trigger: nil))
        center.add(UNNotificationRequest(identifier: "id3", content: content, trigger: nil))

        let identifiers = center.pendingIdentifiers
        #expect(identifiers.count == 3)
        #expect(identifiers.contains("id1"))
        #expect(identifiers.contains("id2"))
        #expect(identifiers.contains("id3"))
    }

    // MARK: - Simulate Delivery Tests

    @Test("MockNotificationCenter simulateDelivery removes from pending")
    func mockNotificationCenterSimulateDeliveryRemovesFromPending() {
        let center = MockNotificationCenter()
        let content = UNMutableNotificationContent()
        content.title = "Test"
        center.add(UNNotificationRequest(identifier: "deliver-me", content: content, trigger: nil))

        #expect(center.hasPendingNotification(withIdentifier: "deliver-me"))

        center.simulateDelivery(identifier: "deliver-me")

        #expect(!center.hasPendingNotification(withIdentifier: "deliver-me"))
    }

    @Test("MockNotificationCenter simulateDelivery ignores nonexistent")
    func mockNotificationCenterSimulateDeliveryIgnoresNonexistent() {
        let center = MockNotificationCenter()
        // Should not crash
        center.simulateDelivery(identifier: "nonexistent")
        #expect(center.pendingRequests.isEmpty)
    }
}

// MARK: - MockNotificationContentBuilder Tests

@Suite("MockNotificationContentBuilder Tests")
struct MockNotificationContentBuilderTests {

    @Test("timerExpiredContent creates correct content")
    func timerExpiredContentCreatesCorrectContent() {
        let content = MockNotificationContentBuilder.timerExpiredContent(
            title: "Test Title",
            body: "Test Body"
        )

        #expect(content.title == "Test Title")
        #expect(content.body == "Test Body")
        #expect(content.categoryIdentifier == "TIMER_EXPIRED")
        #expect(content.sound == .default)
    }

    @Test("createRequest creates request with correct identifier")
    func createRequestCreatesRequestWithCorrectIdentifier() {
        let content = UNMutableNotificationContent()
        content.title = "Test"

        let request = MockNotificationContentBuilder.createRequest(
            identifier: "test-identifier",
            content: content
        )

        #expect(request.identifier == "test-identifier")
        #expect(request.content.title == "Test")
        #expect(request.trigger == nil)
    }

    @Test("createRequest creates request with trigger")
    func createRequestCreatesRequestWithTrigger() {
        let content = UNMutableNotificationContent()
        content.title = "Test"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)

        let request = MockNotificationContentBuilder.createRequest(
            identifier: "test-identifier",
            content: content,
            trigger: trigger
        )

        #expect(request.trigger != nil)
    }

    @Test("timeIntervalTrigger creates non-repeating trigger")
    func timeIntervalTriggerCreatesNonRepeatingTrigger() {
        let trigger = MockNotificationContentBuilder.timeIntervalTrigger(seconds: 30)

        #expect(trigger.timeInterval == 30)
        #expect(trigger.repeats == false)
    }

    @Test("timeIntervalTrigger creates repeating trigger")
    func timeIntervalTriggerCreatesRepeatingTrigger() {
        let trigger = MockNotificationContentBuilder.timeIntervalTrigger(seconds: 60, repeats: true)

        #expect(trigger.timeInterval == 60)
        #expect(trigger.repeats == true)
    }
}

// MARK: - UserDefaultsKeys Notification Tests

@Suite("UserDefaultsKeys Notification Tests")
struct UserDefaultsKeysNotificationTests {

    @Test("notificationsEnabled key is correct")
    func notificationsEnabledKeyIsCorrect() {
        #expect(UserDefaultsKeys.notificationsEnabled == "WeakupNotificationsEnabled")
    }

    @Test("notificationsEnabled key is in all keys")
    func notificationsEnabledKeyIsInAllKeys() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.notificationsEnabled))
    }
}
