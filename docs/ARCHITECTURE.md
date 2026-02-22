# Weakup Architecture

This document provides a comprehensive overview of the Weakup application architecture.

## Overview

Weakup is a macOS menu bar application that prevents system sleep using Apple's IOPMAssertion API. The app is built with Swift 6.0 using a combination of SwiftUI for the settings UI and AppKit for system integration.

## High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              macOS System Layer                              │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  ┌─────────────┐  │
│  │  NSStatusBar  │  │    IOKit      │  │ UserDefaults  │  │ UNUserNotif │  │
│  │  (Menu Bar)   │  │ (Power Mgmt)  │  │ (Preferences) │  │ (Alerts)    │  │
│  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘  └──────┬──────┘  │
└──────────┼──────────────────┼──────────────────┼─────────────────┼──────────┘
           │                  │                  │                 │
┌──────────┼──────────────────┼──────────────────┼─────────────────┼──────────┐
│          ▼                  ▼                  ▼                 ▼          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         Weakup (App Target)                          │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐  │   │
│  │  │   AppDelegate   │  │  SettingsView   │  │    HistoryView      │  │   │
│  │  │  (Entry Point)  │  │   (SwiftUI)     │  │    (SwiftUI)        │  │   │
│  │  └────────┬────────┘  └────────┬────────┘  └──────────┬──────────┘  │   │
│  └───────────┼────────────────────┼──────────────────────┼─────────────┘   │
│              │                    │                      │                  │
│  ┌───────────┼────────────────────┼──────────────────────┼─────────────┐   │
│  │           ▼                    ▼                      ▼             │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                    WeakupCore (Library Target)               │   │   │
│  │  │                                                              │   │   │
│  │  │  ┌──────────────────────────────────────────────────────┐   │   │   │
│  │  │  │                    ViewModels                         │   │   │   │
│  │  │  │  ┌─────────────────────────────────────────────────┐ │   │   │   │
│  │  │  │  │              CaffeineViewModel                   │ │   │   │   │
│  │  │  │  │  - Sleep prevention state                        │ │   │   │   │
│  │  │  │  │  - Timer management                              │ │   │   │   │
│  │  │  │  │  - IOPMAssertion lifecycle                       │ │   │   │   │
│  │  │  │  └─────────────────────────────────────────────────┘ │   │   │   │
│  │  │  └──────────────────────────────────────────────────────┘   │   │   │
│  │  │                                                              │   │   │
│  │  │  ┌──────────────────────────────────────────────────────┐   │   │   │
│  │  │  │                    Utilities                          │   │   │   │
│  │  │  │  ┌────────────┐ ┌────────────┐ ┌────────────────────┐│   │   │   │
│  │  │  │  │   L10n     │ │ IconMgr    │ │ NotificationMgr    ││   │   │   │
│  │  │  │  └────────────┘ └────────────┘ └────────────────────┘│   │   │   │
│  │  │  │  ┌────────────┐ ┌────────────┐ ┌────────────────────┐│   │   │   │
│  │  │  │  │ HotkeyMgr  │ │ ThemeMgr   │ │ ActivityHistoryMgr ││   │   │   │
│  │  │  │  └────────────┘ └────────────┘ └────────────────────┘│   │   │   │
│  │  │  │  ┌────────────┐                                      │   │   │   │
│  │  │  │  │LaunchLogin │                                      │   │   │   │
│  │  │  │  └────────────┘                                      │   │   │   │
│  │  │  └──────────────────────────────────────────────────────┘   │   │   │
│  │  │                                                              │   │   │
│  │  │  ┌──────────────────────────────────────────────────────┐   │   │   │
│  │  │  │                     Models                            │   │   │   │
│  │  │  │  ┌─────────────────┐  ┌─────────────────────────────┐│   │   │   │
│  │  │  │  │ ActivitySession │  │    ActivityStatistics       ││   │   │   │
│  │  │  │  └─────────────────┘  └─────────────────────────────┘│   │   │   │
│  │  │  └──────────────────────────────────────────────────────┘   │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └────────────────────────────────────────────────────────────────────┘   │
│                                                                            │
│                              Weakup.app                                    │
└────────────────────────────────────────────────────────────────────────────┘
```

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           WeakupCore Library                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                        CaffeineViewModel                         │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │    │
│  │  │  isActive   │  │ timerMode   │  │    timeRemaining        │  │    │
│  │  │   (Bool)    │  │   (Bool)    │  │   (TimeInterval)        │  │    │
│  │  └─────────────┘  └─────────────┘  └─────────────────────────┘  │    │
│  │  ┌─────────────────────────────────────────────────────────────┐│    │
│  │  │ Methods: start() | stop() | toggle() | setTimerDuration()   ││    │
│  │  └─────────────────────────────────────────────────────────────┘│    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                              │                                           │
│                              │ uses                                      │
│                              ▼                                           │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                     Manager Singletons                           │    │
│  │                                                                   │    │
│  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────────┐    │    │
│  │  │     L10n      │  │  IconManager  │  │NotificationManager│    │    │
│  │  │   .shared     │  │    .shared    │  │      .shared      │    │    │
│  │  │               │  │               │  │                   │    │    │
│  │  │ - language    │  │ - iconStyle   │  │ - enabled         │    │    │
│  │  │ - strings     │  │ - images      │  │ - authorized      │    │    │
│  │  └───────────────┘  └───────────────┘  └───────────────────┘    │    │
│  │                                                                   │    │
│  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────────┐    │    │
│  │  │ HotkeyManager │  │ ThemeManager  │  │ActivityHistoryMgr │    │    │
│  │  │    .shared    │  │    .shared    │  │      .shared      │    │    │
│  │  │               │  │               │  │                   │    │    │
│  │  │ - config      │  │ - theme       │  │ - sessions        │    │    │
│  │  │ - conflicts   │  │ - colorScheme │  │ - statistics      │    │    │
│  │  └───────────────┘  └───────────────┘  └───────────────────┘    │    │
│  │                                                                   │    │
│  │  ┌───────────────────────────────────────────────────────────┐  │    │
│  │  │                  LaunchAtLoginManager                      │  │    │
│  │  │                        .shared                             │  │    │
│  │  │                                                            │  │    │
│  │  │  - isEnabled: Bool                                         │  │    │
│  │  │  - Uses SMAppService for login item management             │  │    │
│  │  └───────────────────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Sequence Diagram: Sleep Prevention Toggle

```
┌──────┐     ┌───────────┐     ┌─────────────────┐     ┌───────┐     ┌──────────────────┐
│ User │     │AppDelegate│     │CaffeineViewModel│     │ IOKit │     │ActivityHistoryMgr│
└──┬───┘     └─────┬─────┘     └────────┬────────┘     └───┬───┘     └────────┬─────────┘
   │               │                    │                  │                  │
   │  Click Icon   │                    │                  │                  │
   │──────────────>│                    │                  │                  │
   │               │                    │                  │                  │
   │               │    toggle()        │                  │                  │
   │               │───────────────────>│                  │                  │
   │               │                    │                  │                  │
   │               │                    │  IOPMAssertion   │                  │
   │               │                    │  CreateWithName  │                  │
   │               │                    │─────────────────>│                  │
   │               │                    │                  │                  │
   │               │                    │   assertionID    │                  │
   │               │                    │<─────────────────│                  │
   │               │                    │                  │                  │
   │               │                    │  startSession()  │                  │
   │               │                    │─────────────────────────────────────>│
   │               │                    │                  │                  │
   │               │  objectWillChange  │                  │                  │
   │               │<───────────────────│                  │                  │
   │               │                    │                  │                  │
   │               │  updateStatusIcon()│                  │                  │
   │               │───────────────────>│                  │                  │
   │               │                    │                  │                  │
   │  Icon Updated │                    │                  │                  │
   │<──────────────│                    │                  │                  │
   │               │                    │                  │                  │
