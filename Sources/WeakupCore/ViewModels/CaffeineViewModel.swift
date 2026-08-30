import AppKit
import Foundation
import IOKit.pwr_mgt

/// The main view model responsible for managing system sleep prevention.
///
/// `CaffeineViewModel` provides the core functionality for preventing macOS from sleeping
/// by creating and managing IOPMAssertion power assertions. It supports both indefinite
/// sleep prevention and timer-based modes.
///
/// ## Overview
///
/// The view model uses Apple's IOPMAssertion API to prevent system idle sleep. When active,
/// it creates a `PreventUserIdleSystemSleep` assertion that keeps the system awake until
/// explicitly stopped or until a timer expires.
///
/// ## Usage
///
/// ```swift
/// let viewModel = CaffeineViewModel()
///
/// // Toggle sleep prevention
/// viewModel.toggle()
///
/// // Or explicitly start/stop
/// viewModel.start()
/// viewModel.stop()
///
/// // Timer mode
/// viewModel.setTimerMode(true)
/// viewModel.setTimerDuration(3600) // 1 hour
/// viewModel.start()
/// ```
///
/// ## Thread Safety
///
/// This class is marked with `@MainActor` and all public methods must be called from the main thread.
///
/// - Note: The assertion is automatically released when the app terminates.
@MainActor
public final class CaffeineViewModel: ObservableObject {
    /// Indicates whether sleep prevention is currently active.
    ///
    /// When `true`, the system will not enter idle sleep. This property is updated
    /// automatically by `start()`, `stop()`, and `toggle()` methods.
    @Published public var isActive = false

    /// Indicates whether timer mode is enabled.
    ///
    /// When enabled along with a valid `timerDuration`, sleep prevention will
    /// automatically stop when the timer expires.
    @Published public private(set) var timerMode = false

    /// The remaining time in seconds when timer mode is active.
    ///
    /// This value counts down from `timerDuration` to zero. When it reaches zero,
    /// sleep prevention is automatically disabled and a notification is sent.
    @Published public var timeRemaining: TimeInterval = 0

    /// Indicates that a request to turn off the display is currently running.
    @Published public private(set) var isDisplaySleepRequestInFlight = false

    /// Controls whether sound feedback is played on state changes.
    ///
    /// When enabled, a sound plays when sleep prevention starts or stops.
    /// The value is persisted to UserDefaults.
    @Published public var soundEnabled: Bool {
        didSet {
            UserDefaultsStore.shared.set(soundEnabled, forKey: UserDefaultsKeys.soundEnabled)
            Logger.preferenceChanged(key: UserDefaultsKeys.soundEnabled, value: soundEnabled)
        }
    }

    /// Controls whether the countdown timer is displayed in the menu bar.
    ///
    /// When enabled and timer mode is active, the remaining time appears
    /// next to the status icon in the menu bar.
    @Published public var showCountdownInMenuBar: Bool {
        didSet {
            UserDefaultsStore.shared.set(
                showCountdownInMenuBar, forKey: UserDefaultsKeys.showCountdownInMenuBar
            )
            Logger.preferenceChanged(
                key: UserDefaultsKeys.showCountdownInMenuBar, value: showCountdownInMenuBar
            )
        }
    }

    /// Controls whether notifications are enabled for timer expiry.
    ///
    /// When enabled, a system notification is sent when the timer expires.
    @Published public var notificationsEnabled: Bool {
        didSet {
            notificationManager.notificationsEnabled = notificationsEnabled
        }
    }

    /// The duration in seconds for timer mode.
    ///
    /// Set this value using `setTimerDuration(_:)` to ensure proper persistence
    /// and state management.
    public private(set) var timerDuration: TimeInterval = 0

    private var timer: Timer?
    private var systemAssertionID: IOPMAssertionID = 0
    private var displayAssertionID: IOPMAssertionID = 0
    private var timerStartDate: Date?
    private var timerExpiredByTimer = false
    private var displaySleepRequestGeneration: UInt = 0

    /// The notification manager used for timer expiry notifications.
    private let notificationManager: NotificationManaging
    private let powerAssertionManager: PowerAssertionManaging
    private let displaySleepRequester: DisplaySleepRequesting

    // Initialization

    /// Creates a new CaffeineViewModel with the specified notification manager.
    ///
    /// - Parameter notificationManager: The notification manager to use. Defaults to
    ///   `NotificationManager.shared` for production use. Pass a mock implementation
    ///   for testing.
    public convenience init(notificationManager: NotificationManaging? = nil) {
        self.init(
            notificationManager: notificationManager,
            powerAssertionManager: IOKitPowerAssertionManager(),
            displaySleepRequester: PMSetDisplaySleepRequester()
        )
    }

