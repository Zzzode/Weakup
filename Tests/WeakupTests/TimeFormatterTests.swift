import Foundation
import Testing
@testable import WeakupCore

@Suite("TimeFormatter Tests")
struct TimeFormatterTests {

    // MARK: - Countdown Tests (TF-001 to TF-010)

    @Suite("Countdown Format Tests")
    struct CountdownTests {

        @Test("Zero seconds returns 00:00")
        func countdownZeroSeconds() {
            let result = TimeFormatter.countdown(0)
            #expect(result == "00:00", "Zero seconds should return 00:00")
        }

        @Test("Seconds only formats correctly", arguments: [
            (1, "00:01"),
            (9, "00:09"),
            (10, "00:10"),
            (45, "00:45"),
            (59, "00:59")
        ])
        func countdownSecondsOnly(seconds: Int, expected: String) {
            let result = TimeFormatter.countdown(TimeInterval(seconds))
            #expect(result == expected, "Expected \(expected) for \(seconds) seconds")
        }

        @Test("Minutes and seconds formats correctly", arguments: [
            (60, "01:00"),
            (61, "01:01"),
            (90, "01:30"),
            (125, "02:05"),
            (599, "09:59"),
            (600, "10:00"),
            (3599, "59:59")
        ])
        func countdownMinutesAndSeconds(seconds: Int, expected: String) {
            let result = TimeFormatter.countdown(TimeInterval(seconds))
            #expect(result == expected, "Expected \(expected) for \(seconds) seconds")
        }

        @Test("Hours, minutes, and seconds formats correctly", arguments: [
            (3600, "1:00:00"),
            (3601, "1:00:01"),
            (3661, "1:01:01"),
            (7200, "2:00:00"),
            (7325, "2:02:05"),
            (86399, "23:59:59"),
            (86400, "24:00:00")
        ])
        func countdownHoursMinutesSeconds(seconds: Int, expected: String) {
            let result = TimeFormatter.countdown(TimeInterval(seconds))
            #expect(result == expected, "Expected \(expected) for \(seconds) seconds")
        }

        @Test("Negative values clamp to zero")
        func countdownNegativeValues() {
            #expect(TimeFormatter.countdown(-1) == "00:00", "Negative should clamp to 00:00")
            #expect(TimeFormatter.countdown(-100) == "00:00", "Negative should clamp to 00:00")
            #expect(TimeFormatter.countdown(-3600) == "00:00", "Negative should clamp to 00:00")
        }

        @Test("Fractional seconds are truncated")
        func countdownFractionalSeconds() {
            #expect(TimeFormatter.countdown(1.9) == "00:01", "1.9 should truncate to 1")
            #expect(TimeFormatter.countdown(59.999) == "00:59", "59.999 should truncate to 59")
            #expect(TimeFormatter.countdown(60.5) == "01:00", "60.5 should truncate to 60")
        }

        @Test("Large values format correctly")
        func countdownLargeValues() {
            // 100 hours
            let result = TimeFormatter.countdown(360000)
            #expect(result == "100:00:00", "100 hours should format correctly")
        }
    }

    // MARK: - Duration Tests (TF-011 to TF-020)

    @Suite("Duration Format Tests")
    struct DurationTests {

        @Test("Zero seconds returns 0m")
        func durationZeroSeconds() {
            let result = TimeFormatter.duration(0)
            #expect(result == "0m", "Zero seconds should return 0m")
        }

        @Test("Less than a minute returns 0m")
        func durationLessThanMinute() {
            #expect(TimeFormatter.duration(1) == "0m", "1 second should return 0m")
            #expect(TimeFormatter.duration(30) == "0m", "30 seconds should return 0m")
            #expect(TimeFormatter.duration(59) == "0m", "59 seconds should return 0m")
        }

        @Test("Minutes only formats correctly", arguments: [
            (60, "1m"),
            (120, "2m"),
            (300, "5m"),
            (900, "15m"),
            (1800, "30m"),
            (2700, "45m"),
            (3540, "59m")
        ])
        func durationMinutesOnly(seconds: Int, expected: String) {
            let result = TimeFormatter.duration(TimeInterval(seconds))
            #expect(result == expected, "Expected \(expected) for \(seconds) seconds")
        }

