# Testing Guide

This document describes testing practices and procedures for Weakup.

## Test Architecture

```
Tests/
├── WeakupTests/
│   ├── CaffeineViewModelTests.swift        # Core logic (90% coverage target)
│   ├── L10nTests.swift                     # Localization (85% coverage target)
│   ├── ActivityHistoryManagerTests.swift   # History tracking
│   ├── HotkeyManagerTests.swift            # Keyboard shortcuts
│   ├── IconManagerTests.swift              # Icon management
│   ├── ThemeManagerTests.swift             # Theme management
│   ├── NotificationManagerTests.swift      # Notifications
│   ├── LaunchAtLoginManagerTests.swift     # Login item
│   ├── ActivitySessionTests.swift          # Data models
│   ├── AppLanguageTests.swift              # Language enum
│   ├── VersionTests.swift                  # Version info
│   ├── Integration/
│   │   ├── SleepPreventionIntegrationTests.swift
│   │   ├── TimerIntegrationTests.swift
│   │   ├── PersistenceIntegrationTests.swift
│   │   └── LocalizationIntegrationTests.swift
│   └── Mocks/
│       ├── MockNotificationCenter.swift
│       ├── MockNotificationManager.swift
│       ├── MockSleepPreventionService.swift
│       ├── MockUserDefaults.swift
│       └── TestFixtures.swift
└── WeakupUITests/
    ├── MenuBarUITests.swift
    ├── SettingsPopoverUITests.swift
    └── KeyboardShortcutUITests.swift
```

## Running Tests

### With Swift Package Manager

```bash
# Run all tests
swift test

# Run with verbose output
swift test --verbose

# Run specific test class
swift test --filter CaffeineViewModelTests

# Run specific test method
swift test --filter CaffeineViewModelTests/testToggle_startsWhenInactive

# Run tests with coverage (requires Xcode)
swift test --enable-code-coverage
```

If you see `sandbox-exec: sandbox_apply: Operation not permitted`, rerun with sandbox disabled:

```bash
swift test --disable-sandbox
```

### With Xcode

```bash
# Generate Xcode project
swift package generate-xcodeproj

# Open and run tests
open Weakup.xcodeproj
# Press Cmd+U to run tests
```

## Test Coverage Goals

| Component | Target | Current |
|-----------|--------|---------|
| CaffeineViewModel | 90% | - |
| L10n | 85% | - |
| ActivityHistoryManager | 80% | - |
| HotkeyManager | 75% | - |
| IconManager | 80% | - |
| ThemeManager | 80% | - |
| NotificationManager | 70% | - |
| LaunchAtLoginManager | 75% | - |
| Models | 90% | - |

## Unit Test Examples

### CaffeineViewModel Tests

```swift
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
        if viewModel.isActive {
            viewModel.stop()
        }
        viewModel = nil
        try await super.tearDown()
    }

    // Initial State Tests

    func testInitialState_isInactive() {
        XCTAssertFalse(viewModel.isActive)
    }

    func testInitialState_timerModeDisabled() {
        XCTAssertFalse(viewModel.timerMode)
    }

    func testInitialState_timeRemainingIsZero() {
        XCTAssertEqual(viewModel.timeRemaining, 0)
    }

    // Toggle Tests

    func testToggle_startsWhenInactive() {
        XCTAssertFalse(viewModel.isActive)
        viewModel.toggle()
        XCTAssertTrue(viewModel.isActive)
    }

    func testToggle_stopsWhenActive() {
        viewModel.start()
        XCTAssertTrue(viewModel.isActive)
        viewModel.toggle()
        XCTAssertFalse(viewModel.isActive)
    }

    // Timer Tests

    func testSetTimerDuration_updatesValue() {
        viewModel.setTimerDuration(3600)
        XCTAssertEqual(viewModel.timerDuration, 3600)
    }

    func testSetTimerDuration_negativeClampsToZero() {
        viewModel.setTimerDuration(-100)
        XCTAssertEqual(viewModel.timerDuration, 0)
    }

    func testTimerMode_withDuration_setsTimeRemaining() {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()
        XCTAssertEqual(viewModel.timeRemaining, 60, accuracy: 1)
    }
}
```

### L10n Tests

