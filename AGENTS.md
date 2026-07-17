# Repository Guidelines

## Project Structure & Module Organization

Weakup is a Swift 6 macOS 13+ menu-bar application managed with Swift Package Manager. `Sources/Weakup/` contains the SwiftUI/AppKit application target, lifecycle code, views, entitlements, and localized `.lproj` resources. Keep reusable business logic in `Sources/WeakupCore/`, organized into `ViewModels/`, `Models/`, `Protocols/`, and `Utilities/`. Unit and integration tests live in `Tests/WeakupTests/`; shared mocks belong in `Mocks/`, while scenario tests belong in `Integration/`. XCTest UI tests are kept separately in `Tests/WeakupUITests/` and run through Xcode. Supporting guides are under `docs/`, automation under `scripts/`, and generated `.build/` and `Weakup.app/` artifacts should not be committed.

## Build, Test, and Development Commands

- `swift build` builds a debug binary for quick iteration.
- `swift build -c release` builds the optimized executable.
- `./build.sh` creates the complete `Weakup.app` bundle, including localizations and icons.
- `open Weakup.app` launches the bundled application; `.build/debug/weakup` runs the debug binary directly.
- `swift test` runs Swift Testing unit and integration suites.
- `swift test --filter CaffeineViewModelTests` runs one suite.
- `swift test --enable-code-coverage` collects WeakupCore coverage; CI expects an 80% project threshold.
- `./scripts/format.sh` applies SwiftFormat and runs SwiftLint.

Use the Swift version recorded in `.swift-version`. Some app behavior requires a proper bundle, so validate UI or localization changes with `./build.sh`.

## Coding Style & Naming Conventions

Use four-space indentation, same-line braces, alphabetized imports, and a 120-column target as configured in `.swiftformat`. Follow Swift API Design Guidelines: types use `UpperCamelCase`; methods, properties, and test functions use `lowerCamelCase`. Keep SwiftUI views small and logic in `WeakupCore`. Use `Logger`, `Constants`, and `UserDefaultsKeys` instead of `print()`, duplicated literals, or raw preference keys. Add every user-facing string to all eight localization files and expose it through `L10n`.

## Testing Guidelines

Write unit and integration tests with Swift Testing (`@Suite`, `@Test`, `#expect`); name files `FeatureTests.swift`. Place XCUITest-only coverage in `WeakupUITests`. Test success, failure, persistence, and timer boundaries, using mocks rather than macOS services where possible. Run `swift test` before every pull request and manually verify menu-bar, hotkey, notification, and localization changes.

## Commit & Pull Request Guidelines

Recent history uses Conventional Commit prefixes such as `feat:`, `fix(ci):`, `test:`, and `docs:`; keep subjects imperative and focused. Branches follow patterns such as `feature/description`, `fix/description`, or `docs/description`. Pull requests should explain the change and verification performed, link relevant issues, include screenshots for UI updates, update documentation/localizations when needed, and remain small enough for focused review. At least one approval is required.
