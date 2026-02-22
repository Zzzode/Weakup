# CLAUDE.md - AI Development Guide

This file provides context for AI assistants working on the Weakup codebase.

## Project Overview

**Weakup** is a macOS menu bar application that prevents system sleep. It's a lightweight utility similar to Amphetamine or Caffeine, built with Swift 6.0 using SwiftUI and AppKit.

### Key Features
- One-click sleep prevention toggle
- Timer mode with preset and custom durations
- Global keyboard shortcut (customizable, default: Cmd+Ctrl+0)
- Multi-language support (8 languages) with real-time switching
- Multiple icon styles (Power, Bolt, Coffee, Moon, Eye)
- Dark/Light/System theme support
- Activity history tracking with export
- Timer expiry notifications
- Launch at login support
- Menu bar only (no dock icon)

## Architecture

### Modular Design

The project is split into two targets:
1. **WeakupCore**: Library containing business logic, view models, and utilities
2. **Weakup**: Main executable containing UI views and app lifecycle management

### Component Overview

| Component | Location | Purpose |
|-----------|----------|---------|
| `WeakupApp` | `Sources/Weakup/main.swift` | Entry point |
| `AppDelegate` | `Sources/Weakup/App/AppDelegate.swift` | Menu bar, system integration |
| `SettingsView` | `Sources/Weakup/Views/SettingsView.swift` | Settings UI |
| `HistoryView` | `Sources/Weakup/Views/HistoryView.swift` | Activity history UI |
| `CaffeineViewModel` | `Sources/WeakupCore/ViewModels/CaffeineViewModel.swift` | Sleep prevention logic |
| `L10n` | `Sources/WeakupCore/Utilities/L10n.swift` | Localization system |
| `HotkeyManager` | `Sources/WeakupCore/Utilities/HotkeyManager.swift` | Keyboard shortcuts |
| `IconManager` | `Sources/WeakupCore/Utilities/IconManager.swift` | Menu bar icons |
| `ThemeManager` | `Sources/WeakupCore/Utilities/ThemeManager.swift` | App theme |
| `NotificationManager` | `Sources/WeakupCore/Utilities/NotificationManager.swift` | System notifications |
| `ActivityHistoryManager` | `Sources/WeakupCore/Utilities/ActivityHistoryManager.swift` | Session tracking |
| `LaunchAtLoginManager` | `Sources/WeakupCore/Utilities/LaunchAtLoginManager.swift` | Login item |
| `ActivitySession` | `Sources/WeakupCore/Models/ActivitySession.swift` | Session data model |

### Manager Singletons

All managers use the singleton pattern with `.shared` access:

```swift
L10n.shared.currentLanguage
IconManager.shared.currentStyle
ThemeManager.shared.currentTheme
HotkeyManager.shared.currentConfig
NotificationManager.shared.notificationsEnabled
ActivityHistoryManager.shared.sessions
LaunchAtLoginManager.shared.isEnabled
```

### Localization

`Sources/WeakupCore/Utilities/L10n.swift` handles internationalization:
- `AppLanguage` enum defines supported languages (en, zh-Hans, zh-Hant, ja, ko, fr, de, es)
- `L10n` singleton manages current language
- Strings stored in `.lproj/Localizable.strings` files in `Sources/Weakup/`
- Fallback to English if translation missing

## Key Technical Decisions

### 1. IOPMAssertion API

Sleep prevention uses Apple's native IOPMAssertion:
```swift
IOPMAssertionCreateWithName(
    kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
    IOPMAssertionLevel(kIOPMAssertionLevelOn),
    "Weakup preventing sleep" as CFString,
    &id
)
```
This is preferred over spawning `caffeinate` for lower overhead.

### 2. Accessory App

The app uses `.accessory` activation policy to avoid dock clutter:
```swift
app.setActivationPolicy(.accessory)
```

### 3. Real-Time Localization

