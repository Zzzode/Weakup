# Weakup macOS App - QA Plan

## 1. Application Overview

**Weakup** is a macOS menu bar application that prevents system sleep. It provides:
- Menu bar status icon with toggle functionality
- Timer mode with preset durations (15m, 30m, 1h, 2h, 3h)
- Keyboard shortcut (Cmd+Ctrl+0) for quick toggle
- Bilingual support (English, Chinese Simplified)
- Settings popover with language selection

**Target Platform:** macOS 13.0+
**Architecture:** Swift 6.0, SwiftUI, AppKit, IOKit

---

## 2. Testing Strategy

### 2.1 Testing Levels

| Level | Coverage Target | Priority |
|-------|----------------|----------|
| Unit Tests | 80% code coverage | High |
| Integration Tests | Core workflows | High |
| UI Tests | Critical user flows | Medium |
| Manual Tests | Edge cases, UX | Medium |

### 2.2 Testing Pyramid

```
        /\
       /  \  Manual/Exploratory (10%)
      /----\
     /      \  UI Tests (20%)
    /--------\
   /          \  Integration Tests (30%)
  /------------\
 /              \  Unit Tests (40%)
/________________\
```

---

## 3. Unit Test Plan

### 3.1 CaffeineViewModel Tests

| Test Case | Description | Priority |
|-----------|-------------|----------|
| `test_initialState` | Verify initial values: isActive=false, timerMode=false, timeRemaining=0 | P0 |
| `test_toggle_startsWhenInactive` | Calling toggle() when inactive should start | P0 |
| `test_toggle_stopsWhenActive` | Calling toggle() when active should stop | P0 |
| `test_start_createsAssertion` | Verify IOPMAssertion is created on start | P0 |
| `test_stop_releasesAssertion` | Verify IOPMAssertion is released on stop | P0 |
| `test_timerMode_countsDown` | Timer decrements correctly each second | P0 |
| `test_timerMode_stopsAtZero` | Timer auto-stops when reaching zero | P0 |
| `test_setTimerDuration_stopsIfActive` | Setting duration while active stops the session | P1 |
| `test_setTimerDuration_updatesValue` | Duration value is correctly stored | P1 |
| `test_start_withoutTimerMode` | Start without timer mode doesn't set timeRemaining | P1 |

### 3.2 L10n (Localization) Tests

| Test Case | Description | Priority |
|-----------|-------------|----------|
| `test_defaultLanguage_detectsSystem` | Correct language detected from system locale | P0 |
| `test_setLanguage_persists` | Language preference saved to UserDefaults | P0 |
| `test_setLanguage_updatesStrings` | UI strings update after language change | P0 |
| `test_englishStrings_allKeysExist` | All localization keys have English values | P1 |
| `test_chineseStrings_allKeysExist` | All localization keys have Chinese values | P1 |
| `test_stringForKey_returnsCorrectValue` | string(forKey:) returns expected localized string | P1 |

### 3.3 AppLanguage Tests

| Test Case | Description | Priority |
|-----------|-------------|----------|
| `test_allCases_containsExpectedLanguages` | Enum contains english and chinese | P1 |
| `test_displayName_correctForEachLanguage` | Display names are "English" and "Chinese" | P1 |
| `test_bundle_returnsValidBundle` | Bundle property returns valid localization bundle | P1 |

---

## 4. Integration Test Plan

### 4.1 Sleep Prevention Integration

| Test Case | Description | Priority |
|-----------|-------------|----------|
| `test_sleepPrevention_assertionActive` | System sleep is actually prevented when active | P0 |
| `test_sleepPrevention_assertionReleased` | System sleep is allowed after stop | P0 |
| `test_multipleToggle_noAssertionLeak` | Rapid toggling doesn't leak assertions | P0 |

### 4.2 Timer Integration

| Test Case | Description | Priority |
|-----------|-------------|----------|
| `test_timer_accuracyOver1Minute` | Timer countdown is accurate within 1 second over 1 minute | P0 |
| `test_timer_stopsAtZero_releasesSleep` | Sleep prevention released when timer expires | P0 |
| `test_timer_manualStop_cancelsTimer` | Manual stop properly cancels running timer | P1 |

### 4.3 Persistence Integration

| Test Case | Description | Priority |
|-----------|-------------|----------|
| `test_languagePreference_persistsAcrossLaunches` | Language setting survives app restart | P1 |

---

## 5. UI Test Plan

### 5.1 Menu Bar Tests

