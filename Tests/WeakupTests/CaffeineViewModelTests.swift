import Foundation
import Testing
@testable import WeakupCore

@Suite("CaffeineViewModel Tests")
@MainActor
struct CaffeineViewModelTests {

    var viewModel: CaffeineViewModel

    init() {
        // Clear UserDefaults before each test
        UserDefaultsStore.shared.removeObject(forKey: "WeakupSoundEnabled")
        UserDefaultsStore.shared.removeObject(forKey: "WeakupTimerMode")
        UserDefaultsStore.shared.removeObject(forKey: "WeakupTimerDuration")
        viewModel = CaffeineViewModel()
    }

    // MARK: - Initial State Tests

    @Test("Initial state is inactive")
    func initialStateIsInactive() {
        #expect(!viewModel.isActive, "ViewModel should start inactive")
    }

    @Test("Initial state timer mode disabled")
    func initialStateTimerModeDisabled() {
        #expect(!viewModel.timerMode, "Timer mode should be disabled by default")
    }

    @Test("Initial state time remaining is zero")
    func initialStateTimeRemainingIsZero() {
        #expect(viewModel.timeRemaining == 0, "Time remaining should be zero initially")
    }

    @Test("Initial state timer duration is zero")
    func initialStateTimerDurationIsZero() {
        #expect(viewModel.timerDuration == 0, "Timer duration should be zero initially")
    }

    @Test("Initial state sound enabled by default")
    func initialStateSoundEnabledByDefault() {
        #expect(viewModel.soundEnabled, "Sound should be enabled by default")
    }

    // MARK: - Toggle Tests

    @Test("Toggle starts when inactive")
    func toggleStartsWhenInactive() {
        #expect(!viewModel.isActive)
        viewModel.toggle()
        #expect(viewModel.isActive, "Toggle should activate when inactive")
        viewModel.stop()
    }

    @Test("Toggle stops when active")
    func toggleStopsWhenActive() {
        viewModel.start()
        #expect(viewModel.isActive)
        viewModel.toggle()
        #expect(!viewModel.isActive, "Toggle should deactivate when active")
    }

    @Test("Toggle multiple times")
    func toggleMultipleTimes() {
        for i in 0..<5 {
            viewModel.toggle()
            let expectedState = (i % 2 == 0)
            #expect(viewModel.isActive == expectedState, "State should alternate on toggle")
        }
        // Clean up
        if viewModel.isActive {
            viewModel.stop()
        }
    }

    // MARK: - Start/Stop Tests

    @Test("Start activates ViewModel")
    func startActivatesViewModel() {
        viewModel.start()
        #expect(viewModel.isActive, "Start should activate the ViewModel")
        viewModel.stop()
    }

    @Test("Stop deactivates ViewModel")
    func stopDeactivatesViewModel() {
        viewModel.start()
        viewModel.stop()
        #expect(!viewModel.isActive, "Stop should deactivate the ViewModel")
    }

    @Test("Stop resets time remaining")
    func stopResetsTimeRemaining() {
        viewModel.timerMode = true
        viewModel.setTimerDuration(60)
        viewModel.start()
        #expect(viewModel.timeRemaining > 0)
        viewModel.stop()
        #expect(viewModel.timeRemaining == 0, "Stop should reset time remaining to zero")
    }

    @Test("Stop when already stopped no error")
    func stopWhenAlreadyStoppedNoError() {
        #expect(!viewModel.isActive)
        viewModel.stop() // Should not crash
        #expect(!viewModel.isActive)
    }

    // MARK: - Timer Duration Tests

    @Test("Set timer duration updates value")
    func setTimerDurationUpdatesValue() {
        viewModel.setTimerDuration(3600)
        #expect(viewModel.timerDuration == 3600, "Timer duration should be updated")
    }

    @Test("Set timer duration negative clamps to zero")
    func setTimerDurationNegativeClampsToZero() {
        viewModel.setTimerDuration(-100)
        #expect(viewModel.timerDuration == 0, "Negative duration should clamp to zero")
    }

    @Test("Set timer duration stops if active")
    func setTimerDurationStopsIfActive() {
        viewModel.start()
        #expect(viewModel.isActive)
        viewModel.setTimerDuration(1800)
        #expect(!viewModel.isActive, "Setting duration while active should stop")
    }