        @Test("Hours only formats correctly", arguments: [
            (3600, "1h"),
            (7200, "2h"),
            (36000, "10h"),
            (86400, "24h")
        ])
        func durationHoursOnly(seconds: Int, expected: String) {
            let result = TimeFormatter.duration(TimeInterval(seconds))
            #expect(result == expected, "Expected \(expected) for \(seconds) seconds")
        }

        @Test("Hours and minutes formats correctly", arguments: [
            (3660, "1h 1m"),
            (5400, "1h 30m"),
            (9000, "2h 30m"),
            (5940, "1h 39m"),
            (90000, "25h 0m")
        ])
        func durationHoursAndMinutes(seconds: Int, expected: String) {
            let result = TimeFormatter.duration(TimeInterval(seconds))
            // Note: 25h 0m case - when hours > 0 but minutes == 0, it should return "25h"
            if seconds == 90000 {
                #expect(result == "25h", "25 hours with 0 minutes should return 25h")
            } else {
                #expect(result == expected, "Expected \(expected) for \(seconds) seconds")
            }
        }

        @Test("Negative values clamp to zero")
        func durationNegativeValues() {
            #expect(TimeFormatter.duration(-1) == "0m", "Negative should return 0m")
            #expect(TimeFormatter.duration(-3600) == "0m", "Negative should return 0m")
        }

        @Test("Fractional seconds are truncated")
        func durationFractionalSeconds() {
            #expect(TimeFormatter.duration(59.9) == "0m", "59.9 should truncate to 59, returning 0m")
            #expect(TimeFormatter.duration(60.9) == "1m", "60.9 should truncate to 60, returning 1m")
        }

        @Test("Seconds are ignored in duration format")
        func durationIgnoresSeconds() {
            // Duration only shows hours and minutes, seconds are dropped
            #expect(TimeFormatter.duration(3601) == "1h", "3601s = 1h 0m 1s should return 1h")
            #expect(TimeFormatter.duration(3659) == "1h", "3659s = 1h 0m 59s should return 1h")
            #expect(TimeFormatter.duration(3661) == "1h 1m", "3661s = 1h 1m 1s should return 1h 1m")
        }
    }

    // MARK: - Session Duration Tests (TF-021 to TF-025)

    @Suite("Session Duration Tests")
    struct SessionDurationTests {

        @Test("Session duration delegates to countdown")
        func sessionDurationDelegatesToCountdown() {
            // sessionDuration should return the same as countdown
            let testValues: [TimeInterval] = [0, 45, 125, 3661, 86400]
            for value in testValues {
                let sessionResult = TimeFormatter.sessionDuration(value)
                let countdownResult = TimeFormatter.countdown(value)
                #expect(sessionResult == countdownResult, "sessionDuration should match countdown for \(value)")
            }
        }

        @Test("Session duration formats examples correctly", arguments: [
            (0, "00:00"),
            (125, "02:05"),
            (3661, "1:01:01")
        ])
        func sessionDurationExamples(seconds: Int, expected: String) {
            let result = TimeFormatter.sessionDuration(TimeInterval(seconds))
            #expect(result == expected, "Expected \(expected) for \(seconds) seconds")
        }
    }

    // MARK: - Components Tests (TF-026 to TF-035)

    @Suite("Components Tests")
    struct ComponentsTests {

        @Test("Components from zero seconds")
        func componentsFromZero() {
            let components = TimeFormatter.components(from: 0)
            #expect(components.hours == 0)
            #expect(components.minutes == 0)
            #expect(components.seconds == 0)
        }

        @Test("Components from seconds only", arguments: [
            (1, 0, 0, 1),
            (30, 0, 0, 30),
            (59, 0, 0, 59)
        ])
        func componentsFromSecondsOnly(input: Int, expectedHours: Int, expectedMinutes: Int, expectedSeconds: Int) {
            let components = TimeFormatter.components(from: TimeInterval(input))
            #expect(components.hours == expectedHours)
            #expect(components.minutes == expectedMinutes)
            #expect(components.seconds == expectedSeconds)
        }

        @Test("Components from minutes and seconds", arguments: [
            (60, 0, 1, 0),
            (90, 0, 1, 30),
            (125, 0, 2, 5),
            (3599, 0, 59, 59)
        ])
        func componentsFromMinutesAndSeconds(input: Int, expectedHours: Int, expectedMinutes: Int, expectedSeconds: Int) {
            let components = TimeFormatter.components(from: TimeInterval(input))
            #expect(components.hours == expectedHours)
            #expect(components.minutes == expectedMinutes)
            #expect(components.seconds == expectedSeconds)
        }

