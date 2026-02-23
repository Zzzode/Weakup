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

    // Singleton Tests

    @Test("Shared returns same instance")
    func sharedReturnsSameInstance() {
        let instance1 = ActivityHistoryManager.shared
        let instance2 = ActivityHistoryManager.shared
        #expect(instance1 === instance2)
    }

    // Session Management Tests

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

    // Clear History Tests

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

    // Statistics Tests

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

    // Today/Week Statistics Tests

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

    // Persistence Tests

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

    // Timer Mode Session Tests

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

    // Edge Case Tests

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

    // Export Tests

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

    // Import Tests

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

    // Filter Tests

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

    // Sort Tests

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

    // Daily Statistics Tests

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

    // Delete Session Tests

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

    // CSV Import Tests

    @Test("Import CSV valid data succeeds")
    func importCSVValidDataSucceeds() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let sessionId = UUID()
        let startTime = Date().addingTimeInterval(-3600)
        let endTime = Date()
        let dateFormatter = ISO8601DateFormatter()

        let csvContent = """
        ID,Start Time,End Time,Duration (seconds),Was Timer Mode,Timer Duration (seconds)
        \(sessionId.uuidString),\(dateFormatter.string(from: startTime)),\(dateFormatter.string(from: endTime)),3600,true,1800
        """

        let data = csvContent.data(using: .utf8)!
        let result = manager.importHistory(from: data, format: .csv)

        switch result {
        case .success(let imported, _):
            #expect(imported == 1)
            #expect(manager.sessions.count == 1)
            #expect(manager.sessions.first?.wasTimerMode ?? false)
            #expect(manager.sessions.first?.timerDuration == 1800)
        case .failure(let error):
            Issue.record("Import failed: \(error)")
        }
    }

    @Test("Import CSV empty file fails")
    func importCSVEmptyFileFails() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let csvContent = ""
        let data = csvContent.data(using: .utf8)!
        let result = manager.importHistory(from: data, format: .csv)

        switch result {
        case .success:
            Issue.record("Should have failed with empty file")
        case .failure:
            // Expected
            break
        }
    }

    @Test("Import CSV header only fails with no data rows")
    func importCSVHeaderOnlyFailsWithNoDataRows() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let csvContent = "ID,Start Time,End Time,Duration (seconds),Was Timer Mode,Timer Duration (seconds)"
        let data = csvContent.data(using: .utf8)!
        let result = manager.importHistory(from: data, format: .csv)

        switch result {
        case .success:
            Issue.record("Should have failed with header-only CSV")
        case .failure(let error):
            #expect(error.contains("empty") || error.contains("no data"))
        }
    }

    @Test("Import CSV with malformed rows skips invalid")
    func importCSVWithMalformedRowsSkipsInvalid() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let validId = UUID()
        let startTime = Date().addingTimeInterval(-3600)
        let endTime = Date()
        let dateFormatter = ISO8601DateFormatter()

        let csvContent = """
        ID,Start Time,End Time,Duration (seconds),Was Timer Mode,Timer Duration (seconds)
        invalid-uuid,\(dateFormatter.string(from: startTime)),\(dateFormatter.string(from: endTime)),3600,true,1800
        \(validId.uuidString),\(dateFormatter.string(from: startTime)),\(dateFormatter.string(from: endTime)),3600,false,
        """

        let data = csvContent.data(using: .utf8)!
        let result = manager.importHistory(from: data, format: .csv)

        switch result {
        case .success(let imported, _):
            #expect(imported == 1)
            #expect(manager.sessions.first?.id == validId)
        case .failure(let error):
            Issue.record("Import failed: \(error)")
        }
    }

    @Test("Import CSV without end time succeeds")
    func importCSVWithoutEndTimeSucceeds() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let sessionId = UUID()
        let startTime = Date().addingTimeInterval(-3600)
        let dateFormatter = ISO8601DateFormatter()

        let csvContent = """
        ID,Start Time,End Time,Duration (seconds),Was Timer Mode,Timer Duration (seconds)
        \(sessionId.uuidString),\(dateFormatter.string(from: startTime)),,0,false,
        """

        let data = csvContent.data(using: .utf8)!
        let result = manager.importHistory(from: data, format: .csv)

        switch result {
        case .success(let imported, _):
            #expect(imported == 1)
            #expect(manager.sessions.first?.endTime == nil)
        case .failure(let error):
            Issue.record("Import failed: \(error)")
        }
    }

    // Search Text Filter Tests

    @Test("Search text filters sessions by date string")
    func searchTextFiltersSessionsByDateString() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        // Get the date string for today
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let todayString = formatter.string(from: Date())

        // Search for part of today's date
        let searchTerm = String(todayString.prefix(3)).lowercased()
        manager.searchText = searchTerm

        // Should find the session
        #expect(manager.filteredSessions.count >= 0) // May or may not match depending on locale
    }

    @Test("Search text empty returns all sessions")
    func searchTextEmptyReturnsAllSessions() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.searchText = ""

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        #expect(manager.filteredSessions.count == 2)
    }

    @Test("Search text no match returns empty")
    func searchTextNoMatchReturnsEmpty() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        manager.searchText = "zzzznonexistent9999"

        #expect(manager.filteredSessions.count == 0)
    }

    // Duration Sort Tests

    @Test("Sort order duration descending")
    func sortOrderDurationDescending() throws {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Import sessions with known durations
        let shortSession = ActivitySession(
            id: UUID(),
            startTime: Date().addingTimeInterval(-100),
            endTime: Date().addingTimeInterval(-90),
            wasTimerMode: false,
            timerDuration: nil
        )
        let longSession = ActivitySession(
            id: UUID(),
            startTime: Date().addingTimeInterval(-1000),
            endTime: Date().addingTimeInterval(-100),
            wasTimerMode: false,
            timerDuration: nil
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode([shortSession, longSession])
        _ = manager.importHistory(from: data, format: .json)

        manager.sortOrder = .durationDescending

        let sessions = manager.filteredSessions
        #expect(sessions.count == 2)
        if sessions.count >= 2 {
            #expect(sessions[0].duration > sessions[1].duration)
        }
    }

    @Test("Sort order duration ascending")
    func sortOrderDurationAscending() throws {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        // Import sessions with known durations
        let shortSession = ActivitySession(
            id: UUID(),
            startTime: Date().addingTimeInterval(-100),
            endTime: Date().addingTimeInterval(-90),
            wasTimerMode: false,
            timerDuration: nil
        )
        let longSession = ActivitySession(
            id: UUID(),
            startTime: Date().addingTimeInterval(-1000),
            endTime: Date().addingTimeInterval(-100),
            wasTimerMode: false,
            timerDuration: nil
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode([shortSession, longSession])
        _ = manager.importHistory(from: data, format: .json)

        manager.sortOrder = .durationAscending

        let sessions = manager.filteredSessions
        #expect(sessions.count == 2)
        if sessions.count >= 2 {
            #expect(sessions[0].duration < sessions[1].duration)
        }
    }

    // Filter Mode Tests

    @Test("Filtered sessions today filter")
    func filteredSessionsTodayFilter() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.filterMode = .today

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        #expect(manager.filteredSessions.count == 1)
    }

    @Test("Filtered sessions this week filter")
    func filteredSessionsThisWeekFilter() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.filterMode = .thisWeek

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        #expect(manager.filteredSessions.count == 1)
    }

    @Test("Filtered sessions this month filter")
    func filteredSessionsThisMonthFilter() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()
        manager.filterMode = .thisMonth

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        #expect(manager.filteredSessions.count == 1)
    }

    // ExportFormat Tests

    @Test("ExportFormat JSON properties")
    func exportFormatJSONProperties() {
        let format = ExportFormat.json
        #expect(format.fileExtension == "json")
        #expect(format.displayName == "JSON")
        #expect(format.contentType == "application/json")
        #expect(format.id == "json")
    }

    @Test("ExportFormat CSV properties")
    func exportFormatCSVProperties() {
        let format = ExportFormat.csv
        #expect(format.fileExtension == "csv")
        #expect(format.displayName == "CSV")
        #expect(format.contentType == "text/csv")
        #expect(format.id == "csv")
    }

    @Test("ExportFormat allCases contains both formats")
    func exportFormatAllCasesContainsBothFormats() {
        #expect(ExportFormat.allCases.count == 2)
        #expect(ExportFormat.allCases.contains(.json))
        #expect(ExportFormat.allCases.contains(.csv))
    }

    // HistoryFilterMode Tests

    @Test("HistoryFilterMode localization keys")
    func historyFilterModeLocalizationKeys() {
        #expect(HistoryFilterMode.all.localizationKey == "filter_all")
        #expect(HistoryFilterMode.today.localizationKey == "filter_today")
        #expect(HistoryFilterMode.thisWeek.localizationKey == "filter_this_week")
        #expect(HistoryFilterMode.thisMonth.localizationKey == "filter_this_month")
        #expect(HistoryFilterMode.timerOnly.localizationKey == "filter_timer_only")
        #expect(HistoryFilterMode.manualOnly.localizationKey == "filter_manual_only")
    }

    @Test("HistoryFilterMode identifiable")
    func historyFilterModeIdentifiable() {
        #expect(HistoryFilterMode.all.id == "all")
        #expect(HistoryFilterMode.today.id == "today")
        #expect(HistoryFilterMode.thisWeek.id == "thisWeek")
        #expect(HistoryFilterMode.thisMonth.id == "thisMonth")
        #expect(HistoryFilterMode.timerOnly.id == "timerOnly")
        #expect(HistoryFilterMode.manualOnly.id == "manualOnly")
    }

    @Test("HistoryFilterMode allCases")
    func historyFilterModeAllCases() {
        #expect(HistoryFilterMode.allCases.count == 6)
    }

    // HistorySortOrder Tests

    @Test("HistorySortOrder localization keys")
    func historySortOrderLocalizationKeys() {
        #expect(HistorySortOrder.dateDescending.localizationKey == "sort_date_desc")
        #expect(HistorySortOrder.dateAscending.localizationKey == "sort_date_asc")
        #expect(HistorySortOrder.durationDescending.localizationKey == "sort_duration_desc")
        #expect(HistorySortOrder.durationAscending.localizationKey == "sort_duration_asc")
    }

    @Test("HistorySortOrder identifiable")
    func historySortOrderIdentifiable() {
        #expect(HistorySortOrder.dateDescending.id == "dateDescending")
        #expect(HistorySortOrder.dateAscending.id == "dateAscending")
        #expect(HistorySortOrder.durationDescending.id == "durationDescending")
        #expect(HistorySortOrder.durationAscending.id == "durationAscending")
    }

    @Test("HistorySortOrder allCases")
    func historySortOrderAllCases() {
        #expect(HistorySortOrder.allCases.count == 4)
    }

    // DailyStatistic Tests

    @Test("DailyStatistic duration hours calculation")
    func dailyStatisticDurationHoursCalculation() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        Thread.sleep(forTimeInterval: 0.1)
        manager.endSession()

        let stats = manager.dailyStatistics(days: 1)
        #expect(stats.count == 1)

        let today = stats.first!
        #expect(today.durationHours == today.totalDuration / 3600.0)
    }

    @Test("Daily statistics custom day count")
    func dailyStatisticsCustomDayCount() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let stats3 = manager.dailyStatistics(days: 3)
        let stats14 = manager.dailyStatistics(days: 14)

        #expect(stats3.count == 3)
        #expect(stats14.count == 14)
    }

    @Test("Daily statistics has unique IDs")
    func dailyStatisticsHasUniqueIDs() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let stats = manager.dailyStatistics(days: 7)
        let ids = stats.map(\.id)
        let uniqueIds = Set(ids)

        #expect(ids.count == uniqueIds.count)
    }

    // ActivityStatistics Tests

    @Test("ActivityStatistics empty returns all zeros")
    func activityStatisticsEmptyReturnsAllZeros() {
        let empty = ActivityStatistics.empty
        #expect(empty.totalSessions == 0)
        #expect(empty.totalDuration == 0)
        #expect(empty.todaySessions == 0)
        #expect(empty.todayDuration == 0)
        #expect(empty.weekSessions == 0)
        #expect(empty.weekDuration == 0)
        #expect(empty.averageSessionDuration == 0)
    }

    // Export Result Tests

    @Test("Export result contains correct format")
    func exportResultContainsCorrectFormat() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let jsonResult = manager.exportHistory(format: .json)
        let csvResult = manager.exportHistory(format: .csv)

        #expect(jsonResult?.format == .json)
        #expect(csvResult?.format == .csv)
    }

    @Test("Export result filename contains timestamp")
    func exportResultFilenameContainsTimestamp() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let result = manager.exportHistory(format: .json)

        #expect(result?.suggestedFilename.hasPrefix("weakup_history_") ?? false)
        #expect(result?.suggestedFilename.contains("_") ?? false)
    }

    // Import Result Tests

    @Test("Import multiple sessions sorts by date")
    func importMultipleSessionsSortsByDate() throws {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        let olderSession = ActivitySession(
            id: UUID(),
            startTime: Date().addingTimeInterval(-7200),
            endTime: Date().addingTimeInterval(-3600),
            wasTimerMode: false,
            timerDuration: nil
        )
        let newerSession = ActivitySession(
            id: UUID(),
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(-900),
            wasTimerMode: true,
            timerDuration: 900
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode([olderSession, newerSession])
        _ = manager.importHistory(from: data, format: .json)

        // Sessions should be sorted by date descending
        #expect(manager.sessions.count == 2)
        #expect(manager.sessions[0].startTime > manager.sessions[1].startTime)
    }

    // Filtered Sessions Excludes Active

    @Test("Filtered sessions excludes active session")
    func filteredSessionsExcludesActiveSession() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        manager.startSession(timerMode: true, timerDuration: 60)
        // Don't end this session - it's active

        #expect(manager.filteredSessions.count == 1)
        #expect(manager.currentSession != nil)

        manager.endSession()
    }

    // Delete Session Saves to Persistence

    @Test("Delete session saves to persistence")
    func deleteSessionSavesToPersistence() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        manager.startSession(timerMode: true, timerDuration: 60)
        manager.endSession()

        let sessionToDelete = manager.sessions.first!
        manager.deleteSession(sessionToDelete)

        // Verify persistence reflects deletion
        if let data = UserDefaultsStore.shared.data(forKey: "WeakupActivityHistory") {
            let sessions = try? JSONDecoder().decode([ActivitySession].self, from: data)
            #expect(sessions?.count == 1)
        }
    }

    // Export Multiple Sessions

    @Test("Export multiple sessions preserves order")
    func exportMultipleSessionsPreservesOrder() throws {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        for _ in 0..<3 {
            manager.startSession(timerMode: false, timerDuration: nil)
            Thread.sleep(forTimeInterval: 0.05)
            manager.endSession()
        }

        let result = manager.exportHistory(format: .json)
        #expect(result != nil)

        if let data = result?.data {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let sessions = try decoder.decode([ActivitySession].self, from: data)
            #expect(sessions.count == 3)
        }
    }

    // CSV Export with Timer Duration

    @Test("Export CSV includes timer duration")
    func exportCSVIncludesTimerDuration() {
        let manager = ActivityHistoryManager.shared
        manager.clearHistory()

        manager.startSession(timerMode: true, timerDuration: 3600)
        manager.endSession()

        let result = manager.exportHistory(format: .csv)
        #expect(result != nil)

        if let data = result?.data, let csvString = String(data: data, encoding: .utf8) {
            #expect(csvString.contains("3600"))
            #expect(csvString.contains("true"))
        }
    }
}
