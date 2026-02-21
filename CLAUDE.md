# CLAUDE.md - AI Development Guide

This file provides context for AI assistants working on the Weakup codebase.

## Project Overview

**Weakup** is a macOS menu bar application that prevents system sleep. It's a lightweight utility similar to Amphetamine or Caffeine, built with Swift 6.0 using SwiftUI and AppKit.

### Key Features
- One-click sleep prevention toggle
- Timer mode with preset durations
- Global keyboard shortcut (Cmd+Ctrl+0)
- Real-time language switching (English/Chinese)
- Menu bar only (no dock icon)

## Architecture

### Modular Design

The project is split into two targets:
1. **WeakupCore**: Library containing business logic, view models, and utilities.
2. **Weakup**: Main executable containing UI views and app lifecycle management.

| Component | Location | Purpose |
|-----------|----------|---------|
| `WeakupApp` | `Sources/Weakup/main.swift` | Entry point |
| `AppDelegate` | `Sources/Weakup/App/AppDelegate.swift` | Menu bar, system integration |
| `SettingsView` | `Sources/Weakup/Views/SettingsView.swift` | Settings UI |
| `CaffeineViewModel` | `Sources/WeakupCore/ViewModels/CaffeineViewModel.swift` | Sleep prevention logic |
| `NotificationManager` | `Sources/WeakupCore/Utilities/NotificationManager.swift` | Notification handling |
| `L10n` | `Sources/WeakupCore/Utilities/L10n.swift` | Localization system |

### Localization

`Sources/WeakupCore/Utilities/L10n.swift` handles internationalization:
- `AppLanguage` enum defines supported languages
- `L10n` singleton manages current language
- Strings stored in `.lproj/Localizable.strings` files in `Sources/Weakup/`

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

## Important File Locations

```
Sources/
├── Weakup/                 # App UI and Executable
│   ├── App/                # App Delegate
│   ├── Views/              # SwiftUI Views
│   ├── main.swift          # Entry point
│   └── *.lproj/            # Localization strings
└── WeakupCore/             # Business Logic Library
    ├── Models/             # Data models
    ├── Utilities/          # Managers (Hotkey, Icon, Theme, etc.)
    └── ViewModels/         # View Models (CaffeineViewModel)

build.sh                    # Build script (creates .app bundle)
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

### Testing Power Assertions

```bash
pmset -g assertions
# Shows active power assertions
```

## Common Tasks

### Adding a New Setting

1. Add `@Published` property to `CaffeineViewModel`
2. Add UI control in `SettingsView`
3. Add localized string keys to both `.strings` files
4. Add string accessor to `L10n` extension

### Adding a New Language

1. Create `Sources/Weakup/XX.lproj/Localizable.strings`
2. Add case to `AppLanguage` enum in `L10n.swift`
3. Update `build.sh` to copy new `.lproj` folder
4. Add to `CFBundleLocalizations` in Info.plist (in build.sh)

### Adding a Menu Item

In `AppDelegate.updateMenu()`:
```swift
menu.addItem(NSMenuItem(
    title: L10n.shared.menuItemName,
    action: #selector(actionMethod),
    keyEquivalent: "x"
))
```

### Adding a Keyboard Shortcut

In `AppDelegate.setupHotkeys()`:
```swift
if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 0x00 {
    // Handle Cmd+Shift+A
    return nil
}
```

## Code Patterns

### MainActor Usage

All UI-related code uses `@MainActor`:
```swift
@MainActor
final class CaffeineViewModel: ObservableObject { ... }
```

### Timer Pattern

Timer callbacks dispatch to MainActor:
```swift
timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
    Task { @MainActor [weak self] in
        // Update state
    }
}
```

### Localization Pattern

```swift
// In L10n.swift
var menuSettings: String { string(forKey: "menu_settings") }

// Usage
Text(L10n.shared.menuSettings)
```

## Testing Guidelines

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

## Future Improvements

See README.md roadmap:
- Dark/light theme support
- Custom timer durations
- Notification on timer expiry
- Menu bar icon customization
- Launch at login

## Resources

- [IOPMAssertion Documentation](https://developer.apple.com/documentation/iokit/iopmassertion)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