        @Test("Components from hours, minutes, and seconds", arguments: [
            (3600, 1, 0, 0),
            (3661, 1, 1, 1),
            (7325, 2, 2, 5),
            (86399, 23, 59, 59),
            (86400, 24, 0, 0)
        ])
        func componentsFromHoursMinutesSeconds(input: Int, expectedHours: Int, expectedMinutes: Int, expectedSeconds: Int) {
            let components = TimeFormatter.components(from: TimeInterval(input))
            #expect(components.hours == expectedHours)
            #expect(components.minutes == expectedMinutes)
            #expect(components.seconds == expectedSeconds)
        }

        @Test("Components from negative values clamp to zero")
        func componentsFromNegative() {
            let components = TimeFormatter.components(from: -100)
            #expect(components.hours == 0)
            #expect(components.minutes == 0)
            #expect(components.seconds == 0)
        }

        @Test("Components from fractional seconds truncate")
        func componentsFromFractional() {
            let components = TimeFormatter.components(from: 61.9)
            #expect(components.hours == 0)
            #expect(components.minutes == 1)
            #expect(components.seconds == 1, "61.9 should truncate to 61 seconds = 1m 1s")
        }

        @Test("Components from large values")
        func componentsFromLargeValues() {
            // 100 hours
            let components = TimeFormatter.components(from: 360000)
            #expect(components.hours == 100)
            #expect(components.minutes == 0)
            #expect(components.seconds == 0)
        }

        @Test("TimeComponents is Sendable")
        func timeComponentsIsSendable() {
            let components = TimeFormatter.components(from: 3661)
            // This test verifies that TimeComponents can be used in concurrent contexts
            let _: any Sendable = components
            #expect(components.hours == 1)
        }
    }

    // MARK: - Interval Tests (TF-036 to TF-045)

    @Suite("Interval Tests")
    struct IntervalTests {

        @Test("Interval from zero components")
        func intervalFromZero() {
            let interval = TimeFormatter.interval(hours: 0, minutes: 0, seconds: 0)
            #expect(interval == 0)
        }

        @Test("Interval from seconds only", arguments: [
            (0, 0, 1, 1.0),
            (0, 0, 30, 30.0),
            (0, 0, 59, 59.0)
        ])
        func intervalFromSecondsOnly(hours: Int, minutes: Int, seconds: Int, expected: TimeInterval) {
            let interval = TimeFormatter.interval(hours: hours, minutes: minutes, seconds: seconds)
            #expect(interval == expected)
        }

        @Test("Interval from minutes only", arguments: [
            (0, 1, 0, 60.0),
            (0, 30, 0, 1800.0),
            (0, 59, 0, 3540.0)
        ])
        func intervalFromMinutesOnly(hours: Int, minutes: Int, seconds: Int, expected: TimeInterval) {
            let interval = TimeFormatter.interval(hours: hours, minutes: minutes, seconds: seconds)
            #expect(interval == expected)
        }

        @Test("Interval from hours only", arguments: [
            (1, 0, 0, 3600.0),
            (2, 0, 0, 7200.0),
            (24, 0, 0, 86400.0)
        ])
        func intervalFromHoursOnly(hours: Int, minutes: Int, seconds: Int, expected: TimeInterval) {
            let interval = TimeFormatter.interval(hours: hours, minutes: minutes, seconds: seconds)
            #expect(interval == expected)
        }

        @Test("Interval from mixed components", arguments: [
            (1, 1, 1, 3661.0),
            (2, 30, 45, 9045.0),
            (0, 2, 5, 125.0)
        ])
        func intervalFromMixedComponents(hours: Int, minutes: Int, seconds: Int, expected: TimeInterval) {
            let interval = TimeFormatter.interval(hours: hours, minutes: minutes, seconds: seconds)
            #expect(interval == expected)
        }

        @Test("Interval uses default parameters")
        func intervalDefaultParameters() {
            // Test that default parameters work
            #expect(TimeFormatter.interval() == 0)
            #expect(TimeFormatter.interval(hours: 1) == 3600)
            #expect(TimeFormatter.interval(minutes: 30) == 1800)
            #expect(TimeFormatter.interval(seconds: 45) == 45)
            #expect(TimeFormatter.interval(hours: 1, minutes: 30) == 5400)
            #expect(TimeFormatter.interval(minutes: 30, seconds: 30) == 1830)
        }

