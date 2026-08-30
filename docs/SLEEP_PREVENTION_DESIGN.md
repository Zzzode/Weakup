# Sleep Prevention Design

This document explains how Weakup prevents sleep on macOS, focusing on system mechanisms, state management, timers, notifications, and cleanup.

## Goals and Scope

- Goal: prevent user-idle system sleep when enabled, with an optional timer mode that stops automatically
- Scope: core sleep-prevention mechanics only; UI details are out of scope

## Core Mechanism: IOPMAssertion

Weakup uses macOS native IOPMAssertion APIs to create power assertions and keep the system awake. When the user enables sleep prevention, it:

1. Creates a system sleep assertion to block user-idle system sleep
2. Creates a display sleep assertion to keep the display awake when needed
3. Stores assertion IDs for later release
4. Releases assertions on stop or app termination

Implementation reference: [CaffeineViewModel.swift](../Sources/WeakupCore/ViewModels/CaffeineViewModel.swift#L169-L206).

## Assertion Types and Reason

- System assertion: `kIOPMAssertionTypePreventUserIdleSystemSleep`
- Display assertion: `kIOPMAssertionTypePreventUserIdleDisplaySleep`
- Reason string: centralized in app constants for diagnostics and debugging

This approach avoids extra processes (like `caffeinate`) and provides direct lifecycle control.

## Turn Off Display and Keep Running

“Turn Off Display” is a one-time action. Weakup keeps the system sleep assertion active and
asks macOS to turn off the display immediately with `/usr/bin/pmset displaysleepnow`. The
display sleep assertion remains part of the normal active session; the forced display-sleep
request is independent from idle display sleep.

When the action starts an inactive Weakup session, both normal session assertions are acquired
before the display is turned off. The visible active state, timer, and history session are committed
only after the command succeeds. On failure, Weakup releases provisional assertions and retains
any handle whose release fails so cleanup can be retried. Existing active and timed sessions
continue without restarting.

Whether waking the display requires a password is controlled by macOS Lock Screen settings or
device-management policy. Weakup does not change or bypass those security settings. Closing a
laptop lid, choosing Sleep manually, or critical battery conditions can still put the Mac to sleep.

## Lifecycle and State Flow

`CaffeineViewModel` holds the core state and is `@MainActor`-isolated to keep UI and logic in sync. Key state includes:

- `isActive`: whether sleep prevention is enabled
- `timerMode`: whether timer mode is enabled
- `timerDuration`: total timer duration
- `timeRemaining`: remaining countdown

State flow summary:

1. User triggers start
2. Assertion creation succeeds → `isActive = true`
3. If timer mode is enabled with a valid duration, initialize `timeRemaining` and start the timer
4. On stop or timer expiry, release assertions, stop timer, and reset state

## Timer Mode Design

Timer mode uses a `Timer` to update the countdown and stop automatically at zero.

Key points:

- `timerStartDate` is recorded to correct drift
- callbacks refresh `timeRemaining`
- hitting zero triggers an automatic stop and assertion release

Implementation reference: [CaffeineViewModel.swift](../Sources/WeakupCore/ViewModels/CaffeineViewModel.swift#L211-L233).

## Notifications and User Feedback

When the timer expires and notifications are enabled, `NotificationManager` sends a system notification. Authorization is requested during initialization, and the toggle is synced with user preferences.

References:

- [CaffeineViewModel.swift](../Sources/WeakupCore/ViewModels/CaffeineViewModel.swift#L86-L139)
- [NotificationManager.swift](../Sources/WeakupCore/Utilities/NotificationManager.swift)

## Menu Bar Countdown

When “menu bar countdown” is enabled and timer mode is active, the status item displays the remaining time for quick visibility.

References:

- [AppDelegate.swift](../Sources/Weakup/App/AppDelegate.swift#L185-L196)
- [TimeFormatter.swift](../Sources/WeakupCore/Utilities/TimeFormatter.swift)

## Cleanup and Edge Paths

To avoid assertion leaks, Weakup releases assertions on:

- user stop
- timer expiry
- app termination (`applicationWillTerminate`)

This ensures the system state is consistent with the app state.

## System Diagnostics

Use the following to verify assertions:

```bash
pmset -g assertions
```

You should see `PreventUserIdleSystemSleep` with Weakup’s assertion reason.

## Design Trade-offs

- Use IOPMAssertion instead of `caffeinate` to reduce overhead and simplify lifecycle control
- Prevent both system and display sleep for a consistent user experience
- Keep core logic in `WeakupCore` for testability and separation of concerns

## Risks and Boundaries

- If IOKit assertion creation fails, `isActive` remains false
- Immediate display sleep relies on Apple's `pmset` system command and is a best-effort capability
- Timer drift is possible, mitigated with `timerStartDate`
- Forced termination relies on system cleanup; avoid killing the app during active sessions
