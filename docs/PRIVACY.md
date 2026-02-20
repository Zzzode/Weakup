# Privacy Policy

**Last updated:** February 2026

## Overview

Weakup is designed with privacy as a core principle. This document explains what data Weakup collects, stores, and how it is used.

## Data Collection

### What We Collect

**Nothing.**

Weakup does not collect, transmit, or share any personal data. The application operates entirely offline and does not communicate with any external servers.

### What We Store Locally

Weakup stores minimal data on your device:

| Data | Location | Purpose |
|------|----------|---------|
| Language preference | UserDefaults | Remember your selected language |

This data is stored locally in macOS's standard preferences system and is never transmitted anywhere.

## Network Access

Weakup does not:
- Connect to the internet
- Send analytics or telemetry
- Check for updates automatically
- Communicate with any servers

The application has no network capabilities and operates entirely offline.

## System Access

Weakup requires access to:

### Power Management (IOKit)

- **What:** Ability to create power assertions
- **Why:** To prevent your Mac from sleeping
- **How:** Uses Apple's IOPMAssertion API
- **Data:** No user data is accessed

### Menu Bar (AppKit)

- **What:** Display icon in menu bar
- **Why:** Provide user interface
- **How:** Standard macOS APIs
- **Data:** No user data is accessed

### Keyboard Events (Carbon)

- **What:** Monitor keyboard shortcuts
- **Why:** Enable global hotkey (Cmd+Ctrl+0)
- **How:** Local event monitoring only
- **Data:** No keystrokes are recorded or stored

## Data Storage

### UserDefaults

The only persistent data stored:

```
Key: WeakupLanguage
Value: "en" or "zh-Hans"
Purpose: Remember language preference
```

To clear this data:
```bash
defaults delete com.weakup.app
```

### No Other Storage

Weakup does not:
- Create log files
- Store usage history
- Cache any data
- Write to disk (except preferences)

## Third-Party Services

Weakup uses no third-party services:
- No analytics (Google Analytics, Mixpanel, etc.)
- No crash reporting (Crashlytics, Sentry, etc.)
- No advertising
- No cloud services

## Open Source

Weakup is open source. You can:
- Review the source code
- Verify privacy claims
- Build from source yourself

Repository: [GitHub](https://github.com/yourusername/weakup)

## Children's Privacy

Weakup does not collect any data from anyone, including children.

## Changes to This Policy

If we make changes to this privacy policy, we will update the "Last updated" date at the top of this document.

Since Weakup collects no data, significant privacy policy changes are unlikely.

## Your Rights

Since Weakup stores no personal data:
- There is no data to access
- There is no data to delete
- There is no data to export

The only stored preference (language) can be reset by:
1. Deleting the app
2. Running `defaults delete com.weakup.app`

## Contact

For privacy-related questions:
- Open an issue on GitHub
- Email: [your-email@example.com]

## Summary

| Question | Answer |
|----------|--------|
| Does Weakup collect personal data? | No |
| Does Weakup connect to the internet? | No |
| Does Weakup track usage? | No |
| Does Weakup share data with third parties? | No |
| What data is stored locally? | Language preference only |
| Can I use Weakup offline? | Yes, it only works offline |

---

**Weakup respects your privacy by design.**
