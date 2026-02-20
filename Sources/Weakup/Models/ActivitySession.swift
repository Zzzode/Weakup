import Foundation

// MARK: - Activity Session

struct ActivitySession: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var wasTimerMode: Bool
    var timerDuration: TimeInterval?

    var duration: TimeInterval {
        guard let end = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return end.timeIntervalSince(startTime)
    }

    var isActive: Bool {
        endTime == nil
    }

    init(startTime: Date = Date(), wasTimerMode: Bool = false, timerDuration: TimeInterval? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = nil
        self.wasTimerMode = wasTimerMode
        self.timerDuration = timerDuration
    }

    mutating func end() {
        endTime = Date()
    }
}

// MARK: - Activity Statistics

struct ActivityStatistics {
    let totalSessions: Int
    let totalDuration: TimeInterval
    let todaySessions: Int
    let todayDuration: TimeInterval
    let weekSessions: Int
    let weekDuration: TimeInterval
    let averageSessionDuration: TimeInterval

    static var empty: ActivityStatistics {
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
