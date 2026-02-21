import Foundation

// Activity Session

public struct ActivitySession: Codable, Identifiable, Sendable {
    public let id: UUID
    public let startTime: Date
    public var endTime: Date?
    public var wasTimerMode: Bool
    public var timerDuration: TimeInterval?

    public var duration: TimeInterval {
        guard let end = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return end.timeIntervalSince(startTime)
    }

    public var isActive: Bool {
        endTime == nil
    }

    public init(startTime: Date = Date(), wasTimerMode: Bool = false, timerDuration: TimeInterval? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = nil
        self.wasTimerMode = wasTimerMode
        self.timerDuration = timerDuration
    }

    public mutating func end() {
        endTime = Date()
    }
}

// Activity Statistics

public struct ActivityStatistics: Sendable {
    public let totalSessions: Int
    public let totalDuration: TimeInterval
    public let todaySessions: Int
    public let todayDuration: TimeInterval
    public let weekSessions: Int
    public let weekDuration: TimeInterval
    public let averageSessionDuration: TimeInterval

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
