import Foundation
import Testing
@testable import WeakupCore

// MARK: - Logger Category Tests

@Suite("Logger Category Tests")
struct LoggerCategoryTests {

    // Category Enum Tests (LOG-001)

    @Test("All categories are defined")
    func allCategoriesAreDefined() {
        // Verify all expected categories exist
        let categories: [Logger.Category] = [
            .general,
            .power,
            .timer,
            .notifications,
            .hotkey,
            .history,
            .preferences
        ]
        #expect(categories.count == 7, "Should have exactly 7 log categories")
    }

    @Test("General category exists")
    func generalCategoryExists() {
        let category = Logger.Category.general
        #expect(category == .general)
    }

    @Test("Power category exists")
    func powerCategoryExists() {
        let category = Logger.Category.power
        #expect(category == .power)
    }

    @Test("Timer category exists")
    func timerCategoryExists() {
        let category = Logger.Category.timer
        #expect(category == .timer)
    }

    @Test("Notifications category exists")
    func notificationsCategoryExists() {
        let category = Logger.Category.notifications
        #expect(category == .notifications)
    }

    @Test("Hotkey category exists")
    func hotkeyCategoryExists() {
        let category = Logger.Category.hotkey
        #expect(category == .hotkey)
    }

    @Test("History category exists")
    func historyCategoryExists() {
        let category = Logger.Category.history
        #expect(category == .history)
    }

    @Test("Preferences category exists")
    func preferencesCategoryExists() {
        let category = Logger.Category.preferences
        #expect(category == .preferences)
    }

    // Category Logger Property Tests (LOG-002)

    @Test("Each category has a logger")
    func eachCategoryHasALogger() {
        let categories: [Logger.Category] = [
            .general, .power, .timer, .notifications, .hotkey, .history, .preferences
        ]
        for category in categories {
            // Accessing the logger property should not crash
            _ = category.logger
        }
    }

    // Category Equality Tests

    @Test("Categories are equatable")
    func categoriesAreEquatable() {
        #expect(Logger.Category.general == Logger.Category.general)
        #expect(Logger.Category.power == Logger.Category.power)
        #expect(Logger.Category.timer == Logger.Category.timer)
        #expect(Logger.Category.notifications == Logger.Category.notifications)
        #expect(Logger.Category.hotkey == Logger.Category.hotkey)
        #expect(Logger.Category.history == Logger.Category.history)
        #expect(Logger.Category.preferences == Logger.Category.preferences)
    }

    @Test("Different categories are not equal")
    func differentCategoriesAreNotEqual() {
        #expect(Logger.Category.general != Logger.Category.power)
        #expect(Logger.Category.timer != Logger.Category.notifications)
        #expect(Logger.Category.hotkey != Logger.Category.history)
        #expect(Logger.Category.preferences != Logger.Category.general)
    }
}

// MARK: - Logger Log Level Tests

@Suite("Logger Log Level Tests")
struct LoggerLogLevelTests {

    // Debug Level Tests (LOG-003)

    @Test("Debug logs without crashing")
    func debugLogsWithoutCrashing() {
        Logger.debug("Test debug message")
    }

    @Test("Debug logs with default category")
    func debugLogsWithDefaultCategory() {
        Logger.debug("Test debug message with default category")
    }

    @Test("Debug logs with all categories")
    func debugLogsWithAllCategories() {
        Logger.debug("Debug general", category: .general)
        Logger.debug("Debug power", category: .power)
        Logger.debug("Debug timer", category: .timer)
        Logger.debug("Debug notifications", category: .notifications)
        Logger.debug("Debug hotkey", category: .hotkey)
        Logger.debug("Debug history", category: .history)
        Logger.debug("Debug preferences", category: .preferences)
    }

    @Test("Debug logs empty message")
    func debugLogsEmptyMessage() {
        Logger.debug("")
    }

    @Test("Debug logs long message")
    func debugLogsLongMessage() {
        let longMessage = String(repeating: "a", count: 1000)
        Logger.debug(longMessage)
    }

    @Test("Debug logs special characters")
    func debugLogsSpecialCharacters() {
        Logger.debug("Special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?")
    }

    @Test("Debug logs unicode")
    func debugLogsUnicode() {
        Logger.debug("Unicode: \u{1F600} \u{1F389} \u{2764}")
    }

