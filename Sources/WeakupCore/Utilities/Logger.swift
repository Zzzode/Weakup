import Foundation
import os

// Logger

/// Centralized logging framework for the Weakup application.
/// Uses Apple's unified logging system (os.log) for efficient, privacy-aware logging.
public enum Logger {

    // Subsystem

    private static let subsystem = "com.weakup.app"

    // Categories

    private static let general = os.Logger(subsystem: subsystem, category: "general")
    private static let power = os.Logger(subsystem: subsystem, category: "power")
    private static let timer = os.Logger(subsystem: subsystem, category: "timer")
    private static let notifications = os.Logger(subsystem: subsystem, category: "notifications")
    private static let hotkey = os.Logger(subsystem: subsystem, category: "hotkey")
    private static let history = os.Logger(subsystem: subsystem, category: "history")
    private static let preferences = os.Logger(subsystem: subsystem, category: "preferences")

    // Log Levels

    /// Log a debug message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - category: The log category.
    public static func debug(_ message: String, category: Category = .general) {
        category.logger.debug("\(message, privacy: .public)")
    }

    /// Log an info message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - category: The log category.
    public static func info(_ message: String, category: Category = .general) {
        category.logger.info("\(message, privacy: .public)")
    }

    /// Log a warning message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - category: The log category.
    public static func warning(_ message: String, category: Category = .general) {
        category.logger.log(level: .default, "⚠️ \(message, privacy: .public)")
    }

    /// Log an error message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - category: The log category.
    public static func error(_ message: String, category: Category = .general) {
        category.logger.error("\(message, privacy: .public)")
    }

    /// Log an error with an Error object.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - error: The error object.
    ///   - category: The log category.
    public static func error(_ message: String, error: Error, category: Category = .general) {
        category.logger.error("\(message, privacy: .public): \(error.localizedDescription, privacy: .public)")
    }

    /// Log a fault (critical error).
    /// - Parameters:
    ///   - message: The message to log.
    ///   - category: The log category.
    public static func fault(_ message: String, category: Category = .general) {
        category.logger.fault("\(message, privacy: .public)")
    }

    // Category

    /// Log categories for organizing log messages.
    public enum Category {
        case general
        case power
        case timer
        case notifications
        case hotkey
        case history
        case preferences

        var logger: os.Logger {
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

// Convenience Extensions

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
