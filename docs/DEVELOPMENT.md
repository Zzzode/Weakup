# Development Guide

This guide covers setting up and developing Weakup.

## Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode Command Line Tools
- Swift 6.0+

### Installing Prerequisites

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify Swift version
swift --version
# Should show Swift 6.0 or later
```

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/Zzzode/weakup.git
cd weakup
```

### Build the App

```bash
# Build and create app bundle
./build.sh

# The script will:
# 1. Build the Swift package in release mode
# 2. Create the Weakup.app bundle
# 3. Copy localization files
# 4. Generate app icons
# 5. Create Info.plist
```

### Run the App

```bash
# Run the built app
open Weakup.app

# Or run directly from build directory (for debugging)
.build/release/weakup
```

## Project Structure

```
Weakup/
├── Package.swift              # Swift Package Manager configuration
├── build.sh                   # Build script for creating .app bundle
├── Sources/
│   ├── Weakup/                # App target (UI + lifecycle)
│   │   ├── main.swift         # Application entry point
│   │   ├── App/
│   │   │   └── AppDelegate.swift
│   │   ├── Views/
│   │   │   ├── SettingsView.swift
│   │   │   ├── OnboardingView.swift
│   │   │   └── HistoryView.swift
│   │   ├── en.lproj/          # English localization
│   │   │   └── Localizable.strings
│   │   ├── zh-Hans.lproj/     # Chinese localization
│   │   │   └── Localizable.strings
│   │   └── ... other .lproj folders
│   └── WeakupCore/            # Core target (logic + managers)
│       ├── ViewModels/
│       │   └── CaffeineViewModel.swift
│       ├── Utilities/
│       │   ├── L10n.swift
│       │   ├── HotkeyManager.swift
│       │   ├── IconManager.swift
│       │   ├── ThemeManager.swift
│       │   ├── NotificationManager.swift
│       │   ├── ActivityHistoryManager.swift
│       │   ├── LaunchAtLoginManager.swift
│       │   ├── Logger.swift
│       │   ├── UserDefaultsKeys.swift
│       │   ├── Constants.swift
│       │   ├── TimeFormatter.swift
│       │   └── Version.swift
│       ├── Models/
│       │   └── ActivitySession.swift
│       └── Protocols/
│           └── NotificationManaging.swift
├── Tests/                     # Unit, integration, and UI tests
│   ├── WeakupTests/           # Swift Testing (unit + integration)
│   │   ├── Integration/       # Integration tests
│   │   └── Mocks/             # Test mocks and fixtures
│   └── WeakupUITests/         # XCTest (UI tests only)
├── docs/                      # Documentation
├── Weakup.app/                # Built application (generated)
```

## Development Workflow

### Making Changes

1. Edit source files in `Sources/Weakup/` or `Sources/WeakupCore/`
2. Rebuild with `./build.sh`
3. Test with `open Weakup.app`

### Quick Iteration

For faster development iteration, you can run directly without creating the app bundle:

```bash
# Build only
swift build -c release

# Run binary directly
.build/release/weakup
```

Note: Running the binary directly may have limited functionality (no app icon, localization may not work correctly).

### Debug Build

```bash
# Build in debug mode
swift build

# Run debug binary
.build/debug/weakup
```

### Running Tests

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter CaffeineViewModelTests

# Run with verbose output
swift test --verbose

# Run with coverage
swift test --enable-code-coverage

