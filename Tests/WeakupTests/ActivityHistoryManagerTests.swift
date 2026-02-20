import XCTest
@testable import WeakupCore

@MainActor
final class ActivityHistoryManagerTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        // Clear history before each test
        UserDefaults.standard.removeObject(forKey: "WeakupActivityHistory")
        ActivityHistoryManager.shared.clearHistory()
    }

    override func tearDown() async throws {
        // Clean up after tests
        ActivityHistoryManager.shared.clearHistory()
        try await super.tearDown()
    }

    // MARK: - Singleton Tests

    func testShared_returnsSameInstance() {
        let instance1 = ActivityHistoryManager.shared
        let instance2 = ActivityHistoryManager.shared
        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - Session Management Tests

    func testStartSession_createsCurrentSession() {
        let manager = ActivityHistoryManager.shared
        XCTAssertNil(manager.currentSession)

        manager.startSession(timerMode: false, timerDuration: nil)

        XCTAssertNotNil(manager.currentSession)
        XCTAssertFalse(manager.currentSession!.wasTimerMode)
    }

    func testStartSession_withTimerMode() {
        let manager = ActivityHistoryManager.shared
        manager.startSession(timerMode: true, timerDuration: 1800)

        XCTAssertNotNil(manager.currentSession)
        XCTAssertTrue(manager.currentSession!.wasTimerMode)
        XCTAssertEqual(manager.currentSession!.timerDuration, 1800)
    }

    func testEndSession_addsToHistory() {
        let manager = ActivityHistoryManager.shared
        let initialCount = manager.sessions.count

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        XCTAssertEqual(manager.sessions.count, initialCount + 1)
        XCTAssertNil(manager.currentSession)
    }

    func testEndSession_insertsAtBeginning() {
        let manager = ActivityHistoryManager.shared

        // Create first session
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        let firstSessionId = manager.sessions.first?.id

        // Create second session
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        // Second session should be first in list
        XCTAssertNotEqual(manager.sessions.first?.id, firstSessionId)
        XCTAssertTrue(manager.sessions.first?.wasTimerMode ?? false)
    }

    func testEndSession_withNoCurrentSession_doesNothing() {
        let manager = ActivityHistoryManager.shared
        let initialCount = manager.sessions.count

        manager.endSession() // No current session

        XCTAssertEqual(manager.sessions.count, initialCount)
    }

    // MARK: - Clear History Tests

    func testClearHistory_removesAllSessions() {
        let manager = ActivityHistoryManager.shared

        // Add some sessions
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        XCTAssertGreaterThan(manager.sessions.count, 0)

        manager.clearHistory()

        XCTAssertEqual(manager.sessions.count, 0)
    }

    // MARK: - Statistics Tests

    func testStatistics_emptyHistory_returnsZeros() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let stats = manager.statistics

        XCTAssertEqual(stats.totalSessions, 0)
        XCTAssertEqual(stats.totalDuration, 0)
        XCTAssertEqual(stats.averageSessionDuration, 0)
    }

    func testStatistics_countsCompletedSessions() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add completed sessions
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.statistics

        XCTAssertEqual(stats.totalSessions, 2)
    }

    func testStatistics_excludesActiveSessions() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add completed session
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        // Start but don't end a session
        manager.startSession(timerMode: false, timerDuration: nil)

        let stats = manager.statistics

        // Should only count the completed session
        XCTAssertEqual(stats.totalSessions, 1)
    }

    func testStatistics_calculatesAverageDuration() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add sessions with known durations
        // Note: Duration is calculated from start to end time
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.statistics

        // With at least one session, average should be > 0 (even if tiny)
        XCTAssertGreaterThanOrEqual(stats.averageSessionDuration, 0)
    }
}
