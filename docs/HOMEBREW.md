# Homebrew Installation

Weakup includes a cask for local testing, but it has not been accepted into the official Homebrew Cask repository.

> The v1.0.2 binary is Apple Silicon-only and is not signed or notarized with Apple Developer ID. Homebrew does not remove macOS Gatekeeper protections.

## Installation

### Official Homebrew Status

The following command is reserved for a future official submission and does **not** currently work:

```bash
brew install --cask weakup
```

### From GitHub Release

Download `Weakup-1.0.2.dmg` or `Weakup-1.0.2.zip` from the [latest GitHub release](https://github.com/Zzzode/weakup/releases/latest). After copying the app to Applications, Control-click it and choose **Open** for the first launch.

### From Local Formula

For development or testing:

```bash
# Clone the repository
git clone https://github.com/Zzzode/weakup.git
cd weakup

# Install v1.0.2 from the repository's versioned cask
brew install --cask ./homebrew/weakup.rb
```

## Updating

The official `brew upgrade --cask weakup` flow is unavailable until the cask is accepted upstream. For the local cask, pull repository updates and reinstall the versioned cask file.

## Uninstalling

```bash
brew uninstall --cask weakup
```

This will remove:
- `/Applications/Weakup.app`
- `~/Library/Preferences/com.weakup.app.plist`
- `~/Library/Caches/com.weakup.app`

## Submitting to Homebrew Cask

To submit Weakup to the official homebrew-cask repository:

1. **Fork** [homebrew-cask](https://github.com/Homebrew/homebrew-cask)

2. **Create a new branch**:
   ```bash
   git checkout -b add-weakup
   ```

3. **Copy the formula**:
   ```bash
   cp homebrew/weakup.rb Casks/w/weakup.rb
   ```

4. **Update the formula** with correct values:
   - Replace `Zzzode` with actual GitHub username
   - Update SHA256 with actual checksum
   - Verify version matches latest release

5. **Test the formula**:
   ```bash
   brew install --cask ./Casks/w/weakup.rb
   brew audit --cask weakup
   ```

6. **Submit a pull request** to homebrew-cask

### Formula Requirements

For acceptance into homebrew-cask, the app must:
- Be a macOS application
- Have a stable release on GitHub
- Be signed and notarized (recommended)
- Have a valid homepage
- Follow the [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)

## Troubleshooting

### "App is damaged" Error

If you see "Weakup.app is damaged and can't be opened":

```bash
# Remove quarantine attribute
xattr -cr /Applications/Weakup.app
```

### SHA256 Mismatch

If installation fails due to SHA256 mismatch:

```bash
# Get the correct SHA256
shasum -a 256 ~/Downloads/Weakup-*.zip

# Update the formula manually or use
./scripts/update-cask.sh
```

### Reinstalling

To force reinstall:

```bash
brew reinstall --cask weakup
```
