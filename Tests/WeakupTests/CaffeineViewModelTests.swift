import XCTest
@testable import WeakupCore

@MainActor
final class CaffeineViewModelTests: XCTestCase {

    var viewModel: CaffeineViewModel!

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "WeakupSoundEnabled")
        UserDefaults.standard.removeObject(forKey: "WeakupTimerMode")
        UserDefaults.standard.removeObject(forKey: "WeakupTimerDuration")
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

    // MARK: - Initial State Tests

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

    // MARK: - Toggle Tests

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

    // MARK: - Start/Stop Tests

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

    // MARK: - Timer Duration Tests

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
        let storedValue = UserDefaults.standard.double(forKey: "WeakupTimerDuration")
        XCTAssertEqual(storedValue, 7200, "Duration should be persisted to UserDefaults")
    }

    // MARK: - Timer Mode Tests

    func testSetTimerMode_updatesValue() {
        viewModel.setTimerMode(true)
        XCTAssertTrue(viewModel.timerMode, "Timer mode should be enabled")
        viewModel.setTimerMode(false)
        XCTAssertFalse(viewModel.timerMode, "Timer mode should be disabled")
    }

    func testSetTimerMode_persistsValue() {
        viewModel.setTimerMode(true)
        let storedValue = UserDefaults.standard.bool(forKey: "WeakupTimerMode")
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

    // MARK: - Sound Enabled Tests

    func testSoundEnabled_persistsValue() {
        viewModel.soundEnabled = false
        let storedValue = UserDefaults.standard.bool(forKey: "WeakupSoundEnabled")
        XCTAssertFalse(storedValue, "Sound enabled should be persisted to UserDefaults")
    }

    func testSoundEnabled_toggles() {
        let initial = viewModel.soundEnabled
        viewModel.soundEnabled = !initial
        XCTAssertNotEqual(viewModel.soundEnabled, initial, "Sound enabled should toggle")
    }
}