    // Info Level Tests (LOG-004)

    @Test("Info logs without crashing")
    func infoLogsWithoutCrashing() {
        Logger.info("Test info message")
    }

    @Test("Info logs with default category")
    func infoLogsWithDefaultCategory() {
        Logger.info("Test info message with default category")
    }

    @Test("Info logs with all categories")
    func infoLogsWithAllCategories() {
        Logger.info("Info general", category: .general)
        Logger.info("Info power", category: .power)
        Logger.info("Info timer", category: .timer)
        Logger.info("Info notifications", category: .notifications)
        Logger.info("Info hotkey", category: .hotkey)
        Logger.info("Info history", category: .history)
        Logger.info("Info preferences", category: .preferences)
    }

    @Test("Info logs empty message")
    func infoLogsEmptyMessage() {
        Logger.info("")
    }

    @Test("Info logs long message")
    func infoLogsLongMessage() {
        let longMessage = String(repeating: "b", count: 1000)
        Logger.info(longMessage)
    }

    // Warning Level Tests (LOG-005)

    @Test("Warning logs without crashing")
    func warningLogsWithoutCrashing() {
        Logger.warning("Test warning message")
    }

    @Test("Warning logs with default category")
    func warningLogsWithDefaultCategory() {
        Logger.warning("Test warning message with default category")
    }

    @Test("Warning logs with all categories")
    func warningLogsWithAllCategories() {
        Logger.warning("Warning general", category: .general)
        Logger.warning("Warning power", category: .power)
        Logger.warning("Warning timer", category: .timer)
        Logger.warning("Warning notifications", category: .notifications)
        Logger.warning("Warning hotkey", category: .hotkey)
        Logger.warning("Warning history", category: .history)
        Logger.warning("Warning preferences", category: .preferences)
    }

    @Test("Warning logs empty message")
    func warningLogsEmptyMessage() {
        Logger.warning("")
    }

    @Test("Warning logs long message")
    func warningLogsLongMessage() {
        let longMessage = String(repeating: "c", count: 1000)
        Logger.warning(longMessage)
    }

    // Error Level Tests (LOG-006)

    @Test("Error logs without crashing")
    func errorLogsWithoutCrashing() {
        Logger.error("Test error message")
    }

    @Test("Error logs with default category")
    func errorLogsWithDefaultCategory() {
        Logger.error("Test error message with default category")
    }

    @Test("Error logs with all categories")
    func errorLogsWithAllCategories() {
        Logger.error("Error general", category: .general)
        Logger.error("Error power", category: .power)
        Logger.error("Error timer", category: .timer)
        Logger.error("Error notifications", category: .notifications)
        Logger.error("Error hotkey", category: .hotkey)
        Logger.error("Error history", category: .history)
        Logger.error("Error preferences", category: .preferences)
    }

    @Test("Error logs empty message")
    func errorLogsEmptyMessage() {
        Logger.error("")
    }

    @Test("Error logs long message")
    func errorLogsLongMessage() {
        let longMessage = String(repeating: "d", count: 1000)
        Logger.error(longMessage)
    }

    // Error with Error Object Tests (LOG-007)

