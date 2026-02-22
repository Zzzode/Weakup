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
└── WeakupUITests/                              # XCTest-based (cannot use Swift Testing)
    ├── MenuBarUITests.swift
    ├── SettingsPopoverUITests.swift
    └── KeyboardShortcutUITests.swift
```

### UI Tests and Swift Testing

**Important:** UI tests in `WeakupUITests/` intentionally use XCTest framework and cannot be migrated to Swift Testing. This is because:

- Swift Testing does not support UI testing
- XCUIApplication, XCUIElement, and the entire XCUITest framework are only available through XCTest
- This is a documented limitation of Swift Testing, which is designed for unit and integration tests only

UI tests require:
- XCTest framework (XCUITest)
- Xcode project configuration
- Accessibility permissions for UI element interaction

## Testing Frameworks

### Mixed Testing Approach

Weakup uses a **mixed testing approach** with two frameworks:

| Framework | Use Case | Test Types |
|-----------|----------|------------|
| **Swift Testing** | Unit and integration tests | WeakupTests (unit, integration) |
| **XCTest** | UI tests only | WeakupUITests |

### Swift Testing (Primary)

Swift Testing is the modern testing framework introduced with Swift 6.0. It provides:

- **Cleaner syntax** with `@Test` attribute and `#expect` macro
- **Better async/await support** built-in
- **Parameterized tests** with `@Test(arguments:)`
- **Traits** for test configuration (`@Test(.disabled)`, `@Test(.tags(...))`)
- **Parallel execution** by default

#### Swift Testing Syntax

```swift
import Testing
@testable import WeakupCore

@Suite("CaffeineViewModel Tests")
@MainActor
struct CaffeineViewModelTests {

    @Test("Initial state is inactive")
    func initialStateIsInactive() {
        let viewModel = CaffeineViewModel()
        #expect(viewModel.isActive == false)
    }

    @Test("Toggle starts when inactive")
    func toggleStartsWhenInactive() {
        let viewModel = CaffeineViewModel()
        viewModel.toggle()
        #expect(viewModel.isActive == true)
    }

    @Test("Timer duration updates correctly", arguments: [900, 1800, 3600])
    func timerDurationUpdates(duration: TimeInterval) {
        let viewModel = CaffeineViewModel()
        viewModel.setTimerDuration(duration)
        #expect(viewModel.timerDuration == duration)
    }
}
```

#### Key Differences from XCTest

| XCTest | Swift Testing |
|--------|---------------|
| `import XCTest` | `import Testing` |
| `class FooTests: XCTestCase` | `struct FooTests` or `@Suite struct FooTests` |
| `func testFoo()` | `@Test func foo()` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertTrue(x)` | `#expect(x)` |
| `XCTAssertNil(x)` | `#expect(x == nil)` |
| `XCTAssertThrowsError` | `#expect(throws:)` |
| `setUp()` / `tearDown()` | `init()` / `deinit` |
| `setUpWithError()` | `init() throws` |

### XCTest (UI Tests Only)

XCTest is retained **only for UI tests** because Swift Testing does not support:

- `XCUIApplication` for launching apps
- `XCUIElement` for UI element queries
- `waitForExistence(timeout:)` for async UI operations
- Screenshot and accessibility testing

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

### CaffeineViewModel Tests (Swift Testing)

