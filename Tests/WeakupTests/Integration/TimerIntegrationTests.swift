import Foundation
import Testing
@testable import WeakupCore

/// Integration tests for timer functionality
/// Tests timer accuracy, auto-stop behavior, and timer-related state management
@Suite("Timer Integration Tests", .serialized)
@MainActor
struct TimerIntegrationTests {

    private var viewModel: CaffeineViewModel

    init() {
        // Clear UserDefaults before each test
        for key in UserDefaultsKeys.all {
            UserDefaultsStore.shared.removeObject(forKey: key)
        }

        viewModel = CaffeineViewModel()
        viewModel.soundEnabled = false
    }

    // MARK: - Timer Accuracy Tests

    @Test("Timer accuracy for short duration")
    func timerAccuracy_shortDuration() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(5) // 5 seconds

        viewModel.start()
        let startTime = viewModel.timeRemaining

        // Wait 3 seconds
        try await Task.sleep(nanoseconds: 3_000_000_000)

        let elapsed = startTime - viewModel.timeRemaining
        #expect(abs(elapsed - 3) < 0.5, "Timer should be accurate within 0.5 seconds")

        viewModel.stop()
    }

    @Test("Timer accuracy for medium duration")
    func timerAccuracy_mediumDuration() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(10) // 10 seconds

        viewModel.start()

        // Wait 5 seconds
        try await Task.sleep(nanoseconds: 5_000_000_000)

        let remaining = viewModel.timeRemaining
        #expect(abs(remaining - 5) < 1, "Timer should be accurate within 1 second over 5 seconds")

        viewModel.stop()
    }

    // MARK: - Auto-Stop Tests

    @Test("Timer auto-stops at zero")
    func timerAutoStop_stopsAtZero() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(2) // 2 seconds

        viewModel.start()
        #expect(viewModel.isActive)

        // Wait for timer to expire plus buffer
        try await Task.sleep(nanoseconds: 3_500_000_000)

        #expect(!viewModel.isActive, "Should auto-stop when timer reaches zero")
        #expect(viewModel.timeRemaining == 0, "Time remaining should be zero")
    }

    @Test("Timer auto-stop releases sleep prevention")
    func timerAutoStop_releasesSleepPrevention() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(2)

        viewModel.start()
        #expect(viewModel.isActive)

        // Wait for expiry
        try await Task.sleep(nanoseconds: 3_500_000_000)

        // Verify sleep prevention is released
        #expect(!viewModel.isActive)

        // Should be able to start again
        viewModel.start()
        #expect(viewModel.isActive)
        viewModel.stop()
    }

    // MARK: - Manual Stop Tests

    @Test("Manual stop cancels timer")
    func manualStop_cancelsTimer() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)

        viewModel.start()
        #expect(viewModel.isActive)
        #expect(viewModel.timeRemaining > 0)

        // Wait briefly
        try await Task.sleep(nanoseconds: 500_000_000)

        viewModel.stop()

        #expect(!viewModel.isActive)
        #expect(viewModel.timeRemaining == 0, "Time remaining should reset on manual stop")

        // Wait to ensure timer doesn't continue
        try await Task.sleep(nanoseconds: 1_000_000_000)
        #expect(!viewModel.isActive, "Should remain stopped")
    }

    @Test("Manual stop mid-countdown")
    func manualStop_midCountdown() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(10)

        viewModel.start()

        // Wait 3 seconds
        try await Task.sleep(nanoseconds: 3_000_000_000)

        let remainingBeforeStop = viewModel.timeRemaining
        #expect(remainingBeforeStop < 10)
        #expect(remainingBeforeStop > 0)

        viewModel.stop()
        #expect(viewModel.timeRemaining == 0)
    }

    // MARK: - Timer Mode Toggle Tests

    @Test("Timer mode toggle while active")
    func timerModeToggle_whileActive() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()

        #expect(viewModel.isActive)
        #expect(viewModel.timerMode)

        // Disable timer mode while active
        viewModel.setTimerMode(false)

        // Timer mode should be disabled
        #expect(!viewModel.timerMode, "Timer mode should be disabled")

        // Note: Session behavior when toggling timer mode depends on implementation
        // The session may continue running without the timer countdown
        // Clean up by stopping if still active
        if viewModel.isActive {
            viewModel.stop()
        }
    }

    @Test("Timer mode toggle preserves duration")
    func timerModeToggle_preservesDuration() {
        viewModel.setTimerDuration(1800) // 30 minutes
        viewModel.setTimerMode(true)
        viewModel.setTimerMode(false)
        viewModel.setTimerMode(true)

        #expect(viewModel.timerDuration == 1800, "Duration should be preserved across mode toggles")
    }

    // MARK: - Duration Change Tests

    @Test("Duration change while active stops")
    func durationChange_whileActive_stops() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()

        #expect(viewModel.isActive)

        viewModel.setTimerDuration(120)

        #expect(!viewModel.isActive, "Changing duration while active should stop")
    }

    @Test("Duration change while inactive preserves")
    func durationChange_whileInactive_preserves() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)

        #expect(!viewModel.isActive)

        viewModel.setTimerDuration(120)

        #expect(viewModel.timerDuration == 120)
        #expect(!viewModel.isActive)
    }

    // MARK: - Timer Without Timer Mode

    @Test("Start without timer mode has no countdown")
    func start_withoutTimerMode_noCountdown() {
        viewModel.setTimerMode(false)
        viewModel.setTimerDuration(60) // Duration set but mode disabled

        viewModel.start()

        #expect(viewModel.isActive)
        #expect(viewModel.timeRemaining == 0, "Should have no countdown when timer mode disabled")

        viewModel.stop()
    }

    @Test("Start with timer mode but zero duration has no countdown")
    func start_withTimerModeButZeroDuration_noCountdown() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(0)

        viewModel.start()

        #expect(viewModel.isActive)
        #expect(viewModel.timeRemaining == 0, "Should have no countdown with zero duration")

        viewModel.stop()
    }

    // MARK: - Restart Timer Tests

    @Test("Restart timer uses same duration")
    func restartTimer_usesSameDuration() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(5)

        viewModel.start()
        #expect(abs(viewModel.timeRemaining - 5) < 0.5)

        // Wait for expiry
        try await Task.sleep(nanoseconds: 6_000_000_000)

        #expect(!viewModel.isActive)

        // Restart
        viewModel.start()
        #expect(viewModel.isActive)
        #expect(abs(viewModel.timeRemaining - 5) < 0.5, "Restart should use same duration")

        viewModel.stop()
    }

    // MARK: - Edge Cases

    @Test("Very short timer")
    func veryShortTimer() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(1) // 1 second

        viewModel.start()
        #expect(viewModel.isActive)

        // Wait for expiry
        try await Task.sleep(nanoseconds: 2_000_000_000)

        #expect(!viewModel.isActive)
    }

    @Test("Negative duration clamps to zero")
    func negativeDuration_clampsToZero() {
        viewModel.setTimerDuration(-100)
        #expect(viewModel.timerDuration == 0, "Negative duration should clamp to 0")
    }

    @Test("Large duration accepted")
    func largeDuration_accepted() {
        let largeDuration: TimeInterval = 86400 // 24 hours
        viewModel.setTimerDuration(largeDuration)
        #expect(viewModel.timerDuration == largeDuration)
    }
}