```

## Sequence Diagram: Timer Mode Flow

```
┌──────┐     ┌─────────────────┐     ┌───────┐     ┌───────────────────┐
│ User │     │CaffeineViewModel│     │ Timer │     │NotificationManager│
└──┬───┘     └────────┬────────┘     └───┬───┘     └─────────┬─────────┘
   │                  │                  │                   │
   │  Enable Timer    │                  │                   │
   │  Set Duration    │                  │                   │
   │─────────────────>│                  │                   │
   │                  │                  │                   │
   │  start()         │                  │                   │
   │─────────────────>│                  │                   │
   │                  │                  │                   │
   │                  │  Schedule Timer  │                   │
   │                  │─────────────────>│                   │
   │                  │                  │                   │
   │                  │                  │                   │
   │                  │  tick (0.5s)     │                   │
   │                  │<─────────────────│                   │
   │                  │                  │                   │
   │                  │  Update          │                   │
   │                  │  timeRemaining   │                   │
   │                  │                  │                   │
   │                  │     ...          │                   │
   │                  │                  │                   │
   │                  │  timeRemaining=0 │                   │
   │                  │<─────────────────│                   │
   │                  │                  │                   │
   │                  │  stop()          │                   │
   │                  │──────────────────│                   │
   │                  │                  │                   │
   │                  │  scheduleTimerExpiryNotification()   │
   │                  │──────────────────────────────────────>│
   │                  │                  │                   │
   │                  │                  │   Notification    │
   │<─────────────────────────────────────────────────────────│
   │                  │                  │                   │
