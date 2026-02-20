import Foundation

// MARK: - Activity History Manager

@MainActor
public final class ActivityHistoryManager: ObservableObject {
    public static let shared = ActivityHistoryManager()

    @Published public private(set) var sessions: [ActivitySession] = []
    @Published public private(set) var currentSession: ActivitySession?

    private let userDefaultsKey = "WeakupActivityHistory"
    private let maxStoredSessions = 100

    private init() {
        loadSessions()
    }

    // MARK: - Session Management

    public func startSession(timerMode: Bool, timerDuration: TimeInterval?) {
        let session = ActivitySession(
            startTime: Date(),
            wasTimerMode: timerMode,
            timerDuration: timerDuration
        )
        currentSession = session
    }

    public func endSession() {
        guard var session = currentSession else { return }
        session.end()
        sessions.insert(session, at: 0)
        currentSession = nil

        // Trim old sessions
        if sessions.count > maxStoredSessions {
            sessions = Array(sessions.prefix(maxStoredSessions))
        }

        saveSessions()
    }

    public func clearHistory() {
        sessions.removeAll()
        saveSessions()
    }

    // MARK: - Statistics

    public var statistics: ActivityStatistics {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now

        let completedSessions = sessions.filter { !$0.isActive }

        let todaySessions = completedSessions.filter { $0.startTime >= startOfToday }
        let weekSessions = completedSessions.filter { $0.startTime >= startOfWeek }

        let totalDuration = completedSessions.reduce(0) { $0 + $1.duration }
        let todayDuration = todaySessions.reduce(0) { $0 + $1.duration }
        let weekDuration = weekSessions.reduce(0) { $0 + $1.duration }

        let averageDuration = completedSessions.isEmpty ? 0 : totalDuration / Double(completedSessions.count)

        return ActivityStatistics(
            totalSessions: completedSessions.count,
            totalDuration: totalDuration,
            todaySessions: todaySessions.count,
            todayDuration: todayDuration,
            weekSessions: weekSessions.count,
            weekDuration: weekDuration,
            averageSessionDuration: averageDuration
        )
    }

    // MARK: - Persistence

    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            sessions = try JSONDecoder().decode([ActivitySession].self, from: data)
        } catch {
            // If decoding fails, start fresh
            sessions = []
        }
    }

    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            // Silently fail - not critical
        }
    }
}
