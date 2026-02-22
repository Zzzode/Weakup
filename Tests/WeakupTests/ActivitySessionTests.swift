import Foundation
import Testing
@testable import WeakupCore

@Suite("ActivitySession Tests")
struct ActivitySessionTests {

    // Initialization Tests

    @Test("Init sets default values")
    func initSetsDefaultValues() {
        let session = ActivitySession()
        #expect(session.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
        #expect(session.endTime == nil)
        #expect(!session.wasTimerMode)
        #expect(session.timerDuration == nil)
    }

    @Test("Init with custom values")
    func initWithCustomValues() {
        let startTime = Date()
        let session = ActivitySession(startTime: startTime, wasTimerMode: true, timerDuration: 3600)

        #expect(session.startTime == startTime)
        #expect(session.wasTimerMode)
        #expect(session.timerDuration == 3600)
    }

    @Test("Init generates unique IDs")
    func initGeneratesUniqueIds() {
        let session1 = ActivitySession()
        let session2 = ActivitySession()
        #expect(session1.id != session2.id)
    }

    // isActive Tests

    @Test("isActive is true when no end time")
    func isActiveTrueWhenNoEndTime() {
        let session = ActivitySession()
        #expect(session.isActive)
    }

    @Test("isActive is false after end")
    func isActiveFalseAfterEnd() {
        var session = ActivitySession()
        session.end()
        #expect(!session.isActive)
    }

    // Duration Tests

    @Test("Duration calculates from start to end")
    func durationCalculatesFromStartToEnd() {
        let startTime = Date().addingTimeInterval(-60) // 1 minute ago
        var session = ActivitySession(startTime: startTime)
        session.endTime = Date()

        #expect(abs(session.duration - 60) < 1)
    }

    @Test("Duration calculates from start to now when active")
    func durationCalculatesFromStartToNowWhenActive() {
        let startTime = Date().addingTimeInterval(-30) // 30 seconds ago
        let session = ActivitySession(startTime: startTime)

        #expect(abs(session.duration - 30) < 2)
    }

    // End Tests

    @Test("End sets end time")
    func endSetsEndTime() {
        var session = ActivitySession()
        #expect(session.endTime == nil)
        session.end()
        #expect(session.endTime != nil)
    }

    @Test("End time is now")
    func endTimeIsNow() {
        var session = ActivitySession()
        let beforeEnd = Date()
        session.end()
        let afterEnd = Date()

        #expect(session.endTime != nil)
        #expect(session.endTime! >= beforeEnd)
        #expect(session.endTime! <= afterEnd)
    }

    // Codable Tests

    @Test("Codable encodes and decodes")
    func codableEncodesAndDecodes() throws {
        let original = ActivitySession(wasTimerMode: true, timerDuration: 1800)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ActivitySession.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.wasTimerMode == original.wasTimerMode)
        #expect(decoded.timerDuration == original.timerDuration)
    }
}

// Activity Statistics Tests

@Suite("ActivityStatistics Tests")
struct ActivityStatisticsTests {

    @Test("Empty returns zero values")
    func emptyReturnsZeroValues() {
        let stats = ActivityStatistics.empty

        #expect(stats.totalSessions == 0)
        #expect(stats.totalDuration == 0)
        #expect(stats.todaySessions == 0)
        #expect(stats.todayDuration == 0)
        #expect(stats.weekSessions == 0)
        #expect(stats.weekDuration == 0)
        #expect(stats.averageSessionDuration == 0)
    }

    @Test("Init stores all values")
    func initStoresAllValues() {
        let stats = ActivityStatistics(
            totalSessions: 10,
            totalDuration: 3600,
            todaySessions: 2,
            todayDuration: 600,
            weekSessions: 5,
            weekDuration: 1800,
            averageSessionDuration: 360
        )

        #expect(stats.totalSessions == 10)
        #expect(stats.totalDuration == 3600)
        #expect(stats.todaySessions == 2)
        #expect(stats.todayDuration == 600)
        #expect(stats.weekSessions == 5)
        #expect(stats.weekDuration == 1800)
        #expect(stats.averageSessionDuration == 360)
    }
}
