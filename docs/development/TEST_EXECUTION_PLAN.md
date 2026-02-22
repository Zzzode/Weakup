# Weakup Test Execution Plan

## Document Information

| Field | Value |
|-------|-------|
| Version | 1.0 |
| Created | 2026-02-22 |
| Author | QA Lead |
| Status | Active |

---

## 1. Test Execution Overview

### 1.1 Test Phases

| Phase | Tests | Trigger | Duration |
|-------|-------|---------|----------|
| 1. Smoke | Critical P0 tests | Every commit | ~30 seconds |
| 2. Unit | All unit tests | Every commit | ~2 minutes |
| 3. Integration | Integration tests | PR merge | ~5 minutes |
| 4. UI | UI automation tests | Nightly | ~10 minutes |
| 5. Manual | Manual test cases | Pre-release | ~2 hours |

### 1.2 Test Environment Matrix

| Environment | macOS Version | Architecture | Priority |
|-------------|---------------|--------------|----------|
| Primary | macOS 14.0 (Sonoma) | Apple Silicon (arm64) | High |
| Secondary | macOS 13.0 (Ventura) | Apple Silicon (arm64) | Medium |
| Legacy | macOS 13.0 (Ventura) | Intel (x86_64) | Low |

---

## 2. Test Execution Commands

### 2.1 Quick Commands

```bash
# Run all tests
swift test

# Run with verbose output
swift test --verbose

# Run specific test file
swift test --filter CaffeineViewModelTests

# Run specific test method
swift test --filter CaffeineViewModelTests.testToggle_startsWhenInactive

# Run tests with coverage
swift test --enable-code-coverage
```

### 2.2 CI/CD Commands

```bash
# Full test suite with coverage
swift test --enable-code-coverage --parallel

# Generate coverage report
xcrun llvm-cov report \
  .build/debug/WeakupPackageTests.xctest/Contents/MacOS/WeakupPackageTests \
  --instr-profile .build/debug/codecov/default.profdata

# Export coverage to lcov format
xcrun llvm-cov export \
  .build/debug/WeakupPackageTests.xctest/Contents/MacOS/WeakupPackageTests \
  --instr-profile .build/debug/codecov/default.profdata \
  --format lcov > coverage.lcov
```

---

## 3. Test Execution Order

### 3.1 Smoke Tests (P0 Critical Path)

Run these first to catch critical regressions:

```bash
swift test --filter "testInitialState_isInactive"
swift test --filter "testToggle_startsWhenInactive"
swift test --filter "testToggle_stopsWhenActive"
swift test --filter "testStart_activatesViewModel"
swift test --filter "testStop_deactivatesViewModel"
```

### 3.2 Unit Tests by Module

Execute in this order for optimal feedback:

1. **CaffeineViewModel** (Core functionality)
   ```bash
   swift test --filter CaffeineViewModelTests
   ```

2. **AppLanguage** (Simple enum, fast)
   ```bash
   swift test --filter AppLanguageTests
   ```

3. **ActivitySession** (Data model)
   ```bash
   swift test --filter ActivitySessionTests
   ```

4. **Version** (Utility)
   ```bash
   swift test --filter VersionTests
   ```

5. **L10n** (Localization)
   ```bash
   swift test --filter L10nTests
   ```

6. **IconManager** (UI utility)
   ```bash
   swift test --filter IconManagerTests
   ```

7. **ThemeManager** (UI utility)
   ```bash
   swift test --filter ThemeManagerTests
   ```

8. **HotkeyManager** (System integration)
   ```bash
   swift test --filter HotkeyManagerTests
   ```

9. **ActivityHistoryManager** (Persistence)
   ```bash
   swift test --filter ActivityHistoryManagerTests
   ```

10. **NotificationManager** (System integration)
    ```bash
    swift test --filter NotificationManagerTests
    ```

11. **LaunchAtLoginManager** (Login item)
    ```bash
    swift test --filter LaunchAtLoginManagerTests
    ```

### 3.3 Integration Tests

```bash
swift test --filter SleepPreventionIntegrationTests
swift test --filter TimerIntegrationTests
swift test --filter PersistenceIntegrationTests
swift test --filter LocalizationIntegrationTests
```

If you see `sandbox-exec: sandbox_apply: Operation not permitted`, rerun with sandbox disabled:

```bash
swift test --disable-sandbox --filter SleepPreventionIntegrationTests
swift test --disable-sandbox --filter TimerIntegrationTests
swift test --disable-sandbox --filter PersistenceIntegrationTests
swift test --disable-sandbox --filter LocalizationIntegrationTests
```

---

## 4. Manual Test Checklist