```swift
import XCTest
@testable import WeakupCore

@MainActor
final class L10nTests: XCTestCase {
    var l10n: L10n!

    override func setUp() async throws {
        try await super.setUp()
        l10n = L10n.shared
        // Reset to English for consistent tests
        l10n.setLanguage(.english)
    }

    func testSetLanguage_updatesCurrentLanguage() {
        l10n.setLanguage(.chinese)
        XCTAssertEqual(l10n.currentLanguage, .chinese)
    }

    func testSetLanguage_persistsToUserDefaults() {
        l10n.setLanguage(.japanese)
        let saved = UserDefaults.standard.string(forKey: "WeakupLanguage")
        XCTAssertEqual(saved, "ja")
    }

    func testString_returnsLocalizedValue() {
        l10n.setLanguage(.english)
        let result = l10n.string(forKey: "app_name")
        XCTAssertEqual(result, "Weakup")
    }

    func testString_fallsBackToEnglish() {
        // Set to a language that might be missing some keys
        l10n.setLanguage(.korean)
        let result = l10n.string(forKey: "app_name")
        // Should return English fallback if Korean is missing
        XCTAssertFalse(result.isEmpty)
    }

    func testAllLanguages_haveDisplayName() {
        for language in AppLanguage.allCases {
            XCTAssertFalse(language.displayName.isEmpty)
        }
    }
}
```

### ActivityHistoryManager Tests

```swift
import XCTest
@testable import WeakupCore

@MainActor
final class ActivityHistoryManagerTests: XCTestCase {
    var manager: ActivityHistoryManager!

    override func setUp() async throws {
        try await super.setUp()
        manager = ActivityHistoryManager.shared
        manager.clearHistory()
    }

    func testStartSession_createsCurrentSession() {
        manager.startSession(timerMode: false, timerDuration: nil)
        XCTAssertNotNil(manager.currentSession)
    }

    func testEndSession_movesToHistory() {
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        XCTAssertNil(manager.currentSession)
        XCTAssertEqual(manager.sessions.count, 1)
    }

    func testStatistics_calculatesCorrectly() {
        // Create a completed session
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.statistics
        XCTAssertEqual(stats.totalSessions, 1)
        XCTAssertGreaterThanOrEqual(stats.todaySessions, 1)
    }

    func testExportHistory_json() {
        manager.startSession(timerMode: true, timerDuration: 3600)
        manager.endSession()

        let result = manager.exportHistory(format: .json)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, .json)
    }

    func testExportHistory_csv() {
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let result = manager.exportHistory(format: .csv)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, .csv)
    }
}
```

### HotkeyManager Tests

```swift
import XCTest
@testable import WeakupCore

@MainActor
final class HotkeyManagerTests: XCTestCase {
    var manager: HotkeyManager!

    override func setUp() async throws {
        try await super.setUp()
        manager = HotkeyManager.shared
        manager.resetToDefault()
    }

    func testDefaultConfig_isCorrect() {
        let config = HotkeyConfig.defaultConfig
        XCTAssertEqual(config.keyCode, UInt32(kVK_ANSI_0))
    }

    func testDisplayString_formatsCorrectly() {
        let config = HotkeyConfig.defaultConfig
        XCTAssertTrue(config.displayString.contains("Cmd"))
        XCTAssertTrue(config.displayString.contains("Ctrl"))
        XCTAssertTrue(config.displayString.contains("0"))
    }

    func testCheckConflicts_detectsSystemShortcuts() {
        // Cmd+Q is a system shortcut
        let config = HotkeyConfig(keyCode: UInt32(kVK_ANSI_Q), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: config)
        XCTAssertFalse(conflicts.isEmpty)
        XCTAssertEqual(conflicts.first?.severity, .high)
    }

    func testStartRecording_setsFlag() {
        manager.startRecording()
        XCTAssertTrue(manager.isRecording)
    }

    func testStopRecording_clearsFlag() {
        manager.startRecording()
        manager.stopRecording()
        XCTAssertFalse(manager.isRecording)
    }
}
```

## Integration Tests

### Sleep Prevention Integration

```swift
import XCTest
@testable import WeakupCore

@MainActor
final class SleepPreventionIntegrationTests: XCTestCase {
    var viewModel: CaffeineViewModel!

    override func setUp() async throws {
        try await super.setUp()
        viewModel = CaffeineViewModel()
    }

    override func tearDown() async throws {
        if viewModel.isActive {
            viewModel.stop()
        }
        viewModel = nil
        try await super.tearDown()
    }

    func testFullCycle_startAndStop() {
        // Start
        viewModel.start()
        XCTAssertTrue(viewModel.isActive)

        // Verify assertion exists (check with pmset -g assertions)

        // Stop
        viewModel.stop()
        XCTAssertFalse(viewModel.isActive)
    }

    func testTimerMode_expiresCorrectly() async throws {
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(2) // 2 seconds
        viewModel.start()

        XCTAssertTrue(viewModel.isActive)
        XCTAssertEqual(viewModel.timeRemaining, 2, accuracy: 0.5)

        // Wait for timer to expire
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds

        XCTAssertFalse(viewModel.isActive)
        XCTAssertEqual(viewModel.timeRemaining, 0)
    }
}
```

## Mock Objects

### MockUserDefaults

