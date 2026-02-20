# Contributing to Weakup

Thank you for your interest in contributing to Weakup!

## Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/weakup.git
cd weakup

# Build the app
./build.sh

# Run
open Weakup.app
```

### Project Structure

```
Weakup/
├── Package.swift              # Swift Package configuration
├── build.sh                  # Build script
├── Sources/Weakup/
│   ├── main.swift           # Main application code
│   ├── L10n.swift           # Localization system
│   ├── en.lproj/           # English localization
│   └── zh-Hans.lproj/      # Chinese (Simplified) localization
└── Weakup.app/             # Built application
```

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI for UI components
- Keep functions focused and small
- Add comments for complex logic

### Adding New Languages

1. Create a new `.lproj` folder in `Sources/Weakup/`
2. Add `Localizable.strings` with translations
3. Add language to `AppLanguage` enum in `L10n.swift`
4. Add display name to `AppLanguage.displayName`

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Reporting Bugs

Please report bugs by opening an issue on GitHub and include:

- macOS version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshot if applicable
