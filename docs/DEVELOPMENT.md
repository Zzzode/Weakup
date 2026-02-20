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
git clone https://github.com/yourusername/weakup.git
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
│   └── Weakup/
│       ├── main.swift         # Main application code
│       ├── L10n.swift         # Localization system
│       ├── en.lproj/          # English localization
│       │   └── Localizable.strings
│       └── zh-Hans.lproj/     # Chinese localization
│           └── Localizable.strings
├── docs/                      # Documentation
├── Weakup.app/                # Built application (generated)
└── .build/                    # Swift build artifacts (generated)
```

## Development Workflow

### Making Changes

1. Edit source files in `Sources/Weakup/`
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

## Code Organization

### main.swift

Contains the core application components:

| Component | Lines | Description |
|-----------|-------|-------------|
| `WeakupApp` | 8-16 | Application entry point |
| `AppDelegate` | 20-94 | System integration, menu bar |
| `CaffeineViewModel` | 98-174 | Business logic, state management |
| `SettingsView` | 178-294 | SwiftUI user interface |

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

2. Add UI in `SettingsView`:
```swift
Toggle("New Setting", isOn: $viewModel.newSetting)
```

3. Add localized strings to both `.strings` files:
```
"new_setting" = "New Setting";
```

4. Add accessor in `L10n`:
```swift
var newSetting: String { string(forKey: "new_setting") }
```

### Adding a New Menu Item

In `AppDelegate.updateMenu()`:
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

2. Open in Xcode:
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