    init(
        notificationManager: NotificationManaging? = nil,
        powerAssertionManager: PowerAssertionManaging,
        displaySleepRequester: DisplaySleepRequesting
    ) {
        // Use provided manager or default to shared instance
        self.notificationManager = notificationManager ?? NotificationManager.shared
        self.powerAssertionManager = powerAssertionManager
        self.displaySleepRequester = displaySleepRequester

        // Safely load preferences with fallbacks
        self.soundEnabled = Self.loadBool(forKey: UserDefaultsKeys.soundEnabled, default: true)
        self.showCountdownInMenuBar = Self.loadBool(
            forKey: UserDefaultsKeys.showCountdownInMenuBar, default: true
        )
        self.timerMode = Self.loadBool(forKey: UserDefaultsKeys.timerMode, default: false)
        self.timerDuration = Self.loadDouble(forKey: UserDefaultsKeys.timerDuration, default: 0)
        self.notificationsEnabled = self.notificationManager.notificationsEnabled

        // Setup notification restart callback
        self.notificationManager.onRestartRequested = { [weak self] in
            Task { @MainActor [weak self] in
                self?.restartTimer()
            }
        }

        // Request notification permissions on first launch
        self.notificationManager.requestAuthorization()

        // Register for app termination to clean up
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.cleanup()
            }
        }
    }

    deinit {
        // Note: deinit runs on arbitrary thread, cleanup should be done via notification
    }

    // Public Methods

    /// Toggles the sleep prevention state.
    ///
    /// If currently inactive, this starts sleep prevention. If active, this stops it.
    public func toggle() {
        guard !isDisplaySleepRequestInFlight else { return }
        if isActive {
            stop()
        } else {
            start()
        }
    }

    /// Starts sleep prevention by creating an IOPMAssertion.
    ///
    /// Creates a `PreventUserIdleSystemSleep` assertion to keep the system awake.
    /// If timer mode is enabled with a valid duration, starts the countdown timer.
    ///
    /// - Note: If the assertion creation fails, the method returns silently without
    ///   changing the `isActive` state.
    public func start() {
        guard !isActive, !isDisplaySleepRequestInFlight else { return }

        do {
            try createSystemAssertion()
            do {
                try createDisplayAssertion()
            } catch {
                _ = releaseSystemAssertion()
                throw error
            }
            activateSession()
        } catch {
            Logger.error("Failed to start sleep prevention", error: error, category: .power)
        }
    }

    /// Immediately turns off the display while keeping the Mac running.
    ///
    /// If sleep prevention is already active, its timer and history session continue unchanged.
    /// The existing display assertion remains active because forced display sleep is independent
    /// from idle display sleep.
    ///
    /// - Throws: An error when the system assertion or display-sleep request fails.
    public func turnOffDisplayKeepingSystemAwake() async throws {
        guard !isDisplaySleepRequestInFlight else { return }
        displaySleepRequestGeneration &+= 1
        let requestGeneration = displaySleepRequestGeneration
        isDisplaySleepRequestInFlight = true
        defer {
            if displaySleepRequestGeneration == requestGeneration {
                isDisplaySleepRequestInFlight = false
            }
        }

        let startedNewSession = !isActive

        if startedNewSession {
            do {
                try createSystemAssertion()
                try createDisplayAssertion()
            } catch {
                let cleanupErrors = releaseAssertions()
                if !cleanupErrors.isEmpty {
                    throw DisplaySleepRequestError.rollbackIncomplete
                }
                throw error
            }
        }

        do {
            try await displaySleepRequester.requestDisplaySleep()
        } catch {
            guard displaySleepRequestGeneration == requestGeneration else { return }
            if startedNewSession, !releaseAssertions().isEmpty {
                throw DisplaySleepRequestError.rollbackIncomplete
            }
            throw error
        }

        guard displaySleepRequestGeneration == requestGeneration else { return }
        if startedNewSession {
            activateSession()
        }
    }

    /// Stops sleep prevention and releases the IOPMAssertion.
    ///
    /// Releases any active power assertion, stops the countdown timer,
    /// and resets all timer-related state.
    public func stop() {
        let wasActive = isActive
        cancelDisplaySleepRequest()
        releaseAssertions()
        stopTimer()
        isActive = false
        timeRemaining = 0
        timerStartDate = nil
        if wasActive {
            playSound(enabled: false)
        }
        notifyChange()
    }

    /// Sets the timer duration for timer mode.
    ///
    /// - Parameter seconds: The duration in seconds. Negative values are clamped to zero.
    ///
    /// - Note: If sleep prevention is currently active, calling this method will stop it.
    ///   The value is persisted to UserDefaults.
    public func setTimerDuration(_ seconds: TimeInterval) {
        guard !isDisplaySleepRequestInFlight else { return }
        timerDuration = max(0, seconds)
        UserDefaultsStore.shared.set(timerDuration, forKey: UserDefaultsKeys.timerDuration)
        if isActive {
            stop()
        }
    }

    /// Enables or disables timer mode.
    ///
    /// - Parameter enabled: Whether timer mode should be enabled.
    ///
    /// When timer mode is enabled and `start()` is called with a valid duration,
    /// sleep prevention will automatically stop when the timer expires.
    ///
    /// - Note: If disabling timer mode while sleep prevention is active, the session will be stopped.
    public func setTimerMode(_ enabled: Bool) {
        guard !isDisplaySleepRequestInFlight else { return }
        timerMode = enabled
        UserDefaultsStore.shared.set(timerMode, forKey: UserDefaultsKeys.timerMode)

        // If disabling timer mode while active, stop the session
        if !enabled, isActive {
            stop()
        }
    }

    // Private Methods

    private func cleanup() {
        cancelDisplaySleepRequest()
        releaseAssertions()
        stopTimer()
    }

    @discardableResult
    private func releaseAssertions() -> [PowerAssertionError] {
        [releaseDisplayAssertion(), releaseSystemAssertion()].compactMap { $0 }
    }

    private func createSystemAssertion() throws {
        guard systemAssertionID == 0 else { return }
        systemAssertionID = try powerAssertionManager.createAssertion(
            .systemSleep, reason: AppConstants.powerAssertionReason
        )
        Logger.powerAssertionCreated(id: systemAssertionID)
    }

    private func createDisplayAssertion() throws {
        guard displayAssertionID == 0 else { return }
        displayAssertionID = try powerAssertionManager.createAssertion(
            .displaySleep, reason: AppConstants.powerAssertionReason
        )
        Logger.powerAssertionCreated(id: displayAssertionID)
    }

    private func releaseSystemAssertion() -> PowerAssertionError? {
        guard systemAssertionID != 0 else { return nil }
        Logger.powerAssertionReleased(id: systemAssertionID)
        let result = powerAssertionManager.releaseAssertion(systemAssertionID)
        if result != kIOReturnSuccess {
            Logger.error("Failed to release system sleep assertion: \(result)", category: .power)
            return .releaseFailed(kind: .systemSleep, code: result)
        }
        systemAssertionID = 0
        return nil
    }

    private func releaseDisplayAssertion() -> PowerAssertionError? {
        guard displayAssertionID != 0 else { return nil }
        Logger.powerAssertionReleased(id: displayAssertionID)
        let result = powerAssertionManager.releaseAssertion(displayAssertionID)
        if result != kIOReturnSuccess {
            Logger.error("Failed to release display sleep assertion: \(result)", category: .power)
            return .releaseFailed(kind: .displaySleep, code: result)
        }
        displayAssertionID = 0
        return nil
    }

    private func cancelDisplaySleepRequest() {
        guard isDisplaySleepRequestInFlight else { return }
        displaySleepRequestGeneration &+= 1
        isDisplaySleepRequestInFlight = false
    }

    private func activateSession() {
        isActive = true
        playSound(enabled: true)

        if timerMode, timerDuration > 0 {
            timeRemaining = timerDuration
            timerStartDate = Date()
            startTimer()
            Logger.timerStarted(duration: timerDuration)
        }

        notifyChange()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startTimer() {
        stopTimer()

        // Use a more accurate timer approach that calculates elapsed time
        // rather than relying on timer intervals (which can drift in background)
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [weak self] in
                self?.updateTimeRemaining()
            }
        }

        // Ensure timer fires even when menu is open
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func updateTimeRemaining() {
        guard let startDate = timerStartDate else {
            stop()
            return
        }

        let elapsed = Date().timeIntervalSince(startDate)
        let remaining = timerDuration - elapsed

        if remaining <= 0 {
            timerExpiredByTimer = true
            Logger.timerExpired()
            stop()
            // Send notification when timer expires
            notificationManager.scheduleTimerExpiryNotification()
            timerExpiredByTimer = false
        } else {
            timeRemaining = remaining
            notifyChange()
        }
    }

    /// Restarts the timer with the same duration.
    ///
    /// This method is typically called from a notification action when the user
    /// chooses to restart the timer after it expires.
    ///
    /// - Note: Does nothing if `timerDuration` is zero or negative.
    public func restartTimer() {
        guard timerDuration > 0, !isDisplaySleepRequestInFlight else { return }
        timerMode = true
        start()
    }

    private func notifyChange() {
        objectWillChange.send()
    }

    private func playSound(enabled: Bool) {
        guard soundEnabled else { return }
        let soundName = enabled ? "Blow" : "Bottle"
        NSSound(named: NSSound.Name(soundName))?.play()
    }

    // Safe UserDefaults Loading

    private static func loadBool(forKey key: String, default defaultValue: Bool) -> Bool {
        guard let value = UserDefaultsStore.shared.object(forKey: key) else {
            return defaultValue
        }
        if let boolValue = value as? Bool {
            return boolValue
        }
        // Handle potential corruption - reset to default
        UserDefaultsStore.shared.removeObject(forKey: key)
        return defaultValue
    }

    private static func loadDouble(forKey key: String, default defaultValue: Double) -> Double {
        guard let value = UserDefaultsStore.shared.object(forKey: key) else {
            return defaultValue
        }
        if let doubleValue = value as? Double {
            return max(0, doubleValue) // Ensure non-negative
        }
        // Handle potential corruption - reset to default
        UserDefaultsStore.shared.removeObject(forKey: key)
        return defaultValue
    }
}