# If sandbox errors occur
swift test --disable-sandbox
```

**Testing Frameworks:**
- **Swift Testing** - Unit and integration tests use modern `@Test` syntax
- **XCTest** - UI tests only (XCUITest framework requirement)

See [TESTING.md](TESTING.md) for detailed testing guidelines.

## Code Organization

### App Entry

- `Sources/Weakup/main.swift` defines the entry point and wires `AppDelegate`.
- `Sources/Weakup/App/AppDelegate.swift` owns the status item, settings window, onboarding window, and hotkey registration.

### Core Logic

- `Sources/WeakupCore/ViewModels/CaffeineViewModel.swift` owns sleep prevention state, timer logic, and preferences.
- `Sources/WeakupCore/Utilities/` contains:
  - **Managers**: `L10n`, `HotkeyManager`, `IconManager`, `ThemeManager`, `NotificationManager`, `ActivityHistoryManager`, `LaunchAtLoginManager`
  - **Utilities**: `Logger`, `UserDefaultsKeys`, `Constants`, `TimeFormatter`, `Version`

### UI Views

- `Sources/Weakup/Views/SettingsView.swift` is the primary settings window UI.
- `Sources/Weakup/Views/OnboardingView.swift` handles first-launch onboarding.
- `Sources/Weakup/Views/HistoryView.swift` renders session history, export/import, and charts.

### L10n.swift

Localization system:

- `AppLanguage` enum - Supported languages
- `L10n` class - Localization manager
- String accessors for all UI text

## Adding New Features

### Adding a New Setting

1. Add state property to `CaffeineViewModel`:

```swift
@Published var newSetting = false
```

1. Add UI in `SettingsView`:

```swift
Toggle("New Setting", isOn: $viewModel.newSetting)
```

1. Add localized strings to all `.strings` files:

```
"new_setting" = "New Setting";
```

1. Add accessor in `L10n`:

```swift
var newSetting: String { string(forKey: "new_setting") }
```

### Adding a New Menu Item

In `AppDelegate.showContextMenu()`:

```swift
menu.addItem(NSMenuItem(
    title: L10n.shared.newMenuItem,
    action: #selector(newAction),
    keyEquivalent: "n"
))
```

### Adding a New Keyboard Shortcut

In `AppDelegate.setupHotkeys()`:

```swift
if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 0x00 {
    // Handle Cmd+Shift+A
    return nil
}
```

## Build Script Details

The `build.sh` script performs these steps:

1. **Swift Build:** Compiles the package in release mode
2. **Bundle Creation:** Creates the `.app` directory structure
3. **Binary Copy:** Copies the executable to `Contents/MacOS/`
4. **Localization:** Copies `.lproj` folders to `Contents/Resources/`
5. **Icon Generation:** Creates app icons from SVG template
6. **Info.plist:** Generates the application metadata

## Debugging

### Console Logging

Add print statements for debugging:

```swift
print("Debug: isActive = \(isActive)")
```

View logs in Console.app or Terminal when running directly.

### Common Issues

**App doesn't appear in menu bar:**

- Check that `app.setActivationPolicy(.accessory)` is called
- Ensure `statusItem` is retained (not deallocated)

**Localization not working:**

- Verify `.lproj` folders are copied to app bundle
- Check `CFBundleLocalizations` in Info.plist
- Ensure bundle path resolution is correct

**Sleep prevention not working:**

- Check IOPMAssertion return value
- Verify the app has necessary permissions
- Test with `pmset -g assertions` in Terminal

### Checking Power Assertions

```bash
# List all power assertions
pmset -g assertions

# Should show something like:
# pid 12345(weakup): [0x0000000100000001] 00:05:00 PreventUserIdleSystemSleep named: "Weakup preventing sleep"
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `WEAKUP_DEBUG` | Enable debug logging (future) |
| `WEAKUP_LANG` | Override language detection (future) |

## IDE Setup

### Xcode

1. Generate Xcode project:

```bash
swift package generate-xcodeproj
```

1. Open in Xcode:

```bash
open Weakup.xcodeproj
```

### VS Code

Recommended extensions:

- Swift (sswg.swift-lang)
- SwiftLint (vknabel.vscode-swiftlint)

### Other Editors

Any editor with Swift LSP support will work. Ensure `sourcekit-lsp` is in your PATH.

## Release Build

For distribution:

```bash
# Build release
./build.sh

# The app is ready at Weakup.app
# Optionally sign for distribution (see code signing docs)
```

## Troubleshooting

### Build Fails

```bash
# Clean build artifacts
rm -rf .build
swift package clean

# Rebuild
./build.sh
```

### Permission Denied on build.sh

```bash
chmod +x build.sh
```

### Swift Version Mismatch

```bash
# Check Swift version
swift --version

# Update Xcode Command Line Tools if needed
xcode-select --install
```