```

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Data Flow                                       │
└─────────────────────────────────────────────────────────────────────────────┘

                          ┌─────────────────┐
                          │   User Action   │
                          │  (Click/Hotkey) │
                          └────────┬────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                            AppDelegate                                        │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │  - Receives user input                                                  │  │
│  │  - Routes to appropriate handler                                        │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
           ┌───────────────┐ ┌──────────┐ ┌─────────────┐
           │CaffeineViewModel│ │ L10n    │ │ Settings    │
           │               │ │          │ │ Managers    │
           └───────┬───────┘ └────┬─────┘ └──────┬──────┘
                   │              │              │
                   │              │              │
        ┌──────────┴──────────────┴──────────────┴──────────┐
        │                                                    │
        ▼                                                    ▼
┌───────────────┐                                   ┌───────────────┐
│    IOKit      │                                   │  UserDefaults │
│  (Power API)  │                                   │ (Persistence) │
└───────────────┘                                   └───────────────┘
        │                                                    │
        │                                                    │
        ▼                                                    ▼
┌───────────────┐                                   ┌───────────────┐
│ System Sleep  │                                   │   Settings    │
│   Prevented   │                                   │   Restored    │
└───────────────┘                                   └───────────────┘
```

## Module Structure

```
Sources/
├── Weakup/                          # App Target (Executable)
│   ├── main.swift                   # Entry point
│   ├── App/
│   │   └── AppDelegate.swift        # Menu bar, system integration
│   ├── Views/
│   │   ├── SettingsView.swift       # Main settings UI
│   │   ├── HistoryView.swift        # Activity history UI
│   │   └── OnboardingView.swift     # First-launch onboarding UI
│   └── *.lproj/                     # Localization strings
│       └── Localizable.strings
│
└── WeakupCore/                      # Library Target
    ├── Models/
    │   └── ActivitySession.swift    # Session data model
    ├── ViewModels/
    │   └── CaffeineViewModel.swift  # Core business logic
    └── Utilities/
        ├── L10n.swift               # Localization manager
        ├── IconManager.swift        # Menu bar icon styles
        ├── ThemeManager.swift       # Light/dark theme
        ├── HotkeyManager.swift      # Keyboard shortcuts
        ├── NotificationManager.swift # System notifications
        ├── ActivityHistoryManager.swift # Session history
        ├── LaunchAtLoginManager.swift   # Login item
        ├── Version.swift            # App version info
        ├── TimeFormatter.swift      # Countdown formatting
        └── Constants.swift          # App constants
    └── Protocols/
        └── NotificationManaging.swift # Notification abstraction
```

## Core Components

### 1. CaffeineViewModel

**File:** `Sources/WeakupCore/ViewModels/CaffeineViewModel.swift`

The central view model managing sleep prevention state:

**Published Properties:**
- `isActive: Bool` - Current sleep prevention state
- `timerMode: Bool` - Whether timer mode is enabled
- `timeRemaining: TimeInterval` - Countdown timer value
- `soundEnabled: Bool` - Sound feedback setting
- `showCountdownInMenuBar: Bool` - Menu bar countdown display
- `notificationsEnabled: Bool` - Timer expiry notifications

**Core Methods:**
- `start()` - Creates IOPMAssertion to prevent sleep
- `stop()` - Releases assertion and allows sleep
- `toggle()` - Switches between active/inactive states
- `setTimerDuration(_:)` - Sets timer duration
- `restartTimer()` - Restarts timer (from notification action)

**IOPMAssertion Integration:**
```swift
IOPMAssertionCreateWithName(
    kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
    IOPMAssertionLevel(kIOPMAssertionLevelOn),
    "Weakup preventing sleep" as CFString,
    &systemID
)

IOPMAssertionCreateWithName(
    kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
    IOPMAssertionLevel(kIOPMAssertionLevelOn),
    "Weakup preventing sleep" as CFString,
    &displayID
)
```

