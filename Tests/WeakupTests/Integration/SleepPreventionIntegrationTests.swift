import XCTest
@testable import WeakupCore

/// Integration tests for sleep prevention functionality
/// These tests verify the actual IOPMAssertion behavior
@MainActor
final class SleepPreventionIntegrationTests: XCTestCase {

    var viewModel: CaffeineViewModel!

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "WeakupSoundEnabled")
        UserDefaults.standard.removeObject(forKey: "WeakupTimerMode")
        UserDefaults.standard.removeObject(forKey: "WeakupTimerDuration")

        viewModel = CaffeineViewModel()
        // Disable sound for tests
        viewModel.soundEnabled = false
    }

    override func tearDown() async throws {
        // Ensure we stop any active session
        if viewModel.isActive {
            viewModel.stop()
        }
        viewModel = nil
        try await super.tearDown()
    }

    // Basic Sleep Prevention Tests

    func testSleepPrevention_startsCorrectly() {
        XCTAssertFalse(viewModel.isActive)
        viewModel.start()
        XCTAssertTrue(viewModel.isActive, "Sleep prevention should be active after start")
    }

    func testSleepPrevention_stopsCorrectly() {
        viewModel.start()
        XCTAssertTrue(viewModel.isActive)
        viewModel.stop()
        XCTAssertFalse(viewModel.isActive, "Sleep prevention should be inactive after stop")
    }

    func testSleepPrevention_toggleWorks() {
        XCTAssertFalse(viewModel.isActive)

        viewModel.toggle()
        XCTAssertTrue(viewModel.isActive, "First toggle should activate")

        viewModel.toggle()
        XCTAssertFalse(viewModel.isActive, "Second toggle should deactivate")
    }

    func testSleepPrevention_displaySleepAssertionActive() {
        viewModel.start()
        defer { viewModel.stop() }

        do {
            let output = try pmsetAssertionsOutput()
            XCTAssertTrue(output.contains("PreventUserIdleDisplaySleep"))
            XCTAssertTrue(output.contains(AppConstants.powerAssertionReason))
        } catch {
            XCTFail("Failed to read pmset assertions: \(error)")
        }
    }

    // Rapid Toggle Tests

    func testMultipleToggle_maintainsConsistentState() {
        for i in 0..<10 {
            viewModel.toggle()
            let expectedState = (i % 2 == 0)
            XCTAssertEqual(viewModel.isActive, expectedState,
                           "State should be consistent after toggle \(i + 1)")
        }

        // Clean up - ensure we end in inactive state
        if viewModel.isActive {
            viewModel.stop()
        }
    }

    func testRapidToggle_noAssertionLeak() {
        // Rapidly toggle many times
        for _ in 0..<20 {
            viewModel.toggle()
        }

        // Should end in inactive state (even number of toggles)
        XCTAssertFalse(viewModel.isActive, "Should be inactive after even number of toggles")

        // Verify we can still toggle normally
        viewModel.toggle()
        XCTAssertTrue(viewModel.isActive)
        viewModel.stop()
        XCTAssertFalse(viewModel.isActive)
    }

    // Start/Stop Edge Cases

    func testStart_whenAlreadyActive_remainsActive() {
        viewModel.start()
        XCTAssertTrue(viewModel.isActive)

        viewModel.start() // Start again
        XCTAssertTrue(viewModel.isActive, "Should remain active after double start")
    }

    func testStop_whenAlreadyInactive_remainsInactive() {
        XCTAssertFalse(viewModel.isActive)

        viewModel.stop() // Stop when already inactive
        XCTAssertFalse(viewModel.isActive, "Should remain inactive after stop when inactive")
    }

    func testStop_multipleTimesInRow_noError() {
        viewModel.start()
        viewModel.stop()
        viewModel.stop()
        viewModel.stop()
        XCTAssertFalse(viewModel.isActive, "Multiple stops should not cause error")
    }

    // Timer Mode Integration

    func testTimerMode_startWithDuration() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60) // 1 minute

        viewModel.start()

        XCTAssertTrue(viewModel.isActive)
        XCTAssertTrue(viewModel.timerMode)
        XCTAssertEqual(viewModel.timeRemaining, 60, accuracy: 1)
    }

    func testTimerMode_stopResetsTimeRemaining() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()

        XCTAssertGreaterThan(viewModel.timeRemaining, 0)

        viewModel.stop()

        XCTAssertEqual(viewModel.timeRemaining, 0, "Time remaining should reset on stop")
    }

    func testTimerMode_changeDurationWhileActive_stops() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()

        XCTAssertTrue(viewModel.isActive)

        viewModel.setTimerDuration(120) // Change duration

        XCTAssertFalse(viewModel.isActive, "Changing duration while active should stop")
    }

    // State Consistency Tests

    func testStateConsistency_afterMultipleOperations() {
        // Perform various operations
        viewModel.start()
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(30)
        viewModel.stop()
        viewModel.start()
        viewModel.toggle()

        // Verify state is consistent
        XCTAssertFalse(viewModel.isActive)
        XCTAssertEqual(viewModel.timeRemaining, 0)
    }

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

// Timer Countdown Integration Tests

@MainActor
final class TimerCountdownIntegrationTests: XCTestCase {

    var viewModel: CaffeineViewModel!

    override func setUp() async throws {
        try await super.setUp()
        UserDefaults.standard.removeObject(forKey: "WeakupSoundEnabled")
        UserDefaults.standard.removeObject(forKey: "WeakupTimerMode")
        UserDefaults.standard.removeObject(forKey: "WeakupTimerDuration")

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

    func testTimerCountdown_decrements() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(5) // 5 seconds

        viewModel.start()

        let initialTime = viewModel.timeRemaining

        // Wait for 2 seconds
        try await Task.sleep(nanoseconds: 2_000_000_000)

        let afterWait = viewModel.timeRemaining

        XCTAssertLessThan(afterWait, initialTime, "Time should have decremented")
        XCTAssertEqual(afterWait, initialTime - 2, accuracy: 1, "Should have decremented by ~2 seconds")

        viewModel.stop()
    }

    func testTimerCountdown_stopsAtZero() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(2) // 2 seconds

        viewModel.start()
        XCTAssertTrue(viewModel.isActive)

        // Wait for timer to expire (plus buffer)
        try await Task.sleep(nanoseconds: 3_000_000_000)

        XCTAssertFalse(viewModel.isActive, "Should auto-stop when timer expires")
        XCTAssertEqual(viewModel.timeRemaining, 0, "Time remaining should be 0")
    }

    func testTimerCountdown_manualStopCancels() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)

        viewModel.start()

        // Wait briefly
        try await Task.sleep(nanoseconds: 500_000_000)

        viewModel.stop()

        XCTAssertFalse(viewModel.isActive)
        XCTAssertEqual(viewModel.timeRemaining, 0)

        // Wait to ensure timer doesn't continue
        try await Task.sleep(nanoseconds: 1_000_000_000)

        XCTAssertFalse(viewModel.isActive, "Should remain stopped")
    }
}
