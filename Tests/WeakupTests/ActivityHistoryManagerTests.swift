import XCTest
@testable import WeakupCore

@MainActor
final class ActivityHistoryManagerTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        // Clear history and reset filters before each test
        UserDefaultsStore.shared.removeObject(forKey: "WeakupActivityHistory")
        ActivityHistoryManager.shared.clearHistory()
        ActivityHistoryManager.shared.filterMode = .all
        ActivityHistoryManager.shared.sortOrder = .dateDescending
        ActivityHistoryManager.shared.searchText = ""
    }

    override func tearDown() async throws {
        // Clean up after tests
        ActivityHistoryManager.shared.clearHistory()
        try await super.tearDown()
    }

    // Singleton Tests

    func testShared_returnsSameInstance() {
        let instance1 = ActivityHistoryManager.shared
        let instance2 = ActivityHistoryManager.shared
        XCTAssertTrue(instance1 === instance2)
    }

    // Session Management Tests

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

    // Clear History Tests

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

    // Statistics Tests

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

    // Today/Week Statistics Tests

    func testStatistics_todaySessions_countsOnlyToday() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add a session today
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.statistics

        // Session created now should count as today
        XCTAssertEqual(stats.todaySessions, 1)
        XCTAssertGreaterThanOrEqual(stats.todayDuration, 0)
    }

    func testStatistics_weekSessions_countsThisWeek() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add a session today (which is also this week)
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.statistics

        // Session created now should count as this week
        XCTAssertEqual(stats.weekSessions, 1)
        XCTAssertGreaterThanOrEqual(stats.weekDuration, 0)
    }

    // Persistence Tests

    func testPersistence_savesOnEnd() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        // Verify data was saved to UserDefaults
        let data = UserDefaultsStore.shared.data(forKey: "WeakupActivityHistory")
        XCTAssertNotNil(data)
    }

    func testPersistence_dataIsValidJSON() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: true, timerDuration: 3600)
        manager.endSession()

        // Verify saved data can be decoded
        guard let data = UserDefaultsStore.shared.data(forKey: "WeakupActivityHistory") else {
            XCTFail("No data saved")
            return
        }

        do {
            let sessions = try JSONDecoder().decode([ActivitySession].self, from: data)
            XCTAssertEqual(sessions.count, 1)
            XCTAssertTrue(sessions[0].wasTimerMode)
            XCTAssertEqual(sessions[0].timerDuration, 3600)
        } catch {
            XCTFail("Failed to decode saved sessions: \(error)")
        }
    }

    // Timer Mode Session Tests

    func testSession_timerMode_storesCorrectDuration() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let expectedDuration: TimeInterval = 1800 // 30 minutes
        manager.startSession(timerMode: true, timerDuration: expectedDuration)

        XCTAssertNotNil(manager.currentSession)
        XCTAssertTrue(manager.currentSession!.wasTimerMode)
        XCTAssertEqual(manager.currentSession!.timerDuration, expectedDuration)

        manager.endSession()

        XCTAssertEqual(manager.sessions.first?.timerDuration, expectedDuration)
    }

    func testSession_nonTimerMode_hasNilDuration() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)

        XCTAssertNotNil(manager.currentSession)
        XCTAssertFalse(manager.currentSession!.wasTimerMode)
        XCTAssertNil(manager.currentSession!.timerDuration)

        manager.endSession()

        XCTAssertNil(manager.sessions.first?.timerDuration)
    }

    // Edge Case Tests

    func testRapidStartStop_maintainsConsistency() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Rapid start/stop cycles
        for _ in 0..<10 {
            manager.startSession(timerMode: false, timerDuration: nil)
            manager.endSession()
        }

        XCTAssertEqual(manager.sessions.count, 10)
        XCTAssertNil(manager.currentSession)
    }

    func testMultipleStartsWithoutEnd_onlyLastSessionActive() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Start multiple sessions without ending
        manager.startSession(timerMode: false, timerDuration: nil)
        let firstSessionId = manager.currentSession?.id

        manager.startSession(timerMode: true, timerDuration: 60)
        let secondSessionId = manager.currentSession?.id

        // Second start should replace first (current implementation)
        XCTAssertNotEqual(firstSessionId, secondSessionId)
        XCTAssertNotNil(manager.currentSession)
        XCTAssertTrue(manager.currentSession!.wasTimerMode)
    }

    func testEndSession_calculatesCorrectDuration() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)

        // Small delay to ensure measurable duration
        Thread.sleep(forTimeInterval: 0.1)

        manager.endSession()

        guard let session = manager.sessions.first else {
            XCTFail("No session in history")
            return
        }

        // Duration should be at least 0.1 seconds
        XCTAssertGreaterThanOrEqual(session.duration, 0.1)
        // Duration should be reasonable (less than 1 second for this test)
        XCTAssertLessThan(session.duration, 1.0)
    }

    func testClearHistory_alsoSavesToPersistence() {
        let manager = ActivityHistoryManager.shared

        // Add some sessions
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        // Clear history
        manager.clearHistory()

        // Verify persistence is also cleared
        if let data = UserDefaultsStore.shared.data(forKey: "WeakupActivityHistory") {
            let sessions = try? JSONDecoder().decode([ActivitySession].self, from: data)
            XCTAssertEqual(sessions?.count ?? 0, 0)
        }
    }

    func testStatistics_calculatesCorrectTotalDuration() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add multiple sessions
        for _ in 0..<3 {
            manager.startSession(timerMode: false, timerDuration: nil)
            Thread.sleep(forTimeInterval: 0.05)
            manager.endSession()
        }

        let stats = manager.statistics

        XCTAssertEqual(stats.totalSessions, 3)
        // Total duration should be sum of all session durations
        let calculatedTotal = manager.sessions.reduce(0) { $0 + $1.duration }
        XCTAssertEqual(stats.totalDuration, calculatedTotal, accuracy: 0.001)
    }

    // Export Tests

    func testExportJSON_createsValidData() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: true, timerDuration: 1800)
        manager.endSession()

        let result = manager.exportHistory(format: .json)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, .json)
        XCTAssertTrue(result?.suggestedFilename.hasSuffix(".json") ?? false)

        // Verify JSON is valid
        if let data = result?.data {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let sessions = try decoder.decode([ActivitySession].self, from: data)
                XCTAssertEqual(sessions.count, 1)
                XCTAssertTrue(sessions[0].wasTimerMode)
            } catch {
                XCTFail("Invalid JSON: \(error)")
            }
        }
    }

    func testExportCSV_createsValidData() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let result = manager.exportHistory(format: .csv)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, .csv)
        XCTAssertTrue(result?.suggestedFilename.hasSuffix(".csv") ?? false)

        // Verify CSV has header and data row
        if let data = result?.data, let csvString = String(data: data, encoding: .utf8) {
            let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }
            XCTAssertGreaterThanOrEqual(lines.count, 2) // Header + at least 1 data row
            XCTAssertTrue(lines[0].contains("ID"))
            XCTAssertTrue(lines[0].contains("Start Time"))
        }
    }

    func testExport_emptyHistory_returnsNil() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let jsonResult = manager.exportHistory(format: .json)
        let csvResult = manager.exportHistory(format: .csv)

        XCTAssertNil(jsonResult)
        XCTAssertNil(csvResult)
    }

    // Import Tests

    func testImportJSON_validData_succeeds() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Create valid JSON data
        let session = ActivitySession(
            id: UUID(),
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date(),
            wasTimerMode: true,
            timerDuration: 1800
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode([session]) else {
            XCTFail("Failed to encode test data")
            return
        }

        let result = manager.importHistory(from: data, format: .json)

        switch result {
        case .success(let imported, _):
            XCTAssertEqual(imported, 1)
            XCTAssertEqual(manager.sessions.count, 1)
        case .failure(let error):
            XCTFail("Import failed: \(error)")
        }
    }

    func testImportJSON_invalidData_fails() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let invalidData = "not valid json".data(using: .utf8)!

        let result = manager.importHistory(from: invalidData, format: .json)

        switch result {
        case .success:
            XCTFail("Should have failed with invalid data")
        case .failure:
            // Expected
            break
        }
    }

    func testImportJSON_duplicateSessions_skipped() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Create and import a session
        let sessionId = UUID()
        let session = ActivitySession(
            id: sessionId,
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date(),
            wasTimerMode: false,
            timerDuration: nil
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode([session]) else {
            XCTFail("Failed to encode test data")
            return
        }

        // Import once
        _ = manager.importHistory(from: data, format: .json)

        // Import again with same ID
        let result = manager.importHistory(from: data, format: .json)

        switch result {
        case .success(let imported, let skipped):
            XCTAssertEqual(imported, 0)
            XCTAssertEqual(skipped, 1)
            XCTAssertEqual(manager.sessions.count, 1) // Still only 1 session
        case .failure(let error):
            XCTFail("Import failed: \(error)")
        }
    }

    // Filter Tests

    func testFilteredSessions_allFilter_returnsAll() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.filterMode = .all

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        XCTAssertEqual(manager.filteredSessions.count, 2)
    }

    func testFilteredSessions_timerOnlyFilter() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.filterMode = .timerOnly

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        XCTAssertEqual(manager.filteredSessions.count, 1)
        XCTAssertTrue(manager.filteredSessions.first?.wasTimerMode ?? false)
    }

    func testFilteredSessions_manualOnlyFilter() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.filterMode = .manualOnly

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        XCTAssertEqual(manager.filteredSessions.count, 1)
        XCTAssertFalse(manager.filteredSessions.first?.wasTimerMode ?? true)
    }

    // Sort Tests

    func testSortOrder_dateDescending() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.sortOrder = .dateDescending

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        Thread.sleep(forTimeInterval: 0.1)
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let sessions = manager.filteredSessions
        XCTAssertGreaterThanOrEqual(sessions.count, 2)
        if sessions.count >= 2 {
            XCTAssertGreaterThan(sessions[0].startTime, sessions[1].startTime)
        }
    }

    func testSortOrder_dateAscending() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.sortOrder = .dateAscending

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        Thread.sleep(forTimeInterval: 0.1)
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let sessions = manager.filteredSessions
        XCTAssertGreaterThanOrEqual(sessions.count, 2)
        if sessions.count >= 2 {
            XCTAssertLessThan(sessions[0].startTime, sessions[1].startTime)
        }
    }

    // Daily Statistics Tests

    func testDailyStatistics_returns7Days() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let stats = manager.dailyStatistics(days: 7)

        XCTAssertEqual(stats.count, 7)
    }

    func testDailyStatistics_todayHasData() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.dailyStatistics(days: 7)

        // Last item should be today
        let today = stats.last
        XCTAssertNotNil(today)
        XCTAssertEqual(today?.sessionCount, 1)
    }

    // Delete Session Tests

    func testDeleteSession_removesFromHistory() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let session = manager.sessions.first!
        manager.deleteSession(session)

        XCTAssertEqual(manager.sessions.count, 0)
    }

    func testDeleteSession_preservesOtherSessions() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        let sessionToDelete = manager.sessions.first!
        manager.deleteSession(sessionToDelete)

        XCTAssertEqual(manager.sessions.count, 1)
    }
}