Language switching happens without restart by using `@Published` properties and SwiftUI's reactive updates.

### 4. Swift Package Manager

Built with SPM instead of Xcode project for simplicity. The `build.sh` script creates the `.app` bundle.

### 5. MainActor Isolation

All UI-related code and managers use `@MainActor` for thread safety:
```swift
@MainActor
public final class CaffeineViewModel: ObservableObject { ... }
```

## Important File Locations

```
Sources/
├── Weakup/                 # App UI and Executable
│   ├── App/
│   │   └── AppDelegate.swift
│   ├── Views/
│   │   ├── SettingsView.swift
│   │   └── HistoryView.swift
│   ├── main.swift          # Entry point
│   └── *.lproj/            # Localization strings (8 languages)
└── WeakupCore/             # Business Logic Library
    ├── Models/
    │   └── ActivitySession.swift
    ├── Utilities/
    │   ├── L10n.swift
    │   ├── HotkeyManager.swift
    │   ├── IconManager.swift
    │   ├── ThemeManager.swift
    │   ├── NotificationManager.swift
    │   ├── ActivityHistoryManager.swift
    │   ├── LaunchAtLoginManager.swift
    │   └── Version.swift
    └── ViewModels/
        └── CaffeineViewModel.swift

Tests/WeakupTests/          # Unit and integration tests
docs/                       # Documentation
    ├── ARCHITECTURE.md     # Architecture diagrams
    └── TESTING.md          # Testing guide
build.sh                    # Build script
Package.swift               # SPM configuration
```

## Development Workflow

### Building

```bash
# Full build with app bundle
./build.sh

# Quick build (binary only)
swift build -c release
```

### Running

```bash
open Weakup.app
# or
.build/release/weakup
```

### Testing

```bash
# Run all tests (Swift Testing + XCTest)
swift test

# Run specific test suite
swift test --filter CaffeineViewModelTests

# Run with verbose output
swift test --verbose

# Run tests with coverage
swift test --enable-code-coverage

# If sandbox errors occur
swift test --disable-sandbox
```

**Testing Frameworks:**
- **Swift Testing** - Used for unit and integration tests (modern `@Test` syntax)
- **XCTest** - Used only for UI tests (XCUITest framework requirement)

### Testing Power Assertions

```bash
pmset -g assertions
# Shows active power assertions
```

## Common Tasks

### Adding a New Setting

1. Add `@Published` property to `CaffeineViewModel` (or appropriate manager)
2. Add UI control in `SettingsView`
3. Add localized string keys to all `.strings` files (8 languages)
4. Add string accessor to `L10n` extension
5. Add persistence to UserDefaults if needed

### Adding a New Language

1. Create `Sources/Weakup/XX.lproj/Localizable.strings`
2. Add case to `AppLanguage` enum in `L10n.swift`
3. Update `build.sh` to copy new `.lproj` folder
4. Add to `CFBundleLocalizations` in Info.plist (in build.sh)

### Adding a New Icon Style

1. Add case to `IconStyle` enum in `IconManager.swift`
2. Define `inactiveSymbol` and `activeSymbol` SF Symbol names
3. Add localization key for the style name

### Adding a New Manager

1. Create file in `Sources/WeakupCore/Utilities/`
2. Use `@MainActor` and singleton pattern
3. Add `@Published` properties for observable state
4. Persist settings to UserDefaults
5. Add tests in `Tests/WeakupTests/`

## Code Patterns

### MainActor Usage

All UI-related code uses `@MainActor`:
```swift
@MainActor
public final class CaffeineViewModel: ObservableObject { ... }
```

### Timer Pattern

Timer callbacks dispatch to MainActor:
```swift
timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
    Task { @MainActor [weak self] in
        self?.updateTimeRemaining()
    }
}
```

### Localization Pattern

```swift
// In L10n.swift extension
var menuSettings: String { string(forKey: "menu_settings") }

// Usage
Text(L10n.shared.menuSettings)
```

