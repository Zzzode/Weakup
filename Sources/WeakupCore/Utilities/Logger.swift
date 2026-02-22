import Foundation
import os.log

// MARK: - Logger

/// Centralized logging framework for the Weakup application.
/// Uses Apple's unified logging system (os.log) for efficient, privacy-aware logging.
public enum Logger {

    // MARK: - Subsystem

    private static let subsystem = "com.weakup.app"

    // MARK: - Categories

    private static let general = OSLog(subsystem: subsystem, category: "general")
    private static let power = OSLog(subsystem: subsystem, category: "power")
    private static let timer = OSLog(subsystem: subsystem, category: "timer")
    private static let notifications = OSLog(subsystem: subsystem, category: "notifications")
    private static let hotkey = OSLog(subsystem: subsystem, category: "hotkey")
    private static let history = OSLog(subsystem: subsystem, category: "history")
    private static let preferences = OSLog(subsystem: subsystem, category: "preferences")

    // MARK: - Log Levels

    /// Log a debug message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - category: The log category.
    public static func debug(_ message: String, category: Category = .general) {
        os_log(.debug, log: category.osLog, "%{public}@", message)
    }

    /// Log an info message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - category: The log category.
    public static func info(_ message: String, category: Category = .general) {
        os_log(.info, log: category.osLog, "%{public}@", message)
    }

    /// Log a warning message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - category: The log category.
    public static func warning(_ message: String, category: Category = .general) {
        os_log(.default, log: category.osLog, "⚠️ %{public}@", message)
    }

    /// Log an error message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - category: The log category.
    public static func error(_ message: String, category: Category = .general) {
        os_log(.error, log: category.osLog, "%{public}@", message)
    }

    /// Log an error with an Error object.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - error: The error object.
    ///   - category: The log category.
    public static func error(_ message: String, error: Error, category: Category = .general) {
        os_log(.error, log: category.osLog, "%{public}@: %{public}@", message, error.localizedDescription)
    }

    /// Log a fault (critical error).
    /// - Parameters:
    ///   - message: The message to log.
    ///   - category: The log category.
    public static func fault(_ message: String, category: Category = .general) {
        os_log(.fault, log: category.osLog, "%{public}@", message)
    }

    // MARK: - Category

    /// Log categories for organizing log messages.
    public enum Category {
        case general
        case power
        case timer
        case notifications
        case hotkey
        case history
        case preferences

        var osLog: OSLog {
            switch self {
            case .general: Logger.general
            case .power: Logger.power
            case .timer: Logger.timer
            case .notifications: Logger.notifications
            case .hotkey: Logger.hotkey
            case .history: Logger.history
            case .preferences: Logger.preferences
            }
        }
    }
}

// MARK: - Convenience Extensions

extension Logger {

    /// Log power assertion creation.
    public static func powerAssertionCreated(id: UInt32) {
        info("Power assertion created with ID: \(id)", category: .power)
    }

    /// Log power assertion release.
    public static func powerAssertionReleased(id: UInt32) {
        info("Power assertion released with ID: \(id)", category: .power)
    }

    /// Log timer start.
    public static func timerStarted(duration: TimeInterval) {
        info("Timer started with duration: \(TimeFormatter.duration(duration))", category: .timer)
    }

    /// Log timer expiry.
    public static func timerExpired() {
        info("Timer expired", category: .timer)
    }

    /// Log notification scheduled.
    public static func notificationScheduled(identifier: String) {
        debug("Notification scheduled: \(identifier)", category: .notifications)
    }

    /// Log notification authorization status.
    public static func notificationAuthorizationStatus(granted: Bool) {
        info("Notification authorization: \(granted ? "granted" : "denied")", category: .notifications)
    }

    /// Log hotkey registration.
    public static func hotkeyRegistered(keyCode: UInt32, modifiers: UInt32) {
        info("Hotkey registered: keyCode=\(keyCode), modifiers=\(modifiers)", category: .hotkey)
    }

    /// Log hotkey conflict.
    public static func hotkeyConflict(message: String) {
        warning("Hotkey conflict: \(message)", category: .hotkey)
    }

    /// Log session start.
    public static func sessionStarted(timerMode: Bool) {
        info("Session started (timerMode: \(timerMode))", category: .history)
    }

    /// Log session end.
    public static func sessionEnded(duration: TimeInterval) {
        info("Session ended (duration: \(TimeFormatter.duration(duration)))", category: .history)
    }

    /// Log preference change.
    public static func preferenceChanged(key: String, value: Any) {
        debug("Preference changed: \(key) = \(value)", category: .preferences)
    }
}
