# Weakup

<div align="center">

![Weakup](https://img.shields.io/badge/macOS-13%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)

A high-performance, lightweight macOS utility to prevent your Mac from sleeping.

</div>

## Features

- **One-Toggle Control** - Enable/disable sleep prevention with a single click
- **Menu Bar App** - Lives in menu bar, no dock clutter
- **Timer Mode** - Set auto-shutdown timer (15min, 30min, 1hr, 2hrs, 3hrs)
- **Visual Status** - Clear filled/empty power circle icon indicator
- **Keyboard Shortcut** - `Cmd + Ctrl + 0` to toggle anywhere
- **Native Performance** - Uses IOPMAssertion API for minimal overhead
- **Real-time Language Switch** - Switch between English and Chinese instantly without restart
- **SwiftUI + AppKit** - Modern, clean codebase

## Screenshots

| Settings (English) | Settings (中文) |
|--------------------|-------------------|
| ![English](screenshots/english.png) | ![Chinese](screenshots/chinese.png) |

## Installation

### From Source

```bash
# Clone the repository
git clone https://github.com/yourusername/weakup.git
cd weakup

# Build the app
./build.sh

# Run
open Weakup.app

# Or drag Weakup.app to your Applications folder
```

### Requirements

- macOS 13.0 or later
- Xcode Command Line Tools

## Usage

1. Click the menu bar icon to toggle sleep prevention
2. Click "Settings" / "设置" to access timer and language options
3. Use `Cmd + Ctrl + 0` keyboard shortcut to toggle from anywhere
4. Switch language instantly in the top-right corner of settings

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd + Ctrl + 0` | Toggle sleep prevention |

## Roadmap

- [ ] White/black theme support
- [ ] Custom timer duration
- [ ] macOS notification when timer expires
- [ ] Menu bar icon customization

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

[English](CONTRIBUTING.md) | [中文](CONTRIBUTING.zh.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Swift](https://swift.org)
- UI framework: [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Sleep prevention: [IOPMAssertion](https://developer.apple.com/documentation/iokit/iopmaassertioncreatewithname)

## Documentation

- [English Documentation](README.en.md)
- [中文文档](README.zh.md)