### UserDefaults Pattern

```swift
@Published public var setting: Bool {
    didSet {
        UserDefaults.standard.set(setting, forKey: "KeyName")
    }
}
```

## Testing Guidelines

### Testing Frameworks

The project uses a **mixed testing approach**:
- **Swift Testing** - For unit and integration tests (modern, cleaner syntax)
- **XCTest** - For UI tests only (XCUITest framework requirement)

### Swift Testing Syntax

```swift
import Testing
@testable import WeakupCore

@Suite("Example Tests")
@MainActor
struct ExampleTests {
    @Test("Description of what this tests")
    func exampleTest() {
        let result = someFunction()
        #expect(result == expectedValue)
    }

    @Test("Parameterized test", arguments: [1, 2, 3])
    func parameterizedTest(value: Int) {
        #expect(value > 0)
    }
}
```

### Unit Tests
- Test all public methods of managers
- Test state transitions in CaffeineViewModel
- Test localization key coverage
- Use `UserDefaultsStore` for test isolation
- Use `@Suite` to group related tests

### Integration Tests
- Test full sleep prevention cycle
- Test timer expiry flow
- Test notification delivery

### UI Tests (XCTest Only)
- UI tests remain on XCTest (Swift Testing limitation)
- Located in `Tests/WeakupUITests/`
- Require Xcode project and accessibility permissions

### Manual Tests
- Toggle sleep prevention on/off
- Verify with `pmset -g assertions`
- Test timer countdown
- Test keyboard shortcut
- Test language switching
- Test app quit (assertion should release)

### Edge Cases
- Rapid toggling
- Timer while already active
- Quit while active
- System sleep attempt while active
- Memory pressure scenarios

## Deployment

### Building for Distribution

```bash
./build.sh
# Creates Weakup.app in project root
```

### Code Signing (if needed)

```bash
codesign --force --deep --sign "Developer ID Application: Name" Weakup.app
```

## Gotchas

1. **Bundle Path Resolution**: When running binary directly (not .app), localization may not work because bundle paths differ.

2. **Status Item Retention**: The `statusItem` must be retained as a property or it will be deallocated.

3. **Timer Memory**: Timer callbacks use `[weak self]` to avoid retain cycles.

4. **Assertion Cleanup**: Always release IOPMAssertion on app termination.

5. **Hotkey Conflicts**: Some shortcuts conflict with system or common app shortcuts. HotkeyManager detects these.

6. **Notification Authorization**: Must request permission before scheduling notifications.

7. **Login Item**: Uses SMAppService which requires proper app bundle structure.

## API Documentation

All public interfaces have documentation comments. Key classes:

- `CaffeineViewModel`: Core sleep prevention logic with timer support
- `L10n`: Localization manager with fallback behavior
- `HotkeyManager`: Keyboard shortcut management with conflict detection
- `ActivityHistoryManager`: Session tracking with export/import
- `NotificationManager`: System notification handling

See source files for detailed API documentation.

## Resources

