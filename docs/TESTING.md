# Testing Guide

This document describes testing practices for Weakup.

## Current Testing Status

Weakup currently relies on manual testing. This guide covers both manual testing procedures and recommendations for adding automated tests.

## Manual Testing

### Core Functionality Tests

#### 1. Sleep Prevention Toggle

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Enable sleep prevention | Click menu bar icon | Icon changes to filled circle, tooltip shows "Weakup: On" |
| Disable sleep prevention | Click menu bar icon again | Icon changes to empty circle, tooltip shows "Weakup: Off" |
| Verify assertion | Run `pmset -g assertions` in Terminal | Shows Weakup assertion when enabled |

#### 2. Timer Mode

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Enable timer mode | Open Settings, toggle Timer Mode on | Duration picker appears |
| Set duration | Select "15m" from duration picker | Duration is set |
| Start timer | Click "Turn On" | Countdown displays in settings |
| Timer expiry | Wait for countdown to reach 0 | Sleep prevention automatically disables |

#### 3. Keyboard Shortcut

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Toggle with shortcut | Press Cmd+Ctrl+0 | Sleep prevention toggles |
| Shortcut while inactive | Press Cmd+Ctrl+0 when off | Enables sleep prevention |
| Shortcut while active | Press Cmd+Ctrl+0 when on | Disables sleep prevention |

#### 4. Language Switching

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Switch to Chinese | Open Settings, select "中文" | All UI text changes to Chinese |
| Switch to English | Select "English" | All UI text changes to English |
| Persistence | Restart app after language change | Selected language is remembered |

#### 5. Settings Popover

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Open settings | Click menu bar icon, select "Settings" | Popover appears below menu bar |
| Close by clicking outside | Click anywhere outside popover | Popover closes |
| Status indicator | Enable/disable while settings open | Green/gray dot updates |

### System Integration Tests

#### Power Management Verification

```bash
# Before enabling Weakup
pmset -g assertions
# Note the current assertions

# Enable Weakup, then run again
pmset -g assertions
# Should show new assertion:
# pid XXXX(weakup): PreventUserIdleSystemSleep named: "Weakup preventing sleep"

# Disable Weakup
pmset -g assertions
# Assertion should be removed
```

#### Menu Bar Integration

- [ ] Icon appears in menu bar on launch
- [ ] Icon updates when state changes
- [ ] Tooltip shows correct status
- [ ] Context menu appears on right-click (or Ctrl+click)
- [ ] "Quit Weakup" terminates the app

### Edge Cases

| Scenario | Test | Expected Behavior |
|----------|------|-------------------|
| Rapid toggling | Click icon repeatedly | State remains consistent |
| Timer while active | Enable timer mode while already active | Stops current session |
| System sleep attempt | Try to sleep Mac while Weakup active | System stays awake |
| App termination | Quit app while active | Assertion is released |

## Automated Testing (Future)

### Unit Tests

Add unit tests for `CaffeineViewModel`:

```swift
import XCTest
@testable import Weakup

final class CaffeineViewModelTests: XCTestCase {
    var viewModel: CaffeineViewModel!

    override func setUp() {
        super.setUp()
        viewModel = CaffeineViewModel()
    }

    func testInitialState() {
        XCTAssertFalse(viewModel.isActive)
        XCTAssertFalse(viewModel.timerMode)
        XCTAssertEqual(viewModel.timeRemaining, 0)
    }

    func testToggle() {
        viewModel.toggle()
        XCTAssertTrue(viewModel.isActive)

        viewModel.toggle()
        XCTAssertFalse(viewModel.isActive)
    }

    func testSetTimerDuration() {
        viewModel.setTimerDuration(900) // 15 minutes
        XCTAssertEqual(viewModel.timerDuration, 900)
    }
}
```

### UI Tests

Add UI tests using XCTest:

```swift
import XCTest

final class WeakupUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func testSettingsPopover() {
        // Test settings UI elements
    }

    func testLanguageSwitch() {
        // Test language switching
    }
}
```

### Integration Tests

Test IOPMAssertion integration:

```swift
func testPowerAssertionCreation() {
    viewModel.start()

    // Verify assertion exists
    // This requires checking system state

    viewModel.stop()

    // Verify assertion is released
}
```

## Test Coverage Goals

| Component | Target Coverage |
|-----------|-----------------|
| CaffeineViewModel | 90% |
| L10n | 80% |
| SettingsView | 70% (UI tests) |
| AppDelegate | 60% |

## Running Tests

### With Swift Package Manager

```bash
# Run all tests
swift test

# Run specific test
swift test --filter CaffeineViewModelTests
```

### With Xcode

```bash
# Generate Xcode project
swift package generate-xcodeproj

# Open and run tests
open Weakup.xcodeproj
# Press Cmd+U to run tests
```

## Continuous Integration

Tests should run on every pull request. See `.github/workflows/` for CI configuration.

## Test Data

### Localization Test Strings

Verify all localization keys have translations:

```bash
# List all keys in English
grep -o '"[^"]*"' Sources/Weakup/en.lproj/Localizable.strings | head -1

# Compare with Chinese
grep -o '"[^"]*"' Sources/Weakup/zh-Hans.lproj/Localizable.strings | head -1
```

## Reporting Issues

When reporting bugs, include:
- macOS version
- Weakup version
- Steps to reproduce
- Expected vs actual behavior
- Output of `pmset -g assertions`
- Console logs if available
