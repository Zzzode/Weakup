import Foundation
import Testing
@testable import WeakupCore

@Suite("ActivityHistoryManager Tests", .serialized)
@MainActor
struct ActivityHistoryManagerTests {

    init() {
        // Clear history and reset filters before each test
        UserDefaultsStore.shared.removeObject(forKey: "WeakupActivityHistory")
        ActivityHistoryManager.shared.clearHistory()
        ActivityHistoryManager.shared.filterMode = .all
        ActivityHistoryManager.shared.sortOrder = .dateDescending
        ActivityHistoryManager.shared.searchText = ""
    }

    // MARK: - Singleton Tests

    @Test("Shared returns same instance")
    func sharedReturnsSameInstance() {
        let instance1 = ActivityHistoryManager.shared
        let instance2 = ActivityHistoryManager.shared
        #expect(instance1 === instance2)
    }

    // MARK: - Session Management Tests

    @Test("Start session creates current session")
    func startSessionCreatesCurrentSession() {
        let manager = ActivityHistoryManager.shared
        #expect(manager.currentSession == nil)

        manager.startSession(timerMode: false, timerDuration: nil)

        #expect(manager.currentSession != nil)
        #expect(!manager.currentSession!.wasTimerMode)
        manager.endSession()
    }

    @Test("Start session with timer mode")
    func startSessionWithTimerMode() {
        let manager = ActivityHistoryManager.shared
        manager.startSession(timerMode: true, timerDuration: 1800)

        #expect(manager.currentSession != nil)
        #expect(manager.currentSession!.wasTimerMode)
        #expect(manager.currentSession!.timerDuration == 1800)
        manager.endSession()
    }

    @Test("End session adds to history")
    func endSessionAddsToHistory() {
        let manager = ActivityHistoryManager.shared
        let initialCount = manager.sessions.count

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        #expect(manager.sessions.count == initialCount + 1)
        #expect(manager.currentSession == nil)
    }

    @Test("End session inserts at beginning")
    func endSessionInsertsAtBeginning() {
        let manager = ActivityHistoryManager.shared

        // Create first session
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        let firstSessionId = manager.sessions.first?.id

        // Create second session
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        // Second session should be first in list
        #expect(manager.sessions.first?.id != firstSessionId)
        #expect(manager.sessions.first?.wasTimerMode ?? false)
    }

    @Test("End session with no current session does nothing")
    func endSessionWithNoCurrentSessionDoesNothing() {
        let manager = ActivityHistoryManager.shared
        let initialCount = manager.sessions.count

        manager.endSession() // No current session

        #expect(manager.sessions.count == initialCount)
    }

    // MARK: - Clear History Tests

    @Test("Clear history removes all sessions")
    func clearHistoryRemovesAllSessions() {
        let manager = ActivityHistoryManager.shared

        // Add some sessions
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        #expect(manager.sessions.count > 0)

        manager.clearHistory()

        #expect(manager.sessions.count == 0)
    }

    // MARK: - Statistics Tests

    @Test("Statistics empty history returns zeros")
    func statisticsEmptyHistoryReturnsZeros() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let stats = manager.statistics

