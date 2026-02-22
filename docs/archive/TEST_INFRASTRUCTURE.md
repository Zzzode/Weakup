# Test Infrastructure Design

**Version:** 1.0
**Date:** 2026-02-22
**Author:** Architecture Team

## Table of Contents

1. [Overview](#overview)
2. [Testing Philosophy](#testing-philosophy)
3. [Test Architecture](#test-architecture)
4. [Unit Testing Strategy](#unit-testing-strategy)
5. [Integration Testing Strategy](#integration-testing-strategy)
6. [UI Testing Strategy](#ui-testing-strategy)
7. [Test Patterns and Best Practices](#test-patterns-and-best-practices)
8. [Mocking and Stubbing](#mocking-and-stubbing)
9. [Test Coverage Goals](#test-coverage-goals)
10. [CI/CD Integration](#cicd-integration)

---

## Overview

This document outlines the comprehensive testing strategy for the Weakup application. The goal is to achieve high test coverage, ensure code quality, and enable confident refactoring.

### Current Testing State

**Existing Tests**:
- ✅ CaffeineViewModelTests (18 tests)
- ✅ ActivityHistoryManagerTests (13 tests)
- ✅ ActivitySessionTests
- ✅ IconManagerTests
- ✅ ThemeManagerTests
- ✅ VersionTests
- ✅ AppLanguageTests
- ✅ HotkeyManagerTests

**Coverage**: ~60% (estimated)

**Gaps**:
- ❌ NotificationManager tests
- ❌ LaunchAtLoginManager tests
- ❌ L10n comprehensive tests
- ❌ Integration tests
- ❌ UI tests
- ❌ AppDelegate tests

---

## Testing Philosophy

### 1. Test Pyramid

```
        ┌─────────┐
        │   UI    │  10% - Critical user flows
        │  Tests  │
        ├─────────┤
        │ Integr. │  20% - Component interactions
        │  Tests  │
        ├─────────┤
        │  Unit   │  70% - Individual components
        │  Tests  │
        └─────────┘
```

### 2. Testing Principles

1. **Fast**: Unit tests should run in milliseconds
2. **Isolated**: Tests don't depend on each other
3. **Repeatable**: Same results every time
4. **Self-Validating**: Pass/fail, no manual verification
5. **Timely**: Written alongside production code

### 3. What to Test

**DO Test**:
- ✅ Business logic (ViewModels, Managers)
- ✅ State transitions
- ✅ Edge cases and error handling
- ✅ Data persistence and retrieval
- ✅ Calculations and transformations

**DON'T Test**:
- ❌ SwiftUI view rendering (trust the framework)
- ❌ Third-party library internals
- ❌ System APIs (IOKit, Carbon) - mock instead
- ❌ Trivial getters/setters

---

## Test Architecture

### Directory Structure

```
Tests/
└── WeakupTests/
    ├── Unit/
    │   ├── ViewModels/
    │   │   └── CaffeineViewModelTests.swift
    │   ├── Managers/
    │   │   ├── ActivityHistoryManagerTests.swift
    │   │   ├── NotificationManagerTests.swift
    │   │   ├── HotkeyManagerTests.swift
    │   │   ├── IconManagerTests.swift
    │   │   ├── ThemeManagerTests.swift
    │   │   ├── LaunchAtLoginManagerTests.swift
    │   │   └── L10nTests.swift
    │   └── Models/
    │       ├── ActivitySessionTests.swift
    │       └── HotkeyConfigTests.swift
    ├── Integration/
    │   ├── CaffeineIntegrationTests.swift
    │   ├── HistoryIntegrationTests.swift
    │   └── NotificationIntegrationTests.swift
    ├── UI/
    │   ├── SettingsViewUITests.swift
    │   └── MenuBarUITests.swift
    ├── Mocks/
    │   ├── MockPowerManager.swift
    │   ├── MockNotificationManager.swift
    │   ├── MockPreferencesService.swift
    │   └── MockTimerFactory.swift
    └── Helpers/
        ├── XCTestCase+Async.swift
        ├── XCTestCase+UserDefaults.swift
        └── TestHelpers.swift
```

### Test Target Configuration

```swift
// Package.swift
.testTarget(
    name: "WeakupTests",
    dependencies: ["WeakupCore"],
    path: "Tests/WeakupTests",
    resources: [
        .copy("Fixtures/")
    ]
)
```

---

## Unit Testing Strategy

### 1. ViewModel Testing

#### CaffeineViewModel Tests

**Coverage Areas**:
- ✅ Initial state
- ✅ Toggle behavior
- ✅ Start/stop operations
- ✅ Timer mode
- ✅ Timer duration
- ✅ Persistence
- ⚠️ IOPMAssertion (needs mocking)
- ⚠️ Timer behavior (needs better testing)
- ❌ Sound playback (needs mocking)
- ❌ Notification integration

**Test Pattern**:
```swift
@MainActor
final class CaffeineViewModelTests: XCTestCase {
    var viewModel: CaffeineViewModel!
    var mockPowerManager: MockPowerManager!
    var mockNotificationManager: MockNotificationManager!

    override func setUp() async throws {
        try await super.setUp()
        clearUserDefaults()
        mockPowerManager = MockPowerManager()
        mockNotificationManager = MockNotificationManager()
        viewModel = CaffeineViewModel(
            powerManager: mockPowerManager,
            notificationManager: mockNotificationManager
        )
    }

    override func tearDown() async throws {
        if viewModel.isActive {
            viewModel.stop()
        }
        viewModel = nil
        mockPowerManager = nil
        mockNotificationManager = nil
        try await super.tearDown()
    }

    func testStart_createsAssertion() {
        viewModel.start()
        XCTAssertTrue(mockPowerManager.assertionCreated)
        XCTAssertTrue(viewModel.isActive)
    }

    func testStop_releasesAssertion() {
        viewModel.start()
        let assertionID = mockPowerManager.lastAssertionID
        viewModel.stop()
        XCTAssertTrue(mockPowerManager.assertionReleased(assertionID))
        XCTAssertFalse(viewModel.isActive)
    }

    func testTimerExpiry_sendsNotification() async {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(1) // 1 second
        viewModel.start()

        // Wait for timer to expire
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s

        XCTAssertFalse(viewModel.isActive)
        XCTAssertTrue(mockNotificationManager.notificationScheduled)
    }
}
```

### 2. Manager Testing

#### ActivityHistoryManager Tests

**Current Coverage**: Good ✅
- Session lifecycle
- Statistics calculation
- Persistence
- Clearing history

**Improvements Needed**:
- Test max session limit (100)
- Test concurrent access (if needed)
- Test data migration (if format changes)

#### NotificationManager Tests (NEW)

**Test Cases**:
```swift
@MainActor
final class NotificationManagerTests: XCTestCase {
    var manager: NotificationManager!
    var mockNotificationCenter: MockUNUserNotificationCenter!

    func testRequestAuthorization_updatesAuthorizationStatus() async {
        mockNotificationCenter.authorizationGranted = true
        await manager.requestAuthorization()
        XCTAssertTrue(manager.isAuthorized)
    }

    func testScheduleNotification_whenDisabled_doesNotSchedule() {
        manager.notificationsEnabled = false
        manager.scheduleTimerExpiryNotification()
        XCTAssertFalse(mockNotificationCenter.notificationScheduled)
    }

    func testScheduleNotification_whenEnabled_schedulesNotification() {
        manager.notificationsEnabled = true
        manager.isAuthorized = true
        manager.scheduleTimerExpiryNotification()
        XCTAssertTrue(mockNotificationCenter.notificationScheduled)
    }

    func testRestartAction_triggersCallback() {
        var callbackFired = false
        manager.onRestartRequested = { callbackFired = true }

        let response = MockNotificationResponse(actionIdentifier: "RESTART_TIMER")
        manager.userNotificationCenter(
            mockNotificationCenter,
            didReceive: response,
            withCompletionHandler: {}
        )

        XCTAssertTrue(callbackFired)
    }
}
```

#### HotkeyManager Tests

**Current Coverage**: Good ✅
- Config persistence
- Recording mode
- Reset to default
- Display string formatting

**Improvements Needed**:
- Test actual hotkey registration (requires mocking Carbon)
- Test conflict detection
- Test modifier combinations

#### L10n Tests (EXPAND)

**Current Tests**: Basic language switching
**Needed Tests**:
```swift
@MainActor
final class L10nTests: XCTestCase {
    func testLanguageDetection_simplifiedChinese() {
        // Mock system locale
        let l10n = L10n()
        // Test detection logic
    }

    func testStringFallback_missingKey_returnsEnglish() {
        let l10n = L10n.shared
        l10n.currentLanguage = .chinese
        let result = l10n.string(forKey: "nonexistent_key")
        // Should fall back to English or formatted key
        XCTAssertNotEqual(result, "nonexistent_key")
    }

    func testAllLocalizedStrings_exist() {
        for language in AppLanguage.allCases {
            L10n.shared.currentLanguage = language
            // Verify all keys have values
            XCTAssertFalse(L10n.shared.appName.isEmpty)
            XCTAssertFalse(L10n.shared.menuSettings.isEmpty)
            // ... test all keys
        }
    }

    func testLanguagePersistence() {
        L10n.shared.setLanguage(.japanese)
        // Create new instance (simulates app restart)
        let newL10n = L10n()
        XCTAssertEqual(newL10n.currentLanguage, .japanese)
    }
}
```

### 3. Model Testing

#### ActivitySession Tests

**Current Coverage**: Good ✅
**Improvements**: Test Codable encoding/decoding

#### HotkeyConfig Tests (NEW)

```swift
final class HotkeyConfigTests: XCTestCase {
    func testDisplayString_allModifiers() {
        let config = HotkeyConfig(
            keyCode: UInt32(kVK_ANSI_A),
            modifiers: UInt32(cmdKey | controlKey | optionKey | shiftKey)
        )
        XCTAssertEqual(config.displayString, "Ctrl + Option + Shift + Cmd + A")
    }

    func testCodable_encodeDecode() throws {
        let original = HotkeyConfig.defaultConfig
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(HotkeyConfig.self, from: data)
        XCTAssertEqual(original, decoded)
    }
}
```

---

## Integration Testing Strategy

### 1. Caffeine Integration Tests

**Purpose**: Test ViewModel + Managers interaction

```swift
@MainActor
final class CaffeineIntegrationTests: XCTestCase {
    var viewModel: CaffeineViewModel!
    var historyManager: ActivityHistoryManager!

    override func setUp() async throws {
        try await super.setUp()
        clearUserDefaults()
        viewModel = CaffeineViewModel()
        historyManager = ActivityHistoryManager.shared
    }

    func testStartStop_createsHistorySession() {
        let initialCount = historyManager.sessions.count

        viewModel.start()
        // Simulate AppDelegate behavior
        historyManager.startSession(
            timerMode: viewModel.timerMode,
            timerDuration: viewModel.timerMode ? viewModel.timerDuration : nil
        )

        XCTAssertNotNil(historyManager.currentSession)

        viewModel.stop()
        historyManager.endSession()

        XCTAssertEqual(historyManager.sessions.count, initialCount + 1)
        XCTAssertNil(historyManager.currentSession)
    }

    func testTimerMode_recordsDuration() async {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(2) // 2 seconds

        viewModel.start()
        historyManager.startSession(timerMode: true, timerDuration: 2)

        try? await Task.sleep(nanoseconds: 2_500_000_000) // 2.5s

        // Timer should have expired
        XCTAssertFalse(viewModel.isActive)

        historyManager.endSession()
        let lastSession = historyManager.sessions.first
        XCTAssertNotNil(lastSession)
        XCTAssertTrue(lastSession!.wasTimerMode)
        XCTAssertEqual(lastSession!.timerDuration, 2, accuracy: 0.1)
    }
}
```

### 2. Notification Integration Tests

```swift
@MainActor
final class NotificationIntegrationTests: XCTestCase {
    var viewModel: CaffeineViewModel!
    var notificationManager: NotificationManager!

    func testTimerExpiry_sendsNotification_restartWorks() async {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(1)
        viewModel.start()

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        // Verify notification sent
        // Simulate user tapping restart
        notificationManager.onRestartRequested?()

        // Verify timer restarted
        XCTAssertTrue(viewModel.isActive)
        XCTAssertTrue(viewModel.timerMode)
    }
}
```

### 3. Hotkey Integration Tests

```swift
@MainActor
final class HotkeyIntegrationTests: XCTestCase {
    var appDelegate: AppDelegate!
    var viewModel: CaffeineViewModel!
    var hotkeyManager: HotkeyManager!

    func testHotkey_togglesCaffeine() {
        XCTAssertFalse(viewModel.isActive)

        // Simulate hotkey press
        hotkeyManager.onHotkeyPressed?()

        XCTAssertTrue(viewModel.isActive)

        hotkeyManager.onHotkeyPressed?()

        XCTAssertFalse(viewModel.isActive)
    }

    func testHotkeyChange_reregisters() {
        let newConfig = HotkeyConfig(
            keyCode: UInt32(kVK_ANSI_K),
            modifiers: UInt32(cmdKey | shiftKey)
        )

        hotkeyManager.currentConfig = newConfig

        // Verify old hotkey doesn't work
        // Verify new hotkey works
        // (Requires mocking Carbon API)
    }
}
```

---

## UI Testing Strategy

### 1. Settings View UI Tests

**Test Cases**:
```swift
final class SettingsViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testToggleCaffeine_updatesUI() {
        // Open settings
        app.statusItems.firstMatch.click()
        app.menuItems["Settings"].click()

        let toggleButton = app.buttons["Turn On"]
        XCTAssertTrue(toggleButton.exists)

        toggleButton.click()

        // Verify button changed
        let stopButton = app.buttons["Turn Off"]
        XCTAssertTrue(stopButton.exists)

        // Verify status indicator
        let statusText = app.staticTexts["Preventing system sleep"]
        XCTAssertTrue(statusText.exists)
    }

    func testTimerMode_showsCountdown() {
        app.statusItems.firstMatch.click()
        app.menuItems["Settings"].click()

        // Enable timer mode
        app.switches["Timer Mode"].click()

        // Select duration
        app.popUpButtons["Duration"].click()
        app.menuItems["15 minutes"].click()

        // Start
        app.buttons["Turn On"].click()

        // Verify countdown appears
        let countdown = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "\\d{2}:\\d{2}")).firstMatch
        XCTAssertTrue(countdown.exists)
    }

    func testLanguageSwitch_updatesUI() {
        app.statusItems.firstMatch.click()
        app.menuItems["Settings"].click()

        // Change language
        app.popUpButtons["Language"].click()
        app.menuItems["简体中文"].click()

        // Verify UI updated
        let chineseText = app.staticTexts["设置"]
        XCTAssertTrue(chineseText.exists)
    }
}
```

### 2. Menu Bar UI Tests

```swift
final class MenuBarUITests: XCTestCase {
    func testLeftClick_togglesCaffeine() {
        let statusItem = app.statusItems.firstMatch
        XCTAssertTrue(statusItem.exists)

        statusItem.click()

        // Verify icon changed (active state)
        // This is tricky - may need to check accessibility description
    }

    func testRightClick_showsMenu() {
        let statusItem = app.statusItems.firstMatch
        statusItem.rightClick()

        XCTAssertTrue(app.menuItems["Settings"].exists)
        XCTAssertTrue(app.menuItems["Quit"].exists)
    }

    func testMenuBarCountdown_updates() {
        // Enable timer and countdown in menu bar
        // Start timer
        // Verify menu bar shows countdown
        // Wait 1 second
        // Verify countdown decreased
    }
}
```

---

## Test Patterns and Best Practices

### 1. Test Naming Convention

```swift
// Pattern: test[MethodName]_[Scenario]_[ExpectedResult]
func testStart_whenInactive_activatesViewModel()
func testStop_whenActive_releasesAssertion()
func testSetTimerDuration_negativeValue_clampsToZero()
```

### 2. Arrange-Act-Assert Pattern

```swift
func testToggle_startsWhenInactive() {
    // Arrange
    XCTAssertFalse(viewModel.isActive)

    // Act
    viewModel.toggle()

    // Assert
    XCTAssertTrue(viewModel.isActive)
}
```

### 3. Test Fixtures

```swift
// Tests/WeakupTests/Helpers/TestHelpers.swift
@MainActor
enum TestHelpers {
    static func createTestSession(
        startTime: Date = Date(),
        duration: TimeInterval = 60,
        timerMode: Bool = false
    ) -> ActivitySession {
        var session = ActivitySession(
            startTime: startTime,
            wasTimerMode: timerMode,
            timerDuration: timerMode ? duration : nil
        )
        session.end()
        return session
    }

    static func clearUserDefaults() {
        let keys = [
            "WeakupSoundEnabled",
            "WeakupTimerMode",
            "WeakupTimerDuration",
            "WeakupActivityHistory",
            "WeakupIconStyle",
            "WeakupTheme",
            "WeakupHotkeyConfig",
            "WeakupLanguage",
            "WeakupNotificationsEnabled"
        ]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
}
```

### 4. Async Testing

```swift
// Tests/WeakupTests/Helpers/XCTestCase+Async.swift
extension XCTestCase {
    @MainActor
    func waitForCondition(
        timeout: TimeInterval = 1.0,
        condition: @escaping () -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            if Date() > deadline {
                XCTFail("Timeout waiting for condition")
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }
    }
}

// Usage:
func testTimerExpiry() async throws {
    viewModel.setTimerDuration(1)
    viewModel.start()

    try await waitForCondition { !self.viewModel.isActive }

    XCTAssertFalse(viewModel.isActive)
}
```

### 5. UserDefaults Testing

```swift
// Tests/WeakupTests/Helpers/XCTestCase+UserDefaults.swift
extension XCTestCase {
    var testUserDefaults: UserDefaults {
        let suiteName = "com.weakup.tests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    func withTestUserDefaults<T>(_ block: (UserDefaults) throws -> T) rethrows -> T {
        let defaults = testUserDefaults
        defer {
            defaults.removePersistentDomain(forName: defaults.suiteName!)
        }
        return try block(defaults)
    }
}
```

---

## Mocking and Stubbing

### 1. Power Manager Mock

```swift
// Tests/WeakupTests/Mocks/MockPowerManager.swift
@MainActor
final class MockPowerManager: PowerManaging {
    var assertionCreated = false
    var assertionReleased = false
    var lastAssertionID: IOPMAssertionID = 0
    var shouldFailCreation = false
    private var nextAssertionID: IOPMAssertionID = 1

    func createAssertion() -> IOPMAssertionID? {
        guard !shouldFailCreation else { return nil }
        assertionCreated = true
        lastAssertionID = nextAssertionID
        nextAssertionID += 1
        return lastAssertionID
    }

    func releaseAssertion(_ id: IOPMAssertionID) {
        assertionReleased = true
    }

    func assertionReleased(_ id: IOPMAssertionID) -> Bool {
        assertionReleased && lastAssertionID == id
    }

    func reset() {
        assertionCreated = false
        assertionReleased = false
        lastAssertionID = 0
        shouldFailCreation = false
    }
}
```

### 2. Notification Manager Mock

```swift
// Tests/WeakupTests/Mocks/MockNotificationManager.swift
@MainActor
final class MockNotificationManager: NotificationManaging {
    var notificationsEnabled: Bool = true
    var isAuthorized: Bool = true
    var notificationScheduled = false
    var notificationCancelled = false
    var scheduledNotificationContent: String?

    func scheduleTimerExpiryNotification() {
        guard notificationsEnabled && isAuthorized else { return }
        notificationScheduled = true
        scheduledNotificationContent = "Timer expired"
    }

    func cancelPendingNotifications() {
        notificationCancelled = true
    }

    func reset() {
        notificationScheduled = false
        notificationCancelled = false
        scheduledNotificationContent = nil
    }
}
```

### 3. Preferences Service Mock

```swift
// Tests/WeakupTests/Mocks/MockPreferencesService.swift
final class MockPreferencesService: PreferencesService {
    private var storage: [String: Any] = [:]

    func bool(forKey key: String) -> Bool {
        storage[key] as? Bool ?? false
    }

    func set(_ value: Bool, forKey key: String) {
        storage[key] = value
    }

    func double(forKey key: String) -> Double {
        storage[key] as? Double ?? 0.0
    }

    func set(_ value: Double, forKey key: String) {
        storage[key] = value
    }

    func data(forKey key: String) -> Data? {
        storage[key] as? Data
    }

    func set(_ value: Data?, forKey key: String) {
        storage[key] = value
    }

    func reset() {
        storage.removeAll()
    }
}
```

### 4. Timer Factory Mock

```swift
// Tests/WeakupTests/Mocks/MockTimerFactory.swift
@MainActor
protocol TimerFactory {
    func makeTimer(
        interval: TimeInterval,
        repeats: Bool,
        block: @escaping (Timer) -> Void
    ) -> Timer
}

@MainActor
final class MockTimerFactory: TimerFactory {
    var timers: [MockTimer] = []

    func makeTimer(
        interval: TimeInterval,
        repeats: Bool,
        block: @escaping (Timer) -> Void
    ) -> Timer {
        let timer = MockTimer(interval: interval, repeats: repeats, block: block)
        timers.append(timer)
        return timer
    }

    func fireAllTimers() {
        timers.forEach { $0.fire() }
    }
}

@MainActor
final class MockTimer: Timer {
    let interval: TimeInterval
    let repeats: Bool
    let block: (Timer) -> Void
    var isValid = true

    init(interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) {
        self.interval = interval
        self.repeats = repeats
        self.block = block
        super.init()
    }

    override func fire() {
        guard isValid else { return }
        block(self)
        if !repeats {
            invalidate()
        }
    }

    override func invalidate() {
        isValid = false
    }
}
```

---

## Test Coverage Goals

### Overall Target: 80%+

| Component | Current | Target | Priority |
|-----------|---------|--------|----------|
| CaffeineViewModel | 70% | 90% | High |
| ActivityHistoryManager | 85% | 90% | Medium |
| NotificationManager | 0% | 80% | High |
| HotkeyManager | 75% | 85% | Medium |
| IconManager | 80% | 85% | Low |
| ThemeManager | 80% | 85% | Low |
| LaunchAtLoginManager | 0% | 70% | Medium |
| L10n | 40% | 80% | High |
| ActivitySession | 90% | 95% | Low |
| AppDelegate | 0% | 60% | Medium |

### Coverage Measurement

```bash
# Generate coverage report
swift test --enable-code-coverage

# View coverage
xcrun llvm-cov show \
  .build/debug/WeakupPackageTests.xctest/Contents/MacOS/WeakupPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata \
  -use-color

# Export coverage report
xcrun llvm-cov export \
  .build/debug/WeakupPackageTests.xctest/Contents/MacOS/WeakupPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata \
  -format=lcov > coverage.lcov
```

### Coverage Enforcement

```swift
// Add to Package.swift (future Swift versions)
.testTarget(
    name: "WeakupTests",
    dependencies: ["WeakupCore"],
    minimumCoveragePercentage: 80
)
```

---

## CI/CD Integration

### 1. GitHub Actions Workflow

```yaml
# .github/workflows/tests.yml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Run tests
        run: swift test --enable-code-coverage

      - name: Generate coverage report
        run: |
          xcrun llvm-cov export \
            .build/debug/WeakupPackageTests.xctest/Contents/MacOS/WeakupPackageTests \
            -instr-profile=.build/debug/codecov/default.profdata \
            -format=lcov > coverage.lcov

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.lcov
          fail_ci_if_error: true

      - name: Check coverage threshold
        run: |
          COVERAGE=$(swift test --enable-code-coverage 2>&1 | grep -o '[0-9.]*%' | head -1 | tr -d '%')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi
```

### 2. Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash

echo "Running tests..."
swift test

if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi

echo "All tests passed!"
```

### 3. Test Reporting

```bash
# Generate HTML report
swift test --enable-code-coverage
xcrun llvm-cov show \
  .build/debug/WeakupPackageTests.xctest/Contents/MacOS/WeakupPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata \
  -format=html \
  -output-dir=coverage-report

open coverage-report/index.html
```

---

## Testing Checklist

### Before Committing

- [ ] All tests pass locally
- [ ] New tests added for new features
- [ ] Edge cases covered
- [ ] UserDefaults cleaned up in tearDown
- [ ] No hardcoded delays (use proper async testing)
- [ ] Tests are isolated (no dependencies between tests)
- [ ] Test names follow convention
- [ ] Mocks reset between tests

### Before Release

- [ ] All tests pass in CI
- [ ] Coverage meets threshold (80%+)
- [ ] Integration tests pass
- [ ] UI tests pass on target macOS versions
- [ ] Performance tests pass (if applicable)
- [ ] Manual testing completed
- [ ] Regression testing completed

---

## Future Improvements

### 1. Performance Testing

```swift
func testPerformance_historyLoading() {
    // Create 100 sessions
    for _ in 0..<100 {
        historyManager.startSession(timerMode: false, timerDuration: nil)
        historyManager.endSession()
    }

    measure {
        _ = historyManager.statistics
    }
}
```

### 2. Snapshot Testing

```swift
// Using swift-snapshot-testing
func testSettingsView_snapshot() {
    let view = SettingsView(viewModel: viewModel)
    assertSnapshot(matching: view, as: .image)
}
```

### 3. Property-Based Testing

```swift
// Using swift-check
func testTimerDuration_alwaysNonNegative() {
    property("Timer duration is never negative") <- forAll { (duration: Double) in
        viewModel.setTimerDuration(duration)
        return viewModel.timerDuration >= 0
    }.check()
}
```

### 4. Mutation Testing

Use tools like Stryker to verify test quality by introducing mutations and checking if tests catch them.

---

## Conclusion

This test infrastructure provides:

- ✅ Comprehensive unit test coverage
- ✅ Integration tests for component interactions
- ✅ UI tests for critical user flows
- ✅ Mocking strategy for system dependencies
- ✅ CI/CD integration
- ✅ Coverage measurement and enforcement

Following these patterns will ensure high code quality, enable confident refactoring, and catch bugs early in development.
