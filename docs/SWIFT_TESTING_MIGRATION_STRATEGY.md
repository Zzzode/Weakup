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
import Foundation  // Required for Date, UUID, JSONEncoder, NSRegularExpression, TimeInterval, etc.
import Testing
@testable import WeakupCore
```

**Why:** XCTest automatically imports Foundation, but Swift Testing does not. Forgetting this will cause compilation errors for Foundation types.

**Common types that require Foundation:**
- `Date`, `UUID`, `TimeInterval`
- `JSONEncoder`, `JSONDecoder`
- `NSRegularExpression`, `NSRange`
- `Bundle`, `URL`
- `Data`, `String` extensions

**Import order matters:** Always put `Foundation` first, then `Testing`, then your module imports.

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
| Foundation import missing | High | Add `import Foundation` to all files |
| Sendable conformance | High | Add `Sendable` to types used in parameterized tests |
| MainActor isolation | Medium | Apply `@MainActor` to `@Suite` |
| Accuracy assertions | Low | Use `#expect(abs(a-b) < accuracy)` |
| XCTestExpectation | Medium | Use async/await patterns |
| Singleton state | Medium | Reset in `init()` |
| tearDown cleanup | Medium | Use `defer` statements or cleanup in tests |
| MARK comments | Low | Remove `// MARK: -` prefix, use plain `// MARK:` |

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

## Practical Migration Experience

### Lessons Learned from Actual Migration

This section documents real issues encountered during the Weakup migration and their solutions.

#### 1. Foundation Import is Non-Negotiable

**Issue:** Compilation errors like `cannot find 'TimeInterval' in scope`, `cannot find 'Date' in scope`.

**Root Cause:** XCTest automatically imports Foundation, creating a hidden dependency. Swift Testing does not.

**Solution:** Add `import Foundation` as the first import in every test file.

**Prevention:** Add this to your migration checklist as the first step.

#### 2. Sendable Conformance for Swift 6

**Issue:** `type 'AppLanguage' does not conform to the 'Sendable' protocol` when using types in parameterized tests or with `@MainActor`.

**Root Cause:** Swift 6 strict concurrency checking requires types used across isolation boundaries to be `Sendable`.

**Solution:** Add `Sendable` conformance to the enum in source code:
```swift
public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    // ...
}
```

**Best Practice:** Fix in source code, not in tests. Use loops instead of parameterized tests if type cannot be made Sendable.

#### 3. Import Order Matters

**Issue:** Compilation errors even with Foundation imported.

**Root Cause:** Import order can affect symbol resolution in some cases.

**Solution:** Always use this order:
```swift
import Foundation  // System frameworks first
import Testing     // Testing framework
@testable import WeakupCore  // Your module last
```

#### 4. MARK Comments Formatting

**Issue:** Linters may flag `// MARK: -` style comments.

**Root Cause:** Swift Testing tests are often simpler and don't need the separator line.

**Solution:** Use plain `// MARK:` without the dash:
```swift
// MARK: String Tests  // Good
// MARK: - String Tests  // Old XCTest style
```

#### 5. Accuracy Comparisons

**Issue:** `XCTAssertEqual(_:_:accuracy:)` has no direct equivalent.

**Root Cause:** Swift Testing uses `#expect()` which doesn't have an accuracy parameter.

**Solution:** Use explicit comparison:
```swift
// Before (XCTest)
XCTAssertEqual(a, b, accuracy: 0.5)

// After (Swift Testing)
#expect(abs(a - b) < 0.5)
```

#### 6. Test Isolation with Singletons

**Issue:** Tests affecting each other due to shared singleton state.

**Root Cause:** Swift Testing may run tests in parallel, and singletons persist between tests.

**Solution:** Reset state in `init()`:
```swift
@Suite("My Tests")
@MainActor
struct MyTests {
    init() {
        // Reset singleton state
        UserDefaultsStore.shared.removeObject(forKey: "key")
        MyManager.shared.reset()
    }
}
```

**Alternative:** Use `@Suite(.serialized)` to force sequential execution.

#### 7. Async Test Patterns

**Issue:** Timer-based tests need real time to pass.

**Root Cause:** No shortcuts for time in integration tests.

**Solution:** Use `Task.sleep` and be generous with timeouts:
```swift
@Test("Timer countdown")
func timerCountdown() async throws {
    viewModel.start()
    try await Task.sleep(nanoseconds: 2_000_000_000)  // 2 seconds
    #expect(viewModel.timeRemaining < initialTime)
}
```

#### 8. UI Test Limitation is Real

**Issue:** Cannot migrate UI tests to Swift Testing.

**Root Cause:** `XCUIApplication`, `XCUIElement` etc. are part of XCTest framework.

**Solution:** Accept mixed testing approach. Document clearly why UI tests stay on XCTest.

**Documentation Example:**
```swift
// UI tests must use XCTest because Swift Testing does not support XCUITest framework.
// This is a known limitation and is expected behavior.
import XCTest

final class MenuBarUITests: XCTestCase {
    // ...
}
```

### Migration Checklist

Use this checklist for each file:

- [ ] Add `import Foundation` as first import
- [ ] Replace `import XCTest` with `import Testing`
- [ ] Convert class to struct with `@Suite` attribute
- [ ] Add `@MainActor` if original class had it
- [ ] Convert `func test*()` to `@Test func *()`
- [ ] Replace all `XCTAssert*` with `#expect()`
- [ ] Convert `setUp()/tearDown()` to `init()/deinit()` or inline cleanup
- [ ] Handle accuracy comparisons with `abs(a - b) < accuracy`
- [ ] Add `.serialized` trait if tests must run sequentially
- [ ] Clean up MARK comments (remove `-` separator)
- [ ] Run tests to verify: `swift test --filter YourTestSuite`

### Quick Reference

**Common Conversions:**

| XCTest | Swift Testing |
|--------|---------------|
| `XCTAssertTrue(x)` | `#expect(x)` |
| `XCTAssertFalse(x)` | `#expect(!x)` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertNotEqual(a, b)` | `#expect(a != b)` |
| `XCTAssertNil(x)` | `#expect(x == nil)` |
| `XCTAssertNotNil(x)` | `#expect(x != nil)` |
| `XCTAssertGreaterThan(a, b)` | `#expect(a > b)` |
| `XCTAssertLessThan(a, b)` | `#expect(a < b)` |
| `XCTAssertEqual(a, b, accuracy: c)` | `#expect(abs(a - b) < c)` |
| `XCTFail("message")` | `Issue.record("message")` |

---

## References

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [Migrating from XCTest](https://developer.apple.com/documentation/testing/migratingfromxctest)
- [Swift Testing WWDC 2024](https://developer.apple.com/videos/play/wwdc2024/10179/)
- [Swift 6 Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)