    @Test("Error with Error object logs without crashing")
    func errorWithErrorObjectLogsWithoutCrashing() {
        let testError = NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "Test error description"])
        Logger.error("Test error with object", error: testError)
    }

    @Test("Error with Error object and default category")
    func errorWithErrorObjectAndDefaultCategory() {
        let testError = NSError(domain: "TestDomain", code: 1, userInfo: nil)
        Logger.error("Error with object default category", error: testError)
    }

    @Test("Error with Error object and all categories")
    func errorWithErrorObjectAndAllCategories() {
        let testError = NSError(domain: "TestDomain", code: 1, userInfo: nil)
        Logger.error("Error object general", error: testError, category: .general)
        Logger.error("Error object power", error: testError, category: .power)
        Logger.error("Error object timer", error: testError, category: .timer)
        Logger.error("Error object notifications", error: testError, category: .notifications)
        Logger.error("Error object hotkey", error: testError, category: .hotkey)
        Logger.error("Error object history", error: testError, category: .history)
        Logger.error("Error object preferences", error: testError, category: .preferences)
    }

    @Test("Error with custom Error type")
    func errorWithCustomErrorType() {
        enum CustomError: Error, LocalizedError {
            case testCase
            var errorDescription: String? { "Custom error description" }
        }
        Logger.error("Custom error", error: CustomError.testCase)
    }

    // Fault Level Tests (LOG-008)

    @Test("Fault logs without crashing")
    func faultLogsWithoutCrashing() {
        Logger.fault("Test fault message")
    }

    @Test("Fault logs with default category")
    func faultLogsWithDefaultCategory() {
        Logger.fault("Test fault message with default category")
    }

    @Test("Fault logs with all categories")
    func faultLogsWithAllCategories() {
        Logger.fault("Fault general", category: .general)
        Logger.fault("Fault power", category: .power)
        Logger.fault("Fault timer", category: .timer)
        Logger.fault("Fault notifications", category: .notifications)
        Logger.fault("Fault hotkey", category: .hotkey)
        Logger.fault("Fault history", category: .history)
        Logger.fault("Fault preferences", category: .preferences)
    }

    @Test("Fault logs empty message")
    func faultLogsEmptyMessage() {
        Logger.fault("")
    }

    @Test("Fault logs long message")
    func faultLogsLongMessage() {
        let longMessage = String(repeating: "e", count: 1000)
        Logger.fault(longMessage)
    }
}

// MARK: - Logger Convenience Method Tests

@Suite("Logger Convenience Method Tests")
struct LoggerConvenienceMethodTests {

    // Power Assertion Methods (LOG-009)

    @Test("Power assertion created logs without crashing")
    func powerAssertionCreatedLogsWithoutCrashing() {
        Logger.powerAssertionCreated(id: 12345)
    }

    @Test("Power assertion created with zero ID")
    func powerAssertionCreatedWithZeroId() {
        Logger.powerAssertionCreated(id: 0)
    }

    @Test("Power assertion created with max ID")
    func powerAssertionCreatedWithMaxId() {
        Logger.powerAssertionCreated(id: UInt32.max)
    }

    @Test("Power assertion released logs without crashing")
    func powerAssertionReleasedLogsWithoutCrashing() {
        Logger.powerAssertionReleased(id: 12345)
    }

    @Test("Power assertion released with zero ID")
    func powerAssertionReleasedWithZeroId() {
        Logger.powerAssertionReleased(id: 0)
    }

    @Test("Power assertion released with max ID")
    func powerAssertionReleasedWithMaxId() {
        Logger.powerAssertionReleased(id: UInt32.max)
    }

    // Timer Methods (LOG-010)

    @Test("Timer started logs without crashing")
    func timerStartedLogsWithoutCrashing() {
        Logger.timerStarted(duration: 3600)
    }

    @Test("Timer started with zero duration")
    func timerStartedWithZeroDuration() {
        Logger.timerStarted(duration: 0)
    }

    @Test("Timer started with small duration")
    func timerStartedWithSmallDuration() {
        Logger.timerStarted(duration: 60)
    }

    @Test("Timer started with large duration")
    func timerStartedWithLargeDuration() {
        Logger.timerStarted(duration: 86400)
    }

    @Test("Timer started with fractional duration")
    func timerStartedWithFractionalDuration() {
        Logger.timerStarted(duration: 90.5)
    }

    @Test("Timer expired logs without crashing")
    func timerExpiredLogsWithoutCrashing() {
        Logger.timerExpired()
    }

    // Notification Methods (LOG-011)

    @Test("Notification scheduled logs without crashing")
    func notificationScheduledLogsWithoutCrashing() {
        Logger.notificationScheduled(identifier: "test-notification-id")
    }

    @Test("Notification scheduled with empty identifier")
    func notificationScheduledWithEmptyIdentifier() {
        Logger.notificationScheduled(identifier: "")
    }

    @Test("Notification scheduled with long identifier")
    func notificationScheduledWithLongIdentifier() {
        let longId = String(repeating: "x", count: 100)
        Logger.notificationScheduled(identifier: longId)
    }

    @Test("Notification scheduled with special characters")
    func notificationScheduledWithSpecialCharacters() {
        Logger.notificationScheduled(identifier: "notification-!@#$%^&*()_+-=")
    }