```swift
import Testing
@testable import WeakupCore

@Suite("CaffeineViewModel Tests")
@MainActor
struct CaffeineViewModelTests {
    let userDefaultsStore: UserDefaultsStore

    init() {
        // Use isolated UserDefaults for test isolation
        userDefaultsStore = UserDefaultsStore(suiteName: "TestDefaults-\(UUID().uuidString)")
    }

    // Initial State Tests

    @Test("Initial state is inactive")
    func initialStateIsInactive() {
        let viewModel = CaffeineViewModel(userDefaultsStore: userDefaultsStore)
        #expect(viewModel.isActive == false)
    }

    @Test("Initial state has timer mode disabled")
    func initialStateTimerModeDisabled() {
        let viewModel = CaffeineViewModel(userDefaultsStore: userDefaultsStore)
        #expect(viewModel.timerMode == false)
    }

    @Test("Initial state has zero time remaining")
    func initialStateTimeRemainingIsZero() {
        let viewModel = CaffeineViewModel(userDefaultsStore: userDefaultsStore)
        #expect(viewModel.timeRemaining == 0)
    }

    // Toggle Tests

    @Test("Toggle starts when inactive")
    func toggleStartsWhenInactive() {
        let viewModel = CaffeineViewModel(userDefaultsStore: userDefaultsStore)
        #expect(viewModel.isActive == false)
        viewModel.toggle()
        #expect(viewModel.isActive == true)
        viewModel.stop()
    }

    @Test("Toggle stops when active")
    func toggleStopsWhenActive() {
        let viewModel = CaffeineViewModel(userDefaultsStore: userDefaultsStore)
        viewModel.start()
        #expect(viewModel.isActive == true)
        viewModel.toggle()
        #expect(viewModel.isActive == false)
    }

    // Timer Tests (Parameterized)

    @Test("Timer duration updates correctly", arguments: [900.0, 1800.0, 3600.0, 7200.0])
    func timerDurationUpdates(duration: TimeInterval) {
        let viewModel = CaffeineViewModel(userDefaultsStore: userDefaultsStore)
        viewModel.setTimerDuration(duration)
        #expect(viewModel.timerDuration == duration)
    }

    @Test("Negative duration clamps to zero")
    func negativeDurationClampsToZero() {
        let viewModel = CaffeineViewModel(userDefaultsStore: userDefaultsStore)
        viewModel.setTimerDuration(-100)
        #expect(viewModel.timerDuration == 0)
    }

    @Test("Timer mode with duration sets time remaining")
    func timerModeWithDurationSetsTimeRemaining() {
        let viewModel = CaffeineViewModel(userDefaultsStore: userDefaultsStore)
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(60)
        viewModel.start()
        #expect(viewModel.timeRemaining == 60.0 || abs(viewModel.timeRemaining - 60.0) < 1.0)
        viewModel.stop()
    }
}
```

### L10n Tests (Swift Testing)

```swift
import Testing
@testable import WeakupCore

@Suite("Localization Tests")
@MainActor
struct L10nTests {
    let l10n: L10n

    init() {
        l10n = L10n.shared
        l10n.setLanguage(.english)
    }

    @Test("Set language updates current language")
    func setLanguageUpdatesCurrentLanguage() {
        l10n.setLanguage(.chinese)
        #expect(l10n.currentLanguage == .chinese)
        l10n.setLanguage(.english) // Reset
    }

    @Test("Set language persists to UserDefaults")
    func setLanguagePersistsToUserDefaults() {
        l10n.setLanguage(.japanese)
        let saved = UserDefaults.standard.string(forKey: "WeakupLanguage")
        #expect(saved == "ja")
        l10n.setLanguage(.english) // Reset
    }

    @Test("String returns localized value")
    func stringReturnsLocalizedValue() {
        l10n.setLanguage(.english)
        let result = l10n.string(forKey: "app_name")
        #expect(result == "Weakup")
    }

    @Test("String falls back to English for missing keys")
    func stringFallsBackToEnglish() {
        l10n.setLanguage(.korean)
        let result = l10n.string(forKey: "app_name")
        #expect(!result.isEmpty)
        l10n.setLanguage(.english) // Reset
    }

    @Test("All languages have display names", arguments: AppLanguage.allCases)
    func allLanguagesHaveDisplayName(language: AppLanguage) {
        #expect(!language.displayName.isEmpty)
    }
}
```

### ActivityHistoryManager Tests (Swift Testing)

