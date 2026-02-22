# Swift Testing Migration Strategy

## Overview

This document outlines the strategy for migrating Weakup's test suite from XCTest to Swift Testing framework.

---

## CRITICAL: Mixed Testing Approach Required

> **Swift Testing does NOT support UI testing (XCUITest).** This is a technical limitation of the framework.

| Test Category | Files | Tests | Framework | Action |
|--------------|-------|-------|-----------|--------|
| Unit Tests | 12 | ~410 | **Swift Testing** | Migrate |
| Integration Tests | 4 | ~66 | **Swift Testing** | Migrate |
| UI Tests | 3 | ~27 | **XCTest** | **Keep as-is** |
| Mocks/Fixtures | 5 | N/A | Both | Update for compatibility |

---

## Migration Scope

### Files to Migrate (16 files)

**Unit Tests (12 files):**

| File | Test Classes | Test Count | Complexity |
|------|-------------|------------|------------|
| `ActivitySessionTests.swift` | 2 | 14 | Low |
| `VersionTests.swift` | 1 | 9 | Low |
| `LaunchAtLoginManagerTests.swift` | 3 | 28 | Medium |
| `AppLanguageTests.swift` | 1 | 32 | Low |
| `WeakupTests.swift` | 1 | 2 | Low |
| `CaffeineViewModelTests.swift` | 1 | 45 | High |
| `ThemeManagerTests.swift` | 2 | 45 | Medium |
| `HotkeyManagerTests.swift` | 3 | 75 | High |
| `NotificationManagerTests.swift` | 1 | 10 | Low |
| `ActivityHistoryManagerTests.swift` | 1 | 50 | High |
| `L10nTests.swift` | 1 | 60 | Medium |
| `IconManagerTests.swift` | 2 | 40 | Medium |

**Integration Tests (4 files):**

| File | Test Classes | Test Count | Complexity |
|------|-------------|------------|------------|
| `LocalizationIntegrationTests.swift` | 1 | 15 | Medium |
| `PersistenceIntegrationTests.swift` | 1 | 18 | Medium |
| `TimerIntegrationTests.swift` | 1 | 15 | High |
| `SleepPreventionIntegrationTests.swift` | 2 | 18 | High |

### Files to Keep on XCTest (3 files)

**UI Tests (3 files, 27 tests):**
1. `WeakupUITests/KeyboardShortcutUITests.swift` (10 tests)
2. `WeakupUITests/SettingsPopoverUITests.swift` (12 tests)
3. `WeakupUITests/MenuBarUITests.swift` (5 tests)

**Reason:** Swift Testing does NOT support UI testing. XCUITest framework requires XCTest.

### Mock/Fixture Files (5 files)

| File | Purpose | Changes Needed |
|------|---------|----------------|
| `TestFixtures.swift` | Test data and utilities | Update for Swift Testing |
| `MockUserDefaults.swift` | Isolated UserDefaults | None (protocol-based) |
| `MockSleepPreventionService.swift` | Mock IOPMAssertion | None |
| `MockNotificationManager.swift` | Mock notifications | None |
| `MockNotificationCenter.swift` | Mock UNUserNotificationCenter | None |

## XCTest to Swift Testing Mapping

### ⚠️ CRITICAL: Import Statements

**Swift Testing does NOT automatically import Foundation like XCTest does.**

All migrated test files MUST include:
```swift
import Foundation  // Required for Date, UUID, JSONEncoder, NSRegularExpression, etc.
import Testing
@testable import WeakupCore
```

**Why:** XCTest automatically imports Foundation, but Swift Testing does not. Forgetting this will cause compilation errors for Foundation types.

### Test Class → Test Suite
```swift
// XCTest
import XCTest
@testable import WeakupCore

@MainActor
final class CaffeineViewModelTests: XCTestCase { }

// Swift Testing
import Foundation  // ⚠️ REQUIRED!
import Testing
@testable import WeakupCore

@MainActor
@Suite("CaffeineViewModel Tests")
struct CaffeineViewModelTests { }
```

### setUp/tearDown → init/deinit
```swift
// XCTest
override func setUp() async throws {
    viewModel = CaffeineViewModel()
}

// Swift Testing
init() async throws {
    viewModel = CaffeineViewModel()
}
```

### Assertions
- `XCTAssertTrue(x)` → `#expect(x)`
- `XCTAssertFalse(x)` → `#expect(!x)`
- `XCTAssertEqual(a, b)` → `#expect(a == b)`
- `XCTAssertEqual(a, b, accuracy: c)` → `#expect(abs(a - b) < c)`

## XCTest Patterns Identified

### Patterns Used in Codebase

1. **`XCTestCase` class inheritance** - All 24 test files
2. **Async `setUp()/tearDown()`** - 10+ files use `async throws`
3. **`@MainActor` isolation** - 10+ test classes for thread safety
4. **`XCTAssert*` assertions** - All variants used extensively
5. **`XCTAssertEqual(_:_:accuracy:)`** - Timer tests for floating point
6. **`XCTestExpectation`** - Combine publisher testing
7. **`XCTestObservation`** - Serial test execution in TestFixtures.swift

### Migration Challenges

| Challenge | Impact | Solution |
|-----------|--------|----------|
| UI Tests incompatible | High | Keep on XCTest |
| MainActor isolation | Medium | Apply `@MainActor` to `@Suite` |
| Accuracy assertions | Low | Use `#expect(abs(a-b) <= accuracy)` |
| XCTestExpectation | Medium | Use `confirmation()` API |
| Singleton state | Medium | Reset in `init()` |
| tearDown cleanup | Medium | Use `defer` statements |

---

## Recommended Migration Order

### Phase 1: Simple Unit Tests (Low Risk)
1. `VersionTests.swift` - No MainActor, no async
2. `ActivitySessionTests.swift` - Simple data model tests
3. `AppLanguageTests.swift` - Enum tests
4. `WeakupTests.swift` - Only 2 tests

### Phase 2: Medium Complexity
5. `ThemeManagerTests.swift` - MainActor, Combine
6. `IconManagerTests.swift` - MainActor, callbacks
7. `NotificationManagerTests.swift` - Simple mocking
8. `L10nTests.swift` - Language switching

### Phase 3: Complex Unit Tests
9. `CaffeineViewModelTests.swift` - Complex state, async
10. `HotkeyManagerTests.swift` - System integration
11. `ActivityHistoryManagerTests.swift` - Persistence
12. `LaunchAtLoginManagerTests.swift` - Async error handling

### Phase 4: Integration Tests
13. `LocalizationIntegrationTests.swift`
14. `PersistenceIntegrationTests.swift`
15. `TimerIntegrationTests.swift`
16. `SleepPreventionIntegrationTests.swift`

Use `@Suite(.serialized)` for tests requiring sequential execution.

---

## Success Criteria

- [ ] All 16 unit/integration test files migrated to Swift Testing
- [ ] All 3 UI test files remain on XCTest (unchanged)
- [ ] All tests pass (`swift test`)
- [ ] Package.swift supports both frameworks
- [ ] CI/CD pipeline works with mixed frameworks
- [ ] Documentation updated

---

## References

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [Migrating from XCTest](https://developer.apple.com/documentation/testing/migratingfromxctest)
- [Swift Testing WWDC 2024](https://developer.apple.com/videos/play/wwdc2024/10179/)
