import Foundation

// MARK: - Export Format

/// Supported formats for exporting activity history.
public enum ExportFormat: String, CaseIterable, Identifiable, Sendable {
    case json
    case csv

    public var id: String {
        rawValue
    }

    public var fileExtension: String {
        rawValue
    }

    public var displayName: String {
        switch self {
        case .json: "JSON"
        case .csv: "CSV"
        }
    }

    public var contentType: String {
        switch self {
        case .json: "application/json"
        case .csv: "text/csv"
        }
    }
}

// MARK: - Export Result

/// Contains the result of an export operation.
public struct ExportResult: Sendable {
    /// The exported data.
    public let data: Data
    /// A suggested filename for saving the export.
    public let suggestedFilename: String
    /// The format of the exported data.
    public let format: ExportFormat
}

// MARK: - Import Result

/// The result of an import operation.
public enum ImportResult: Sendable {
    /// Import succeeded with counts of imported and skipped sessions.
    case success(imported: Int, skipped: Int)
    /// Import failed with an error message.
    case failure(String)
}

// MARK: - Activity History Manager

/// Manages the history of sleep prevention sessions.
///
/// `ActivityHistoryManager` tracks when sleep prevention is activated and deactivated,
/// stores session history, and provides statistics and export/import functionality.
///
/// ## Features
///
/// - Session tracking with start/end times
/// - Statistics (today, this week, total, average)
/// - Filtering and sorting
/// - Export to JSON or CSV
/// - Import from JSON or CSV
///
/// ## Usage
///
/// ```swift
/// // Start a session
/// ActivityHistoryManager.shared.startSession(timerMode: true, timerDuration: 3600)
///
/// // End the session
/// ActivityHistoryManager.shared.endSession()
///
/// // Get statistics
/// let stats = ActivityHistoryManager.shared.statistics
/// print("Total sessions: \(stats.totalSessions)")
///
/// // Export history
/// if let result = ActivityHistoryManager.shared.exportHistory(format: .json) {
///     // Save result.data to file
/// }
/// ```
///
/// ## Thread Safety
///
/// This class is marked with `@MainActor` and all public methods must be called from the main thread.
@MainActor
public final class ActivityHistoryManager: ObservableObject {
    /// The shared singleton instance.
    public static let shared = ActivityHistoryManager()

    @Published public private(set) var sessions: [ActivitySession] = []
    @Published public private(set) var currentSession: ActivitySession?
    @Published public var searchText: String = ""
    @Published public var filterMode: HistoryFilterMode = .all
    @Published public var sortOrder: HistorySortOrder = .dateDescending

    private let maxStoredSessions = AppConstants.maxStoredSessions

    private init() {
        loadSessions()
    }

    // Filtered and Sorted Sessions

    public var filteredSessions: [ActivitySession] {
        var result = sessions.filter { !$0.isActive }

        // Apply filter
        let calendar = Calendar.current
        let now = Date()

        switch filterMode {
        case .all:
            break
        case .today:
            let startOfToday = calendar.startOfDay(for: now)
            result = result.filter { $0.startTime >= startOfToday }
        case .thisWeek:
            let startOfWeek =
                calendar.date(
                    from: calendar.dateComponents(
                        [.yearForWeekOfYear, .weekOfYear],
                        from: now
                    )
                ) ?? now
            result = result.filter { $0.startTime >= startOfWeek }
        case .thisMonth:
            let startOfMonth =
                calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            result = result.filter { $0.startTime >= startOfMonth }
        case .timerOnly:
            result = result.filter(\.wasTimerMode)
        case .manualOnly:
            result = result.filter { !$0.wasTimerMode }
        }

        // Apply search
        if !searchText.isEmpty {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            result = result.filter { session in
                let dateString = formatter.string(from: session.startTime).lowercased()
                return dateString.contains(searchText.lowercased())
            }
        }

        // Apply sort
        switch sortOrder {
        case .dateDescending:
            result.sort { $0.startTime > $1.startTime }
        case .dateAscending:
            result.sort { $0.startTime < $1.startTime }
        case .durationDescending:
            result.sort { $0.duration > $1.duration }
        case .durationAscending:
            result.sort { $0.duration < $1.duration }
        }

        return result
    }

