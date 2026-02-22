import Foundation

// App Constants

/// Application-wide constants and configuration values.
public enum AppConstants {

    // Timer Presets

    /// Preset timer durations in seconds.
    public enum TimerPresets {
        /// Timer disabled (0 seconds).
        public static let off: TimeInterval = 0

        /// 15 minutes in seconds.
        public static let fifteenMinutes: TimeInterval = 900

        /// 30 minutes in seconds.
        public static let thirtyMinutes: TimeInterval = 1_800

        /// 1 hour in seconds.
        public static let oneHour: TimeInterval = 3_600

        /// 2 hours in seconds.
        public static let twoHours: TimeInterval = 7_200

        /// 3 hours in seconds.
        public static let threeHours: TimeInterval = 10_800

        /// Maximum allowed timer duration (24 hours).
        public static let maximum: TimeInterval = 86_400

        /// All preset durations in order.
        public static let all: [TimeInterval] = [
            off, fifteenMinutes, thirtyMinutes, oneHour, twoHours, threeHours
        ]

        /// Preset durations with their localization keys.
        public static let withKeys: [(duration: TimeInterval, key: String)] = [
            (off, "duration_off"),
            (fifteenMinutes, "duration_15m"),
            (thirtyMinutes, "duration_30m"),
            (oneHour, "duration_1h"),
            (twoHours, "duration_2h"),
            (threeHours, "duration_3h")
        ]
    }

    // Timer Configuration

    /// Timer update interval in seconds.
    public static let timerUpdateInterval: TimeInterval = 0.5

    // History Configuration

    /// Maximum number of activity sessions to store.
    public static let maxStoredSessions = 100

    // UI Configuration

    /// Settings window dimensions.
    public enum SettingsWindow {
        public static let width: CGFloat = 300
        public static let height: CGFloat = 480
    }

    /// History view dimensions.
    public enum HistoryView {
        public static let width: CGFloat = 280
        public static let height: CGFloat = 400
        public static let maxVisibleSessions = 20
        public static let sessionListMaxHeight: CGFloat = 150
    }

    // Power Assertion

    /// The reason string for the IOPMAssertion.
    public static let powerAssertionReason = "Weakup preventing sleep"

    // Notification Identifiers

    /// Notification-related identifiers.
    public enum Notifications {
        /// Identifier for timer expiry notification.
        public static let timerExpiredIdentifier = "com.weakup.timer.expired"

        /// Category identifier for timer expiry notifications.
        public static let timerExpiredCategory = "TIMER_EXPIRED"

        /// Action identifier for restart action.
        public static let restartAction = "RESTART_TIMER"

        /// Action identifier for dismiss action.
        public static let dismissAction = "DISMISS"
    }

    // Hotkey

    /// Default hotkey configuration.
    public enum Hotkey {
        /// Hotkey signature for Carbon events ("WEKU").
        public static let signature: OSType = 0x5745_4B55

        /// Hotkey ID.
        public static let id: UInt32 = 1
    }
}