### 2. AppDelegate

**File:** `Sources/Weakup/App/AppDelegate.swift`

Responsibilities:
- **Status Bar Management:** Creates and manages the menu bar icon
- **Menu Setup:** Configures the dropdown menu with Settings and Quit options
- **Hotkey Integration:** Connects HotkeyManager to toggle action
- **Session Tracking:** Coordinates with ActivityHistoryManager

### 3. Manager Singletons

| Manager | Purpose | Key Properties |
|---------|---------|----------------|
| `L10n` | Localization | `currentLanguage`, `string(forKey:)` |
| `IconManager` | Menu bar icons | `currentStyle`, `currentImage(isActive:)` |
| `ThemeManager` | App theme | `currentTheme`, `effectiveColorScheme` |
| `HotkeyManager` | Keyboard shortcuts | `currentConfig`, `isRecording`, `hasConflict` |
| `NotificationManager` | System notifications | `notificationsEnabled`, `isAuthorized` |
| `ActivityHistoryManager` | Session history | `sessions`, `statistics`, `exportHistory()` |
| `LaunchAtLoginManager` | Login item | `isEnabled` |
| `OnboardingManager` | First-launch flow | `shouldShowOnboarding` |

### 4. Models

**ActivitySession:**
```swift
public struct ActivitySession: Codable, Identifiable, Sendable {
    public let id: UUID
    public let startTime: Date
    public var endTime: Date?
    public var wasTimerMode: Bool
    public var timerDuration: TimeInterval?

    public var duration: TimeInterval { ... }
    public var isActive: Bool { ... }
}
```

**ActivityStatistics:**
```swift
public struct ActivityStatistics: Sendable {
    public let totalSessions: Int
    public let totalDuration: TimeInterval
    public let todaySessions: Int
    public let todayDuration: TimeInterval
    public let weekSessions: Int
    public let weekDuration: TimeInterval
    public let averageSessionDuration: TimeInterval
}
```

## Frameworks Used

| Framework | Purpose |
|-----------|---------|
| SwiftUI | Settings UI, History view |
| AppKit | Menu bar, settings window, system integration |
| IOKit | Power management (IOPMAssertion) |
| Foundation | Core utilities, UserDefaults, JSON |
| Carbon | Keyboard event handling |
| UserNotifications | Timer expiry notifications |
| ServiceManagement | Launch at login |

## Design Decisions

### 1. Modular Architecture

The codebase is split into two targets:
- **WeakupCore:** Library containing all business logic, view models, and utilities
- **Weakup:** Executable containing UI views and app lifecycle management

Benefits:
- Clear separation of concerns
- Easier unit testing of core logic
- Potential for code reuse

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

### 5. Singleton Managers

Manager classes use the singleton pattern for:
- Global state management
- Easy access from any component
- Consistent state across the app

## Security Considerations

- **No Network Access:** The app operates entirely offline
- **Minimal Permissions:** Only requires power management access
- **Local Storage Only:** Preferences stored in UserDefaults
- **No Sensitive Data:** No personal information collected
- **Sandboxing Compatible:** Uses standard macOS APIs

## Performance

- **Memory:** ~15-20 MB typical usage
- **CPU:** Negligible (event-driven, no polling)
- **Battery:** Minimal impact (native API usage)
- **Timer Accuracy:** Uses elapsed time calculation to handle background/sleep

## Testing Architecture

```
Tests/WeakupTests/
├── CaffeineViewModelTests.swift     # Core logic tests
├── L10nTests.swift                  # Localization tests
├── ActivityHistoryManagerTests.swift # History tests
├── HotkeyManagerTests.swift         # Hotkey tests
├── IconManagerTests.swift           # Icon tests
├── ThemeManagerTests.swift          # Theme tests
├── NotificationManagerTests.swift   # Notification tests
├── Mocks/
│   ├── MockUserDefaults.swift       # UserDefaults mock
│   ├── MockSleepPreventionService.swift # IOKit mock
│   └── TestFixtures.swift           # Test data
└── Integration/
    └── SleepPreventionIntegrationTests.swift
```

## Future Considerations

- **Widget Support:** Menu bar widget for quick access
- **Shortcuts Integration:** Siri Shortcuts support
- **iCloud Sync:** Sync settings across devices
- **Apple Watch Companion:** Remote control from watch