        @Test("Interval handles negative inputs")
        func intervalNegativeInputs() {
            // The function doesn't clamp negative inputs, it calculates them
            let interval = TimeFormatter.interval(hours: -1, minutes: 0, seconds: 0)
            #expect(interval == -3600, "Negative hours should produce negative interval")
        }

        @Test("Interval handles overflow values")
        func intervalOverflowValues() {
            // Values that overflow their normal range
            let interval = TimeFormatter.interval(hours: 0, minutes: 90, seconds: 0)
            #expect(interval == 5400, "90 minutes should equal 5400 seconds")

            let interval2 = TimeFormatter.interval(hours: 0, minutes: 0, seconds: 120)
            #expect(interval2 == 120, "120 seconds should equal 120 seconds")
        }
    }

    // MARK: - Round Trip Tests (TF-046 to TF-050)

    @Suite("Round Trip Tests")
    struct RoundTripTests {

        @Test("Components and interval round trip", arguments: [0, 1, 60, 125, 3600, 3661, 86400])
        func componentsIntervalRoundTrip(seconds: Int) {
            let original = TimeInterval(seconds)
            let components = TimeFormatter.components(from: original)
            let reconstructed = TimeFormatter.interval(
                hours: components.hours,
                minutes: components.minutes,
                seconds: components.seconds
            )
            #expect(reconstructed == original, "Round trip should preserve value for \(seconds) seconds")
        }

        @Test("Interval and components round trip")
        func intervalComponentsRoundTrip() {
            let testCases: [(Int, Int, Int)] = [
                (0, 0, 0),
                (0, 0, 45),
                (0, 30, 0),
                (1, 0, 0),
                (1, 30, 45),
                (23, 59, 59)
            ]

            for (hours, minutes, seconds) in testCases {
                let interval = TimeFormatter.interval(hours: hours, minutes: minutes, seconds: seconds)
                let components = TimeFormatter.components(from: interval)
                #expect(components.hours == hours, "Hours should match for \(hours):\(minutes):\(seconds)")
                #expect(components.minutes == minutes, "Minutes should match for \(hours):\(minutes):\(seconds)")
                #expect(components.seconds == seconds, "Seconds should match for \(hours):\(minutes):\(seconds)")
            }
        }
    }

    // MARK: - Edge Case Tests (TF-051 to TF-055)

    @Suite("Edge Case Tests")
    struct EdgeCaseTests {

        @Test("Very large time intervals")
        func veryLargeIntervals() {
            // 1000 hours
            let largeInterval: TimeInterval = 3_600_000
            let countdown = TimeFormatter.countdown(largeInterval)
            let components = TimeFormatter.components(from: largeInterval)

            #expect(countdown == "1000:00:00")
            #expect(components.hours == 1000)
            #expect(components.minutes == 0)
            #expect(components.seconds == 0)
        }

        @Test("Boundary values at minute transitions")
        func boundaryMinuteTransitions() {
            #expect(TimeFormatter.countdown(59) == "00:59")
            #expect(TimeFormatter.countdown(60) == "01:00")
            #expect(TimeFormatter.countdown(61) == "01:01")
        }

        @Test("Boundary values at hour transitions")
        func boundaryHourTransitions() {
            #expect(TimeFormatter.countdown(3599) == "59:59")
            #expect(TimeFormatter.countdown(3600) == "1:00:00")
            #expect(TimeFormatter.countdown(3601) == "1:00:01")
        }

        @Test("Duration boundary at hour with no minutes")
        func durationBoundaryHourNoMinutes() {
            // When hours > 0 but minutes == 0, should return "Xh" not "Xh 0m"
            #expect(TimeFormatter.duration(3600) == "1h")
            #expect(TimeFormatter.duration(7200) == "2h")
        }

        @Test("All formatters handle same input consistently")
        func formattersConsistency() {
            let testValue: TimeInterval = 3661 // 1h 1m 1s

            let countdown = TimeFormatter.countdown(testValue)
            let duration = TimeFormatter.duration(testValue)
            let session = TimeFormatter.sessionDuration(testValue)
            let components = TimeFormatter.components(from: testValue)

            #expect(countdown == "1:01:01")
            #expect(duration == "1h 1m")
            #expect(session == countdown)
            #expect(components.hours == 1)
            #expect(components.minutes == 1)
            #expect(components.seconds == 1)
        }
    }
}