| Test Case | Description | Priority |
|-----------|-------------|----------|
| `test_statusIcon_showsInMenuBar` | Status item appears in menu bar | P0 |
| `test_statusIcon_changesOnToggle` | Icon changes between power.circle and power.circle.fill | P0 |
| `test_tooltip_updatesOnToggle` | Tooltip shows correct on/off status | P1 |
| `test_menu_showsSettingsAndQuit` | Right-click menu shows Settings and Quit options | P0 |

### 5.2 Settings Popover Tests

| Test Case | Description | Priority |
|-----------|-------------|----------|
| `test_settingsPopover_opens` | Clicking Settings opens popover | P0 |
| `test_statusIndicator_reflectsState` | Green/gray circle matches active state | P0 |
| `test_toggleButton_changesState` | Turn On/Off button toggles caffeine state | P0 |
| `test_timerModeToggle_enablesDisables` | Timer mode toggle works correctly | P0 |
| `test_durationPicker_appearsInTimerMode` | Duration picker shows only when timer mode enabled | P0 |
| `test_durationPicker_selectsDuration` | Can select different duration values | P1 |
| `test_timerDisplay_showsCountdown` | Timer countdown displays when active in timer mode | P0 |
| `test_languagePicker_switchesLanguage` | Language picker changes UI language | P1 |

### 5.3 Keyboard Shortcut Tests

| Test Case | Description | Priority |
|-----------|-------------|----------|
| `test_cmdCtrl0_togglesCaffeine` | Cmd+Ctrl+0 toggles sleep prevention | P0 |
| `test_shortcut_worksWhenPopoverClosed` | Shortcut works without popover open | P1 |

---

## 6. Edge Cases and Boundary Conditions

### 6.1 Timer Edge Cases

| Scenario | Expected Behavior | Priority |
|----------|-------------------|----------|
| Timer set to 0 (Off) | No countdown, indefinite prevention | P0 |
| Toggle off during countdown | Timer stops, countdown resets | P0 |
| Change duration while active | Stops current session | P1 |
| Rapid toggle during countdown | State remains consistent | P1 |
| System sleep during countdown | Timer continues after wake | P2 |

### 6.2 System Integration Edge Cases

| Scenario | Expected Behavior | Priority |
|----------|-------------------|----------|
| App quit while active | Assertion released on termination | P0 |
| System shutdown while active | Clean shutdown, no assertion leak | P0 |
| Multiple app instances | Prevent or handle gracefully | P1 |
| IOKit failure | Graceful error handling | P1 |
| Low memory conditions | App remains stable | P2 |

### 6.3 Localization Edge Cases

| Scenario | Expected Behavior | Priority |
|----------|-------------------|----------|
| Missing localization key | Falls back to key name or English | P1 |
| System language not supported | Defaults to English | P1 |
| Language change while active | UI updates, state preserved | P1 |
| Corrupted UserDefaults | Defaults to system language | P2 |

### 6.4 UI Edge Cases

| Scenario | Expected Behavior | Priority |
|----------|-------------------|----------|
| Multiple popover opens | Only one popover instance | P1 |
| Popover open during toggle | UI updates correctly | P1 |
| Menu bar hidden by system | App still functional via shortcut | P2 |
| Display configuration change | Status item repositions correctly | P2 |

---

## 7. Critical User Flows

### 7.1 Flow: Basic Sleep Prevention

```
1. User clicks menu bar icon
2. Settings popover opens
3. User clicks "Turn On"
4. Icon changes to filled state
5. System sleep is prevented
6. User clicks "Turn Off"
7. Icon changes to unfilled state
8. System sleep is allowed
```

**Acceptance Criteria:**
- [ ] Icon visually indicates state
- [ ] Tooltip reflects current state
- [ ] Sleep prevention is actually active (verify via pmset -g assertions)
- [ ] State change is immediate

### 7.2 Flow: Timer Mode Usage

```
1. User opens settings
2. User enables Timer Mode toggle
3. Duration picker appears
4. User selects "30m"
5. User clicks "Turn On"
6. Countdown displays "30:00"
7. Timer counts down
8. At 00:00, sleep prevention stops automatically
```

**Acceptance Criteria:**
- [ ] Timer display format is MM:SS
- [ ] Countdown is accurate
- [ ] Auto-stop occurs at exactly 0
- [ ] Icon updates when timer expires

### 7.3 Flow: Language Switch

```
1. User opens settings
2. User selects Chinese from language picker
3. All UI text updates to Chinese
4. User quits and relaunches app
5. Chinese language is preserved
```

**Acceptance Criteria:**
- [ ] All visible strings are translated
- [ ] No English text remains after switch
- [ ] Preference persists across launches

