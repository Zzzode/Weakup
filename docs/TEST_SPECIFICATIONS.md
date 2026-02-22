# Weakup Test Specifications

## Document Information

| Field | Value |
|-------|-------|
| Version | 1.1 |
| Created | 2026-02-22 |
| Updated | 2026-02-22 |
| Author | QA Lead |
| Status | Active |

### Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-22 | Initial test specifications |
| 1.1 | 2026-02-22 | Added Dev3 types (HistoryFilterMode, HistorySortOrder, ExportFormat), Dev5 conflict detection tests, ActivitySession.imported tests |

---

## 1. Test Architecture Overview

### 1.1 Test Directory Structure

```
Tests/
├── WeakupTests/
│   ├── Unit/
│   │   ├── ViewModels/
│   │   │   └── CaffeineViewModelTests.swift
│   │   ├── Models/
│   │   │   └── ActivitySessionTests.swift
│   │   └── Utilities/
│   │       ├── L10nTests.swift
│   │       ├── AppLanguageTests.swift
│   │       ├── IconManagerTests.swift
│   │       ├── ThemeManagerTests.swift
│   │       ├── HotkeyManagerTests.swift
│   │       ├── ActivityHistoryManagerTests.swift
│   │       ├── NotificationManagerTests.swift
│   │       └── VersionTests.swift
│   ├── Integration/
│   │   ├── SleepPreventionIntegrationTests.swift
│   │   ├── TimerIntegrationTests.swift
│   │   ├── PersistenceIntegrationTests.swift
│   │   └── LocalizationIntegrationTests.swift
│   └── Mocks/
│       ├── MockUserDefaults.swift
│       ├── MockNotificationCenter.swift
│       └── MockIOPMAssertion.swift
└── WeakupUITests/
    ├── MenuBarUITests.swift
    ├── SettingsPopoverUITests.swift
    └── KeyboardShortcutUITests.swift
```

### 1.2 Testing Framework