```swift
import Testing
@testable import WeakupCore

@Suite("Activity History Manager Tests")
@MainActor
struct ActivityHistoryManagerTests {
    let manager: ActivityHistoryManager

    init() {
        manager = ActivityHistoryManager.shared
        manager.clearHistory()
    }

    @Test("Start session creates current session")
    func startSessionCreatesCurrentSession() {
        manager.startSession(timerMode: false, timerDuration: nil)
        #expect(manager.currentSession != nil)
        manager.endSession()
    }

    @Test("End session moves to history")
    func endSessionMovesToHistory() {
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()
        #expect(manager.currentSession == nil)
        #expect(manager.sessions.count == 1)
    }

    @Test("Statistics calculates correctly")
    func statisticsCalculatesCorrectly() {
        manager.startSession(timerMode: false, timerDuration: nil)
        manager.endSession()

        let stats = manager.statistics
        #expect(stats.totalSessions == 1)
        #expect(stats.todaySessions >= 1)
    }

    @Test("Export history formats", arguments: [ExportFormat.json, ExportFormat.csv])
    func exportHistoryFormats(format: ExportFormat) {
        manager.startSession(timerMode: true, timerDuration: 3600)
        manager.endSession()

        let result = manager.exportHistory(format: format)
        #expect(result != nil)
        #expect(result?.format == format)
    }
}
```

### HotkeyManager Tests (Swift Testing)

```swift
import Testing
import Carbon.HIToolbox
@testable import WeakupCore

@Suite("Hotkey Manager Tests")
@MainActor
struct HotkeyManagerTests {
    let manager: HotkeyManager

    init() {
        manager = HotkeyManager.shared
        manager.resetToDefault()
    }

    @Test("Default config has correct key code")
    func defaultConfigIsCorrect() {
        let config = HotkeyConfig.defaultConfig
        #expect(config.keyCode == UInt32(kVK_ANSI_0))
    }

    @Test("Display string formats correctly")
    func displayStringFormatsCorrectly() {
        let config = HotkeyConfig.defaultConfig
        #expect(config.displayString.contains("Cmd"))
        #expect(config.displayString.contains("Ctrl"))
        #expect(config.displayString.contains("0"))
    }

    @Test("Check conflicts detects system shortcuts")
    func checkConflictsDetectsSystemShortcuts() {
        // Cmd+Q is a system shortcut
        let config = HotkeyConfig(keyCode: UInt32(kVK_ANSI_Q), modifiers: UInt32(cmdKey))
        let conflicts = manager.checkConflicts(for: config)
        #expect(!conflicts.isEmpty)
        #expect(conflicts.first?.severity == .high)
    }

    @Test("Recording state management")
    func recordingStateManagement() {
        manager.startRecording()
        #expect(manager.isRecording == true)

        manager.stopRecording()
        #expect(manager.isRecording == false)
    }
}
```

## Integration Tests

### Sleep Prevention Integration (Swift Testing)

```swift
import Testing
@testable import WeakupCore

@Suite("Sleep Prevention Integration Tests")
@MainActor
struct SleepPreventionIntegrationTests {
    let userDefaultsStore: UserDefaultsStore

    init() {
        userDefaultsStore = UserDefaultsStore(suiteName: "TestDefaults-\(UUID().uuidString)")
    }

    @Test("Full cycle start and stop")
    func fullCycleStartAndStop() {
        let viewModel = CaffeineViewModel(userDefaultsStore: userDefaultsStore)

        // Start
        viewModel.start()
        #expect(viewModel.isActive == true)

        // Verify assertion exists (check with pmset -g assertions)

        // Stop
        viewModel.stop()
        #expect(viewModel.isActive == false)
    }

    @Test("Timer mode expires correctly")
    func timerModeExpiresCorrectly() async throws {
        let viewModel = CaffeineViewModel(userDefaultsStore: userDefaultsStore)
        viewModel.setTimerMode(true)
        viewModel.setTimerDuration(2) // 2 seconds
        viewModel.start()

        #expect(viewModel.isActive == true)
        #expect(abs(viewModel.timeRemaining - 2) < 0.5)

        // Wait for timer to expire
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds

        #expect(viewModel.isActive == false)
        #expect(viewModel.timeRemaining == 0)
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