### 4.1 Pre-Release Manual Tests

#### Basic Functionality

- [ ] **MT-001**: Launch app - verify menu bar icon appears
- [ ] **MT-002**: Left-click icon - verify toggle works
- [ ] **MT-003**: Right-click icon - verify context menu appears
- [ ] **MT-004**: Select Settings - verify settings window opens
- [ ] **MT-005**: Toggle sleep prevention - verify icon changes
- [ ] **MT-006**: Verify with `pmset -g assertions` - assertion appears/disappears

#### Timer Mode

- [ ] **MT-007**: Enable timer mode toggle
- [ ] **MT-008**: Select 15-minute duration
- [ ] **MT-009**: Start timer - verify countdown displays
- [ ] **MT-010**: Verify countdown is accurate (check at 1 min mark)
- [ ] **MT-011**: Let timer expire - verify auto-stop
- [ ] **MT-012**: Verify notification appears on expiry
- [ ] **MT-012a**: Disable notifications - verify no expiry notification

#### Language Switching

- [ ] **MT-013**: Switch to Chinese - verify all UI updates
- [ ] **MT-014**: Switch to Japanese - verify all UI updates
- [ ] **MT-015**: Quit and relaunch - verify language persists
- [ ] **MT-016**: Switch back to English - verify all UI updates

#### Keyboard Shortcut

- [ ] **MT-017**: Press Cmd+Ctrl+0 - verify toggle works
- [ ] **MT-018**: Open settings, record new shortcut
- [ ] **MT-019**: Verify new shortcut works
- [ ] **MT-020**: Reset to default - verify Cmd+Ctrl+0 works again

#### Theme Switching

- [ ] **MT-021**: Switch to Light theme - verify UI updates
- [ ] **MT-022**: Switch to Dark theme - verify UI updates
- [ ] **MT-023**: Switch to System theme - verify follows system

#### Icon Styles

- [ ] **MT-024**: Switch to Bolt icon - verify menu bar updates
- [ ] **MT-025**: Switch to Cup icon - verify menu bar updates
- [ ] **MT-026**: Switch to Moon icon - verify menu bar updates
- [ ] **MT-027**: Switch to Eye icon - verify menu bar updates
- [ ] **MT-028**: Switch back to Power icon - verify menu bar updates

#### Edge Cases

- [ ] **MT-029**: Rapid toggle (10+ times) - verify no crash
- [ ] **MT-030**: Quit while active - verify clean shutdown
- [ ] **MT-031**: Change duration while active - verify stops correctly
- [ ] **MT-032**: Open multiple settings windows - verify only one opens
- [ ] **MT-033**: Toggle menu bar countdown - verify title shows/hides
- [ ] **MT-034**: Toggle launch at login - verify status updates

### 4.2 Verification Commands

```bash
# Check if sleep prevention is active
pmset -g assertions | grep PreventUserIdleSystemSleep

# View app logs
log show --predicate 'subsystem == "com.weakup"' --last 10m

# Check memory usage
ps aux | grep -i weakup

# Check for memory leaks (run app for 5 minutes then check)
leaks $(pgrep weakup)
```

---

## 5. Test Reporting

### 5.1 Test Result Template

```markdown
# Test Execution Report

**Date**: YYYY-MM-DD
**Tester**: [Name]
**Environment**: macOS XX.X, [Architecture]
**App Version**: X.X.X

## Summary

| Category | Total | Passed | Failed | Skipped |
|----------|-------|--------|--------|---------|
| Unit     |       |        |        |         |
| Integration |    |        |        |         |
| Manual   |       |        |        |         |

## Coverage

| Module | Target | Actual | Status |
|--------|--------|--------|--------|
| CaffeineViewModel | 90% |   | |
| L10n | 85% |   | |
| ... | | | |

## Failed Tests

| Test ID | Test Name | Error | Notes |
|---------|-----------|-------|-------|
|         |           |       |       |

## Bugs Found

| Bug ID | Severity | Description |
|--------|----------|-------------|
|        |          |             |

## Recommendations

[Any recommendations for the release]
```

### 5.2 Coverage Report Generation

```bash
# Generate detailed coverage report
swift test --enable-code-coverage

# View coverage summary
xcrun llvm-cov report \
  .build/debug/WeakupPackageTests.xctest/Contents/MacOS/WeakupPackageTests \
  --instr-profile .build/debug/codecov/default.profdata \
  --sources Sources/WeakupCore/

# Generate HTML report (if xcov is installed)
xcov --project Weakup.xcodeproj --scheme Weakup --output_directory coverage_html
```

---

## 6. Regression Test Suite

