# Weakup

<div align="center">

<img src="Assets/AppIcon.png" width="128" alt="Weakup app icon">

[![CI](https://github.com/Zzzode/weakup/actions/workflows/ci.yml/badge.svg)](https://github.com/Zzzode/weakup/actions/workflows/ci.yml)
[![Release](https://github.com/Zzzode/weakup/actions/workflows/release.yml/badge.svg)](https://github.com/Zzzode/weakup/actions/workflows/release.yml)
[![codecov](https://codecov.io/gh/Zzzode/weakup/branch/main/graph/badge.svg)](https://codecov.io/gh/Zzzode/weakup)
![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![License](https://img.shields.io/badge/license-Apache%202.0-blue)
![Swift](https://img.shields.io/badge/Swift-6.2.3-orange)

> **Testing scope:** The coverage badge reflects `WeakupCore` unit and integration tests. XCUITest source files are present, but UI tests are not currently executed by the Swift Package Manager CI workflow.

A high-performance, lightweight macOS utility to prevent your Mac from sleeping.

</div>

## Features

- **One-Toggle Control** - Enable/disable sleep prevention with a single click
- **Menu Bar App** - Lives in menu bar, no dock clutter
- **Timer Mode** - Set auto-shutdown timer (15min, 30min, 1hr, 2hrs, 3hrs, or custom duration up to 24 hours)
- **Countdown in Menu Bar** - Optional timer countdown next to the status icon
- **Visual Status** - Clear filled/empty icon indicator with multiple icon styles
- **Keyboard Shortcut** - `Cmd + Ctrl + 0` to toggle anywhere
- **Hotkey Conflict Detection** - Warns about common shortcut conflicts and suggests alternatives
- **Native Integration** - Uses macOS IOPMAssertion APIs to prevent idle and display sleep
- **Dark/Light Theme** - Supports system theme, light mode, and dark mode
- **Sound Feedback** - Optional audio feedback when toggling
- **Icon Customization** - Choose from Power, Bolt, Coffee, Moon, or Eye icons
- **Multi-Language Support** - 8 languages with real-time switching
- **Launch at Login** - Optional startup at login with error handling
- **Timer Expiry Notifications** - Optional notification when the timer ends
- **Onboarding** - First-launch walkthrough
- **SwiftUI + AppKit** - Modern, clean codebase

## Supported Languages

| Language | Display Name |
|----------|--------------|
| English | English |
| Chinese (Simplified) | 简体中文 |
| Chinese (Traditional) | 繁體中文 |
| Japanese | 日本語 |
| Korean | 한국어 |
| French | Français |
| German | Deutsch |
| Spanish | Español |

## Installation

### Build from Source

Building locally is currently the **only supported installation method**. To build the latest stable version:

```bash
# Clone the current stable tag
git clone --branch v1.0.2 --depth 1 https://github.com/Zzzode/weakup.git
cd weakup

# Build the app
./build.sh

# Run
open Weakup.app
```

Starting with the next release, GitHub Releases will also include a versioned `Weakup-x.y.z-source.tar.gz` archive built from the exact release commit.

### Prebuilt and Homebrew Status

The DMG and ZIP attached to v1.0.2 are legacy unsigned artifacts and are **not supported for installation**. Weakup has no Developer ID signature or Apple notarization, so those downloads may fail Gatekeeper and signature validation. Weakup is also not available from the official Homebrew Cask repository.

### Requirements

- macOS 13 or later
- Xcode toolchain and Swift 6.2.3 as pinned in `.swift-version`

## Usage

1. Click the menu bar icon to toggle sleep prevention
2. Right-click or select "Settings" to access options
3. Use `Cmd + Ctrl + 0` keyboard shortcut to toggle from anywhere
4. Switch language instantly in the settings panel

### Settings Options

- **Timer Mode** - Enable automatic shutdown after a set duration
- **Duration** - Choose from preset times or set a custom duration (up to 24 hours)
- **Theme** - System, Light, or Dark
- **Sound Feedback** - Toggle audio feedback on/off
- **Notifications** - Toggle timer expiry notifications
- **Menu Bar Countdown** - Show remaining timer next to the icon
- **Icon Style** - Choose your preferred menu bar icon
- **Language** - Switch between 8 supported languages
- **Launch at Login** - Start Weakup when you sign in
- **Hotkey** - Customize shortcut and resolve conflicts

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd + Ctrl + 0` | Toggle sleep prevention |

## Roadmap

### Planned

- [ ] Schedule-based activation (time-of-day rules)
- [ ] Menu bar widget for quick stats
- [ ] Shortcuts app integration

The current stable release is **v1.0.2**. See [CHANGELOG.md](CHANGELOG.md) for shipped changes.

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - System architecture overview
- [Development](docs/DEVELOPMENT.md) - Setup and development workflow
- [Testing](docs/TESTING.md) - Testing guidelines
- [Translations](docs/TRANSLATIONS.md) - Guide for adding new languages
- [Code Signing](docs/CODE_SIGNING.md) - Code signing and notarization guide
- [Homebrew](docs/HOMEBREW.md) - Homebrew installation guide
- [Privacy](docs/PRIVACY.md) - Privacy policy

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

[English](CONTRIBUTING.md) | [中文](CONTRIBUTING.zh.md)

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Swift](https://swift.org)
- UI framework: [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Sleep prevention: [IOPMAssertion](https://developer.apple.com/documentation/iokit/iopmassertion)