    // Session Management

    public func startSession(timerMode: Bool, timerDuration: TimeInterval?) {
        let session = ActivitySession(
            startTime: Date(),
            wasTimerMode: timerMode,
            timerDuration: timerDuration
        )
        currentSession = session
        Logger.sessionStarted(timerMode: timerMode)
    }

    public func endSession() {
        guard var session = currentSession else { return }
        session.end()
        Logger.sessionEnded(duration: session.duration)
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

    // Statistics

    public var statistics: ActivityStatistics {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfWeek =
            calendar
                .date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
                ?? now

        let completedSessions = sessions.filter { !$0.isActive }

        let todaySessions = completedSessions.filter { $0.startTime >= startOfToday }
        let weekSessions = completedSessions.filter { $0.startTime >= startOfWeek }

        let totalDuration = completedSessions.reduce(0) { $0 + $1.duration }
        let todayDuration = todaySessions.reduce(0) { $0 + $1.duration }
        let weekDuration = weekSessions.reduce(0) { $0 + $1.duration }

        let averageDuration =
            completedSessions.isEmpty ? 0 : totalDuration / Double(completedSessions.count)

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

    // Persistence

    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.activityHistory) else {
            return
        }
        do {
            sessions = try JSONDecoder().decode([ActivitySession].self, from: data)
            Logger.debug("Loaded \(sessions.count) sessions from history", category: .history)
        } catch {
            Logger.error("Failed to decode activity history", error: error, category: .history)
            sessions = []
        }
    }

    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.activityHistory)
        } catch {
            Logger.error("Failed to save activity history", error: error, category: .history)
        }
    }

    // Export

    public func exportHistory(format: ExportFormat) -> ExportResult? {
        let completedSessions = sessions.filter { !$0.isActive }

        guard !completedSessions.isEmpty else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "weakup_history_\(timestamp).\(format.fileExtension)"

        switch format {
        case .json:
            return exportAsJSON(sessions: completedSessions, filename: filename)
        case .csv:
            return exportAsCSV(sessions: completedSessions, filename: filename)
        }
    }

    private func exportAsJSON(sessions: [ActivitySession], filename: String) -> ExportResult? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(sessions)
            return ExportResult(data: data, suggestedFilename: filename, format: .json)
        } catch {
            return nil
        }
    }

    private func exportAsCSV(sessions: [ActivitySession], filename: String) -> ExportResult? {
        var csvContent =
            "ID,Start Time,End Time,Duration (seconds),Was Timer Mode,Timer Duration (seconds)\n"

        let dateFormatter = ISO8601DateFormatter()

        for session in sessions {
            let startTime = dateFormatter.string(from: session.startTime)
            let endTime = session.endTime.map { dateFormatter.string(from: $0) } ?? ""
            let duration = Int(session.duration)
            let timerDuration = session.timerDuration.map { String(Int($0)) } ?? ""

            csvContent +=
                "\(session.id.uuidString),\(startTime),\(endTime),\(duration),\(session.wasTimerMode),\(timerDuration)\n"
        }

        guard let data = csvContent.data(using: .utf8) else { return nil }
        return ExportResult(data: data, suggestedFilename: filename, format: .csv)
    }

    // Import

    public func importHistory(from data: Data, format: ExportFormat) -> ImportResult {
        switch format {
        case .json:
            importFromJSON(data: data)
        case .csv:
            importFromCSV(data: data)
        }
    }

    private func importFromJSON(data: Data) -> ImportResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let importedSessions = try decoder.decode([ActivitySession].self, from: data)
            return mergeImportedSessions(importedSessions)
        } catch {
            return .failure("Invalid JSON format: \(error.localizedDescription)")
        }
    }

    private func importFromCSV(data: Data) -> ImportResult {
        guard let csvString = String(data: data, encoding: .utf8) else {
            return .failure("Unable to read CSV data")
        }

        let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else {
            return .failure("CSV file is empty or has no data rows")
        }

        let dateFormatter = ISO8601DateFormatter()
        var importedSessions: [ActivitySession] = []

        for line in lines.dropFirst() {
            let columns = parseCSVLine(line)
            guard columns.count >= 5 else { continue }

            let sessionId = UUID(uuidString: columns[0])
            let startTime = dateFormatter.date(from: columns[1])
            guard let sessionId, let startTime else {
                continue
            }

            let endTime = columns[2].isEmpty ? nil : dateFormatter.date(from: columns[2])
            let wasTimerMode = columns[4].lowercased() == "true"
            let timerDuration =
                columns.count > 5 && !columns[5].isEmpty ? TimeInterval(columns[5]) : nil

            let session = ActivitySession(
                id: sessionId,
                startTime: startTime,
                endTime: endTime,
                wasTimerMode: wasTimerMode,
                timerDuration: timerDuration
            )
            importedSessions.append(session)
        }

        return mergeImportedSessions(importedSessions)
    }

    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false

        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == ",", !inQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)

        return result
    }

    private func mergeImportedSessions(_ importedSessions: [ActivitySession]) -> ImportResult {
        let existingIds = Set(sessions.map(\.id))
        var imported = 0
        var skipped = 0

        for session in importedSessions {
            if existingIds.contains(session.id) {
                skipped += 1
            } else {
                sessions.append(session)
                imported += 1
            }
        }

        // Sort by date descending
        sessions.sort { $0.startTime > $1.startTime }

        // Trim if needed
        if sessions.count > maxStoredSessions {
            sessions = Array(sessions.prefix(maxStoredSessions))
        }

        saveSessions()

        return .success(imported: imported, skipped: skipped)
    }

    // Daily Statistics for Chart

    public func dailyStatistics(days: Int = 7) -> [DailyStatistic] {
        let calendar = Calendar.current
        let now = Date()
        var result: [DailyStatistic] = []

        for dayOffset in (0..<days).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else {
                continue
            }
            let startOfDay = calendar.startOfDay(for: date)
            guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
                continue
            }

            let daySessions = sessions.filter { session in
                !session.isActive && session.startTime >= startOfDay && session.startTime < endOfDay
            }

            let totalDuration = daySessions.reduce(0) { $0 + $1.duration }

            result.append(
                DailyStatistic(
                    date: startOfDay,
                    sessionCount: daySessions.count,
                    totalDuration: totalDuration
                )
            )
        }

        return result
    }

    // Delete Single Session

    public func deleteSession(_ session: ActivitySession) {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
    }
}

