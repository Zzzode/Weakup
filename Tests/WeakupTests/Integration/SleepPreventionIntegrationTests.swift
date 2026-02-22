import Testing
import Foundation
@testable import WeakupCore

/// Integration tests for sleep prevention functionality
/// These tests verify the actual IOPMAssertion behavior
@Suite("Sleep Prevention Integration Tests", .serialized)
@MainActor
struct SleepPreventionIntegrationTests {

    private var viewModel: CaffeineViewModel

    init() {
        // Clear UserDefaults before each test
        UserDefaultsStore.shared.removeObject(forKey: "WeakupSoundEnabled")
        UserDefaultsStore.shared.removeObject(forKey: "WeakupTimerMode")
        UserDefaultsStore.shared.removeObject(forKey: "WeakupTimerDuration")

        viewModel = CaffeineViewModel()
        // Disable sound for tests
        viewModel.soundEnabled = false
    }

    // MARK: - Basic Sleep Prevention Tests

    @Test("Sleep prevention starts correctly")
    func sleepPrevention_startsCorrectly() {
        #expect(!viewModel.isActive)
        viewModel.start()
        #expect(viewModel.isActive, "Sleep prevention should be active after start")
        viewModel.stop()
    }

    @Test("Sleep prevention stops correctly")
    func sleepPrevention_stopsCorrectly() {
        viewModel.start()
        #expect(viewModel.isActive)
        viewModel.stop()
        #expect(!viewModel.isActive, "Sleep prevention should be inactive after stop")
    }

    @Test("Sleep prevention toggle works")
    func sleepPrevention_toggleWorks() {
        #expect(!viewModel.isActive)

        viewModel.toggle()
        #expect(viewModel.isActive, "First toggle should activate")

        viewModel.toggle()
        #expect(!viewModel.isActive, "Second toggle should deactivate")
    }

    @Test("Display sleep assertion is active")
    func sleepPrevention_displaySleepAssertionActive() throws {
        viewModel.start()
        defer { viewModel.stop() }

        let output = try pmsetAssertionsOutput()
        #expect(output.contains("PreventUserIdleDisplaySleep"))
        #expect(output.contains(AppConstants.powerAssertionReason))
    }

    // MARK: - Rapid Toggle Tests

    @Test("Multiple toggle maintains consistent state")
    func multipleToggle_maintainsConsistentState() {
        for i in 0..<10 {
            viewModel.toggle()
            let expectedState = (i % 2 == 0)
            #expect(viewModel.isActive == expectedState,
                    "State should be consistent after toggle \(i + 1)")
        }

        // Clean up - ensure we end in inactive state
        if viewModel.isActive {
            viewModel.stop()
        }
    }

    @Test("Rapid toggle has no assertion leak")
    func rapidToggle_noAssertionLeak() {
        // Rapidly toggle many times
        for _ in 0..<20 {
            viewModel.toggle()
        }

        // Should end in inactive state (even number of toggles)
        #expect(!viewModel.isActive, "Should be inactive after even number of toggles")

        // Verify we can still toggle normally
        viewModel.toggle()
        #expect(viewModel.isActive)
        viewModel.stop()
        #expect(!viewModel.isActive)
    }

    // MARK: - Start/Stop Edge Cases

    @Test("Start when already active remains active")
    func start_whenAlreadyActive_remainsActive() {
        viewModel.start()
        #expect(viewModel.isActive)

        viewModel.start() // Start again
        #expect(viewModel.isActive, "Should remain active after double start")
        viewModel.stop()
    }

    @Test("Stop when already inactive remains inactive")
    func stop_whenAlreadyInactive_remainsInactive() {
        #expect(!viewModel.isActive)

        viewModel.stop() // Stop when already inactive
        #expect(!viewModel.isActive, "Should remain inactive after stop when inactive")
    }

    @Test("Stop multiple times in row causes no error")
    func stop_multipleTimesInRow_noError() {
        viewModel.start()
        viewModel.stop()
        viewModel.stop()
        viewModel.stop()
        #expect(!viewModel.isActive, "Multiple stops should not cause error")
    }

    // MARK: - Timer Mode Integration

    @Test("Timer mode start with duration")
    func timerMode_startWithDuration() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60) // 1 minute

        viewModel.start()

        #expect(viewModel.isActive)
        #expect(viewModel.timerMode)
        #expect(abs(viewModel.timeRemaining - 60) < 1)
        viewModel.stop()
    }

    @Test("Timer mode stop resets time remaining")
    func timerMode_stopResetsTimeRemaining() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()

        #expect(viewModel.timeRemaining > 0)

        viewModel.stop()

        #expect(viewModel.timeRemaining == 0, "Time remaining should reset on stop")
    }

    @Test("Timer mode change duration while active stops")
    func timerMode_changeDurationWhileActive_stops() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()

        #expect(viewModel.isActive)

        viewModel.setTimerDuration(120) // Change duration

        #expect(!viewModel.isActive, "Changing duration while active should stop")
    }

    // MARK: - State Consistency Tests

    @Test("State consistency after multiple operations")
    func stateConsistency_afterMultipleOperations() {
        // Perform various operations
        viewModel.start()
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(30)
        viewModel.stop()
        viewModel.start()
        viewModel.toggle()

        // Verify state is consistent
        #expect(!viewModel.isActive)
        #expect(viewModel.timeRemaining == 0)
    }

    // MARK: - Helper Methods

    private func pmsetAssertionsOutput() throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-g", "assertions"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(decoding: data, as: UTF8.self)
    }
}

// MARK: - Timer Countdown Integration Tests

@Suite("Timer Countdown Integration Tests", .serialized)
@MainActor
struct TimerCountdownIntegrationTests {

    private var viewModel: CaffeineViewModel

    init() {
        UserDefaultsStore.shared.removeObject(forKey: "WeakupSoundEnabled")
        UserDefaultsStore.shared.removeObject(forKey: "WeakupTimerMode")
        UserDefaultsStore.shared.removeObject(forKey: "WeakupTimerDuration")

        viewModel = CaffeineViewModel()
        viewModel.soundEnabled = false
    }

    @Test("Timer countdown decrements")
    func timerCountdown_decrements() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(5) // 5 seconds

        viewModel.start()

        let initialTime = viewModel.timeRemaining

        // Wait for 2 seconds
        try await Task.sleep(nanoseconds: 2_000_000_000)

        let afterWait = viewModel.timeRemaining

        #expect(afterWait < initialTime, "Time should have decremented")
        #expect(abs(afterWait - (initialTime - 2)) < 1, "Should have decremented by ~2 seconds")

        viewModel.stop()
    }

    @Test("Timer countdown stops at zero")
    func timerCountdown_stopsAtZero() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(2) // 2 seconds

        viewModel.start()
        #expect(viewModel.isActive)

        // Wait for timer to expire (plus buffer)
        try await Task.sleep(nanoseconds: 3_000_000_000)

        #expect(!viewModel.isActive, "Should auto-stop when timer expires")
        #expect(viewModel.timeRemaining == 0, "Time remaining should be 0")
    }

    @Test("Timer countdown manual stop cancels")
    func timerCountdown_manualStopCancels() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)

        viewModel.start()

        // Wait briefly
        try await Task.sleep(nanoseconds: 500_000_000)

        viewModel.stop()

        #expect(!viewModel.isActive)
        #expect(viewModel.timeRemaining == 0)

        // Wait to ensure timer doesn't continue
        try await Task.sleep(nanoseconds: 1_000_000_000)

        #expect(!viewModel.isActive, "Should remain stopped")
    }
}