### 6.1 Critical Regression Tests

These tests must pass before any release:

| ID | Test | Verification |
|----|------|--------------|
| REG-001 | Sleep prevention activates | `pmset -g assertions` shows assertion |
| REG-002 | Sleep prevention deactivates | `pmset -g assertions` shows no assertion |
| REG-003 | Timer countdown accurate | Countdown matches wall clock |
| REG-004 | Timer auto-stops | App stops when timer reaches 0 |
| REG-005 | Language persists | Language survives app restart |
| REG-006 | Keyboard shortcut works | Cmd+Ctrl+0 toggles state |
| REG-007 | Clean shutdown | No assertion leak on quit |
| REG-008 | No memory leaks | `leaks` command shows 0 leaks |

### 6.2 Regression Test Command

```bash
# Run all regression tests
swift test --filter "testToggle_startsWhenInactive|testToggle_stopsWhenActive|testTimerCountdown|testLanguageSwitch"
```

---

## 7. Performance Benchmarks

### 7.1 Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| CPU (idle) | < 1% | Activity Monitor |
| Memory (idle) | < 50 MB | Activity Monitor |
| Startup time | < 1 second | Manual timing |
| Toggle response | < 100 ms | Manual observation |

### 7.2 Performance Test Commands

```bash
# Monitor CPU usage
top -pid $(pgrep weakup) -l 10

# Monitor memory
ps -o rss,vsz -p $(pgrep weakup)

# Profile with Instruments
instruments -t "Time Profiler" -D profile.trace .build/release/weakup
```

---

## 8. Test Data Management

### 8.1 Test Data Cleanup

Before running tests, clean up test data:

```bash
# Remove test UserDefaults
defaults delete com.weakup 2>/dev/null || true

# Remove specific keys
defaults delete com.weakup WeakupSoundEnabled 2>/dev/null || true
defaults delete com.weakup WeakupTimerMode 2>/dev/null || true
defaults delete com.weakup WeakupTimerDuration 2>/dev/null || true
defaults delete com.weakup WeakupLanguage 2>/dev/null || true
```

### 8.2 Test Data Reset Script

```bash
#!/bin/bash
# reset_test_data.sh

echo "Resetting Weakup test data..."

# Kill running app
pkill -f weakup 2>/dev/null || true

# Clear UserDefaults
defaults delete com.weakup 2>/dev/null || true

# Clear any cached data
rm -rf ~/Library/Caches/com.weakup 2>/dev/null || true

echo "Test data reset complete."
```

---

## 9. Troubleshooting

### 9.1 Common Test Failures

| Issue | Cause | Solution |
|-------|-------|----------|
| Tests hang | Timer not stopping | Add timeout to async tests |
| Singleton state | Previous test pollution | Reset singletons in setUp |
| UserDefaults conflict | Shared state | Use mock UserDefaults |
| Flaky timer tests | Timing sensitivity | Increase tolerance |

### 9.2 Debug Commands

```bash
# Run single test with debug output
swift test --filter CaffeineViewModelTests.testToggle_startsWhenInactive -Xswiftc -DDEBUG

# Run tests with sanitizers
swift test --sanitize=address
swift test --sanitize=thread

# Check for test leaks
MallocStackLogging=1 swift test 2>&1 | grep "leaked"
```

---

## 10. Appendix

### A. Test File Locations

```
Tests/
├── WeakupTests/
│   ├── CaffeineViewModelTests.swift
│   ├── AppLanguageTests.swift
│   ├── L10nTests.swift
│   ├── ActivitySessionTests.swift
│   ├── ActivityHistoryManagerTests.swift
│   ├── IconManagerTests.swift
│   ├── ThemeManagerTests.swift
│   ├── HotkeyManagerTests.swift
│   ├── NotificationManagerTests.swift
│   ├── VersionTests.swift
│   ├── WeakupTests.swift
│   ├── Integration/
│   │   └── SleepPreventionIntegrationTests.swift
│   └── Mocks/
│       ├── MockUserDefaults.swift
│       ├── MockSleepPreventionService.swift
│       └── TestFixtures.swift
```

### B. CI/CD Configuration Example

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

      - name: Run Tests
        run: swift test --enable-code-coverage

      - name: Generate Coverage Report
        run: |
          xcrun llvm-cov export \
            .build/debug/WeakupPackageTests.xctest/Contents/MacOS/WeakupPackageTests \
            --instr-profile .build/debug/codecov/default.profdata \
            --format lcov > coverage.lcov

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage.lcov
```

---

*Document Version: 1.0*
*Last Updated: 2026-02-22*
*Author: QA Lead*
