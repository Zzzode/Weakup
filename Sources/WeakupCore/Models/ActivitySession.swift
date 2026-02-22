import Foundation

// Activity Session

/// Represents a single sleep prevention session.
///
/// An `ActivitySession` tracks when sleep prevention was activated, when it ended,
/// and whether it was using timer mode.
///
/// ## Properties
///
/// - `id`: Unique identifier for the session
/// - `startTime`: When the session started
/// - `endTime`: When the session ended (nil if still active)
/// - `wasTimerMode`: Whether timer mode was used
/// - `timerDuration`: The timer duration if timer mode was used
///
/// ## Computed Properties
///
/// - `duration`: The total duration of the session
/// - `isActive`: Whether the session is still ongoing
public struct ActivitySession: Codable, Identifiable, Sendable {
    /// Unique identifier for this session.
    public let id: UUID
    /// The time when sleep prevention was activated.
    public let startTime: Date
    /// The time when sleep prevention was deactivated (nil if still active).
    public var endTime: Date?
    /// Whether this session used timer mode.
    public var wasTimerMode: Bool
    /// The timer duration in seconds (if timer mode was used).
    public var timerDuration: TimeInterval?

    /// The duration of the session in seconds.
    ///
    /// For active sessions, returns the time elapsed since start.
    /// For completed sessions, returns the time between start and end.
    public var duration: TimeInterval {
        guard let end = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return end.timeIntervalSince(startTime)
    }

    /// Whether this session is still active (not yet ended).
    public var isActive: Bool {
        endTime == nil
    }

    /// Creates a new activity session.
    ///
    /// - Parameters:
    ///   - startTime: The start time (defaults to now).
    ///   - wasTimerMode: Whether timer mode is being used.
    ///   - timerDuration: The timer duration if timer mode is used.
    public init(startTime: Date = Date(), wasTimerMode: Bool = false, timerDuration: TimeInterval? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = nil
        self.wasTimerMode = wasTimerMode
        self.timerDuration = timerDuration
    }

    /// Creates an activity session with a specific ID (used for importing).
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the session.
    ///   - startTime: The start time of the session.
    ///   - endTime: The end time (nil if still active).
    ///   - wasTimerMode: Whether timer mode was used.
    ///   - timerDuration: The timer duration if timer mode was used.
    public init(id: UUID, startTime: Date, endTime: Date?, wasTimerMode: Bool, timerDuration: TimeInterval?) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.wasTimerMode = wasTimerMode
        self.timerDuration = timerDuration
    }

    /// Ends the session by setting the end time to now.
    public mutating func end() {
        endTime = Date()
    }
}

// Activity Statistics

/// Aggregated statistics about activity sessions.
///
/// Provides summary information about session counts and durations
/// for different time periods (today, this week, all time).
public struct ActivityStatistics: Sendable {
    /// Total number of completed sessions.
    public let totalSessions: Int
    /// Total duration of all sessions in seconds.
    public let totalDuration: TimeInterval
    /// Number of sessions started today.
    public let todaySessions: Int
    /// Total duration of today's sessions in seconds.
    public let todayDuration: TimeInterval
    /// Number of sessions started this week.
    public let weekSessions: Int
    /// Total duration of this week's sessions in seconds.
    public let weekDuration: TimeInterval
    /// Average duration per session in seconds.
    public let averageSessionDuration: TimeInterval

    /// An empty statistics instance with all values set to zero.
    public static var empty: ActivityStatistics {
        ActivityStatistics(
            totalSessions: 0,
            totalDuration: 0,
            todaySessions: 0,
            todayDuration: 0,
            weekSessions: 0,
            weekDuration: 0,
            averageSessionDuration: 0
        )
    }
}