    @Test("Notification authorization status granted")
    func notificationAuthorizationStatusGranted() {
        Logger.notificationAuthorizationStatus(granted: true)
    }

    @Test("Notification authorization status denied")
    func notificationAuthorizationStatusDenied() {
        Logger.notificationAuthorizationStatus(granted: false)
    }

    // Hotkey Methods (LOG-012)

    @Test("Hotkey registered logs without crashing")
    func hotkeyRegisteredLogsWithoutCrashing() {
        Logger.hotkeyRegistered(keyCode: 29, modifiers: 256)
    }

    @Test("Hotkey registered with zero values")
    func hotkeyRegisteredWithZeroValues() {
        Logger.hotkeyRegistered(keyCode: 0, modifiers: 0)
    }

    @Test("Hotkey registered with max values")
    func hotkeyRegisteredWithMaxValues() {
        Logger.hotkeyRegistered(keyCode: UInt32.max, modifiers: UInt32.max)
    }

    @Test("Hotkey conflict logs without crashing")
    func hotkeyConflictLogsWithoutCrashing() {
        Logger.hotkeyConflict(message: "Shortcut conflicts with system shortcut")
    }

    @Test("Hotkey conflict with empty message")
    func hotkeyConflictWithEmptyMessage() {
        Logger.hotkeyConflict(message: "")
    }

    @Test("Hotkey conflict with long message")
    func hotkeyConflictWithLongMessage() {
        let longMessage = String(repeating: "conflict ", count: 50)
        Logger.hotkeyConflict(message: longMessage)
    }

    // Session Methods (LOG-013)

    @Test("Session started with timer mode true")
    func sessionStartedWithTimerModeTrue() {
        Logger.sessionStarted(timerMode: true)
    }

    @Test("Session started with timer mode false")
    func sessionStartedWithTimerModeFalse() {
        Logger.sessionStarted(timerMode: false)
    }

    @Test("Session ended logs without crashing")
    func sessionEndedLogsWithoutCrashing() {
        Logger.sessionEnded(duration: 3600)
    }

    @Test("Session ended with zero duration")
    func sessionEndedWithZeroDuration() {
        Logger.sessionEnded(duration: 0)
    }

    @Test("Session ended with small duration")
    func sessionEndedWithSmallDuration() {
        Logger.sessionEnded(duration: 60)
    }

    @Test("Session ended with large duration")
    func sessionEndedWithLargeDuration() {
        Logger.sessionEnded(duration: 86400)
    }

    @Test("Session ended with fractional duration")
    func sessionEndedWithFractionalDuration() {
        Logger.sessionEnded(duration: 3661.5)
    }

    // Preference Methods (LOG-014)

    @Test("Preference changed with string value")
    func preferenceChangedWithStringValue() {
        Logger.preferenceChanged(key: "theme", value: "dark")
    }

    @Test("Preference changed with int value")
    func preferenceChangedWithIntValue() {
        Logger.preferenceChanged(key: "timerDuration", value: 3600)
    }

    @Test("Preference changed with bool value")
    func preferenceChangedWithBoolValue() {
        Logger.preferenceChanged(key: "notificationsEnabled", value: true)
    }

    @Test("Preference changed with double value")
    func preferenceChangedWithDoubleValue() {
        Logger.preferenceChanged(key: "customDuration", value: 1800.5)
    }

    @Test("Preference changed with empty key")
    func preferenceChangedWithEmptyKey() {
        Logger.preferenceChanged(key: "", value: "test")
    }

    @Test("Preference changed with long key")
    func preferenceChangedWithLongKey() {
        let longKey = String(repeating: "key", count: 50)
        Logger.preferenceChanged(key: longKey, value: "value")
    }

    @Test("Preference changed with array value")
    func preferenceChangedWithArrayValue() {
        Logger.preferenceChanged(key: "recentDurations", value: [300, 600, 900])
    }

    @Test("Preference changed with dictionary value")
    func preferenceChangedWithDictionaryValue() {
        Logger.preferenceChanged(key: "settings", value: ["key1": "value1", "key2": "value2"])
    }

    @Test("Preference changed with nil value")
    func preferenceChangedWithNilValue() {
        let nilValue: String? = nil
        Logger.preferenceChanged(key: "optionalSetting", value: nilValue as Any)
    }
}

