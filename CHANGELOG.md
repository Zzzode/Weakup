# Changelog

All notable changes to Weakup will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

No unreleased changes.

---

## [1.1.0] - 2026-02-22

### Added

#### New Features
- **Keyboard Shortcut Conflict Detection** - Warns when shortcuts conflict with system or app shortcuts, with severity levels (high/medium/low) and suggestions
- **Launch at Login** - Option to automatically start Weakup when you log in to your Mac
- **Activity History Export** - Export your session history to CSV or JSON format
- **Activity History Import** - Import previously exported history data
- **Enhanced History View** - Filter sessions by date range, timer mode, and search; sort by date or duration
- **Daily Statistics Chart** - Visual chart showing activity over the past 7 days
- **Onboarding Flow** - Welcome screen for new users

#### Testing and Quality
- **462 Unit Tests** - Comprehensive test coverage across all components, **100% pass rate**
- **90% Coverage** on CaffeineViewModel (core business logic)
- **85% Coverage** on L10n (localization system)
- **Integration Tests** - End-to-end tests for sleep prevention and timer flows
- **CI/CD Improvements** - Automated testing and coverage reports on every PR

### Changed

#### Code Improvements
- **Centralized Constants** - All UserDefaults keys, app constants, and identifiers in dedicated files
- **Logger Utility** - Consistent logging across the application
- **TimeFormatter** - Shared time formatting utilities
- **Refactored Managers** - Cleaner dependency injection for NotificationManager

#### Documentation
- **Architecture Diagrams** - Component, sequence, and data flow diagrams
- **API Documentation** - Comprehensive doc comments on all public interfaces
- **Testing Guide** - Updated with examples and best practices
- **CLAUDE.md** - AI development guide updated for current architecture

### Fixed
- Timer accuracy improvements when system is under load
- Hotkey registration reliability improvements
- Memory leak fixes in timer callbacks

### Technical

#### New Utilities
- `UserDefaultsKeys` - Centralized preference keys
- `AppConstants` - Application-wide constants
- `Logger` - Structured logging
- `TimeFormatter` - Duration formatting

#### Test Infrastructure
- `MockUserDefaults` - For isolated preference testing
- `MockSleepPreventionService` - For testing without system calls
- `TestFixtures` - Shared test data

---

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
| 1.1.0 | 2026-02-22 | Testing suite, history export, shortcut conflict detection |
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

- [GitHub Repository](https://github.com/user/weakup)
- [Issue Tracker](https://github.com/user/weakup/issues)
- [Documentation](./docs/)
