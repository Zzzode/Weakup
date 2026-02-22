# Contributing to Weakup

Thank you for your interest in contributing to Weakup! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Making Changes](#making-changes)
- [Code Style](#code-style)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Assume good intentions

## Getting Started

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode Command Line Tools (`xcode-select --install`)
- Swift 6.0+
- Git

### Quick Start

```bash
# Clone the repository
git clone https://github.com/Zzzode/weakup.git
cd weakup

# Build the app
./build.sh

# Run
open Weakup.app
```

## Development Setup

For detailed development instructions, see [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

### Building

```bash
# Full build with app bundle
./build.sh

# Quick build (no app bundle)
swift build -c release
```

### Running

```bash
# Run app bundle
open Weakup.app

# Run binary directly (for quick testing)
.build/release/weakup
```

## Project Structure

```
Weakup/
├── Package.swift              # Swift Package configuration
├── build.sh                   # Build script
├── Sources/Weakup/
│   ├── main.swift             # Main application code
│   │   ├── WeakupApp          # Entry point
│   │   ├── AppDelegate        # System integration
│   │   ├── CaffeineViewModel  # Business logic
│   │   └── SettingsView       # SwiftUI UI
│   ├── L10n.swift             # Localization system
│   ├── en.lproj/              # English localization
│   │   └── Localizable.strings
│   └── zh-Hans.lproj/         # Chinese localization
│       └── Localizable.strings
├── docs/                      # Documentation
│   ├── ARCHITECTURE.md        # System architecture
│   ├── DEVELOPMENT.md         # Development guide
│   ├── TESTING.md             # Testing guide
│   ├── TRANSLATIONS.md        # Translation guide
│   └── PRIVACY.md             # Privacy policy
└── Weakup.app/                # Built application
```

## Making Changes

### Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation
- `refactor/description` - Code refactoring
- `translation/language-code` - New translations

### Commit Messages

Write clear, concise commit messages:

```
Add timer expiry notification

- Show macOS notification when timer reaches zero
- Add notification permission request
- Update localization strings
```

## Code Style

### Swift Guidelines

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftUI for UI components
- Keep functions focused and small (under 30 lines)
- Use meaningful variable and function names
- Add comments for complex logic only

### Formatting

```swift
// Good
func toggleCaffeine() {
    viewModel.toggle()
    updateStatusIcon()
}

// Avoid
func toggleCaffeine(){viewModel.toggle();updateStatusIcon()}
```

### SwiftUI Best Practices

- Extract reusable views into separate structs
- Use `@StateObject` for owned objects, `@ObservedObject` for passed objects
- Keep view bodies simple and readable

## Testing

See [docs/TESTING.md](docs/TESTING.md) for detailed testing guidelines.

### Manual Testing Checklist

Before submitting a PR, verify:

- [ ] Sleep prevention toggles correctly
- [ ] Timer mode works as expected
- [ ] Keyboard shortcut (Cmd+Ctrl+0) functions
- [ ] Language switching works
- [ ] App quits cleanly
- [ ] No memory leaks or crashes

### Verifying Power Assertions

```bash
# Check if assertion is created/released properly
pmset -g assertions
```

## Submitting Changes

### Pull Request Process

1. Fork the repository
2. Create a feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Make your changes
4. Test thoroughly
5. Commit with clear messages:
   ```bash
   git commit -m 'Add amazing feature'
   ```
6. Push to your fork:
   ```bash
   git push origin feature/amazing-feature
   ```
7. Open a Pull Request

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Changes are tested manually
- [ ] Documentation is updated if needed
- [ ] Localization strings added for new UI text
- [ ] No breaking changes (or clearly documented)

### Review Process

- PRs require at least one approval
- Address review feedback promptly
- Keep PRs focused and reasonably sized

## Reporting Bugs

Open an issue on GitHub with:

- **macOS version** (e.g., macOS 14.2)
- **Weakup version** (if known)
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **Screenshots** (if applicable)
- **Console logs** (if available)

### Getting Console Logs

```bash
# Run app and capture output
./build/release/weakup 2>&1 | tee weakup.log
```

## Feature Requests

We welcome feature suggestions! Open an issue with:

- Clear description of the feature
- Use case / why it would be useful
- Any implementation ideas (optional)

### Roadmap Features

Check the README for planned features. PRs for roadmap items are especially welcome.

## Adding New Languages

See [docs/TRANSLATIONS.md](docs/TRANSLATIONS.md) for the complete translation guide.

Quick steps:
1. Create `Sources/Weakup/XX.lproj/Localizable.strings`
2. Add language to `AppLanguage` enum in `L10n.swift`
3. Update `build.sh` to copy new localization
4. Test thoroughly

## Questions?

- Open an issue for questions
- Check existing issues and documentation first
- Be patient - maintainers are volunteers

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

---

Thank you for contributing to Weakup!