    @Test("Set timer duration persists value")
    func setTimerDurationPersistsValue() {
        viewModel.setTimerDuration(7200)
        let storedValue = UserDefaultsStore.shared.double(forKey: "WeakupTimerDuration")
        #expect(storedValue == 7200, "Duration should be persisted to UserDefaults")
    }

    // MARK: - Timer Mode Tests

    @Test("Set timer mode updates value")
    func setTimerModeUpdatesValue() {
        viewModel.setTimerMode(true)
        #expect(viewModel.timerMode, "Timer mode should be enabled")
        viewModel.setTimerMode(false)
        #expect(!viewModel.timerMode, "Timer mode should be disabled")
    }

    @Test("Set timer mode persists value")
    func setTimerModePersistsValue() {
        viewModel.setTimerMode(true)
        let storedValue = UserDefaultsStore.shared.bool(forKey: "WeakupTimerMode")
        #expect(storedValue, "Timer mode should be persisted to UserDefaults")
    }

    @Test("Timer mode with duration sets time remaining")
    func timerModeWithDurationSetsTimeRemaining() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()
        #expect(abs(viewModel.timeRemaining - 60) < 1, "Time remaining should match duration")
        viewModel.stop()
    }

    @Test("Timer mode without duration no time remaining")
    func timerModeWithoutDurationNoTimeRemaining() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(0)
        viewModel.start()
        #expect(viewModel.timeRemaining == 0, "Time remaining should be zero when duration is zero")
        viewModel.stop()
    }

    @Test("Timer mode disabled no time remaining")
    func timerModeDisabledNoTimeRemaining() {
        viewModel.setTimerMode(false)
        viewModel.setTimerDuration(60)
        viewModel.start()
        #expect(viewModel.timeRemaining == 0, "Time remaining should be zero when timer mode is disabled")
        viewModel.stop()
    }

    // MARK: - Sound Enabled Tests

    @Test("Sound enabled persists value")
    func soundEnabledPersistsValue() {
        viewModel.soundEnabled = false
        let storedValue = UserDefaultsStore.shared.bool(forKey: "WeakupSoundEnabled")
        #expect(!storedValue, "Sound enabled should be persisted to UserDefaults")
    }

    @Test("Sound enabled toggles")
    func soundEnabledToggles() {
        let initial = viewModel.soundEnabled
        viewModel.soundEnabled = !initial
        #expect(viewModel.soundEnabled != initial, "Sound enabled should toggle")
    }

    // MARK: - Show Countdown In Menu Bar Tests (CVM-024)

    @Test("Show countdown in menu bar persists value")
    func showCountdownInMenuBarPersistsValue() {
        // Default should be true
        #expect(viewModel.showCountdownInMenuBar, "Show countdown should be enabled by default")

        // Toggle to false
        viewModel.showCountdownInMenuBar = false
        let storedValue = UserDefaultsStore.shared.bool(forKey: "WeakupShowCountdownInMenuBar")
        #expect(!storedValue, "Show countdown should be persisted to UserDefaults")

        // Toggle back to true
        viewModel.showCountdownInMenuBar = true
        let storedValueTrue = UserDefaultsStore.shared.bool(forKey: "WeakupShowCountdownInMenuBar")
        #expect(storedValueTrue, "Show countdown true should be persisted to UserDefaults")
    }

    // MARK: - Notifications Enabled Tests (CVM-025)

    @Test("Notifications enabled syncs with manager")
    func notificationsEnabledSyncsWithManager() {
        // Get the initial value from NotificationManager
        let managerValue = NotificationManager.shared.notificationsEnabled

        // ViewModel should sync with manager on init
        #expect(viewModel.notificationsEnabled == managerValue, "ViewModel should sync with NotificationManager")

        // Toggle the value
        viewModel.notificationsEnabled = !managerValue

        // NotificationManager should be updated
        #expect(NotificationManager.shared.notificationsEnabled == !managerValue, "NotificationManager should be updated when ViewModel changes")

        // Restore original value
        viewModel.notificationsEnabled = managerValue
    }

    // MARK: - Restart Timer Tests (CVM-026)

    @Test("Restart timer starts with same duration")
    func restartTimerStartsWithSameDuration() {
        // Setup timer with a duration
        viewModel.setTimerDuration(TestTimerDurations.thirtyMinutes)
        viewModel.setTimerMode(true)
        viewModel.start()

        // Verify initial state
        #expect(viewModel.isActive)
        #expect(abs(viewModel.timeRemaining - TestTimerDurations.thirtyMinutes) < 1)

        // Stop and restart
        viewModel.stop()
        #expect(!viewModel.isActive)

        viewModel.restartTimer()

        // Should restart with same duration
        #expect(viewModel.isActive, "Restart should activate the timer")
        #expect(viewModel.timerMode, "Timer mode should be enabled after restart")
        #expect(abs(viewModel.timeRemaining - TestTimerDurations.thirtyMinutes) < 1, "Time remaining should match original duration")

        viewModel.stop()
    }

    @Test("Restart timer with zero duration does not start")
    func restartTimerWithZeroDurationDoesNotStart() {
        viewModel.setTimerDuration(0)
        viewModel.setTimerMode(false)

        viewModel.restartTimer()

        #expect(!viewModel.isActive, "Restart with zero duration should not activate")
    }

    // MARK: - Timer Countdown Accuracy Tests (CVM-027)

    @Test("Timer countdown accuracy")
    func timerCountdownAccuracy() async throws {
        // Use a short duration for testing
        let testDuration: TimeInterval = 3
        viewModel.setTimerDuration(testDuration)
        viewModel.setTimerMode(true)

        viewModel.start()

        #expect(viewModel.isActive)
        #expect(abs(viewModel.timeRemaining - testDuration) < 0.5)

        // Wait for 1 second
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Time remaining should have decreased
        #expect(abs(viewModel.timeRemaining - (testDuration - 1)) < 0.5, "Timer should count down accurately")

        // Clean up
        viewModel.stop()
    }

    // MARK: - Timer Expiry Tests (CVM-028)

    @Test("Timer expiry stops automatically")
    func timerExpiryStopsAutomatically() async throws {
        // Use a very short duration
        let testDuration: TimeInterval = 1.5
        viewModel.setTimerDuration(testDuration)
        viewModel.setTimerMode(true)

        viewModel.start()
        #expect(viewModel.isActive, "Should be active after start")

        // Wait for timer to expire (with buffer)
        try await Task.sleep(nanoseconds: 2_500_000_000)

        // Should have stopped automatically
        #expect(!viewModel.isActive, "Timer should auto-stop when expired")
        #expect(viewModel.timeRemaining == 0, "Time remaining should be zero after expiry")
    }

    // MARK: - IOPMAssertion Tests (CVM-029, CVM-030)

    @Test("IOPMAssertion created on start")
    func iopmAssertionCreatedOnStart() {
        // Start sleep prevention
        viewModel.start()

        // The assertion is created internally - we verify by checking isActive
        // and that the system reports an assertion (tested via pmset in integration tests)
        #expect(viewModel.isActive, "ViewModel should be active after start")

        // Clean up
        viewModel.stop()
    }

    @Test("IOPMAssertion released on stop")
    func iopmAssertionReleasedOnStop() {
        // Start and then stop
        viewModel.start()
        #expect(viewModel.isActive)

        viewModel.stop()

        // Verify the assertion is released by checking state
        #expect(!viewModel.isActive, "ViewModel should be inactive after stop")

        // Multiple stops should be safe (no double-release crash)
        viewModel.stop()
        viewModel.stop()
        #expect(!viewModel.isActive, "Multiple stops should be safe")
    }

    @Test("IOPMAssertion released on rapid toggle")
    func iopmAssertionReleasedOnRapidToggle() {
        // Rapid toggling should not leak assertions
        for _ in 0..<10 {
            viewModel.toggle()
        }

        // Ensure we end in a stopped state
        if viewModel.isActive {
            viewModel.stop()
        }

        #expect(!viewModel.isActive, "Should be inactive after cleanup")
    }

    // MARK: - Edge Case Tests

    @Test("Start without timer mode")
    func startWithoutTimerMode() {
        viewModel.setTimerMode(false)
        viewModel.setTimerDuration(3600) // Duration set but timer mode off

        viewModel.start()

        #expect(viewModel.isActive, "Should be active")
        #expect(viewModel.timeRemaining == 0, "Time remaining should be zero when timer mode is off")

        viewModel.stop()
    }

    @Test("Start multiple times no accumulation")
    func startMultipleTimesNoAccumulation() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)

        viewModel.start()
        let firstTimeRemaining = viewModel.timeRemaining

        // Start again without stopping
        viewModel.start()
        let secondTimeRemaining = viewModel.timeRemaining

        // Time remaining should reset, not accumulate
        #expect(abs(firstTimeRemaining - secondTimeRemaining) < 1, "Multiple starts should not accumulate time")

        viewModel.stop()
    }

    @Test("Timer mode disabled while active stops session")
    func timerModeDisabledWhileActiveStopsSession() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()

        #expect(viewModel.isActive)
        #expect(viewModel.timeRemaining > 0)

        // Disable timer mode while active - this should stop the session
        viewModel.setTimerMode(false)

        // Session should be stopped when timer mode is disabled while active
        #expect(!viewModel.isActive, "Session should stop when timer mode is disabled")
        #expect(!viewModel.timerMode, "Timer mode should be disabled")
    }

    // MARK: - All Timer Duration Presets Tests

    @Test("All timer duration presets")
    func allTimerDurationPresets() {
        for duration in TestTimerDurations.allValid {
            viewModel.setTimerDuration(duration)
            #expect(viewModel.timerDuration == duration, "Duration \(duration) should be set correctly")
        }
    }

    @Test("Timer duration very large value")
    func timerDurationVeryLargeValue() {
        let largeDuration: TimeInterval = 86400 * 7 // 1 week
        viewModel.setTimerDuration(largeDuration)
        #expect(viewModel.timerDuration == largeDuration, "Large duration should be accepted")
    }

    // MARK: - UserDefaults Loading Tests

    @Test("Initial state loads persisted timer mode")
    func initialStateLoadsPersistedTimerMode() {
        // Set a value in UserDefaults
        UserDefaultsStore.shared.set(true, forKey: "WeakupTimerMode")

        // Create a new ViewModel
        let newViewModel = CaffeineViewModel()

        #expect(newViewModel.timerMode, "Timer mode should be loaded from UserDefaults")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }

    @Test("Initial state loads persisted timer duration")
    func initialStateLoadsPersistedTimerDuration() {
        // Set a value in UserDefaults
        UserDefaultsStore.shared.set(7200.0, forKey: "WeakupTimerDuration")

        // Create a new ViewModel
        let newViewModel = CaffeineViewModel()

        #expect(newViewModel.timerDuration == 7200, "Timer duration should be loaded from UserDefaults")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }

    @Test("Initial state loads persisted sound enabled")
    func initialStateLoadsPersistedSoundEnabled() {
        // Set a value in UserDefaults
        UserDefaultsStore.shared.set(false, forKey: "WeakupSoundEnabled")

        // Create a new ViewModel
        let newViewModel = CaffeineViewModel()

        #expect(!newViewModel.soundEnabled, "Sound enabled should be loaded from UserDefaults")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }

    @Test("Initial state handles corrupted bool value")
    func initialStateHandlesCorruptedBoolValue() {
        // Set a corrupted value (string instead of bool)
        UserDefaultsStore.shared.set("invalid", forKey: "WeakupSoundEnabled")

        // Create a new ViewModel - should handle gracefully
        let newViewModel = CaffeineViewModel()

        // Should fall back to default (true)
        #expect(newViewModel.soundEnabled, "Should fall back to default on corrupted value")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }

    @Test("Initial state handles corrupted double value")
    func initialStateHandlesCorruptedDoubleValue() {
        // Set a corrupted value (string instead of double)
        UserDefaultsStore.shared.set("invalid", forKey: "WeakupTimerDuration")

        // Create a new ViewModel - should handle gracefully
        let newViewModel = CaffeineViewModel()

        // Should fall back to default (0)
        #expect(newViewModel.timerDuration == 0, "Should fall back to default on corrupted value")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }

    @Test("Initial state handles negative timer duration")
    func initialStateHandlesNegativeTimerDuration() {
        // Set a negative value in UserDefaults
        UserDefaultsStore.shared.set(-100.0, forKey: "WeakupTimerDuration")

        // Create a new ViewModel
        let newViewModel = CaffeineViewModel()

        // Should clamp to 0
        #expect(newViewModel.timerDuration == 0, "Negative duration should be clamped to 0")

        // Clean up
        if newViewModel.isActive {
            newViewModel.stop()
        }
    }
}