// MARK: - Logger Thread Safety Tests

@Suite("Logger Thread Safety Tests")
struct LoggerThreadSafetyTests {

    @Test("Logger can be used from main thread")
    @MainActor
    func loggerCanBeUsedFromMainThread() {
        Logger.info("Main thread log")
    }

    @Test("Logger can be used from detached task")
    func loggerCanBeUsedFromDetachedTask() async {
        let task = Task.detached {
            Logger.info("Detached task log")
        }
        await task.value
    }

    @Test("Logger can be used from multiple concurrent tasks")
    func loggerCanBeUsedFromMultipleConcurrentTasks() async {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    Logger.info("Concurrent task \(i)")
                }
            }
        }
    }

    @Test("Logger can be used with different levels concurrently")
    func loggerCanBeUsedWithDifferentLevelsConcurrently() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { Logger.debug("Concurrent debug") }
            group.addTask { Logger.info("Concurrent info") }
            group.addTask { Logger.warning("Concurrent warning") }
            group.addTask { Logger.error("Concurrent error") }
            group.addTask { Logger.fault("Concurrent fault") }
        }
    }

    @Test("Logger can be used with different categories concurrently")
    func loggerCanBeUsedWithDifferentCategoriesConcurrently() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { Logger.info("General", category: .general) }
            group.addTask { Logger.info("Power", category: .power) }
            group.addTask { Logger.info("Timer", category: .timer) }
            group.addTask { Logger.info("Notifications", category: .notifications) }
            group.addTask { Logger.info("Hotkey", category: .hotkey) }
            group.addTask { Logger.info("History", category: .history) }
            group.addTask { Logger.info("Preferences", category: .preferences) }
        }
    }

    @Test("Convenience methods can be used concurrently")
    func convenienceMethodsCanBeUsedConcurrently() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { Logger.powerAssertionCreated(id: 1) }
            group.addTask { Logger.powerAssertionReleased(id: 1) }
            group.addTask { Logger.timerStarted(duration: 60) }
            group.addTask { Logger.timerExpired() }
            group.addTask { Logger.notificationScheduled(identifier: "test") }
            group.addTask { Logger.notificationAuthorizationStatus(granted: true) }
            group.addTask { Logger.hotkeyRegistered(keyCode: 1, modifiers: 1) }
            group.addTask { Logger.hotkeyConflict(message: "test") }
            group.addTask { Logger.sessionStarted(timerMode: true) }
            group.addTask { Logger.sessionEnded(duration: 60) }
            group.addTask { Logger.preferenceChanged(key: "test", value: "value") }
        }
    }

    @Test("Rapid logging does not crash")
    func rapidLoggingDoesNotCrash() async {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask {
                    Logger.info("Rapid log \(i)")
                }
            }
        }
    }
}

// MARK: - Logger Message Formatting Tests

@Suite("Logger Message Formatting Tests")
struct LoggerMessageFormattingTests {

    @Test("Messages with newlines")
    func messagesWithNewlines() {
        Logger.info("Line 1\nLine 2\nLine 3")
    }

    @Test("Messages with tabs")
    func messagesWithTabs() {
        Logger.info("Column1\tColumn2\tColumn3")
    }

    @Test("Messages with carriage returns")
    func messagesWithCarriageReturns() {
        Logger.info("Line 1\r\nLine 2\r\nLine 3")
    }

    @Test("Messages with null characters")
    func messagesWithNullCharacters() {
        Logger.info("Before\0After")
    }

    @Test("Messages with backslashes")
    func messagesWithBackslashes() {
        Logger.info("Path: C:\\Users\\Test\\File.txt")
    }

    @Test("Messages with quotes")
    func messagesWithQuotes() {
        Logger.info("He said \"Hello\" and 'Goodbye'")
    }

    @Test("Messages with percent signs")
    func messagesWithPercentSigns() {
        Logger.info("Progress: 50% complete")
    }

    @Test("Messages with format specifiers")
    func messagesWithFormatSpecifiers() {
        // These should be treated as literal strings, not format specifiers
        Logger.info("Format: %d %s %@ %f")
    }

