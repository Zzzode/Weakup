# Changelog

All notable changes to Weakup are documented here. The project follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Versioned source archive attached to each GitHub Release with its SHA-256 checksum

### Fixed
- **Coverage Reporting** - Fixed Codecov showing incorrect 47% coverage by excluding UI code from Swift Package coverage statistics
  - Updated `codecov.yml` to ignore `Sources/Weakup/**` because the UI target is not exercised by the current SPM test job
  - Updated CI workflow to filter coverage reports to WeakupCore only
  - Added coverage generation script (`scripts/generate_coverage.sh`)
  - Updated documentation to explain coverage scope (`WeakupCore`: ~88%; UI test sources are not part of SPM coverage)
  - Actual business logic coverage is 87.73%, not 47%

## [1.0.2] - 2026-02-23

### Added
- Display-sleep prevention alongside idle-system-sleep prevention
- Swift 6.2.3 toolchain pinning for reproducible builds

### Changed
- Migrated unit and integration tests from XCTest to Swift Testing
- Improved preference isolation and test infrastructure
- Updated architecture, development, and testing documentation

## [1.0.1] - 2026-02-23

Maintenance release with versioning and release-workflow corrections.

## [1.0.0] - 2026-02-21

### Added

#### Core Features
- One-click sleep prevention toggle
- Menu bar app with no dock clutter (accessory app)
- Timer mode with preset durations:
  - 15 minutes
  - 30 minutes
  - 1 hour
  - 2 hours
  - 3 hours
- Custom timer duration (up to 24 hours)
- Visual status indicator (filled/empty icon)

#### User Interface
- Multiple icon styles:
  - Power (default)
  - Bolt
  - Coffee cup
  - Moon
  - Eye
- Dark/Light/System theme support
- Settings window with organized sections
- Display countdown timer in menu bar (optional)

#### Keyboard Shortcuts
- Global keyboard shortcut: Cmd + Ctrl + 0
- Customizable hotkey with recording interface
- Hotkey conflict detection

#### Localization
- Multi-language support (8 languages):
  - English
  - Chinese (Simplified)
  - Chinese (Traditional)
  - Japanese
  - Korean
  - French
  - German
  - Spanish
- In-app language switcher
- Real-time language switching without restart
- System language auto-detection on first launch

#### Notifications
- macOS notification when timer expires
- Notification actions: Restart timer, Dismiss
- Configurable notification preferences

#### Activity Tracking
- Session history with start/end times
- Statistics: today, this week, total, average
- Timer mode tracking per session

#### Preferences
- Sound feedback option (on/off)
- Launch at Login support
- All preferences persisted to UserDefaults

### Technical

#### Architecture
- Modular design with two targets:
  - WeakupCore (library): Business logic, view models, utilities
  - Weakup (executable): UI views, app lifecycle
- MVVM architecture pattern
- Singleton managers for global state

#### Frameworks
- SwiftUI for settings UI
- AppKit for menu bar and system integration
- IOKit for power management (IOPMAssertion)
- Carbon for keyboard event handling
- UserNotifications for system notifications
- ServiceManagement for login items

#### Build System
- Swift Package Manager
- Build script for app bundle creation
- CI/CD with GitHub Actions
- SwiftLint and SwiftFormat integration

#### Performance
- Memory: ~15-20 MB typical usage
- CPU: Negligible (event-driven)
- Battery: Minimal impact (native APIs)

### Security
- No network access required
- Minimal permissions (power management only)
- Local storage only (UserDefaults)
- No sensitive data collection

---

## Version History Summary

| Version | Date | Highlights |
|---------|------|------------|
| 1.0.2 | 2026-02-23 | Display sleep prevention and Swift Testing migration |
| 1.0.1 | 2026-02-23 | Release metadata maintenance |
| 1.0.0 | 2026-02-21 | Initial release with full feature set |

## Upgrade Notes

### From Pre-release to 1.0.0
- First stable release, no migration needed
- All preferences are stored fresh on first launch

## Known Issues

### v1.0.0
- Timer accuracy may drift slightly when system is under heavy load
- Some keyboard shortcuts may conflict with third-party apps

## Deprecation Notices

None at this time.

---

## Links

- [GitHub Repository](https://github.com/Zzzode/Weakup)
- [Issue Tracker](https://github.com/Zzzode/Weakup/issues)
- [Documentation](./docs/)