### 7.4 Flow: Keyboard Shortcut Toggle

```
1. App is running (popover closed)
2. User presses Cmd+Ctrl+0
3. Sleep prevention toggles
4. Icon updates to reflect new state
```

**Acceptance Criteria:**
- [ ] Shortcut works globally when app is active
- [ ] State change is immediate
- [ ] Icon updates without opening popover

---

## 8. Test Environment Requirements

### 8.1 Hardware

- Mac with Apple Silicon (arm64) - primary
- Mac with Intel processor (x86_64) - secondary
- Various macOS versions: 13.0, 14.0, 15.0

### 8.2 Software

- Xcode 15.0+ with XCTest framework
- Swift Testing framework (for modern tests)
- pmset command-line tool (for assertion verification)

### 8.3 Test Data

- Localization string files (en, zh-Hans)
- Mock UserDefaults for persistence tests

---

## 9. Bug Tracking Approach

### 9.1 Bug Severity Levels

| Level | Definition | Response Time |
|-------|------------|---------------|
| Critical (S1) | App crash, data loss, security issue | Immediate |
| Major (S2) | Core feature broken, no workaround | 24 hours |
| Minor (S3) | Feature issue with workaround | 1 week |
| Trivial (S4) | Cosmetic, typo, minor UX | Backlog |

### 9.2 Bug Report Template

```markdown
**Title:** [Brief description]

**Severity:** S1/S2/S3/S4

**Environment:**
- macOS version:
- App version:
- Hardware:

**Steps to Reproduce:**
1.
2.
3.

**Expected Result:**

**Actual Result:**

**Screenshots/Logs:**

**Additional Context:**
```

### 9.3 Known Issues to Track

| Issue | Severity | Status |
|-------|----------|--------|
| Keyboard shortcut only works when app is frontmost | S3 | Known limitation |
| Timer accuracy may drift over long periods | S3 | To verify |

---

## 10. Test Coverage Targets

### 10.1 Code Coverage Goals

| Module | Target | Current |
|--------|--------|---------|
| CaffeineViewModel | 90% | 0% |
| L10n | 85% | 0% |
| AppLanguage | 100% | 0% |
| SettingsView | 70% | 0% |
| AppDelegate | 60% | 0% |

### 10.2 Feature Coverage Matrix

| Feature | Unit | Integration | UI | Manual |
|---------|------|-------------|-----|--------|
| Sleep Prevention | Yes | Yes | Yes | Yes |
| Timer Mode | Yes | Yes | Yes | Yes |
| Language Switch | Yes | Yes | Yes | Yes |
| Menu Bar Icon | No | No | Yes | Yes |
| Keyboard Shortcut | No | No | Yes | Yes |
| Settings Popover | No | No | Yes | Yes |

---

## 11. Test Automation Strategy

### 11.1 Recommended Test Structure

```
Tests/
├── WeakupTests/
│   ├── Unit/
│   │   ├── CaffeineViewModelTests.swift
│   │   ├── L10nTests.swift
│   │   └── AppLanguageTests.swift
│   └── Integration/
│       ├── SleepPreventionTests.swift
│       └── TimerIntegrationTests.swift
└── WeakupUITests/
    ├── MenuBarTests.swift
    ├── SettingsPopoverTests.swift
    └── KeyboardShortcutTests.swift
```

### 11.2 CI/CD Integration

- Run unit tests on every commit
- Run integration tests on PR merge
- Run UI tests nightly
- Generate coverage reports

---

## 12. Acceptance Criteria Summary

### Release Readiness Checklist

- [ ] All P0 test cases pass
- [ ] No S1 or S2 bugs open
- [ ] Code coverage >= 80% for core modules
- [ ] All critical user flows verified
- [ ] Localization complete for both languages
- [ ] Performance acceptable (< 1% CPU when idle)
- [ ] Memory usage stable (no leaks)
- [ ] Clean app termination verified

---

## 13. Appendix

### A. Test Commands

```bash
# Run all tests
swift test

# Run specific test
swift test --filter CaffeineViewModelTests

# Generate coverage report
swift test --enable-code-coverage

# Verify sleep assertions (manual)
pmset -g assertions
```

### B. Useful Debugging Commands

```bash
# Check if sleep is prevented
pmset -g assertions | grep PreventUserIdleSystemSleep

# View app logs
log show --predicate 'subsystem == "com.weakup"' --last 1h

# Monitor memory usage
leaks --atExit -- ./weakup
```

---

*Document Version: 1.0*
*Last Updated: 2026-02-21*
*Author: QA Engineer*
