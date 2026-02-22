import XCTest
@testable import WeakupCore

@MainActor
final class CaffeineViewModelTests: XCTestCase {

    var viewModel: CaffeineViewModel!

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults before each test
        UserDefaultsStore.shared.removeObject(forKey: "WeakupSoundEnabled")
        UserDefaultsStore.shared.removeObject(forKey: "WeakupTimerMode")
        UserDefaultsStore.shared.removeObject(forKey: "WeakupTimerDuration")
        viewModel = CaffeineViewModel()
    }

    override func tearDown() async throws {
        // Ensure we stop any active session
        if viewModel.isActive {
            viewModel.stop()
        }
        viewModel = nil
        try await super.tearDown()
    }

    // Initial State Tests

    func testInitialState_isInactive() {
        XCTAssertFalse(viewModel.isActive, "ViewModel should start inactive")
    }

    func testInitialState_timerModeDisabled() {
        XCTAssertFalse(viewModel.timerMode, "Timer mode should be disabled by default")
    }

    func testInitialState_timeRemainingIsZero() {
        XCTAssertEqual(viewModel.timeRemaining, 0, "Time remaining should be zero initially")
    }

    func testInitialState_timerDurationIsZero() {
        XCTAssertEqual(viewModel.timerDuration, 0, "Timer duration should be zero initially")
    }

    func testInitialState_soundEnabledByDefault() {
        XCTAssertTrue(viewModel.soundEnabled, "Sound should be enabled by default")
    }

    // Toggle Tests

    func testToggle_startsWhenInactive() {
        XCTAssertFalse(viewModel.isActive)
        viewModel.toggle()
        XCTAssertTrue(viewModel.isActive, "Toggle should activate when inactive")
    }

    func testToggle_stopsWhenActive() {
        viewModel.start()
        XCTAssertTrue(viewModel.isActive)
        viewModel.toggle()
        XCTAssertFalse(viewModel.isActive, "Toggle should deactivate when active")
    }

    func testToggle_multipleTimes() {
        for i in 0..<5 {
            viewModel.toggle()
            let expectedState = (i % 2 == 0)
            XCTAssertEqual(viewModel.isActive, expectedState, "State should alternate on toggle")
        }
        // Clean up
        if viewModel.isActive {
            viewModel.stop()
        }
    }

    // Start/Stop Tests

    func testStart_activatesViewModel() {
        viewModel.start()
        XCTAssertTrue(viewModel.isActive, "Start should activate the ViewModel")
    }

    func testStop_deactivatesViewModel() {
        viewModel.start()
        viewModel.stop()
        XCTAssertFalse(viewModel.isActive, "Stop should deactivate the ViewModel")
    }

    func testStop_resetsTimeRemaining() {
        viewModel.timerMode = true
        viewModel.setTimerDuration(60)
        viewModel.start()
        XCTAssertGreaterThan(viewModel.timeRemaining, 0)
        viewModel.stop()
        XCTAssertEqual(viewModel.timeRemaining, 0, "Stop should reset time remaining to zero")
    }

    func testStop_whenAlreadyStopped_noError() {
        XCTAssertFalse(viewModel.isActive)
        viewModel.stop() // Should not crash
        XCTAssertFalse(viewModel.isActive)
    }

    // Timer Duration Tests

    func testSetTimerDuration_updatesValue() {
        viewModel.setTimerDuration(3600)
        XCTAssertEqual(viewModel.timerDuration, 3600, "Timer duration should be updated")
    }

    func testSetTimerDuration_negativeClampsToZero() {
        viewModel.setTimerDuration(-100)
        XCTAssertEqual(viewModel.timerDuration, 0, "Negative duration should clamp to zero")
    }

    func testSetTimerDuration_stopsIfActive() {
        viewModel.start()
        XCTAssertTrue(viewModel.isActive)
        viewModel.setTimerDuration(1800)
        XCTAssertFalse(viewModel.isActive, "Setting duration while active should stop")
    }

    func testSetTimerDuration_persistsValue() {
        viewModel.setTimerDuration(7200)
        let storedValue = UserDefaultsStore.shared.double(forKey: "WeakupTimerDuration")
        XCTAssertEqual(storedValue, 7200, "Duration should be persisted to UserDefaults")
    }

    // Timer Mode Tests

    func testSetTimerMode_updatesValue() {
        viewModel.setTimerMode(true)
        XCTAssertTrue(viewModel.timerMode, "Timer mode should be enabled")
        viewModel.setTimerMode(false)
        XCTAssertFalse(viewModel.timerMode, "Timer mode should be disabled")
    }

    func testSetTimerMode_persistsValue() {
        viewModel.setTimerMode(true)
        let storedValue = UserDefaultsStore.shared.bool(forKey: "WeakupTimerMode")
        XCTAssertTrue(storedValue, "Timer mode should be persisted to UserDefaults")
    }

    func testTimerMode_withDuration_setsTimeRemaining() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()
        XCTAssertEqual(viewModel.timeRemaining, 60, accuracy: 1, "Time remaining should match duration")
    }

    func testTimerMode_withoutDuration_noTimeRemaining() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(0)
        viewModel.start()
        XCTAssertEqual(viewModel.timeRemaining, 0, "Time remaining should be zero when duration is zero")
    }

    func testTimerMode_disabled_noTimeRemaining() {
        viewModel.setTimerMode(false)
        viewModel.setTimerDuration(60)
        viewModel.start()
        XCTAssertEqual(viewModel.timeRemaining, 0, "Time remaining should be zero when timer mode is disabled")
    }

    // Sound Enabled Tests

    func testSoundEnabled_persistsValue() {
        viewModel.soundEnabled = false
        let storedValue = UserDefaultsStore.shared.bool(forKey: "WeakupSoundEnabled")
        XCTAssertFalse(storedValue, "Sound enabled should be persisted to UserDefaults")
    }

    func testSoundEnabled_toggles() {
        let initial = viewModel.soundEnabled
        viewModel.soundEnabled = !initial
        XCTAssertNotEqual(viewModel.soundEnabled, initial, "Sound enabled should toggle")
    }

    // Show Countdown In Menu Bar Tests (CVM-024)

    func testShowCountdownInMenuBar_persistsValue() {
        // Default should be true
        XCTAssertTrue(viewModel.showCountdownInMenuBar, "Show countdown should be enabled by default")

        // Toggle to false
        viewModel.showCountdownInMenuBar = false
        let storedValue = UserDefaultsStore.shared.bool(forKey: "WeakupShowCountdownInMenuBar")
        XCTAssertFalse(storedValue, "Show countdown should be persisted to UserDefaults")

        // Toggle back to true
        viewModel.showCountdownInMenuBar = true
        let storedValueTrue = UserDefaultsStore.shared.bool(forKey: "WeakupShowCountdownInMenuBar")
        XCTAssertTrue(storedValueTrue, "Show countdown true should be persisted to UserDefaults")
    }

    // Notifications Enabled Tests (CVM-025)

    func testNotificationsEnabled_syncsWithManager() {
        // Get the initial value from NotificationManager
        let managerValue = NotificationManager.shared.notificationsEnabled

        // ViewModel should sync with manager on init
        XCTAssertEqual(viewModel.notificationsEnabled, managerValue, "ViewModel should sync with NotificationManager")

        // Toggle the value
        viewModel.notificationsEnabled = !managerValue

        // NotificationManager should be updated
        XCTAssertEqual(NotificationManager.shared.notificationsEnabled, !managerValue, "NotificationManager should be updated when ViewModel changes")

        // Restore original value
        viewModel.notificationsEnabled = managerValue
    }

    // Restart Timer Tests (CVM-026)

    func testRestartTimer_startsWithSameDuration() {
        // Setup timer with a duration
        viewModel.setTimerDuration(TestTimerDurations.thirtyMinutes)
        viewModel.setTimerMode(true)
        viewModel.start()

        // Verify initial state
        XCTAssertTrue(viewModel.isActive)
        XCTAssertEqual(viewModel.timeRemaining, TestTimerDurations.thirtyMinutes, accuracy: 1)

        // Stop and restart
        viewModel.stop()
        XCTAssertFalse(viewModel.isActive)

        viewModel.restartTimer()

        // Should restart with same duration
        XCTAssertTrue(viewModel.isActive, "Restart should activate the timer")
        XCTAssertTrue(viewModel.timerMode, "Timer mode should be enabled after restart")
        XCTAssertEqual(viewModel.timeRemaining, TestTimerDurations.thirtyMinutes, accuracy: 1, "Time remaining should match original duration")
    }

    func testRestartTimer_withZeroDuration_doesNotStart() {
        viewModel.setTimerDuration(0)
        viewModel.setTimerMode(false)

        viewModel.restartTimer()

        XCTAssertFalse(viewModel.isActive, "Restart with zero duration should not activate")
    }

    // Timer Countdown Accuracy Tests (CVM-027)

    func testTimerCountdown_accuracy() async throws {
        // Use a short duration for testing
        let testDuration: TimeInterval = 3
        viewModel.setTimerDuration(testDuration)
        viewModel.setTimerMode(true)

        viewModel.start()

        XCTAssertTrue(viewModel.isActive)
        XCTAssertEqual(viewModel.timeRemaining, testDuration, accuracy: 0.5)

        // Wait for 1 second
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Time remaining should have decreased
        XCTAssertEqual(viewModel.timeRemaining, testDuration - 1, accuracy: 0.5, "Timer should count down accurately")

        // Clean up
        viewModel.stop()
    }

    // Timer Expiry Tests (CVM-028)

    func testTimerExpiry_stopsAutomatically() async throws {
        // Use a very short duration
        let testDuration: TimeInterval = 1.5
        viewModel.setTimerDuration(testDuration)
        viewModel.setTimerMode(true)

        viewModel.start()
        XCTAssertTrue(viewModel.isActive, "Should be active after start")

        // Wait for timer to expire (with buffer)
        try await Task.sleep(nanoseconds: 2_500_000_000)

        // Should have stopped automatically
        XCTAssertFalse(viewModel.isActive, "Timer should auto-stop when expired")
        XCTAssertEqual(viewModel.timeRemaining, 0, "Time remaining should be zero after expiry")
    }

    // IOPMAssertion Tests (CVM-029, CVM-030)

    func testIOPMAssertion_createdOnStart() {
        // Start sleep prevention
        viewModel.start()

        // The assertion is created internally - we verify by checking isActive
        // and that the system reports an assertion (tested via pmset in integration tests)
        XCTAssertTrue(viewModel.isActive, "ViewModel should be active after start")

        // Clean up
        viewModel.stop()
    }

    func testIOPMAssertion_releasedOnStop() {
        // Start and then stop
        viewModel.start()
        XCTAssertTrue(viewModel.isActive)

        viewModel.stop()

        // Verify the assertion is released by checking state
        XCTAssertFalse(viewModel.isActive, "ViewModel should be inactive after stop")

        // Multiple stops should be safe (no double-release crash)
        viewModel.stop()
        viewModel.stop()
        XCTAssertFalse(viewModel.isActive, "Multiple stops should be safe")
    }

    func testIOPMAssertion_releasedOnRapidToggle() {
        // Rapid toggling should not leak assertions
        for _ in 0..<10 {
            viewModel.toggle()
        }

        // Ensure we end in a stopped state
        if viewModel.isActive {
            viewModel.stop()
        }

        XCTAssertFalse(viewModel.isActive, "Should be inactive after cleanup")
    }

    // Edge Case Tests

    func testStart_withoutTimerMode() {
        viewModel.setTimerMode(false)
        viewModel.setTimerDuration(3600) // Duration set but timer mode off

        viewModel.start()

        XCTAssertTrue(viewModel.isActive, "Should be active")
        XCTAssertEqual(viewModel.timeRemaining, 0, "Time remaining should be zero when timer mode is off")
    }

    func testStart_multipleTimes_noAccumulation() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)

        viewModel.start()
        let firstTimeRemaining = viewModel.timeRemaining

        // Start again without stopping
        viewModel.start()
        let secondTimeRemaining = viewModel.timeRemaining

        // Time remaining should reset, not accumulate
        XCTAssertEqual(firstTimeRemaining, secondTimeRemaining, accuracy: 1, "Multiple starts should not accumulate time")

        viewModel.stop()
    }

    func testTimerMode_disabledWhileActive_stopsSession() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()

        XCTAssertTrue(viewModel.isActive)
        XCTAssertGreaterThan(viewModel.timeRemaining, 0)

        // Disable timer mode while active - this should stop the session
        viewModel.setTimerMode(false)

        // Session should be stopped when timer mode is disabled while active
        XCTAssertFalse(viewModel.isActive, "Session should stop when timer mode is disabled")
        XCTAssertFalse(viewModel.timerMode, "Timer mode should be disabled")
    }

    // All Timer Duration Presets Tests

    func testAllTimerDurationPresets() {
        for duration in TestTimerDurations.allValid {
            viewModel.setTimerDuration(duration)
            XCTAssertEqual(viewModel.timerDuration, duration, "Duration \(duration) should be set correctly")
        }
    }

    func testTimerDuration_veryLargeValue() {
        let largeDuration: TimeInterval = 86400 * 7 // 1 week
        viewModel.setTimerDuration(largeDuration)
        XCTAssertEqual(viewModel.timerDuration, largeDuration, "Large duration should be accepted")
    }

    // UserDefaults Loading Tests

    func testInitialState_loadsPersistedTimerMode() {
        // Set a value in UserDefaults
        UserDefaultsStore.shared.set(true, forKey: "WeakupTimerMode")

        // Create a new ViewModel
        let newViewModel = CaffeineViewModel()

        XCTAssertTrue(newViewModel.timerMode, "Timer mode should be loaded from UserDefaults")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }

    func testInitialState_loadsPersistedTimerDuration() {
        // Set a value in UserDefaults
        UserDefaultsStore.shared.set(7200.0, forKey: "WeakupTimerDuration")

        // Create a new ViewModel
        let newViewModel = CaffeineViewModel()

        XCTAssertEqual(newViewModel.timerDuration, 7200, "Timer duration should be loaded from UserDefaults")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }

    func testInitialState_loadsPersistedSoundEnabled() {
        // Set a value in UserDefaults
        UserDefaultsStore.shared.set(false, forKey: "WeakupSoundEnabled")

        // Create a new ViewModel
        let newViewModel = CaffeineViewModel()

        XCTAssertFalse(newViewModel.soundEnabled, "Sound enabled should be loaded from UserDefaults")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }

    func testInitialState_handlesCorruptedBoolValue() {
        // Set a corrupted value (string instead of bool)
        UserDefaultsStore.shared.set("invalid", forKey: "WeakupSoundEnabled")

        // Create a new ViewModel - should handle gracefully
        let newViewModel = CaffeineViewModel()

        // Should fall back to default (true)
        XCTAssertTrue(newViewModel.soundEnabled, "Should fall back to default on corrupted value")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }

    func testInitialState_handlesCorruptedDoubleValue() {
        // Set a corrupted value (string instead of double)
        UserDefaultsStore.shared.set("invalid", forKey: "WeakupTimerDuration")

        // Create a new ViewModel - should handle gracefully
        let newViewModel = CaffeineViewModel()

        // Should fall back to default (0)
        XCTAssertEqual(newViewModel.timerDuration, 0, "Should fall back to default on corrupted value")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }

    func testInitialState_handlesNegativeTimerDuration() {
        // Set a negative value in UserDefaults
        UserDefaultsStore.shared.set(-100.0, forKey: "WeakupTimerDuration")

        // Create a new ViewModel
        let newViewModel = CaffeineViewModel()

        // Should clamp to 0
        XCTAssertEqual(newViewModel.timerDuration, 0, "Negative duration should be clamped to 0")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }
}
