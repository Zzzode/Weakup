# Homebrew Installation

Weakup is not currently available through Homebrew. The repository cask is retained for future packaging work, but it is not a supported installation method.

> The v1.0.2 binary is unsigned, not notarized, and fails strict signature validation. Installing it through Homebrew does not make it usable.

## Installation

### Official Homebrew Status

The following command is reserved for a future official submission and does **not** currently work:

```bash
brew install --cask weakup
```

### Supported Alternative

Build Weakup locally from the stable source tag:

```bash
# Clone the repository
git clone --branch v1.0.3 --depth 1 https://github.com/Zzzode/weakup.git
cd weakup
./build.sh
open Weakup.app
```

## Updating

Homebrew update support will become available only after Weakup has a signed, notarized release and its cask is accepted upstream.

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
