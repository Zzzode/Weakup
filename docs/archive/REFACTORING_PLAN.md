# Refactoring Plan

**Version:** 1.0
**Date:** 2026-02-22
**Author:** Architecture Team

## Table of Contents

1. [Overview](#overview)
2. [Code Duplication Analysis](#code-duplication-analysis)
3. [Refactoring Priorities](#refactoring-priorities)
4. [Detailed Refactoring Tasks](#detailed-refactoring-tasks)
5. [Testing Strategy](#testing-strategy)
6. [Implementation Timeline](#implementation-timeline)

---

## Overview

This document outlines identified code smells, duplication, and architectural improvements needed in the Weakup codebase. Each refactoring is prioritized based on impact and effort.

### Refactoring Principles

1. **Red-Green-Refactor**: Ensure tests pass before and after
2. **Small Steps**: Make incremental changes
3. **Preserve Behavior**: Don't change functionality
4. **Test Coverage**: Maintain or improve coverage
5. **Review**: Get code review for significant changes

---

## Code Duplication Analysis

### 1. Time Formatting Duplication

**Location**: Multiple files
- `SettingsView.swift:352-362` - formatTime()
- `SettingsView.swift:364-376` - formatDurationDisplay()
- `AppDelegate.swift:187-197` - formatMenuBarTime()

**Issue**: Same logic repeated 3 times

**Impact**: Medium (maintainability)

**Example**:
```swift
// SettingsView.swift
private func formatTime(_ time: TimeInterval) -> String {
    let totalSeconds = Int(time)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    return String(format: "%02d:%02d", minutes, seconds)
}

// AppDelegate.swift
private func formatMenuBarTime(_ time: TimeInterval) -> String {
    let totalSeconds = Int(time)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    return String(format: "%02d:%02d", minutes, seconds)
}
```

### 2. UserDefaults Keys Duplication

**Location**: Multiple managers
- `CaffeineViewModel.swift:36-41` - Keys enum
- `ActivityHistoryManager.swift:12` - userDefaultsKey string
- `NotificationManager.swift:18-20` - Keys enum
- `IconManager.swift:57` - userDefaultsKey string
- `ThemeManager.swift:43` - userDefaultsKey string
- `HotkeyManager.swift:108` - userDefaultsKey string
- `L10n.swift:44` - userDefaultsKey string

**Issue**: Inconsistent key naming, no centralized management

**Impact**: High (risk of conflicts, hard to maintain)

**Example**:
```swift
// CaffeineViewModel
private enum Keys {
    static let soundEnabled = "WeakupSoundEnabled"
    static let timerMode = "WeakupTimerMode"
    static let timerDuration = "WeakupTimerDuration"
    static let showCountdownInMenuBar = "WeakupShowCountdownInMenuBar"
}

// ActivityHistoryManager
private let userDefaultsKey = "WeakupActivityHistory"

// IconManager
private let userDefaultsKey = "WeakupIconStyle"
```

### 3. UserDefaults Access Pattern Duplication

**Location**: Multiple managers
- `CaffeineViewModel.swift:208-230` - Safe loading helpers
- All managers: Direct UserDefaults.standard access

**Issue**: Inconsistent error handling, no abstraction

**Impact**: High (testability, maintainability)

### 4. Singleton Pattern Duplication

**Location**: All managers
```swift
@MainActor
public final class Manager: ObservableObject {
    public static let shared = Manager()
    private init() { /* ... */ }
}
```

**Issue**: Repeated boilerplate, hard to test

**Impact**: Medium (testability)

### 5. Localization String Accessors

**Location**: `L10n.swift:112-190`

**Issue**: 70+ lines of repetitive property accessors

**Example**:
```swift
public extension L10n {
    var appName: String { string(forKey: "app_name") }
    var menuSettings: String { string(forKey: "menu_settings") }
    var menuQuit: String { string(forKey: "menu_quit") }
    // ... 60+ more
}
```

**Impact**: Low (works well, but verbose)

---

## Refactoring Priorities

### Priority Matrix

```
High Impact, Low Effort (Do First)
├── P1: Centralize UserDefaults keys
├── P2: Extract time formatting utilities
└── P3: Create PreferencesService abstraction

High Impact, High Effort (Plan Carefully)
├── P4: Implement dependency injection
├── P5: Refactor singleton pattern
└── P6: Create protocol abstractions

Low Impact, Low Effort (Quick Wins)
├── P7: Extract common constants
├── P8: Consolidate error handling
└── P9: Improve code organization

Low Impact, High Effort (Defer)
├── P10: Migrate to TCA architecture
└── P11: Rewrite with SwiftUI App lifecycle
```

---

## Detailed Refactoring Tasks

### P1: Centralize UserDefaults Keys (HIGH PRIORITY)

**Effort**: 2 hours
**Impact**: High
**Risk**: Low

**Current State**: Keys scattered across files
**Target State**: Single source of truth

**Implementation**:

```swift
// Sources/WeakupCore/Utilities/PreferencesKeys.swift
public enum PreferencesKeys {
    // CaffeineViewModel
    public static let soundEnabled = "WeakupSoundEnabled"
    public static let timerMode = "WeakupTimerMode"
    public static let timerDuration = "WeakupTimerDuration"
    public static let showCountdownInMenuBar = "WeakupShowCountdownInMenuBar"

    // ActivityHistoryManager
    public static let activityHistory = "WeakupActivityHistory"

    // NotificationManager
    public static let notificationsEnabled = "WeakupNotificationsEnabled"

    // IconManager
    public static let iconStyle = "WeakupIconStyle"

    // ThemeManager
    public static let theme = "WeakupTheme"

    // HotkeyManager
    public static let hotkeyConfig = "WeakupHotkeyConfig"

    // L10n
    public static let language = "WeakupLanguage"

    // LaunchAtLoginManager
    // (Uses ServiceManagement, no UserDefaults)

    // Validation
    public static var allKeys: [String] {
        [
            soundEnabled, timerMode, timerDuration, showCountdownInMenuBar,
            activityHistory, notificationsEnabled, iconStyle, theme,
            hotkeyConfig, language
        ]
    }

    // Testing helper
    public static func clearAll() {
        allKeys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
}
```

**Migration Steps**:
1. Create PreferencesKeys.swift
2. Update CaffeineViewModel to use PreferencesKeys
3. Update all managers
4. Update tests to use PreferencesKeys.clearAll()
5. Remove old Keys enums

**Tests**:
```swift
func testPreferencesKeys_noDuplicates() {
    let keys = PreferencesKeys.allKeys
    let uniqueKeys = Set(keys)
    XCTAssertEqual(keys.count, uniqueKeys.count, "Duplicate keys found")
}

func testPreferencesKeys_allHavePrefix() {
    for key in PreferencesKeys.allKeys {
        XCTAssertTrue(key.hasPrefix("Weakup"), "Key \(key) missing Weakup prefix")
    }
}
```

---

### P2: Extract Time Formatting Utilities (HIGH PRIORITY)

**Effort**: 1 hour
**Impact**: Medium
**Risk**: Low

**Implementation**:

```swift
// Sources/WeakupCore/Utilities/TimeFormatter.swift
import Foundation

public enum TimeFormatter {
    /// Formats time interval as HH:MM:SS or MM:SS
    /// Examples: "1:23:45", "23:45"
    public static func formatCountdown(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Formats time interval as "Xh Ym" or "Xh" or "Ym"
    /// Examples: "2h 30m", "1h", "45m"
    public static func formatDuration(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    /// Formats time interval for menu bar display
    /// Examples: "1:23:45", "23:45"
    public static func formatMenuBar(_ time: TimeInterval) -> String {
        formatCountdown(time)
    }

    /// Formats date as relative string (e.g., "2 hours ago", "Yesterday")
    public static func formatRelative(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
```

**Migration Steps**:
1. Create TimeFormatter.swift
2. Add unit tests for TimeFormatter
3. Replace formatTime() in SettingsView
4. Replace formatDurationDisplay() in SettingsView
5. Replace formatMenuBarTime() in AppDelegate
6. Remove old methods

**Tests**:
```swift
final class TimeFormatterTests: XCTestCase {
    func testFormatCountdown_hoursMinutesSeconds() {
        XCTAssertEqual(TimeFormatter.formatCountdown(3661), "1:01:01")
    }

    func testFormatCountdown_minutesSeconds() {
        XCTAssertEqual(TimeFormatter.formatCountdown(125), "02:05")
    }

    func testFormatCountdown_zero() {
        XCTAssertEqual(TimeFormatter.formatCountdown(0), "00:00")
    }

    func testFormatDuration_hoursAndMinutes() {
        XCTAssertEqual(TimeFormatter.formatDuration(5400), "1h 30m")
    }

    func testFormatDuration_hoursOnly() {
        XCTAssertEqual(TimeFormatter.formatDuration(7200), "2h")
    }

    func testFormatDuration_minutesOnly() {
        XCTAssertEqual(TimeFormatter.formatDuration(1800), "30m")
    }
}
```

---

### P3: Create PreferencesService Abstraction (HIGH PRIORITY)

**Effort**: 4 hours
**Impact**: High (enables testing)
**Risk**: Medium

**Implementation**:

```swift
// Sources/WeakupCore/Utilities/PreferencesService.swift
import Foundation

public protocol PreferencesService: Sendable {
    func bool(forKey key: String) -> Bool
    func set(_ value: Bool, forKey key: String)
    func double(forKey key: String) -> Double
    func set(_ value: Double, forKey key: String)
    func string(forKey key: String) -> String?
    func set(_ value: String?, forKey key: String)
    func data(forKey key: String) -> Data?
    func set(_ value: Data?, forKey key: String)
    func removeObject(forKey key: String)
    func synchronize()
}

// Production implementation
public final class UserDefaultsPreferencesService: PreferencesService {
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func bool(forKey key: String) -> Bool {
        userDefaults.bool(forKey: key)
    }

    public func set(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    public func double(forKey key: String) -> Double {
        userDefaults.double(forKey: key)
    }

    public func set(_ value: Double, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    public func string(forKey key: String) -> String? {
        userDefaults.string(forKey: key)
    }

    public func set(_ value: String?, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    public func data(forKey key: String) -> Data? {
        userDefaults.data(forKey: key)
    }

    public func set(_ value: Data?, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    public func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }

    public func synchronize() {
        userDefaults.synchronize()
    }
}

// Test implementation
public final class InMemoryPreferencesService: PreferencesService {
    private var storage: [String: Any] = [:]
    private let lock = NSLock()

    public init() {}

    public func bool(forKey key: String) -> Bool {
        lock.withLock { storage[key] as? Bool ?? false }
    }

    public func set(_ value: Bool, forKey key: String) {
        lock.withLock { storage[key] = value }
    }

    public func double(forKey key: String) -> Double {
        lock.withLock { storage[key] as? Double ?? 0.0 }
    }

    public func set(_ value: Double, forKey key: String) {
        lock.withLock { storage[key] = value }
    }

    public func string(forKey key: String) -> String? {
        lock.withLock { storage[key] as? String }
    }

    public func set(_ value: String?, forKey key: String) {
        lock.withLock { storage[key] = value }
    }

    public func data(forKey key: String) -> Data? {
        lock.withLock { storage[key] as? Data }
    }

    public func set(_ value: Data?, forKey key: String) {
        lock.withLock { storage[key] = value }
    }

    public func removeObject(forKey key: String) {
        lock.withLock { storage.removeValue(forKey: key) }
    }

    public func synchronize() {
        // No-op for in-memory
    }

    public func clear() {
        lock.withLock { storage.removeAll() }
    }
}
```

**Migration Steps**:
1. Create PreferencesService protocol and implementations
2. Add tests for PreferencesService
3. Update CaffeineViewModel to accept PreferencesService
4. Update all managers to accept PreferencesService
5. Update AppDelegate to inject PreferencesService
6. Update all tests to use InMemoryPreferencesService

**Example Migration**:
```swift
// Before
@MainActor
public final class IconManager: ObservableObject {
    public static let shared = IconManager()
    private let userDefaultsKey = "WeakupIconStyle"

    private init() {
        if let savedStyle = UserDefaults.standard.string(forKey: userDefaultsKey),
           let style = IconStyle(rawValue: savedStyle) {
            currentStyle = style
        } else {
            currentStyle = .power
        }
    }
}

// After
@MainActor
public final class IconManager: ObservableObject {
    public static let shared = IconManager()
    private let preferences: PreferencesService

    public init(preferences: PreferencesService = UserDefaultsPreferencesService()) {
        self.preferences = preferences
        if let savedStyle = preferences.string(forKey: PreferencesKeys.iconStyle),
           let style = IconStyle(rawValue: savedStyle) {
            currentStyle = style
        } else {
            currentStyle = .power
        }
    }
}
```

---

### P4: Implement Dependency Injection (HIGH PRIORITY)

**Effort**: 8 hours
**Impact**: High (testability)
**Risk**: High

**Implementation**:

```swift
// Sources/WeakupCore/Utilities/DependencyContainer.swift
@MainActor
public final class DependencyContainer {
    public static let shared = DependencyContainer()

    // Services
    public let preferences: PreferencesService
    public let powerManager: PowerManaging
    public let notificationCenter: NotificationCenterProtocol

    // Managers (lazy to avoid circular dependencies)
    public private(set) lazy var iconManager: IconManager = {
        IconManager(preferences: preferences)
    }()

    public private(set) lazy var themeManager: ThemeManager = {
        ThemeManager(preferences: preferences)
    }()

    public private(set) lazy var hotkeyManager: HotkeyManager = {
        HotkeyManager(preferences: preferences)
    }()

    public private(set) lazy var l10n: L10n = {
        L10n(preferences: preferences)
    }()

    public private(set) lazy var notificationManager: NotificationManager = {
        NotificationManager(
            preferences: preferences,
            notificationCenter: notificationCenter,
            l10n: l10n
        )
    }()

    public private(set) lazy var historyManager: ActivityHistoryManager = {
        ActivityHistoryManager(preferences: preferences)
    }()

    public private(set) lazy var launchAtLoginManager: LaunchAtLoginManager = {
        LaunchAtLoginManager()
    }()

    public init(
        preferences: PreferencesService = UserDefaultsPreferencesService(),
        powerManager: PowerManaging = IOKitPowerManager(),
        notificationCenter: NotificationCenterProtocol = UNUserNotificationCenter.current()
    ) {
        self.preferences = preferences
        self.powerManager = powerManager
        self.notificationCenter = notificationCenter
    }

    // Factory methods
    public func makeCaffeineViewModel() -> CaffeineViewModel {
        CaffeineViewModel(
            powerManager: powerManager,
            notificationManager: notificationManager,
            preferences: preferences
        )
    }

    // Testing helper
    public static func makeTest() -> DependencyContainer {
        DependencyContainer(
            preferences: InMemoryPreferencesService(),
            powerManager: MockPowerManager(),
            notificationCenter: MockNotificationCenter()
        )
    }
}
```

**Migration Steps**:
1. Create protocol abstractions (PowerManaging, NotificationCenterProtocol)
2. Create DependencyContainer
3. Update managers to accept dependencies
4. Update AppDelegate to use DependencyContainer
5. Update tests to use DependencyContainer.makeTest()

---

### P5: Refactor Singleton Pattern (MEDIUM PRIORITY)

**Effort**: 6 hours
**Impact**: Medium
**Risk**: Medium

**Current Problem**: Singletons make testing difficult

**Solution**: Keep singleton for convenience, but allow injection

```swift
// Before
@MainActor
public final class IconManager: ObservableObject {
    public static let shared = IconManager()
    private init() { /* ... */ }
}

// After
@MainActor
public final class IconManager: ObservableObject {
    public static let shared = IconManager()

    private let preferences: PreferencesService

    public init(preferences: PreferencesService = UserDefaultsPreferencesService()) {
        self.preferences = preferences
        // ... initialization
    }
}
```

**Benefits**:
- Backward compatible (shared still works)
- Testable (can inject mock preferences)
- Flexible (can create multiple instances if needed)

---

### P6: Extract Common Constants (LOW PRIORITY)

**Effort**: 1 hour
**Impact**: Low
**Risk**: Low

**Implementation**:

```swift
// Sources/WeakupCore/Utilities/Constants.swift
public enum Constants {
    // History
    public static let maxStoredSessions = 100

    // Timer
    public static let timerUpdateInterval: TimeInterval = 0.5
    public static let maxTimerDuration: TimeInterval = 24 * 3600 // 24 hours

    // Hotkey
    public static let hotkeySignature: OSType = 0x57454B55 // "WEKU"

    // Notifications
    public enum NotificationIdentifier {
        public static let timerExpired = "com.weakup.timer.expired"
    }

    public enum ActionIdentifier {
        public static let restart = "RESTART_TIMER"
        public static let dismiss = "DISMISS"
    }

    public enum CategoryIdentifier {
        public static let timerExpired = "TIMER_EXPIRED"
    }
}
```

---

### P7: Consolidate Error Handling (MEDIUM PRIORITY)

**Effort**: 3 hours
**Impact**: Medium
**Risk**: Low

**Current State**: Inconsistent error handling
- Some methods return nil on failure
- Some print to console
- Some silently fail

**Implementation**:

```swift
// Sources/WeakupCore/Utilities/WeakupError.swift
public enum WeakupError: Error, LocalizedError {
    case assertionCreationFailed
    case assertionReleaseFailed
    case hotkeyRegistrationFailed
    case notificationAuthorizationDenied
    case persistenceError(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .assertionCreationFailed:
            return "Failed to create power assertion"
        case .assertionReleaseFailed:
            return "Failed to release power assertion"
        case .hotkeyRegistrationFailed:
            return "Failed to register global hotkey"
        case .notificationAuthorizationDenied:
            return "Notification permission denied"
        case .persistenceError(let error):
            return "Failed to save data: \(error.localizedDescription)"
        }
    }
}

// Usage
public func start() throws {
    var id: IOPMAssertionID = 0
    let result = IOPMAssertionCreateWithName(...)

    guard result == kIOReturnSuccess else {
        throw WeakupError.assertionCreationFailed
    }

    assertionID = id
    isActive = true
}
```

---

### P8: Improve Code Organization (LOW PRIORITY)

**Effort**: 2 hours
**Impact**: Low
**Risk**: Low

**Reorganize files**:

```
Sources/WeakupCore/
├── Models/
│   ├── ActivitySession.swift
│   ├── ActivityStatistics.swift
│   ├── HotkeyConfig.swift
│   ├── IconStyle.swift
│   ├── AppTheme.swift
│   └── AppLanguage.swift
├── ViewModels/
│   └── CaffeineViewModel.swift
├── Services/
│   ├── PowerManagement/
│   │   ├── PowerManaging.swift
│   │   └── IOKitPowerManager.swift
│   ├── Preferences/
│   │   ├── PreferencesService.swift
│   │   ├── PreferencesKeys.swift
│   │   └── UserDefaultsPreferencesService.swift
│   └── Notifications/
│       ├── NotificationManaging.swift
│       └── NotificationManager.swift
├── Managers/
│   ├── ActivityHistoryManager.swift
│   ├── HotkeyManager.swift
│   ├── IconManager.swift
│   ├── ThemeManager.swift
│   └── LaunchAtLoginManager.swift
├── Utilities/
│   ├── L10n.swift
│   ├── TimeFormatter.swift
│   ├── Constants.swift
│   ├── WeakupError.swift
│   └── DependencyContainer.swift
└── Extensions/
    └── (future extensions)
```

---

## Testing Strategy

### For Each Refactoring

1. **Before**: Run all tests, ensure they pass
2. **During**: Make incremental changes
3. **After**: Run all tests, ensure they still pass
4. **Verify**: Manual testing of affected features

### Regression Testing Checklist

- [ ] Sleep prevention works (start/stop)
- [ ] Timer mode works (countdown, expiry)
- [ ] Notifications work (timer expiry, restart)
- [ ] Hotkeys work (toggle, custom hotkey)
- [ ] Settings persist (relaunch app)
- [ ] Language switching works
- [ ] Theme switching works
- [ ] Icon switching works
- [ ] History tracking works
- [ ] Launch at login works

---

## Implementation Timeline

### Phase 1: Foundation (Week 1)
- P1: Centralize UserDefaults keys (Day 1)
- P2: Extract time formatting utilities (Day 1)
- P3: Create PreferencesService abstraction (Days 2-3)
- Testing and verification (Days 4-5)

### Phase 2: Dependency Injection (Week 2)
- Create protocol abstractions (Days 1-2)
- P4: Implement DependencyContainer (Days 3-4)
- P5: Refactor singleton pattern (Day 5)

### Phase 3: Polish (Week 3)
- P6: Extract common constants (Day 1)
- P7: Consolidate error handling (Days 2-3)
- P8: Improve code organization (Day 4)
- Final testing and documentation (Day 5)

### Phase 4: Future Improvements (Backlog)
- P10: Migrate to TCA architecture
- P11: Rewrite with SwiftUI App lifecycle
- Property-based testing
- Performance optimization

---

## Success Metrics

### Code Quality
- [ ] Test coverage increases to 85%+
- [ ] No code duplication (DRY principle)
- [ ] All managers are testable
- [ ] Consistent error handling

### Developer Experience
- [ ] Tests run faster (no UserDefaults I/O)
- [ ] Easy to mock dependencies
- [ ] Clear code organization
- [ ] Good documentation

### User Experience
- [ ] No regressions
- [ ] Same or better performance
- [ ] All features work as before

---

## Risks and Mitigation

### Risk 1: Breaking Changes
**Mitigation**: Comprehensive test suite, incremental changes

### Risk 2: Performance Regression
**Mitigation**: Performance testing, profiling

### Risk 3: Merge Conflicts
**Mitigation**: Small PRs, frequent merges, communicate with team

### Risk 4: Scope Creep
**Mitigation**: Stick to plan, defer nice-to-haves

---

## Conclusion

This refactoring plan addresses key technical debt in the Weakup codebase:

1. **Centralized configuration** (UserDefaults keys)
2. **Reduced duplication** (time formatting, preferences)
3. **Improved testability** (dependency injection)
4. **Better organization** (clear structure)

Following this plan will result in:
- ✅ More maintainable code
- ✅ Better test coverage
- ✅ Easier to add new features
- ✅ Reduced bugs

The phased approach ensures we can deliver value incrementally while minimizing risk.