- [IOPMAssertion Documentation](https://developer.apple.com/documentation/iokit/iopmassertion)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [ServiceManagement Framework](https://developer.apple.com/documentation/servicemanagement)

## Documentation Structure

The project follows a clear documentation structure to keep files organized and maintainable.

### Root Level Documentation

**User-Facing Documents** (kept in root for visibility):
- `README.md` - Project overview, features, installation (English)
- `README.zh.md` - Chinese version of README
- `CHANGELOG.md` - Version history and release notes
- `CONTRIBUTING.md` - Contribution guidelines (English)
- `CONTRIBUTING.zh.md` - Chinese version of contribution guidelines
- `CLAUDE.md` - AI assistant development guide (this file)

### `/docs` - Technical Documentation

**Core Technical Docs** (main docs directory):
- `ARCHITECTURE.md` - System architecture, design patterns, component diagrams
- `TESTING.md` - Testing strategy, test pyramid, coverage targets
- `TEST_SPECIFICATIONS.md` - Detailed test cases (150+ specifications)
- `DEVELOPMENT.md` - Development setup, build process, debugging
- `TRANSLATIONS.md` - Localization guide, adding new languages
- `PRIVACY.md` - Privacy policy and data handling
- `CODE_SIGNING.md` - Code signing and notarization guide
- `HOMEBREW.md` - Homebrew formula maintenance

### `/docs/development` - Development Process

**Sprint and Planning Documents**:
- `SPRINT_PLAN.md` - Sprint planning, task breakdown, timeline
- `RISK_ASSESSMENT.md` - Risk analysis and mitigation strategies
- `TEST_EXECUTION_PLAN.md` - QA test execution procedures
- `QA_PLAN.md` - Quality assurance strategy

These documents are used during active development and kept for reference.

### `/docs/releases` - Release Documentation

**Version-Specific Release Docs**:
- `RELEASE_NOTES_v1.1.0.md` - User-facing release notes for v1.1.0
- `RELEASE_READINESS_REPORT.md` - Internal release approval report
- `TEST_REPORT.md` - Final QA test results

Each major release should have its own release notes file following the pattern `RELEASE_NOTES_vX.Y.Z.md`.

### `/docs/archive` - Archived Documents

**Historical/Superseded Documents**:
- `ARCHITECTURE_DIAGRAMS.md` - Old architecture diagrams (superseded by ARCHITECTURE.md)
- `ARCHITECTURE_SUMMARY.md` - Old architecture summary
- `REFACTORING_PLAN.md` - Completed refactoring plans
- `TEST_INFRASTRUCTURE.md` - Old test infrastructure docs (now in TESTING.md)

Documents are moved here when they become outdated or are superseded by newer versions.

### `/screenshots` - Visual Assets

**Application Screenshots**:
- `README.md` - Screenshot index and descriptions
- Various `.png` files - App screenshots for documentation

### Documentation Guidelines

**When Creating New Documentation**:

1. **Choose the Right Location**:
   - User-facing or frequently accessed → Root level
   - Technical/architectural → `/docs`
   - Process/planning → `/docs/development`
   - Release-specific → `/docs/releases`
   - Outdated → `/docs/archive`

2. **Naming Conventions**:
   - Use UPPERCASE for major docs (e.g., `ARCHITECTURE.md`)
   - Use descriptive names (e.g., `RELEASE_NOTES_v1.1.0.md`)
   - Include version numbers for release docs
   - Use `.zh.md` suffix for Chinese versions

3. **Content Standards**:
   - Start with a clear title and purpose
   - Include table of contents for docs > 200 lines
   - Use Markdown formatting consistently
   - Add code examples where helpful
   - Keep language clear and concise
   - Update related docs when making changes

4. **Maintenance**:
   - Review docs quarterly for accuracy
   - Archive superseded documents
   - Update cross-references when moving files
   - Keep CHANGELOG.md current with each release

**Cross-Referencing**:
- Use relative paths: `[ARCHITECTURE](docs/ARCHITECTURE.md)`
- Check links after moving files
- Update CLAUDE.md when structure changes

### Quick Reference

**For Users**:
- Installation → `README.md`
- What's new → `CHANGELOG.md`
- Contributing → `CONTRIBUTING.md`

**For Developers**:
- Getting started → `docs/DEVELOPMENT.md`
- Architecture → `docs/ARCHITECTURE.md`
- Testing → `docs/TESTING.md`
- Localization → `docs/TRANSLATIONS.md`
- AI context → `CLAUDE.md`

**For Release Managers**:
- Release process → `docs/CODE_SIGNING.md`, `docs/HOMEBREW.md`
- Release notes → `docs/releases/RELEASE_NOTES_vX.Y.Z.md`
- Test results → `docs/releases/TEST_REPORT.md`