        #expect(stats.totalSessions == 0)
        #expect(stats.totalDuration == 0)
        #expect(stats.averageSessionDuration == 0)
    }

    @Test("Statistics counts completed sessions")
    func statisticsCountsCompletedSessions() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add completed sessions
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.statistics

        #expect(stats.totalSessions == 2)
    }

    @Test("Statistics excludes active sessions")
    func statisticsExcludesActiveSessions() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add completed session
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        // Start but don't end a session
        manager.startSession(timerMode: false, timerDuration: nil)

        let stats = manager.statistics

        // Should only count the completed session
        #expect(stats.totalSessions == 1)
        manager.endSession()
    }

    @Test("Statistics calculates average duration")
    func statisticsCalculatesAverageDuration() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add sessions with known durations
        // Note: Duration is calculated from start to end time
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.statistics

        // With at least one session, average should be > 0 (even if tiny)
        #expect(stats.averageSessionDuration >= 0)
    }

    // MARK: - Today/Week Statistics Tests

    @Test("Statistics today sessions counts only today")
    func statisticsTodaySessionsCountsOnlyToday() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add a session today
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.statistics

        // Session created now should count as today
        #expect(stats.todaySessions == 1)
        #expect(stats.todayDuration >= 0)
    }

    @Test("Statistics week sessions counts this week")
    func statisticsWeekSessionsCountsThisWeek() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add a session today (which is also this week)
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.statistics

        // Session created now should count as this week
        #expect(stats.weekSessions == 1)
        #expect(stats.weekDuration >= 0)
    }

    // MARK: - Persistence Tests

    @Test("Persistence saves on end")
    func persistenceSavesOnEnd() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        // Verify data was saved to UserDefaults
        let data = UserDefaultsStore.shared.data(forKey: "WeakupActivityHistory")
        #expect(data != nil)
    }

    @Test("Persistence data is valid JSON")
    func persistenceDataIsValidJSON() throws {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: true, timerDuration: 3600)
        manager.endSession()

        // Verify saved data can be decoded
        guard let data = UserDefaultsStore.shared.data(forKey: "WeakupActivityHistory") else {
            Issue.record("No data saved")
            return
        }

        let sessions = try JSONDecoder().decode([ActivitySession].self, from: data)
        #expect(sessions.count == 1)
        #expect(sessions[0].wasTimerMode)
        #expect(sessions[0].timerDuration == 3600)
    }

    // MARK: - Timer Mode Session Tests

    @Test("Session timer mode stores correct duration")
    func sessionTimerModeStoresCorrectDuration() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let expectedDuration: TimeInterval = 1800 // 30 minutes
        manager.startSession(timerMode: true, timerDuration: expectedDuration)

        #expect(manager.currentSession != nil)
        #expect(manager.currentSession!.wasTimerMode)
        #expect(manager.currentSession!.timerDuration == expectedDuration)

        manager.endSession()

        #expect(manager.sessions.first?.timerDuration == expectedDuration)
    }

    @Test("Session non-timer mode has nil duration")
    func sessionNonTimerModeHasNilDuration() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)

        #expect(manager.currentSession != nil)
        #expect(!manager.currentSession!.wasTimerMode)
        #expect(manager.currentSession!.timerDuration == nil)

        manager.endSession()

        #expect(manager.sessions.first?.timerDuration == nil)
    }

    // MARK: - Edge Case Tests

    @Test("Rapid start stop maintains consistency")
    func rapidStartStopMaintainsConsistency() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Rapid start/stop cycles
        for _ in 0..<10 {
            manager.startSession(timerMode: false, timerDuration: nil)
            manager.endSession()
        }

        #expect(manager.sessions.count == 10)
        #expect(manager.currentSession == nil)
    }

    @Test("Multiple starts without end only last session active")
    func multipleStartsWithoutEndOnlyLastSessionActive() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Start multiple sessions without ending
        manager.startSession(timerMode: false, timerDuration: nil)
        let firstSessionId = manager.currentSession?.id

        manager.startSession(timerMode: true, timerDuration: 60)
        let secondSessionId = manager.currentSession?.id

        // Second start should replace first (current implementation)
        #expect(firstSessionId != secondSessionId)
        #expect(manager.currentSession != nil)
        #expect(manager.currentSession!.wasTimerMode)
        manager.endSession()
    }

    @Test("End session calculates correct duration")
    func endSessionCalculatesCorrectDuration() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)

        // Small delay to ensure measurable duration
        Thread.sleep(forTimeInterval: 0.1)

        manager.endSession()

        guard let session = manager.sessions.first else {
            Issue.record("No session in history")
            return
        }

        // Duration should be at least 0.1 seconds
        #expect(session.duration >= 0.1)
        // Duration should be reasonable (less than 1 second for this test)
        #expect(session.duration < 1.0)
    }

    @Test("Clear history also saves to persistence")
    func clearHistoryAlsoSavesToPersistence() {
        let manager = ActivityHistoryManager.shared

        // Add some sessions
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        // Clear history
        manager.clearHistory()

        // Verify persistence is also cleared
        if let data = UserDefaultsStore.shared.data(forKey: "WeakupActivityHistory") {
            let sessions = try? JSONDecoder().decode([ActivitySession].self, from: data)
            #expect(sessions?.count ?? 0 == 0)
        }
    }

    @Test("Statistics calculates correct total duration")
    func statisticsCalculatesCorrectTotalDuration() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Add multiple sessions
        for _ in 0..<3 {
            manager.startSession(timerMode: false, timerDuration: nil)
            Thread.sleep(forTimeInterval: 0.05)
            manager.endSession()
        }

        let stats = manager.statistics

        #expect(stats.totalSessions == 3)
        // Total duration should be sum of all session durations
        let calculatedTotal = manager.sessions.reduce(0) { $0 + $1.duration }
        #expect(abs(stats.totalDuration - calculatedTotal) < 0.001)
    }

    // MARK: - Export Tests

    @Test("Export JSON creates valid data")
    func exportJSONCreatesValidData() throws {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: true, timerDuration: 1800)
        manager.endSession()

        let result = manager.exportHistory(format: .json)

        #expect(result != nil)
        #expect(result?.format == .json)
        #expect(result?.suggestedFilename.hasSuffix(".json") ?? false)

        // Verify JSON is valid
        if let data = result?.data {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let sessions = try decoder.decode([ActivitySession].self, from: data)
            #expect(sessions.count == 1)
            #expect(sessions[0].wasTimerMode)
        }
    }

    @Test("Export CSV creates valid data")
    func exportCSVCreatesValidData() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let result = manager.exportHistory(format: .csv)

        #expect(result != nil)
        #expect(result?.format == .csv)
        #expect(result?.suggestedFilename.hasSuffix(".csv") ?? false)

        // Verify CSV has header and data row
        if let data = result?.data, let csvString = String(data: data, encoding: .utf8) {
            let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }
            #expect(lines.count >= 2) // Header + at least 1 data row
            #expect(lines[0].contains("ID"))
            #expect(lines[0].contains("Start Time"))
        }
    }

    @Test("Export empty history returns nil")
    func exportEmptyHistoryReturnsNil() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let jsonResult = manager.exportHistory(format: .json)
        let csvResult = manager.exportHistory(format: .csv)

        #expect(jsonResult == nil)
        #expect(csvResult == nil)
    }

    // MARK: - Import Tests

    @Test("Import JSON valid data succeeds")
    func importJSONValidDataSucceeds() throws {
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
        let data = try encoder.encode([session])

        let result = manager.importHistory(from: data, format: .json)

        switch result {
        case .success(let imported, _):
            #expect(imported == 1)
            #expect(manager.sessions.count == 1)
        case .failure(let error):
            Issue.record("Import failed: \(error)")
        }
    }

    @Test("Import JSON invalid data fails")
    func importJSONInvalidDataFails() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let invalidData = "not valid json".data(using: .utf8)!

        let result = manager.importHistory(from: invalidData, format: .json)

        switch result {
        case .success:
            Issue.record("Should have failed with invalid data")
        case .failure:
            // Expected
            break
        }
    }

    @Test("Import JSON duplicate sessions skipped")
    func importJSONDuplicateSessionsSkipped() throws {
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
        let data = try encoder.encode([session])

        // Import once
        _ = manager.importHistory(from: data, format: .json)

        // Import again with same ID
        let result = manager.importHistory(from: data, format: .json)

        switch result {
        case .success(let imported, let skipped):
            #expect(imported == 0)
            #expect(skipped == 1)
            #expect(manager.sessions.count == 1) // Still only 1 session
        case .failure(let error):
            Issue.record("Import failed: \(error)")
        }
    }

    // MARK: - Filter Tests

    @Test("Filtered sessions all filter returns all")
    func filteredSessionsAllFilterReturnsAll() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.filterMode = .all

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        #expect(manager.filteredSessions.count == 2)
    }

    @Test("Filtered sessions timer only filter")
    func filteredSessionsTimerOnlyFilter() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.filterMode = .timerOnly

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        #expect(manager.filteredSessions.count == 1)
        #expect(manager.filteredSessions.first?.wasTimerMode ?? false)
    }

    @Test("Filtered sessions manual only filter")
    func filteredSessionsManualOnlyFilter() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.filterMode = .manualOnly

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        #expect(manager.filteredSessions.count == 1)
        #expect(!(manager.filteredSessions.first?.wasTimerMode ?? true))
    }

    // MARK: - Sort Tests

    @Test("Sort order date descending")
    func sortOrderDateDescending() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.sortOrder = .dateDescending

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        Thread.sleep(forTimeInterval: 0.1)
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let sessions = manager.filteredSessions
        #expect(sessions.count >= 2)
        if sessions.count >= 2 {
            #expect(sessions[0].startTime > sessions[1].startTime)
        }
    }

    @Test("Sort order date ascending")
    func sortOrderDateAscending() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.sortOrder = .dateAscending

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        Thread.sleep(forTimeInterval: 0.1)
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let sessions = manager.filteredSessions
        #expect(sessions.count >= 2)
        if sessions.count >= 2 {
            #expect(sessions[0].startTime < sessions[1].startTime)
        }
    }

    // MARK: - Daily Statistics Tests

    @Test("Daily statistics returns 7 days")
    func dailyStatisticsReturns7Days() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let stats = manager.dailyStatistics(days: 7)

        #expect(stats.count == 7)
    }

    @Test("Daily statistics today has data")
    func dailyStatisticsTodayHasData() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.dailyStatistics(days: 7)

        // Last item should be today
        let today = stats.last
        #expect(today != nil)
        #expect(today?.sessionCount == 1)
    }

    // MARK: - Delete Session Tests

    @Test("Delete session removes from history")
    func deleteSessionRemovesFromHistory() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let session = manager.sessions.first!
        manager.deleteSession(session)

        #expect(manager.sessions.count == 0)
    }

    @Test("Delete session preserves other sessions")
    func deleteSessionPreservesOtherSessions() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        let sessionToDelete = manager.sessions.first!
        manager.deleteSession(sessionToDelete)

        #expect(manager.sessions.count == 1)
    }
}