```swift
import Foundation

class MockUserDefaults: UserDefaults {
    private var storage: [String: Any] = [:]

    override func object(forKey defaultName: String) -> Any? {
        storage[defaultName]
    }

    override func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }

    override func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }

    override func bool(forKey defaultName: String) -> Bool {
        storage[defaultName] as? Bool ?? false
    }

    override func double(forKey defaultName: String) -> Double {
        storage[defaultName] as? Double ?? 0
    }

    override func string(forKey defaultName: String) -> String? {
        storage[defaultName] as? String
    }

    override func data(forKey defaultName: String) -> Data? {
        storage[defaultName] as? Data
    }

    func reset() {
        storage.removeAll()
    }
}
```

### TestFixtures

```swift
import Foundation
@testable import WeakupCore

enum TestFixtures {
    static func createSession(
        startTime: Date = Date(),
        endTime: Date? = nil,
        wasTimerMode: Bool = false,
        timerDuration: TimeInterval? = nil
    ) -> ActivitySession {
        var session = ActivitySession(
            startTime: startTime,
            wasTimerMode: wasTimerMode,
            timerDuration: timerDuration
        )
        if let end = endTime {
            session.endTime = end
        }
        return session
    }

    static func createCompletedSession(duration: TimeInterval = 3600) -> ActivitySession {
        let startTime = Date().addingTimeInterval(-duration)
        return createSession(startTime: startTime, endTime: Date())
    }

    static var sampleSessions: [ActivitySession] {
        [
            createCompletedSession(duration: 3600),  // 1 hour
            createCompletedSession(duration: 1800),  // 30 min
            createCompletedSession(duration: 900),   // 15 min
        ]
    }
}
```

## Manual Testing

### Core Functionality Tests

#### 1. Sleep Prevention Toggle

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Enable sleep prevention | Click menu bar icon | Icon changes to filled, tooltip shows "On" |
| Disable sleep prevention | Click menu bar icon again | Icon changes to empty, tooltip shows "Off" |
| Verify assertion | Run `pmset -g assertions` | Shows Weakup assertion when enabled |

#### 2. Timer Mode

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Enable timer mode | Open Settings, toggle Timer Mode | Duration picker appears |
| Set duration | Select "15m" | Duration is set |
| Start timer | Click "Turn On" | Countdown displays |
| Timer expiry | Wait for countdown | Auto-disables, notification sent |

#### 3. Keyboard Shortcut

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Default shortcut | Press Cmd+Ctrl+0 | Toggles sleep prevention |
| Custom shortcut | Set new shortcut in settings | New shortcut works |
| Conflict detection | Set Cmd+C | Warning displayed |

#### 4. Language Switching

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Switch language | Select different language | UI updates immediately |
| Persistence | Restart app | Language preserved |

### Power Management Verification

```bash
# Before enabling Weakup
pmset -g assertions
# Note current assertions

# Enable Weakup, then run again
pmset -g assertions
# Should show:
# pid XXXX(weakup): PreventUserIdleSystemSleep named: "Weakup preventing sleep"

# Disable Weakup
pmset -g assertions
# Assertion should be removed
```

### Edge Cases

| Scenario | Test | Expected Behavior |
|----------|------|-------------------|
| Rapid toggling | Click icon repeatedly | State remains consistent |
| Timer while active | Enable timer mode while active | Stops current session |
| System sleep attempt | Try to sleep Mac while active | System stays awake |
| App termination | Quit app while active | Assertion released |
| Memory pressure | Run with limited memory | App remains responsive |

## Continuous Integration

Tests run automatically on every pull request via GitHub Actions.

### CI Configuration

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: swift build
      - name: Run tests
        run: swift test --enable-code-coverage
      - name: Generate coverage report
        run: |
          xcrun llvm-cov export \
            .build/debug/WeakupPackageTests.xctest/Contents/MacOS/WeakupPackageTests \
            -instr-profile .build/debug/codecov/default.profdata \
            -format lcov > coverage.lcov
```

## Test Data

### Localization Test Strings

Verify all localization keys have translations:

```bash
# List all keys in English
grep -o '"[^"]*"' Sources/Weakup/en.lproj/Localizable.strings | head -20

# Compare with other languages
for lang in zh-Hans zh-Hant ja ko fr de es; do
  echo "=== $lang ==="
  wc -l Sources/Weakup/$lang.lproj/Localizable.strings
done
```

## Reporting Issues

When reporting bugs, include:
- macOS version
- Weakup version
- Steps to reproduce
- Expected vs actual behavior
- Output of `pmset -g assertions`
- Console logs if available

### Getting Console Logs

```bash
# Stream Weakup logs
log stream --predicate 'subsystem == "com.weakup"' --level debug

# Or search recent logs
log show --predicate 'subsystem == "com.weakup"' --last 1h
```