// Filter Mode

public enum HistoryFilterMode: String, CaseIterable, Identifiable {
    case all
    case today
    case thisWeek
    case thisMonth
    case timerOnly
    case manualOnly

    public var id: String {
        rawValue
    }

    public var localizationKey: String {
        switch self {
        case .all: "filter_all"
        case .today: "filter_today"
        case .thisWeek: "filter_this_week"
        case .thisMonth: "filter_this_month"
        case .timerOnly: "filter_timer_only"
        case .manualOnly: "filter_manual_only"
        }
    }
}

// Sort Order

public enum HistorySortOrder: String, CaseIterable, Identifiable {
    case dateDescending
    case dateAscending
    case durationDescending
    case durationAscending

    public var id: String {
        rawValue
    }

    public var localizationKey: String {
        switch self {
        case .dateDescending: "sort_date_desc"
        case .dateAscending: "sort_date_asc"
        case .durationDescending: "sort_duration_desc"
        case .durationAscending: "sort_duration_asc"
        }
    }
}

// Daily Statistic

public struct DailyStatistic: Identifiable, Sendable {
    public let id = UUID()
    public let date: Date
    public let sessionCount: Int
    public let totalDuration: TimeInterval

    public var durationHours: Double {
        totalDuration / 3_600.0
    }
}
