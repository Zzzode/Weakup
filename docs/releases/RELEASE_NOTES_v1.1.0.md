# Weakup v1.1.0 Release Notes

**Release Date:** August 30, 2026

Weakup v1.1.0 adds **Turn Off Display**, a one-click action for leaving long-running work active while switching off the display.

## Turn Off Display

- Open the menu bar context menu and choose **Turn Off Display**, or use the same action in Settings.
- Weakup keeps the Mac and background tasks running while macOS turns off the display.
- Move the mouse or press a key to wake the display.
- Existing keep-awake timers continue from their current remaining time. Starting the action while Weakup is inactive starts a normal keep-awake session.
- The action is available in all eight supported languages.

## Security and Power Boundaries

- Whether waking the display requires a password is controlled by macOS Lock Screen settings or device-management policy. Weakup does not change or bypass those settings.
- Weakup prevents sleep caused by user inactivity. Closing a MacBook lid, choosing Sleep manually, or critical battery conditions can still put the Mac to sleep.

## Reliability Improvements

- Display-sleep requests run asynchronously so the interface remains responsive.
- Power assertion creation, rollback, cleanup, repeated requests, and concurrent state changes are covered by regression tests.
- Keep-awake startup is idempotent and no longer risks leaking assertions when invoked repeatedly.

## Installation

Building from source remains the supported installation method unless the GitHub Release includes signed and notarized prebuilt downloads.

```bash
git clone --branch v1.1.0 --depth 1 https://github.com/Zzzode/weakup.git
cd weakup
./build.sh
open Weakup.app
```

## Requirements

- macOS 13 or later
- Xcode with Swift 6.2.3 or later

See [CHANGELOG.md](../../CHANGELOG.md) for the complete version history.