- **Primary**: XCTest (Apple's native testing framework)
- **Async Testing**: XCTest async/await support
- **UI Testing**: XCUITest for UI automation
- **Mocking**: Protocol-based dependency injection

---

## 2. Unit Test Specifications

### 2.1 CaffeineViewModel Tests

**File**: `Tests/WeakupTests/CaffeineViewModelTests.swift`
**Target Coverage**: 90%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| CVM-001 | `testInitialState_isInactive` | Verify isActive is false on init | P0 | Implemented |
| CVM-002 | `testInitialState_timerModeDisabled` | Verify timerMode is false on init | P0 | Implemented |
| CVM-003 | `testInitialState_timeRemainingIsZero` | Verify timeRemaining is 0 on init | P0 | Implemented |
| CVM-004 | `testInitialState_timerDurationIsZero` | Verify timerDuration is 0 on init | P0 | Implemented |
| CVM-005 | `testInitialState_soundEnabledByDefault` | Verify soundEnabled is true on init | P0 | Implemented |
| CVM-006 | `testToggle_startsWhenInactive` | Toggle when inactive starts prevention | P0 | Implemented |
| CVM-007 | `testToggle_stopsWhenActive` | Toggle when active stops prevention | P0 | Implemented |
| CVM-008 | `testToggle_multipleTimes` | Rapid toggling maintains consistency | P0 | Implemented |
| CVM-009 | `testStart_activatesViewModel` | Start sets isActive to true | P0 | Implemented |
| CVM-010 | `testStop_deactivatesViewModel` | Stop sets isActive to false | P0 | Implemented |
| CVM-011 | `testStop_resetsTimeRemaining` | Stop resets timeRemaining to 0 | P0 | Implemented |
| CVM-012 | `testStop_whenAlreadyStopped_noError` | Stop when inactive is safe | P1 | Implemented |
| CVM-013 | `testSetTimerDuration_updatesValue` | Duration setter works correctly | P0 | Implemented |
| CVM-014 | `testSetTimerDuration_negativeClampsToZero` | Negative duration clamps to 0 | P1 | Implemented |
| CVM-015 | `testSetTimerDuration_stopsIfActive` | Setting duration stops active session | P1 | Implemented |
| CVM-016 | `testSetTimerDuration_persistsValue` | Duration persists to UserDefaults | P1 | Implemented |
| CVM-017 | `testSetTimerMode_updatesValue` | Timer mode setter works | P0 | Implemented |
| CVM-018 | `testSetTimerMode_persistsValue` | Timer mode persists to UserDefaults | P1 | Implemented |
| CVM-019 | `testTimerMode_withDuration_setsTimeRemaining` | Timer mode sets timeRemaining | P0 | Implemented |
| CVM-020 | `testTimerMode_withoutDuration_noTimeRemaining` | Zero duration means no countdown | P1 | Implemented |
| CVM-021 | `testTimerMode_disabled_noTimeRemaining` | Disabled timer mode has no countdown | P1 | Implemented |
| CVM-022 | `testSoundEnabled_persistsValue` | Sound setting persists | P1 | Implemented |
| CVM-023 | `testSoundEnabled_toggles` | Sound setting can toggle | P1 | Implemented |
| CVM-024 | `testShowCountdownInMenuBar_persistsValue` | Menu bar countdown persists | P1 | Pending |
| CVM-025 | `testNotificationsEnabled_syncsWithManager` | Notifications sync with manager | P1 | Pending |
| CVM-026 | `testRestartTimer_startsWithSameDuration` | Restart uses same duration | P1 | Pending |
| CVM-027 | `testTimerCountdown_accuracy` | Timer counts down accurately | P0 | Pending |
| CVM-028 | `testTimerExpiry_stopsAutomatically` | Timer auto-stops at zero | P0 | Pending |
| CVM-029 | `testIOPMAssertion_createdOnStart` | Assertion created on start | P0 | Pending |
| CVM-030 | `testIOPMAssertion_releasedOnStop` | Assertion released on stop | P0 | Pending |

#### Test Data

```swift
// Timer durations for testing
let testDurations: [TimeInterval] = [
    0,      // Off
    900,    // 15 minutes
    1800,   // 30 minutes
    3600,   // 1 hour
    7200,   // 2 hours
    10800   // 3 hours
]
```

---

### 2.2 L10n Tests

**File**: `Tests/WeakupTests/L10nTests.swift`
**Target Coverage**: 85%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| L10N-001 | `testShared_returnsSameInstance` | Singleton returns same instance | P0 | Pending |
| L10N-002 | `testDefaultLanguage_detectsSystem` | Detects system language correctly | P0 | Pending |
| L10N-003 | `testSetLanguage_updatesCurrentLanguage` | Setting language updates property | P0 | Pending |
| L10N-004 | `testSetLanguage_persistsToUserDefaults` | Language persists to UserDefaults | P0 | Pending |
| L10N-005 | `testStringForKey_returnsLocalizedString` | Returns correct localized string | P0 | Pending |
| L10N-006 | `testStringForKey_fallsBackToEnglish` | Falls back to English if missing | P1 | Pending |
| L10N-007 | `testStringForKey_returnsKeyIfNotFound` | Returns formatted key if not found | P1 | Pending |
| L10N-008 | `testAllStringProperties_returnNonEmpty` | All string properties return values | P1 | Pending |
| L10N-009 | `testLanguageSwitch_updatesAllStrings` | Switching updates all strings | P0 | Pending |
| L10N-010 | `testChineseDetection_simplified` | Detects simplified Chinese correctly | P1 | Pending |
| L10N-011 | `testChineseDetection_traditional` | Detects traditional Chinese correctly | P1 | Pending |
| L10N-012 | `testJapaneseDetection` | Detects Japanese correctly | P1 | Pending |
| L10N-013 | `testKoreanDetection` | Detects Korean correctly | P1 | Pending |
| L10N-014 | `testFrenchDetection` | Detects French correctly | P1 | Pending |
| L10N-015 | `testGermanDetection` | Detects German correctly | P1 | Pending |
| L10N-016 | `testSpanishDetection` | Detects Spanish correctly | P1 | Pending |
| L10N-017 | `testUnsupportedLanguage_defaultsToEnglish` | Unsupported defaults to English | P1 | Pending |

---

### 2.3 AppLanguage Tests

**File**: `Tests/WeakupTests/AppLanguageTests.swift`
**Target Coverage**: 100%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| AL-001 | `testAllCases_containsExpectedLanguages` | All 8 languages present | P0 | Needs Update |
| AL-002 | `testRawValue_english` | English raw value is "en" | P0 | Implemented |
| AL-003 | `testRawValue_chinese` | Chinese raw value is "zh-Hans" | P0 | Implemented |
| AL-004 | `testRawValue_chineseTraditional` | Traditional Chinese is "zh-Hant" | P0 | Pending |
| AL-005 | `testRawValue_japanese` | Japanese raw value is "ja" | P0 | Pending |
| AL-006 | `testRawValue_korean` | Korean raw value is "ko" | P0 | Pending |
| AL-007 | `testRawValue_french` | French raw value is "fr" | P0 | Pending |
| AL-008 | `testRawValue_german` | German raw value is "de" | P0 | Pending |
| AL-009 | `testRawValue_spanish` | Spanish raw value is "es" | P0 | Pending |
| AL-010 | `testId_matchesRawValue` | ID equals raw value | P1 | Implemented |
| AL-011 | `testDisplayName_english` | English display name correct | P1 | Implemented |
| AL-012 | `testDisplayName_chinese` | Chinese display name correct | P1 | Needs Update |
| AL-013 | `testDisplayName_allLanguagesHaveDisplayNames` | All have display names | P1 | Implemented |
| AL-014 | `testBundle_returnsBundle` | Bundle property returns bundle | P1 | Implemented |
| AL-015 | `testInit_fromValidRawValue` | Init from valid raw value | P1 | Implemented |
| AL-016 | `testInit_fromInvalidRawValue` | Init from invalid returns nil | P1 | Implemented |

---

### 2.4 ActivitySession Tests

**File**: `Tests/WeakupTests/ActivitySessionTests.swift`
**Target Coverage**: 95%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| AS-001 | `testInit_setsDefaultValues` | Default init sets correct values | P0 | Implemented |
| AS-002 | `testInit_withCustomValues` | Custom init works correctly | P0 | Implemented |
| AS-003 | `testInit_generatesUniqueIds` | Each session has unique ID | P0 | Implemented |
| AS-004 | `testIsActive_trueWhenNoEndTime` | Active when no end time | P0 | Implemented |
| AS-005 | `testIsActive_falseAfterEnd` | Inactive after end() called | P0 | Implemented |
| AS-006 | `testDuration_calculatesFromStartToEnd` | Duration calc with end time | P0 | Implemented |
| AS-007 | `testDuration_calculatesFromStartToNowWhenActive` | Duration calc when active | P0 | Implemented |
| AS-008 | `testEnd_setsEndTime` | end() sets endTime | P0 | Implemented |
| AS-009 | `testEnd_endTimeIsNow` | endTime is current time | P0 | Implemented |
| AS-010 | `testCodable_encodesAndDecodes` | Codable round-trip works | P1 | Implemented |
| AS-011 | `testImported_defaultFalse` | imported property defaults to false | P1 | Pending |
| AS-012 | `testImported_canBeSetTrue` | imported property can be set to true | P1 | Pending |
| AS-013 | `testImported_persistsInCodable` | imported property survives encode/decode | P1 | Pending |
| AS-014 | `testInit_withImported` | Init with imported parameter works | P1 | Pending |

---

### 2.5 ActivityHistoryManager Tests

**File**: `Tests/WeakupTests/ActivityHistoryManagerTests.swift`
**Target Coverage**: 90%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| AHM-001 | `testShared_returnsSameInstance` | Singleton works | P0 | Implemented |
| AHM-002 | `testStartSession_createsCurrentSession` | Start creates session | P0 | Implemented |
| AHM-003 | `testStartSession_withTimerMode` | Timer mode session works | P0 | Implemented |
| AHM-004 | `testEndSession_addsToHistory` | End adds to history | P0 | Implemented |
| AHM-005 | `testEndSession_insertsAtBeginning` | New sessions at front | P0 | Implemented |
| AHM-006 | `testEndSession_withNoCurrentSession_doesNothing` | End without start is safe | P1 | Implemented |
| AHM-007 | `testClearHistory_removesAllSessions` | Clear removes all | P0 | Implemented |
| AHM-008 | `testStatistics_emptyHistory_returnsZeros` | Empty stats are zero | P0 | Implemented |
| AHM-009 | `testStatistics_countsCompletedSessions` | Stats count completed | P0 | Implemented |
| AHM-010 | `testStatistics_excludesActiveSessions` | Stats exclude active | P0 | Implemented |
| AHM-011 | `testStatistics_calculatesAverageDuration` | Average calc works | P1 | Implemented |
| AHM-012 | `testStatistics_todaySessions` | Today filter works | P1 | Pending |
| AHM-013 | `testStatistics_weekSessions` | Week filter works | P1 | Pending |
| AHM-014 | `testPersistence_savesOnEnd` | Sessions persist on end | P1 | Pending |
| AHM-015 | `testPersistence_loadsOnInit` | Sessions load on init | P1 | Pending |
| AHM-016 | `testFilterMode_allCases` | HistoryFilterMode has all expected cases | P1 | Pending |
| AHM-017 | `testFilterMode_filtering` | Filter mode correctly filters sessions | P1 | Pending |
| AHM-018 | `testSortOrder_allCases` | HistorySortOrder has all expected cases | P1 | Pending |
| AHM-019 | `testSortOrder_sorting` | Sort order correctly sorts sessions | P1 | Pending |
| AHM-020 | `testExportFormat_sendable` | ExportFormat conforms to Sendable | P1 | Pending |
| AHM-021 | `testExportFormat_allCases` | ExportFormat has all expected cases | P1 | Pending |
| AHM-022 | `testExport_json` | Export to JSON format works | P1 | Pending |
| AHM-023 | `testExport_csv` | Export to CSV format works | P1 | Pending |
| AHM-024 | `testImportSessions` | Import sessions from data works | P1 | Pending |

---

### 2.5.1 HistoryFilterMode Tests (New)

**Enum**: `HistoryFilterMode`
**Target Coverage**: 100%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| HFM-001 | `testAllCases_containsExpectedModes` | All filter modes present | P0 | Pending |
| HFM-002 | `testRawValue_all` | Raw value for all mode | P1 | Pending |
| HFM-003 | `testRawValue_today` | Raw value for today mode | P1 | Pending |
| HFM-004 | `testRawValue_thisWeek` | Raw value for this week mode | P1 | Pending |
| HFM-005 | `testRawValue_timerOnly` | Raw value for timer only mode | P1 | Pending |
| HFM-006 | `testId_matchesRawValue` | ID equals raw value | P1 | Pending |

---

### 2.5.2 HistorySortOrder Tests (New)

**Enum**: `HistorySortOrder`
**Target Coverage**: 100%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| HSO-001 | `testAllCases_containsExpectedOrders` | All sort orders present | P0 | Pending |
| HSO-002 | `testRawValue_newest` | Raw value for newest first | P1 | Pending |
| HSO-003 | `testRawValue_oldest` | Raw value for oldest first | P1 | Pending |
| HSO-004 | `testRawValue_longest` | Raw value for longest duration | P1 | Pending |
| HSO-005 | `testRawValue_shortest` | Raw value for shortest duration | P1 | Pending |
| HSO-006 | `testId_matchesRawValue` | ID equals raw value | P1 | Pending |

---

### 2.5.3 ExportFormat Tests (New)

**Enum**: `ExportFormat`
**Target Coverage**: 100%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| EF-001 | `testAllCases_containsExpectedFormats` | All export formats present | P0 | Pending |
| EF-002 | `testSendable_conformance` | ExportFormat conforms to Sendable | P0 | Pending |
| EF-003 | `testRawValue_json` | Raw value for JSON format | P1 | Pending |
| EF-004 | `testRawValue_csv` | Raw value for CSV format | P1 | Pending |
| EF-005 | `testFileExtension_json` | File extension for JSON | P1 | Pending |
| EF-006 | `testFileExtension_csv` | File extension for CSV | P1 | Pending |
| EF-007 | `testMimeType_json` | MIME type for JSON | P1 | Pending |
| EF-008 | `testMimeType_csv` | MIME type for CSV | P1 | Pending |

---

### 2.6 IconManager Tests

**File**: `Tests/WeakupTests/IconManagerTests.swift`
**Target Coverage**: 85%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| IM-001 | `testAllCases_containsExpectedStyles` | All 5 styles present | P0 | Implemented |
| IM-002 | `testRawValues` | Raw values are correct | P0 | Implemented |
| IM-003 | `testId_matchesRawValue` | ID equals raw value | P1 | Implemented |
| IM-004 | `testLocalizationKey_format` | Localization key format | P1 | Implemented |
| IM-005 | `testInactiveSymbol_*` | Inactive symbols correct | P0 | Implemented |
| IM-006 | `testActiveSymbol_*` | Active symbols correct | P0 | Implemented |
| IM-007 | `testShared_returnsSameInstance` | Singleton works | P0 | Implemented |
| IM-008 | `testSetStyle_persistsValue` | Style persists | P1 | Implemented |
| IM-009 | `testImage_returnsImage` | Image generation works | P1 | Implemented |
| IM-010 | `testCurrentImage_usesCurrentStyle` | Current image uses style | P1 | Implemented |
| IM-011 | `testOnIconChanged_calledWhenStyleChanges` | Callback fires on change | P1 | Implemented |

---

### 2.7 ThemeManager Tests

**File**: `Tests/WeakupTests/ThemeManagerTests.swift`
**Target Coverage**: 90%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| TM-001 | `testAllCases_containsExpectedThemes` | All 3 themes present | P0 | Implemented |
| TM-002 | `testRawValue_*` | Raw values correct | P0 | Implemented |
| TM-003 | `testId_matchesRawValue` | ID equals raw value | P1 | Implemented |
| TM-004 | `testLocalizationKey_*` | Localization keys correct | P1 | Implemented |
| TM-005 | `testColorScheme_system_returnsNil` | System returns nil | P0 | Implemented |
| TM-006 | `testColorScheme_light_returnsLight` | Light returns .light | P0 | Implemented |
| TM-007 | `testColorScheme_dark_returnsDark` | Dark returns .dark | P0 | Implemented |
| TM-008 | `testShared_returnsSameInstance` | Singleton works | P0 | Implemented |
| TM-009 | `testDefaultTheme_isSystem` | Default is system | P1 | Implemented |
| TM-010 | `testSetTheme_persistsValue` | Theme persists | P1 | Implemented |
| TM-011 | `testEffectiveColorScheme_matchesTheme` | Effective scheme correct | P1 | Implemented |

---

### 2.8 HotkeyManager Tests

**File**: `Tests/WeakupTests/HotkeyManagerTests.swift`
**Target Coverage**: 85%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| HM-001 | `testDefaultConfig_hasExpectedKeyCode` | Default key is 0 | P0 | Implemented |
| HM-002 | `testDefaultConfig_hasCommandAndControlModifiers` | Default has Cmd+Ctrl | P0 | Implemented |
| HM-003 | `testEquatable_sameConfigs_areEqual` | Equal configs match | P1 | Implemented |
| HM-004 | `testEquatable_differentKeyCode_areNotEqual` | Different keys differ | P1 | Implemented |
| HM-005 | `testEquatable_differentModifiers_areNotEqual` | Different mods differ | P1 | Implemented |
| HM-006 | `testDisplayString_defaultConfig` | Default display string | P1 | Implemented |
| HM-007 | `testDisplayString_withAllModifiers` | All modifiers display | P1 | Implemented |
| HM-008 | `testDisplayString_functionKey` | Function key display | P1 | Implemented |
| HM-009 | `testDisplayString_specialKeys` | Special keys display | P1 | Implemented |
| HM-010 | `testCodable_encodesAndDecodes` | Codable round-trip | P1 | Implemented |
| HM-011 | `testShared_returnsSameInstance` | Singleton works | P0 | Implemented |
| HM-012 | `testStartRecording_setsIsRecordingTrue` | Recording starts | P0 | Implemented |
| HM-013 | `testStopRecording_setsIsRecordingFalse` | Recording stops | P0 | Implemented |
| HM-014 | `testResetToDefault_restoresDefaultConfig` | Reset works | P1 | Implemented |
| HM-015 | `testHasConflict_initiallyFalse` | No initial conflict | P1 | Implemented |
| HM-016 | `testOnHotkeyPressed_canBeSet` | Callback can be set | P1 | Implemented |
| HM-017 | `testRecordKey_updatesConfig` | Recording updates config | P1 | Pending |
| HM-018 | `testRegisterHotkey_registersWithSystem` | Registration works | P1 | Pending |
| HM-019 | `testCheckForConflicts_noConflict` | No conflict when shortcut is unique | P0 | Pending |
| HM-020 | `testCheckForConflicts_systemConflict` | Detects system shortcut conflicts | P0 | Pending |
| HM-021 | `testCheckForConflicts_appConflict` | Detects other app shortcut conflicts | P0 | Pending |
| HM-022 | `testCheckForConflicts_possibleConflict` | Detects possible conflicts | P1 | Pending |
| HM-023 | `testConflictSeverity_high` | High severity for system conflicts | P1 | Pending |
| HM-024 | `testConflictSeverity_medium` | Medium severity for app conflicts | P1 | Pending |
| HM-025 | `testConflictSeverity_low` | Low severity for possible conflicts | P1 | Pending |
| HM-026 | `testConflictMessage_systemConflict` | Correct message for system conflict | P1 | Pending |
| HM-027 | `testConflictMessage_appConflict` | Correct message for app conflict | P1 | Pending |
| HM-028 | `testConflictSuggestion_providesAlternative` | Suggests alternative shortcuts | P2 | Pending |

---

### 2.9 NotificationManager Tests

**File**: `Tests/WeakupTests/NotificationManagerTests.swift`
**Target Coverage**: 80%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| NM-001 | `testShared_returnsSameInstance` | Singleton works | P0 | Pending |
| NM-002 | `testNotificationsEnabled_defaultTrue` | Default enabled | P0 | Pending |
| NM-003 | `testNotificationsEnabled_persistsValue` | Setting persists | P1 | Pending |
| NM-004 | `testRequestAuthorization_updatesIsAuthorized` | Auth updates state | P1 | Pending |
| NM-005 | `testScheduleTimerExpiryNotification_whenEnabled` | Schedules when enabled | P1 | Pending |
| NM-006 | `testScheduleTimerExpiryNotification_whenDisabled` | Skips when disabled | P1 | Pending |
| NM-007 | `testCancelPendingNotifications` | Cancel removes pending | P1 | Pending |
| NM-008 | `testOnRestartRequested_callback` | Restart callback fires | P1 | Pending |

---

### 2.10 Version Tests

**File**: `Tests/WeakupTests/VersionTests.swift`
**Target Coverage**: 100%

#### Test Cases

| ID | Test Name | Description | Priority | Status |
|----|-----------|-------------|----------|--------|
| VER-001 | `testString_returnsValidVersion` | Version string exists | P0 | Implemented |
| VER-002 | `testString_matchesSemanticVersionFormat` | Semantic version format | P0 | Implemented |
| VER-003 | `testBuild_returnsValidBuild` | Build string exists | P0 | Implemented |
| VER-004 | `testFullString_containsVersionAndBuild` | Full string complete | P0 | Implemented |
| VER-005 | `testFullString_format` | Full string format | P0 | Implemented |
| VER-006 | `testComponents_returnsTuple` | Components tuple valid | P1 | Implemented |
| VER-007 | `testComponents_matchVersionString` | Components match string | P1 | Implemented |
| VER-008 | `testComponents_defaultsForMissingParts` | Defaults for missing | P1 | Implemented |

---

## 3. Integration Test Specifications

### 3.1 Sleep Prevention Integration Tests

**File**: `Tests/WeakupTests/Integration/SleepPreventionIntegrationTests.swift`

#### Test Cases

| ID | Test Name | Description | Priority |
|----|-----------|-------------|----------|
| SPI-001 | `testSleepPrevention_assertionActive` | Verify IOPMAssertion is active | P0 |
| SPI-002 | `testSleepPrevention_assertionReleased` | Verify assertion released on stop | P0 |
| SPI-003 | `testMultipleToggle_noAssertionLeak` | No assertion leaks on rapid toggle | P0 |
| SPI-004 | `testAppTermination_releasesAssertion` | Assertion released on quit | P0 |
| SPI-005 | `testSystemSleep_preventedWhenActive` | System sleep actually prevented | P0 |

#### Verification Method

```bash
# Verify assertion active
pmset -g assertions | grep PreventUserIdleSystemSleep

# Expected output when active:
# PreventUserIdleSystemSleep: 1
# Weakup preventing sleep
```

---

### 3.2 Timer Integration Tests

**File**: `Tests/WeakupTests/Integration/TimerIntegrationTests.swift`

#### Test Cases

| ID | Test Name | Description | Priority |
|----|-----------|-------------|----------|
| TI-001 | `testTimer_accuracyOver1Minute` | Timer accurate within 1 second over 1 minute | P0 |
| TI-002 | `testTimer_stopsAtZero_releasesSleep` | Auto-stop releases sleep prevention | P0 |
| TI-003 | `testTimer_manualStop_cancelsTimer` | Manual stop cancels timer | P1 |
| TI-004 | `testTimer_backgroundAccuracy` | Timer accurate in background | P1 |
| TI-005 | `testTimer_menuOpenAccuracy` | Timer accurate with menu open | P1 |
| TI-006 | `testTimer_notification_onExpiry` | Notification sent on expiry | P1 |

---

### 3.3 Persistence Integration Tests

**File**: `Tests/WeakupTests/Integration/PersistenceIntegrationTests.swift`

#### Test Cases

| ID | Test Name | Description | Priority |
|----|-----------|-------------|----------|
| PI-001 | `testLanguagePreference_persistsAcrossLaunches` | Language survives restart | P1 |
| PI-002 | `testTimerDuration_persistsAcrossLaunches` | Duration survives restart | P1 |
| PI-003 | `testTimerMode_persistsAcrossLaunches` | Timer mode survives restart | P1 |
| PI-004 | `testSoundEnabled_persistsAcrossLaunches` | Sound setting survives restart | P1 |
| PI-005 | `testIconStyle_persistsAcrossLaunches` | Icon style survives restart | P1 |
| PI-006 | `testTheme_persistsAcrossLaunches` | Theme survives restart | P1 |
| PI-007 | `testHotkeyConfig_persistsAcrossLaunches` | Hotkey survives restart | P1 |
| PI-008 | `testActivityHistory_persistsAcrossLaunches` | History survives restart | P1 |

---

### 3.4 Localization Integration Tests

**File**: `Tests/WeakupTests/Integration/LocalizationIntegrationTests.swift`

#### Test Cases

| ID | Test Name | Description | Priority |
|----|-----------|-------------|----------|
| LI-001 | `testAllStrings_existInEnglish` | All keys have English values | P0 |
| LI-002 | `testAllStrings_existInChinese` | All keys have Chinese values | P0 |
| LI-003 | `testLanguageSwitch_updatesAllUI` | Switch updates all UI | P0 |
| LI-004 | `testLanguageSwitch_preservesState` | Switch preserves app state | P1 |
| LI-005 | `testFallback_worksCorrectly` | Missing keys fall back | P1 |

---

## 4. UI Test Specifications

### 4.1 Menu Bar UI Tests

**File**: `Tests/WeakupUITests/MenuBarUITests.swift`

#### Test Cases

| ID | Test Name | Description | Priority |
|----|-----------|-------------|----------|
| MB-001 | `testStatusIcon_showsInMenuBar` | Icon appears in menu bar | P0 |
| MB-002 | `testStatusIcon_changesOnToggle` | Icon changes on toggle | P0 |
| MB-003 | `testTooltip_updatesOnToggle` | Tooltip shows correct status | P1 |
| MB-004 | `testRightClickMenu_showsSettingsAndQuit` | Context menu works | P0 |
| MB-005 | `testLeftClick_togglesCaffeine` | Left click toggles | P0 |
| MB-006 | `testCountdown_showsInMenuBar` | Countdown displays | P1 |

---

### 4.2 Settings Popover UI Tests

**File**: `Tests/WeakupUITests/SettingsPopoverUITests.swift`

#### Test Cases

| ID | Test Name | Description | Priority |
|----|-----------|-------------|----------|
| SP-001 | `testSettingsPopover_opens` | Popover opens from menu | P0 |
| SP-002 | `testStatusIndicator_reflectsState` | Status indicator correct | P0 |
| SP-003 | `testToggleButton_changesState` | Toggle button works | P0 |
| SP-004 | `testTimerModeToggle_enablesDisables` | Timer mode toggle works | P0 |
| SP-005 | `testDurationPicker_appearsInTimerMode` | Duration picker shows | P0 |
| SP-006 | `testDurationPicker_selectsDuration` | Duration selection works | P1 |
| SP-007 | `testTimerDisplay_showsCountdown` | Countdown displays | P0 |
| SP-008 | `testLanguagePicker_switchesLanguage` | Language switch works | P1 |
| SP-009 | `testThemePicker_switchesTheme` | Theme switch works | P1 |
| SP-010 | `testIconPicker_switchesIcon` | Icon switch works | P1 |
| SP-011 | `testSoundToggle_togglesSound` | Sound toggle works | P1 |
| SP-012 | `testHotkeySection_displaysShortcut` | Hotkey displays | P1 |

---

### 4.3 Keyboard Shortcut UI Tests

**File**: `Tests/WeakupUITests/KeyboardShortcutUITests.swift`

#### Test Cases

| ID | Test Name | Description | Priority |
|----|-----------|-------------|----------|
| KS-001 | `testDefaultShortcut_togglesCaffeine` | Cmd+Ctrl+0 toggles | P0 |
| KS-002 | `testShortcut_worksWhenPopoverClosed` | Works without popover | P1 |
| KS-003 | `testCustomShortcut_canBeRecorded` | Custom shortcut recording | P1 |
| KS-004 | `testShortcut_resetToDefault` | Reset to default works | P1 |

---

## 5. Mock Strategies

### 5.1 MockUserDefaults

```swift
class MockUserDefaults: UserDefaults {
    private var storage: [String: Any] = [:]

    override func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }

    override func object(forKey defaultName: String) -> Any? {
        return storage[defaultName]
    }

    override func bool(forKey defaultName: String) -> Bool {
        return storage[defaultName] as? Bool ?? false
    }

    override func double(forKey defaultName: String) -> Double {
        return storage[defaultName] as? Double ?? 0
    }

    override func string(forKey defaultName: String) -> String? {
        return storage[defaultName] as? String
    }

    override func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }

    func reset() {
        storage.removeAll()
    }
}
```

### 5.2 MockNotificationCenter

```swift
class MockNotificationCenter {
    var pendingRequests: [UNNotificationRequest] = []
    var authorizationGranted = true
    var authorizationStatus: UNAuthorizationStatus = .authorized

    func add(_ request: UNNotificationRequest, completion: ((Error?) -> Void)?) {
        pendingRequests.append(request)
        completion?(nil)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        pendingRequests.removeAll { identifiers.contains($0.identifier) }
    }

    func requestAuthorization(options: UNAuthorizationOptions, completion: @escaping (Bool, Error?) -> Void) {
        completion(authorizationGranted, nil)
    }
}
```

### 5.3 IOPMAssertion Mock Strategy

Since IOPMAssertion is a system API, we use protocol-based abstraction:

```swift
protocol SleepPreventionService {
    func createAssertion() -> Bool
    func releaseAssertion()
    var isAssertionActive: Bool { get }
}

class MockSleepPreventionService: SleepPreventionService {
    private(set) var isAssertionActive = false
    var shouldSucceed = true
    var createCount = 0
    var releaseCount = 0

    func createAssertion() -> Bool {
        createCount += 1
        if shouldSucceed {
            isAssertionActive = true
            return true
        }
        return false
    }

    func releaseAssertion() {
        releaseCount += 1
        isAssertionActive = false
    }
}
```

---

## 6. Test Data Fixtures

### 6.1 Timer Duration Fixtures

```swift
enum TestTimerDurations {
    static let off: TimeInterval = 0
    static let fifteenMinutes: TimeInterval = 900
    static let thirtyMinutes: TimeInterval = 1800
    static let oneHour: TimeInterval = 3600
    static let twoHours: TimeInterval = 7200
    static let threeHours: TimeInterval = 10800
    static let custom: TimeInterval = 5400 // 1.5 hours

    static let all: [TimeInterval] = [
        off, fifteenMinutes, thirtyMinutes, oneHour, twoHours, threeHours
    ]
}
```

### 6.2 Localization Test Data

```swift
enum LocalizationTestData {
    static let allLanguages: [AppLanguage] = AppLanguage.allCases

    static let requiredKeys: [String] = [
        "app_name",
        "menu_settings",
        "menu_quit",
        "status_on",
        "status_off",
        "timer_mode",
        "turn_on",
        "turn_off",
        // ... all required keys
    ]
}
```

### 6.3 Activity Session Fixtures

```swift
enum ActivitySessionFixtures {
    static func activeSession() -> ActivitySession {
        ActivitySession(startTime: Date(), wasTimerMode: false)
    }

    static func completedSession(duration: TimeInterval = 3600) -> ActivitySession {
        var session = ActivitySession(startTime: Date().addingTimeInterval(-duration))
        session.end()
        return session
    }

    static func timerSession(duration: TimeInterval = 1800) -> ActivitySession {
        ActivitySession(startTime: Date(), wasTimerMode: true, timerDuration: duration)
    }
}
```

---

## 7. Test Coverage Measurement

### 7.1 Coverage Targets

| Module | Target | Measurement Method |
|--------|--------|-------------------|
| CaffeineViewModel | 90% | Line coverage |
| L10n | 85% | Line coverage |
| AppLanguage | 100% | Line coverage |
| ActivitySession | 95% | Line coverage |
| ActivityHistoryManager | 90% | Line coverage |
| IconManager | 85% | Line coverage |
| ThemeManager | 90% | Line coverage |
| HotkeyManager | 85% | Line coverage |
| NotificationManager | 80% | Line coverage |
| Version | 100% | Line coverage |

### 7.2 Coverage Commands

```bash
# Generate coverage report
swift test --enable-code-coverage

# View coverage in Xcode
xcodebuild test -scheme Weakup -enableCodeCoverage YES

# Generate HTML report (requires xcov or similar)
xcov --project Weakup.xcodeproj --scheme Weakup --output_directory coverage_report
```

### 7.3 Coverage Report Format

```
================================================================================
                           CODE COVERAGE REPORT
================================================================================

Module: WeakupCore
--------------------------------------------------------------------------------
File                              Lines    Covered    Coverage
--------------------------------------------------------------------------------
CaffeineViewModel.swift           231      208        90.0%
L10n.swift                        191      162        84.8%
ActivitySession.swift             59       56         94.9%
ActivityHistoryManager.swift      145      130        89.7%
IconManager.swift                 162      138        85.2%
ThemeManager.swift                124      112        90.3%
HotkeyManager.swift               176      150        85.2%
NotificationManager.swift         155      124        80.0%
Version.swift                     77       77         100.0%
--------------------------------------------------------------------------------
TOTAL                             1320     1157       87.7%
================================================================================
```

---

## 8. Bug Tracking Process

### 8.1 Bug Severity Definitions

| Severity | Definition | Example | Response Time |
|----------|------------|---------|---------------|
| S1 - Critical | App crash, data loss, security | Crash on toggle | Immediate |
| S2 - Major | Core feature broken | Sleep prevention fails | 24 hours |
| S3 - Minor | Feature issue with workaround | Timer off by 2 seconds | 1 week |
| S4 - Trivial | Cosmetic, typo | Alignment issue | Backlog |

### 8.2 Bug Report Template

```markdown
## Bug Report

**ID**: BUG-XXXX
**Title**: [Brief description]
**Severity**: S1/S2/S3/S4
**Priority**: P0/P1/P2
**Status**: Open/In Progress/Resolved/Closed

### Environment
- macOS Version:
- App Version:
- Hardware:

### Steps to Reproduce
1.
2.
3.

### Expected Result


### Actual Result


### Screenshots/Logs


### Test Case Reference
Related test case ID:

### Additional Context

```

### 8.3 Bug Lifecycle

```
New -> Triaged -> Assigned -> In Progress -> Fixed -> Verified -> Closed
                                    |
                                    v
                              Won't Fix / Duplicate
```

---

## 9. Test Execution Plan

### 9.1 Continuous Integration

| Trigger | Tests Run | Coverage Required |
|---------|-----------|-------------------|
| Every commit | Unit tests | 80% |
| PR merge | Unit + Integration | 85% |
| Nightly | All tests | 85% |
| Release | All tests + Manual | 90% |

### 9.2 Test Execution Order

1. **Unit Tests** (fastest, run first)
   - CaffeineViewModelTests
   - AppLanguageTests
   - ActivitySessionTests
   - VersionTests
   - All utility tests

2. **Integration Tests** (medium speed)
   - SleepPreventionIntegrationTests
   - TimerIntegrationTests
   - PersistenceIntegrationTests
   - LocalizationIntegrationTests

3. **UI Tests** (slowest, run last)
   - MenuBarUITests
   - SettingsPopoverUITests
   - KeyboardShortcutUITests

### 9.3 Test Commands

```bash
# Run all tests
swift test

# Run specific test file
swift test --filter CaffeineViewModelTests

# Run specific test
swift test --filter CaffeineViewModelTests.testToggle_startsWhenInactive

# Run with verbose output
swift test --verbose

# Run with coverage
swift test --enable-code-coverage

# Run UI tests (requires Xcode)
xcodebuild test -scheme WeakupUITests -destination 'platform=macOS'
```

---

## 10. Appendix

### A. Test Environment Setup

```bash
# Prerequisites
- macOS 13.0+
- Xcode 15.0+
- Swift 6.0

# Clone and build
git clone <repository>
cd Weakup
swift build

# Run tests
swift test
```

### B. Useful Debugging Commands

```bash
# Check sleep assertions
pmset -g assertions

# View app logs
log show --predicate 'subsystem == "com.weakup"' --last 1h

# Monitor memory
leaks --atExit -- ./.build/debug/weakup

# Profile CPU
instruments -t "Time Profiler" ./.build/debug/weakup
```

### C. Test Naming Conventions

```
test<MethodOrProperty>_<Scenario>_<ExpectedBehavior>

Examples:
- testToggle_whenInactive_startsPreventingSleep
- testSetTimerDuration_withNegativeValue_clampsToZero
- testLanguageSwitch_toChineseSimplified_updatesAllStrings
```

---

*Document Version: 1.0*
*Last Updated: 2026-02-22*
*Author: QA Lead*