    @Test("Messages with emoji")
    func messagesWithEmoji() {
        Logger.info("Status: Active \u{2705}")
    }

    @Test("Messages with CJK characters")
    func messagesWithCJKCharacters() {
        Logger.info("Chinese: \u{4E2D}\u{6587} Japanese: \u{65E5}\u{672C}\u{8A9E} Korean: \u{D55C}\u{AD6D}\u{C5B4}")
    }

    @Test("Messages with RTL characters")
    func messagesWithRTLCharacters() {
        Logger.info("Arabic: \u{0645}\u{0631}\u{062D}\u{0628}\u{0627} Hebrew: \u{05E9}\u{05DC}\u{05D5}\u{05DD}")
    }

    @Test("Messages with combining characters")
    func messagesWithCombiningCharacters() {
        Logger.info("Combining: e\u{0301} = \u{00E9}")
    }

    @Test("Messages with zero-width characters")
    func messagesWithZeroWidthCharacters() {
        Logger.info("Zero\u{200B}Width\u{200C}Chars\u{200D}Here")
    }

    @Test("Messages with control characters")
    func messagesWithControlCharacters() {
        Logger.info("Bell: \u{0007} Escape: \u{001B}")
    }

    @Test("Messages with very long single word")
    func messagesWithVeryLongSingleWord() {
        let longWord = String(repeating: "a", count: 500)
        Logger.info("Word: \(longWord)")
    }
}

// MARK: - Logger Integration Tests

@Suite("Logger Integration Tests")
struct LoggerIntegrationTests {

    @Test("Full logging workflow")
    func fullLoggingWorkflow() {
        // Simulate a typical app workflow with logging
        Logger.info("App started", category: .general)
        Logger.debug("Loading preferences", category: .preferences)
        Logger.preferenceChanged(key: "theme", value: "dark")
        Logger.hotkeyRegistered(keyCode: 29, modifiers: 4352)
        Logger.sessionStarted(timerMode: false)
        Logger.powerAssertionCreated(id: 12345)
        Logger.info("Sleep prevention active", category: .power)
        Logger.powerAssertionReleased(id: 12345)
        Logger.sessionEnded(duration: 3600)
        Logger.info("App terminating", category: .general)
    }

    @Test("Timer workflow logging")
    func timerWorkflowLogging() {
        Logger.sessionStarted(timerMode: true)
        Logger.timerStarted(duration: 1800)
        Logger.powerAssertionCreated(id: 99999)
        Logger.notificationScheduled(identifier: "timer-expiry")
        Logger.timerExpired()
        Logger.powerAssertionReleased(id: 99999)
        Logger.sessionEnded(duration: 1800)
    }

    @Test("Error handling workflow")
    func errorHandlingWorkflow() {
        let testError = NSError(domain: "TestDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: "Internal error"])
        Logger.warning("Potential issue detected", category: .general)
        Logger.error("Operation failed", error: testError, category: .general)
        Logger.fault("Critical system failure", category: .general)
    }

    @Test("Hotkey workflow logging")
    func hotkeyWorkflowLogging() {
        Logger.debug("Registering hotkey", category: .hotkey)
        Logger.hotkeyRegistered(keyCode: 29, modifiers: 4352)
        Logger.hotkeyConflict(message: "Cmd+Shift+0 conflicts with system shortcut")
        Logger.info("Hotkey re-registered with new combination", category: .hotkey)
        Logger.hotkeyRegistered(keyCode: 30, modifiers: 4352)
    }

    @Test("Notification workflow logging")
    func notificationWorkflowLogging() {
        Logger.debug("Requesting notification authorization", category: .notifications)
        Logger.notificationAuthorizationStatus(granted: true)
        Logger.notificationScheduled(identifier: "timer-expiry-001")
        Logger.info("Notification delivered", category: .notifications)
    }

    @Test("Preference change workflow")
    func preferenceChangeWorkflow() {
        Logger.preferenceChanged(key: "language", value: "en")
        Logger.preferenceChanged(key: "theme", value: "system")
        Logger.preferenceChanged(key: "iconStyle", value: "power")
        Logger.preferenceChanged(key: "notificationsEnabled", value: true)
        Logger.preferenceChanged(key: "launchAtLogin", value: false)
    }
}
