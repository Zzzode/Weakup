# Weakup v1.1.0 Release Notes

**Release Date:** February 22, 2026

We're excited to announce Weakup v1.1.0! This release focuses on quality, testing, and new features to make Weakup even more reliable and useful.

## What's New

### Keyboard Shortcut Conflict Detection
Weakup now warns you when your chosen keyboard shortcut conflicts with system shortcuts (like Cmd+C) or common app shortcuts. Conflicts are categorized by severity with helpful suggestions for alternatives.

### Launch at Login
Start Weakup automatically when you log in to your Mac. Enable this in Settings to ensure sleep prevention is always just a click away.

### Activity History Export & Import
- **Export** your session history to CSV or JSON format for backup or analysis
- **Import** previously exported data to restore your history on a new machine

### Enhanced History View
- **Filter** sessions by: Today, This Week, This Month, Timer Only, Manual Only
- **Sort** by date or duration (ascending/descending)
- **Search** through your session history
- **Daily Chart** showing your activity over the past 7 days

## Quality Improvements

### Comprehensive Test Suite
- **462 tests** covering all components - **100% pass rate**
- **90% coverage** on core business logic
- **Integration tests** for end-to-end flows
- **Automated CI/CD** with coverage reports

### Code Quality
- Centralized constants and configuration
- Improved logging and error handling
- Cleaner architecture with better separation of concerns
- Comprehensive API documentation

## Bug Fixes
- Improved timer accuracy under system load
- More reliable hotkey registration
- Fixed memory leaks in timer callbacks

## Installation

### Homebrew
```bash
brew upgrade weakup
```

### Direct Download
Download `Weakup-1.1.0.dmg` from the assets below.

### From Source
```bash
git clone https://github.com/Zzzode/weakup.git
cd weakup && ./build.sh
```

## Requirements
- macOS 13.0 or later

## Full Changelog
See [CHANGELOG.md](https://github.com/Zzzode/weakup/blob/main/CHANGELOG.md) for complete details.

---

**Thank you** to everyone who contributed to this release!
