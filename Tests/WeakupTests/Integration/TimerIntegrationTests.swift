import XCTest
@testable import WeakupCore

/// Integration tests for timer functionality
/// Tests timer accuracy, auto-stop behavior, and timer-related state management
@MainActor
final class TimerIntegrationTests: XCTestCase {

    var viewModel: CaffeineViewModel!

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults before each test
        for key in UserDefaultsKeys.all {
            UserDefaults.standard.removeObject(forKey: key)
        }

        viewModel = CaffeineViewModel()
        viewModel.soundEnabled = false
    }

    override func tearDown() async throws {
        if viewModel.isActive {
            viewModel.stop()
        }
        viewModel = nil
        try await super.tearDown()
    }

    // MARK: - Timer Accuracy Tests

    func testTimerAccuracy_shortDuration() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(5) // 5 seconds

        viewModel.start()
        let startTime = viewModel.timeRemaining

        // Wait 3 seconds
        try await Task.sleep(nanoseconds: 3_000_000_000)

        let elapsed = startTime - viewModel.timeRemaining
        XCTAssertEqual(elapsed, 3, accuracy: 0.5, "Timer should be accurate within 0.5 seconds")
    }

    func testTimerAccuracy_mediumDuration() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(10) // 10 seconds

        viewModel.start()

        // Wait 5 seconds
        try await Task.sleep(nanoseconds: 5_000_000_000)

        let remaining = viewModel.timeRemaining
        XCTAssertEqual(remaining, 5, accuracy: 1, "Timer should be accurate within 1 second over 5 seconds")

        viewModel.stop()
    }

    // MARK: - Auto-Stop Tests

    func testTimerAutoStop_stopsAtZero() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(2) // 2 seconds

        viewModel.start()
        XCTAssertTrue(viewModel.isActive)

        // Wait for timer to expire plus buffer
        try await Task.sleep(nanoseconds: 3_500_000_000)

        XCTAssertFalse(viewModel.isActive, "Should auto-stop when timer reaches zero")
        XCTAssertEqual(viewModel.timeRemaining, 0, "Time remaining should be zero")
    }

    func testTimerAutoStop_releasesSleepPrevention() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(2)

        viewModel.start()
        XCTAssertTrue(viewModel.isActive)

        // Wait for expiry
        try await Task.sleep(nanoseconds: 3_500_000_000)

        // Verify sleep prevention is released
        XCTAssertFalse(viewModel.isActive)

        // Should be able to start again
        viewModel.start()
        XCTAssertTrue(viewModel.isActive)
        viewModel.stop()
    }

    // MARK: - Manual Stop Tests

    func testManualStop_cancelsTimer() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)

        viewModel.start()
        XCTAssertTrue(viewModel.isActive)
        XCTAssertGreaterThan(viewModel.timeRemaining, 0)

        // Wait briefly
        try await Task.sleep(nanoseconds: 500_000_000)

        viewModel.stop()

        XCTAssertFalse(viewModel.isActive)
        XCTAssertEqual(viewModel.timeRemaining, 0, "Time remaining should reset on manual stop")

        // Wait to ensure timer doesn't continue
        try await Task.sleep(nanoseconds: 1_000_000_000)
        XCTAssertFalse(viewModel.isActive, "Should remain stopped")
    }

    func testManualStop_midCountdown() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(10)

        viewModel.start()

        // Wait 3 seconds
        try await Task.sleep(nanoseconds: 3_000_000_000)

        let remainingBeforeStop = viewModel.timeRemaining
        XCTAssertLessThan(remainingBeforeStop, 10)
        XCTAssertGreaterThan(remainingBeforeStop, 0)

        viewModel.stop()
        XCTAssertEqual(viewModel.timeRemaining, 0)
    }

    // MARK: - Timer Mode Toggle Tests

    func testTimerModeToggle_whileActive() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()

        XCTAssertTrue(viewModel.isActive)
        XCTAssertTrue(viewModel.timerMode)

        // Disable timer mode while active
        viewModel.setTimerMode(false)

        // Timer mode should be disabled
        XCTAssertFalse(viewModel.timerMode, "Timer mode should be disabled")

        // Note: Session behavior when toggling timer mode depends on implementation
        // The session may continue running without the timer countdown
        // Clean up by stopping if still active
        if viewModel.isActive {
            viewModel.stop()
        }
    }

    func testTimerModeToggle_preservesDuration() {
        viewModel.setTimerDuration(1800) // 30 minutes
        viewModel.setTimerMode(true)
        viewModel.setTimerMode(false)
        viewModel.setTimerMode(true)

        XCTAssertEqual(viewModel.timerDuration, 1800, "Duration should be preserved across mode toggles")
    }

    // MARK: - Duration Change Tests

    func testDurationChange_whileActive_stops() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()

        XCTAssertTrue(viewModel.isActive)

        viewModel.setTimerDuration(120)

        XCTAssertFalse(viewModel.isActive, "Changing duration while active should stop")
    }

    func testDurationChange_whileInactive_preserves() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)

        XCTAssertFalse(viewModel.isActive)

        viewModel.setTimerDuration(120)

        XCTAssertEqual(viewModel.timerDuration, 120)
        XCTAssertFalse(viewModel.isActive)
    }

    // MARK: - Timer Without Timer Mode

    func testStart_withoutTimerMode_noCountdown() {
        viewModel.setTimerMode(false)
        viewModel.setTimerDuration(60) // Duration set but mode disabled

        viewModel.start()

        XCTAssertTrue(viewModel.isActive)
        XCTAssertEqual(viewModel.timeRemaining, 0, "Should have no countdown when timer mode disabled")

        viewModel.stop()
    }

    func testStart_withTimerModeButZeroDuration_noCountdown() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(0)

        viewModel.start()

        XCTAssertTrue(viewModel.isActive)
        XCTAssertEqual(viewModel.timeRemaining, 0, "Should have no countdown with zero duration")

        viewModel.stop()
    }

    // MARK: - Restart Timer Tests

    func testRestartTimer_usesSameDuration() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(5)

        viewModel.start()
        XCTAssertEqual(viewModel.timeRemaining, 5, accuracy: 0.5)

        // Wait for expiry
        try await Task.sleep(nanoseconds: 6_000_000_000)

        XCTAssertFalse(viewModel.isActive)

        // Restart
        viewModel.start()
        XCTAssertTrue(viewModel.isActive)
        XCTAssertEqual(viewModel.timeRemaining, 5, accuracy: 0.5, "Restart should use same duration")

        viewModel.stop()
    }

    // MARK: - Edge Cases

    func testVeryShortTimer() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(1) // 1 second

        viewModel.start()
        XCTAssertTrue(viewModel.isActive)

        // Wait for expiry
        try await Task.sleep(nanoseconds: 2_000_000_000)

        XCTAssertFalse(viewModel.isActive)
    }

    func testNegativeDuration_clampsToZero() {
        viewModel.setTimerDuration(-100)
        XCTAssertEqual(viewModel.timerDuration, 0, "Negative duration should clamp to 0")
    }

    func testLargeDuration_accepted() {
        let largeDuration: TimeInterval = 86400 // 24 hours
        viewModel.setTimerDuration(largeDuration)
        XCTAssertEqual(viewModel.timerDuration, largeDuration)
    }
}
