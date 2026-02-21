import XCTest
@testable import WeakupCore

final class ActivitySessionTests: XCTestCase {

    // Initialization Tests

    func testInit_setsDefaultValues() {
        let session = ActivitySession()
        XCTAssertNotNil(session.id)
        XCTAssertNil(session.endTime)
        XCTAssertFalse(session.wasTimerMode)
        XCTAssertNil(session.timerDuration)
    }

    func testInit_withCustomValues() {
        let startTime = Date()
        let session = ActivitySession(startTime: startTime, wasTimerMode: true, timerDuration: 3600)

        XCTAssertEqual(session.startTime, startTime)
        XCTAssertTrue(session.wasTimerMode)
        XCTAssertEqual(session.timerDuration, 3600)
    }

    func testInit_generatesUniqueIds() {
        let session1 = ActivitySession()
        let session2 = ActivitySession()
        XCTAssertNotEqual(session1.id, session2.id)
    }

    // isActive Tests

    func testIsActive_trueWhenNoEndTime() {
        let session = ActivitySession()
        XCTAssertTrue(session.isActive)
    }

    func testIsActive_falseAfterEnd() {
        var session = ActivitySession()
        session.end()
        XCTAssertFalse(session.isActive)
    }

    // Duration Tests

    func testDuration_calculatesFromStartToEnd() {
        let startTime = Date().addingTimeInterval(-60) // 1 minute ago
        var session = ActivitySession(startTime: startTime)
        session.endTime = Date()

        XCTAssertEqual(session.duration, 60, accuracy: 1)
    }

    func testDuration_calculatesFromStartToNowWhenActive() {
        let startTime = Date().addingTimeInterval(-30) // 30 seconds ago
        let session = ActivitySession(startTime: startTime)

        XCTAssertEqual(session.duration, 30, accuracy: 2)
    }

    // End Tests

    func testEnd_setsEndTime() {
        var session = ActivitySession()
        XCTAssertNil(session.endTime)
        session.end()
        XCTAssertNotNil(session.endTime)
    }

    func testEnd_endTimeIsNow() {
        var session = ActivitySession()
        let beforeEnd = Date()
        session.end()
        let afterEnd = Date()

        XCTAssertNotNil(session.endTime)
        XCTAssertGreaterThanOrEqual(session.endTime!, beforeEnd)
        XCTAssertLessThanOrEqual(session.endTime!, afterEnd)
    }

    // Codable Tests

    func testCodable_encodesAndDecodes() throws {
        let original = ActivitySession(wasTimerMode: true, timerDuration: 1800)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ActivitySession.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.wasTimerMode, original.wasTimerMode)
        XCTAssertEqual(decoded.timerDuration, original.timerDuration)
    }
}

// Activity Statistics Tests

final class ActivityStatisticsTests: XCTestCase {

    func testEmpty_returnsZeroValues() {
        let stats = ActivityStatistics.empty

        XCTAssertEqual(stats.totalSessions, 0)
        XCTAssertEqual(stats.totalDuration, 0)
        XCTAssertEqual(stats.todaySessions, 0)
        XCTAssertEqual(stats.todayDuration, 0)
        XCTAssertEqual(stats.weekSessions, 0)
        XCTAssertEqual(stats.weekDuration, 0)
        XCTAssertEqual(stats.averageSessionDuration, 0)
    }

    func testInit_storesAllValues() {
        let stats = ActivityStatistics(
            totalSessions: 10,
            totalDuration: 3600,
            todaySessions: 2,
            todayDuration: 600,
            weekSessions: 5,
            weekDuration: 1800,
            averageSessionDuration: 360
        )

        XCTAssertEqual(stats.totalSessions, 10)
        XCTAssertEqual(stats.totalDuration, 3600)
        XCTAssertEqual(stats.todaySessions, 2)
        XCTAssertEqual(stats.todayDuration, 600)
        XCTAssertEqual(stats.weekSessions, 5)
        XCTAssertEqual(stats.weekDuration, 1800)
        XCTAssertEqual(stats.averageSessionDuration, 360)
    }
}
