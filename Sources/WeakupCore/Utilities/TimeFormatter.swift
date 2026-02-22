import Foundation

// Time Formatter

/// Centralized time formatting utilities for consistent display across the app.
/// Provides various formats for duration display in different contexts.
public enum TimeFormatter {

    // Countdown Format (HH:MM:SS or MM:SS)

    /// Formats a time interval as a countdown string.
    /// - Parameter interval: The time interval in seconds.
    /// - Returns: Formatted string like "1:23:45" or "23:45".
    ///
    /// Examples:
    /// - 3661 seconds -> "1:01:01"
    /// - 125 seconds -> "02:05"
    /// - 0 seconds -> "00:00"
    public static func countdown(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Human-Readable Duration (Xh Ym)

    /// Formats a time interval as a human-readable duration string.
    /// - Parameter interval: The time interval in seconds.
    /// - Returns: Formatted string like "2h 30m" or "45m".
    ///
    /// Examples:
    /// - 9000 seconds -> "2h 30m"
    /// - 2700 seconds -> "45m"
    /// - 0 seconds -> "0m"
    public static func duration(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60

        if hours > 0, minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
        }
    }

    // Compact Duration (Xh Ym or HH:MM:SS)

    /// Formats a time interval for session history display.
    /// Uses HH:MM:SS format for precision.
    /// - Parameter interval: The time interval in seconds.
    /// - Returns: Formatted string like "1:23:45" or "23:45".
    ///
    /// Examples:
    /// - 3661 seconds -> "1:01:01"
    /// - 125 seconds -> "02:05"
    public static func sessionDuration(_ interval: TimeInterval) -> String {
        countdown(interval)
    }

    // Components

    public struct TimeComponents: Sendable {
        public let hours: Int
        public let minutes: Int
        public let seconds: Int
    }

    /// Extracts time components from a time interval.
    /// - Parameter interval: The time interval in seconds.
    /// - Returns: A tuple containing hours, minutes, and seconds.
    public static func components(from interval: TimeInterval) -> TimeComponents {
        let totalSeconds = max(0, Int(interval))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60
        return TimeComponents(hours: hours, minutes: minutes, seconds: seconds)
    }

    /// Creates a time interval from components.
    /// - Parameters:
    ///   - hours: Number of hours.
    ///   - minutes: Number of minutes.
    ///   - seconds: Number of seconds.
    /// - Returns: The total time interval in seconds.
    public static func interval(hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> TimeInterval {
        TimeInterval(hours * 3_600 + minutes * 60 + seconds)
    }
}
