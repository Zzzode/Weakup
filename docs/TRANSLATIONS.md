# Translation Guide

This guide explains how to add new language support to Weakup.

## Current Languages

| Language | Code | File |
|----------|------|------|
| English | `en` | `Sources/Weakup/en.lproj/Localizable.strings` |
| Chinese (Simplified) | `zh-Hans` | `Sources/Weakup/zh-Hans.lproj/Localizable.strings` |
| Chinese (Traditional) | `zh-Hant` | `Sources/Weakup/zh-Hant.lproj/Localizable.strings` |
| Japanese | `ja` | `Sources/Weakup/ja.lproj/Localizable.strings` |
| Korean | `ko` | `Sources/Weakup/ko.lproj/Localizable.strings` |
| French | `fr` | `Sources/Weakup/fr.lproj/Localizable.strings` |
| German | `de` | `Sources/Weakup/de.lproj/Localizable.strings` |
| Spanish | `es` | `Sources/Weakup/es.lproj/Localizable.strings` |

## Adding a New Language

### Step 1: Create Language Directory

Create a new `.lproj` folder for your language:

```bash
mkdir -p Sources/Weakup/XX.lproj
```

Replace `XX` with the appropriate language code:
- `fr` - French
- `de` - German
- `ja` - Japanese
- `ko` - Korean
- `es` - Spanish
- `pt-BR` - Portuguese (Brazil)
- `zh-Hant` - Chinese (Traditional)

### Step 2: Create Localizable.strings

Copy the English strings file and translate:

```bash
cp Sources/Weakup/en.lproj/Localizable.strings Sources/Weakup/XX.lproj/
```

Edit the new file with translations.

### Step 3: Update L10n.swift

Add the new language to the `AppLanguage` enum in `Sources/WeakupCore/Utilities/L10n.swift`:

```swift
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh-Hans"
    case french = "fr"  // Add new case

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        case .french: return "Francais"  // Add display name
        }
    }
    // ...
}
```

### Step 4: Update build.sh

Add the new language to the build script:

```bash
# Copy localization files
mkdir -p "$APP_PATH/Contents/Resources/XX.lproj"
cp "Sources/Weakup/XX.lproj/Localizable.strings" "$APP_PATH/Contents/Resources/XX.lproj/"
```

### Step 5: Update Info.plist

The build script generates Info.plist. Add your language code to `CFBundleLocalizations`:

```xml
<key>CFBundleLocalizations</key>
<array>
    <string>en</string>
    <string>zh-Hans</string>
    <string>XX</string>  <!-- Add new language -->
</array>
```

## String Keys Reference

All translatable strings and their context:

### App Strings

| Key | English | Context |
|-----|---------|---------|
| `app_name` | Weakup | App name (usually not translated) |

### Menu Strings

| Key | English | Context |
|-----|---------|---------|
| `menu_settings` | Settings | Menu item to open settings |
| `menu_quit` | Quit Weakup | Menu item to quit the app |

### Status Strings

| Key | English | Context |
|-----|---------|---------|
| `status_on` | Weakup: On | Tooltip when active |
| `status_off` | Weakup: Off | Tooltip when inactive |
| `status_preventing` | Preventing Sleep | Status text when active |
| `status_sleep_enabled` | Sleep Enabled | Status text when inactive |

### Settings Strings

| Key | English | Context |
|-----|---------|---------|
| `timer_mode` | Timer Mode | Toggle label |
| `duration` | Duration | Picker label |
| `duration_off` | Off | Duration option |
| `duration_15m` | 15m | Duration option |
| `duration_30m` | 30m | Duration option |
| `duration_1h` | 1h | Duration option |
| `duration_2h` | 2h | Duration option |
| `duration_3h` | 3h | Duration option |

### Action Strings

| Key | English | Context |
|-----|---------|---------|
| `turn_on` | Turn On | Button text |
| `turn_off` | Turn Off | Button text |

### Hint Strings

| Key | English | Context |
|-----|---------|---------|
| `shortcut_hint` | Cmd + Ctrl + 0 to toggle | Keyboard shortcut hint |

## Translation File Format

The `.strings` file uses this format:

```
/* Comment describing the string */
"key" = "Translated value";
```

Example for French:

```
/* French Localization */

// App
"app_name" = "Weakup";

// Menu
"menu_settings" = "Parametres";
"menu_quit" = "Quitter Weakup";

// Status
"status_on" = "Weakup: Active";
"status_off" = "Weakup: Desactive";
"status_preventing" = "Veille desactivee";
"status_sleep_enabled" = "Veille activee";

// Settings
"timer_mode" = "Mode minuterie";
"duration" = "Duree";
"duration_off" = "Desactive";
"duration_15m" = "15 min";
"duration_30m" = "30 min";
"duration_1h" = "1 h";
"duration_2h" = "2 h";
"duration_3h" = "3 h";

// Actions
"turn_on" = "Activer";
"turn_off" = "Desactiver";

// Hints
"shortcut_hint" = "Cmd + Ctrl + 0 pour basculer";
```

## Translation Guidelines

### General Rules

1. **Keep it concise** - Menu bar space is limited
2. **Be consistent** - Use the same terms throughout
3. **Match platform conventions** - Use standard macOS terminology
4. **Test in context** - Verify strings fit in the UI

### Platform Terminology

Use standard macOS terms for your language:

| English | Concept |
|---------|---------|
| Settings | System preferences/settings |
| Quit | Standard app quit action |
| Sleep | System sleep/standby |

### Character Considerations

- Ensure special characters are properly encoded (UTF-8)
- Test with different character widths (CJK vs Latin)
- Verify right-to-left languages display correctly (future support)

## Testing Translations

### Build and Test

```bash
# Rebuild with new translations
./build.sh

# Run the app
open Weakup.app

# Switch to your language in Settings
```

### Verify All Strings

Check that all strings are translated:

```bash
# Count keys in each file
wc -l Sources/Weakup/*/Localizable.strings
```

All files should have the same number of lines.

### Check for Missing Keys

```bash
# Extract keys from English
grep -o '^"[^"]*"' Sources/Weakup/en.lproj/Localizable.strings | sort > /tmp/en_keys.txt

# Extract keys from your translation
grep -o '^"[^"]*"' Sources/Weakup/XX.lproj/Localizable.strings | sort > /tmp/xx_keys.txt

# Compare
diff /tmp/en_keys.txt /tmp/xx_keys.txt
```

## Submitting Translations

1. Fork the repository
2. Create a branch: `git checkout -b translation/XX`
3. Add your translation files
4. Update `L10n.swift` and `build.sh`
5. Test thoroughly
6. Submit a pull request

### Pull Request Checklist

- [ ] All strings translated
- [ ] `AppLanguage` enum updated
- [ ] `build.sh` updated
- [ ] Tested in app
- [ ] No encoding issues
- [ ] Strings fit in UI

## Questions?

Open an issue on GitHub if you have questions about translations.
