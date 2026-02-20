# Screenshots

This directory contains screenshots for the Weakup README and documentation.

## Required Screenshots

| Filename | Description |
|----------|-------------|
| `english.png` | Settings view in English |
| `chinese.png` | Settings view in Chinese (Simplified) |
| `menubar.png` | Menu bar with Weakup icon |
| `timer-active.png` | Timer countdown active |
| `dark-theme.png` | Settings view in dark theme |
| `light-theme.png` | Settings view in light theme |

## Generating Screenshots

### Manual Method

1. Build and run the app:
   ```bash
   ./build.sh
   open Weakup.app
   ```

2. Take screenshots using:
   - `Cmd + Shift + 4` then `Space` to capture a window
   - Or use the Screenshot app (`Cmd + Shift + 5`)

3. Save screenshots to this directory with the filenames listed above.

### Recommended Settings

- **Resolution:** Retina display recommended (2x)
- **Format:** PNG
- **Size:** Approximately 480x400 pixels for settings views
- **Background:** Clean desktop background

### Screenshot Checklist

- [ ] English settings view (default state)
- [ ] Chinese settings view (switch language first)
- [ ] Menu bar icon (crop to show just the menu bar area)
- [ ] Timer active with countdown visible
- [ ] Dark theme settings
- [ ] Light theme settings

## Tips

- Use a clean desktop background
- Close other menu bar items if possible
- Ensure the popover is fully visible
- Capture at 2x resolution for crisp images
