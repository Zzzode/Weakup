# Weakup Architecture

This document provides an overview of the Weakup application architecture.

## Overview

Weakup is a macOS menu bar application that prevents system sleep using Apple's IOPMAssertion API. The app is built with Swift 6.0 using a combination of SwiftUI for the settings UI and AppKit for system integration.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        macOS System                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Menu Bar      │  │   IOKit         │  │   UserDefaults  │  │
│  │   (NSStatusBar) │  │   (Power Mgmt)  │  │   (Preferences) │  │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘  │
└───────────┼────────────────────┼────────────────────┼───────────┘
            │                    │                    │
┌───────────┼────────────────────┼────────────────────┼───────────┐
│           ▼                    ▼                    ▼           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                     AppDelegate                          │   │
│  │  - Status bar setup                                      │   │
│  │  - Menu management                                       │   │
│  │  - Hotkey registration                                   │   │
│  └─────────────────────────┬───────────────────────────────┘   │
│                            │                                    │
│           ┌────────────────┼────────────────┐                  │
│           ▼                ▼                ▼                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐    │
│  │SettingsView │  │CaffeineVM   │  │      L10n           │    │
│  │  (SwiftUI)  │  │(ViewModel)  │  │  (Localization)     │    │
│  └─────────────┘  └─────────────┘  └─────────────────────┘    │
│                                                                 │
│                        Weakup.app                               │
└─────────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. WeakupApp (Entry Point)

**File:** `Sources/Weakup/main.swift:8-16`

The application entry point that:
- Creates the NSApplication instance
- Sets up the AppDelegate
- Configures the app as an accessory (menu bar only, no dock icon)

```swift
@MainActor
struct WeakupApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}
```

### 2. AppDelegate

**File:** `Sources/Weakup/main.swift:20-94`

Responsibilities:
- **Status Bar Management:** Creates and manages the menu bar icon
- **Menu Setup:** Configures the dropdown menu with Settings and Quit options
- **Hotkey Registration:** Registers global keyboard shortcut (Cmd+Ctrl+0)
- **Popover Management:** Shows/hides the settings popover

Key methods:
- `setupStatusBar()` - Initializes the menu bar item
- `updateMenu()` - Creates the context menu
- `setupHotkeys()` - Registers keyboard shortcuts
- `toggleCaffeine()` - Toggles sleep prevention
- `showSettings()` - Displays the settings popover

### 3. CaffeineViewModel

**File:** `Sources/Weakup/main.swift:98-174`

The view model managing the sleep prevention state:

**Properties:**
- `isActive: Bool` - Current sleep prevention state
- `timerMode: Bool` - Whether timer mode is enabled
- `timeRemaining: TimeInterval` - Countdown timer value
- `timerDuration: TimeInterval` - Selected timer duration

**Core Functionality:**
- `start()` - Creates an IOPMAssertion to prevent sleep
- `stop()` - Releases the assertion and allows sleep
- `toggle()` - Switches between active/inactive states

**IOPMAssertion Integration:**
```swift
IOPMAssertionCreateWithName(
    kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
    IOPMAssertionLevel(kIOPMAssertionLevelOn),
    "Weakup preventing sleep" as CFString,
    &id
)
```

### 4. SettingsView

**File:** `Sources/Weakup/main.swift:178-294`

A SwiftUI view providing the user interface:
- Status indicator (green/gray dot)
- Language picker (English/Chinese)
- Timer mode toggle
- Duration picker (15m, 30m, 1h, 2h, 3h)
- Main toggle button
- Keyboard shortcut hint

### 5. L10n (Localization)

**File:** `Sources/Weakup/L10n.swift`

Manages internationalization:
- Supports English and Chinese (Simplified)
- Real-time language switching without app restart
- Persists language preference in UserDefaults
- Auto-detects system language on first launch

## Data Flow

```
User Action → AppDelegate → CaffeineViewModel → IOKit API
                  ↓
            SettingsView ← L10n (localized strings)
                  ↓
            UI Update (status icon, menu)
```

## File Structure

```
Weakup/
├── Package.swift                    # Swift Package configuration
├── build.sh                         # Build script
├── Sources/Weakup/
│   ├── main.swift                   # App entry, delegate, VM, views
│   ├── L10n.swift                   # Localization system
│   ├── en.lproj/
│   │   └── Localizable.strings      # English strings
│   └── zh-Hans.lproj/
│       └── Localizable.strings      # Chinese strings
└── Weakup.app/                      # Built application bundle
    └── Contents/
        ├── MacOS/weakup             # Executable
        ├── Resources/               # Localizations, icons
        └── Info.plist               # App metadata
```

## Frameworks Used

| Framework | Purpose |
|-----------|---------|
| SwiftUI | Settings UI |
| AppKit | Menu bar, popover, system integration |
| IOKit | Power management (IOPMAssertion) |
| Foundation | Core utilities, UserDefaults |
| Carbon | Keyboard event handling |

## Design Decisions

### 1. Single-File Architecture

The main application code is contained in `main.swift` for simplicity. As the app grows, consider splitting into:
- `AppDelegate.swift`
- `CaffeineViewModel.swift`
- `SettingsView.swift`

### 2. Menu Bar Only (Accessory App)

The app uses `.accessory` activation policy to:
- Avoid cluttering the dock
- Run as a background utility
- Focus on minimal resource usage

### 3. IOPMAssertion vs caffeinate

We use IOPMAssertion directly instead of spawning a `caffeinate` process because:
- Lower resource overhead
- Better control over assertion lifecycle
- Native Swift integration
- No subprocess management

### 4. Real-Time Localization

Language switching happens instantly without restart by:
- Using `@Published` property in L10n singleton
- Observing language changes in SwiftUI views
- Dynamically loading bundle for selected language

## Security Considerations

- **No Network Access:** The app operates entirely offline
- **Minimal Permissions:** Only requires power management access
- **Local Storage Only:** Preferences stored in UserDefaults
- **No Sensitive Data:** No personal information collected

## Performance

- **Memory:** ~15-20 MB typical usage
- **CPU:** Negligible (event-driven, no polling)
- **Battery:** Minimal impact (native API usage)
