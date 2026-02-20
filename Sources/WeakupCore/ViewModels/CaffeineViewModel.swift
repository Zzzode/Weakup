import Foundation
import IOKit.pwr_mgt
import AppKit

// MARK: - Caffeine View Model

@MainActor
public final class CaffeineViewModel: ObservableObject {
    @Published public var isActive = false
    @Published public var timerMode = false
    @Published public var timeRemaining: TimeInterval = 0
    @Published public var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: Keys.soundEnabled)
        }
    }
    public private(set) var timerDuration: TimeInterval = 0

    private var timer: Timer?
    private var assertionID: IOPMAssertionID = 0
    private var timerStartDate: Date?

    // MARK: - Constants

    private enum Keys {
        static let soundEnabled = "WeakupSoundEnabled"
        static let timerMode = "WeakupTimerMode"
        static let timerDuration = "WeakupTimerDuration"
    }

    // MARK: - Initialization

    public init() {
        // Safely load preferences with fallbacks
        self.soundEnabled = Self.loadBool(forKey: Keys.soundEnabled, default: true)
        self.timerMode = Self.loadBool(forKey: Keys.timerMode, default: false)
        self.timerDuration = Self.loadDouble(forKey: Keys.timerDuration, default: 0)

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

    // MARK: - Public Methods

    public func toggle() {
        isActive ? stop() : start()
    }

    public func start() {
        var id: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Weakup preventing sleep" as CFString,
            &id
        )

        guard result == kIOReturnSuccess else { return }
        assertionID = id
        isActive = true
        playSound(enabled: true)

        if timerMode && timerDuration > 0 {
            timeRemaining = timerDuration
            timerStartDate = Date()
            startTimer()
        }

        notifyChange()
    }

    public func stop() {
        releaseAssertion()
        stopTimer()
        isActive = false
        timeRemaining = 0
        timerStartDate = nil
        playSound(enabled: false)
        notifyChange()
    }

    public func setTimerDuration(_ seconds: TimeInterval) {
        timerDuration = max(0, seconds)
        UserDefaults.standard.set(timerDuration, forKey: Keys.timerDuration)
        if isActive {
            stop()
        }
    }

    public func setTimerMode(_ enabled: Bool) {
        timerMode = enabled
        UserDefaults.standard.set(timerMode, forKey: Keys.timerMode)
    }

    // MARK: - Private Methods

    private func cleanup() {
        releaseAssertion()
        stopTimer()
    }

    private func releaseAssertion() {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
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
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                self?.updateTimeRemaining()
            }
        }

        // Ensure timer fires even when menu is open
        if let timer = timer {
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
            stop()
        } else {
            timeRemaining = remaining
            notifyChange()
        }
    }

    private func notifyChange() {
        objectWillChange.send()
    }

    private func playSound(enabled: Bool) {
        guard soundEnabled else { return }
        let soundName = enabled ? "Blow" : "Bottle"
        NSSound(named: NSSound.Name(soundName))?.play()
    }

    // MARK: - Safe UserDefaults Loading

    private static func loadBool(forKey key: String, default defaultValue: Bool) -> Bool {
        guard let value = UserDefaults.standard.object(forKey: key) else {
            return defaultValue
        }
        if let boolValue = value as? Bool {
            return boolValue
        }
        // Handle potential corruption - reset to default
        UserDefaults.standard.removeObject(forKey: key)
        return defaultValue
    }

    private static func loadDouble(forKey key: String, default defaultValue: Double) -> Double {
        guard let value = UserDefaults.standard.object(forKey: key) else {
            return defaultValue
        }
        if let doubleValue = value as? Double {
            return max(0, doubleValue) // Ensure non-negative
        }
        // Handle potential corruption - reset to default
        UserDefaults.standard.removeObject(forKey: key)
        return defaultValue
    }
}
