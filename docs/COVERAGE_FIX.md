# Coverage Reporting Fix

## Problem

Codecov was showing **47% coverage** instead of the actual **~88% coverage** for the WeakupCore business logic.

## Root Cause

The test target in `Package.swift` only includes `WeakupCore` as a dependency:

```swift
.testTarget(
    name: "WeakupTests",
    dependencies: ["WeakupCore"],  // ⚠️ UI code not included
    path: "Tests/WeakupTests"
)
```

This means:
- ✅ **WeakupCore** (13 files) - Compiled into test binary, has coverage data
- ❌ **Weakup UI** (5 files) - NOT compiled into test binary, no coverage data

Codecov was calculating: `(WeakupCore covered lines) / (WeakupCore + Weakup UI total lines) = 47%`

## Solution

### 1. Updated `codecov.yml`

Added UI code to ignore list:

```yaml
ignore:
  - "Tests/**"
  - ".build/**"
  - "**/*.generated.swift"
  - "Sources/Weakup/**"  # ⭐ NEW: Exclude UI code
```

### 2. Updated CI Workflow (`.github/workflows/ci.yml`)

Added filter to exclude UI code from coverage export:

```yaml
xcrun llvm-cov export \
  -format=lcov \
  -ignore-filename-regex='\.build/|Tests/|Sources/Weakup/' \  # ⭐ NEW: Filter UI
  > coverage.lcov
```

### 3. Created Coverage Generation Script

Added `scripts/generate_coverage.sh` for local coverage generation:

```bash
./scripts/generate_coverage.sh          # Generate report
./scripts/generate_coverage.sh --html   # Generate + open HTML report
```

### 4. Updated Documentation

- **README.md**: Added note explaining coverage scope
- **README.zh.md**: Added Chinese version of note
- **docs/TESTING.md**: Added comprehensive coverage reporting section
- **CHANGELOG.md**: Documented the fix

## Verification

Run the coverage script to verify:

```bash
./scripts/generate_coverage.sh
```

Expected output:
```
=== Summary ===
WeakupCore Coverage: 87.73%
Files in LCOV report:
  - Total: 13
  - WeakupCore: 13
  - Weakup UI: 0
```

## Coverage Breakdown

| Component | Files | Line Coverage | Function Coverage |
|-----------|-------|---------------|-------------------|
| **WeakupCore** | 13 | **87.73%** | 90.40% |
| ActivitySession | 1 | 100% | 100% |
| TimeFormatter | 1 | 100% | 100% |
| Logger | 1 | 98.89% | 96.88% |
| IconManager | 1 | 97.87% | 100% |
| ThemeManager | 1 | 97.37% | 100% |
| L10n | 1 | 94.83% | 97.48% |
| ActivityHistoryManager | 1 | 94.22% | 92.54% |
| HotkeyManager | 1 | 93.96% | 83.87% |
| Version | 1 | 92.00% | 100% |
| LaunchAtLoginManager | 1 | 90.18% | 83.33% |
| CaffeineViewModel | 1 | 89.37% | 85.29% |
| UserDefaultsKeys | 1 | 76.92% | 66.67% |
| NotificationManager | 1 | **20.11%** ⚠️ | 42.11% |

**Note**: NotificationManager has low coverage due to test environment detection guards. This is a known issue and will be addressed in a future refactoring (see issue tracker).

## Architecture Rationale

### Why UI Code is Excluded

1. **Architectural Design**: UI code is in a separate executable target that cannot be imported into test targets
2. **Testing Framework**: UI code requires XCUITest (not Swift Testing) which:
   - Cannot run via Swift Package Manager
   - Requires Xcode project configuration
   - Needs accessibility permissions
   - Has different coverage collection mechanism
3. **Separation of Concerns**: Business logic (WeakupCore) is unit-testable; UI is tested via end-to-end UI tests

### Coverage Scope

| Layer | Testing Method | Coverage Tool | Included in Codecov |
|-------|----------------|---------------|---------------------|
| **Business Logic** (WeakupCore) | Swift Testing (unit + integration) | llvm-cov | ✅ Yes (87.73%) |
| **UI Layer** (Weakup) | XCUITest (end-to-end) | Xcode UI Test Coverage | ❌ No (separate) |

## Impact

### Before Fix
- Codecov: **47%** ❌ (misleading)
- Actual WeakupCore: **87.73%** (hidden)

### After Fix
- Codecov: **87.73%** ✅ (accurate)
- Clear documentation about UI testing

## Files Modified

1. `codecov.yml` - Added UI code to ignore list
2. `.github/workflows/ci.yml` - Added coverage filters
3. `scripts/generate_coverage.sh` - New coverage generation script
4. `README.md` - Added coverage note
5. `README.zh.md` - Added Chinese coverage note
6. `docs/TESTING.md` - Added coverage reporting section
7. `CHANGELOG.md` - Documented the fix

## Next Steps

1. **Merge this fix** - Get accurate coverage reporting on Codecov
2. **Monitor coverage** - Ensure it stays above 80% threshold
3. **Improve NotificationManager** - Refactor to enable better testing (target: 80%+)
4. **Consider UI coverage** - Evaluate adding XCUITest coverage reporting separately

## References

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [llvm-cov Documentation](https://llvm.org/docs/CommandGuide/llvm-cov.html)
- [Codecov Configuration](https://docs.codecov.com/docs/codecov-yaml)
