# Homebrew Installation

Weakup can be installed via Homebrew Cask.

## Installation

### From Official Homebrew (Coming Soon)

Once accepted into homebrew-cask:

```bash
brew install --cask weakup
```

### From GitHub Release

Until the formula is accepted into homebrew-cask, you can install directly:

```bash
# Download the latest release
curl -LO https://github.com/yourusername/weakup/releases/latest/download/Weakup-1.0.0.zip

# Extract and install
unzip Weakup-1.0.0.zip
mv Weakup.app /Applications/
```

### From Local Formula

For development or testing:

```bash
# Clone the repository
git clone https://github.com/yourusername/weakup.git
cd weakup

# Build the app
./build.sh

# Create ZIP
ditto -c -k --keepParent Weakup.app Weakup-1.0.0.zip

# Update the cask formula with correct SHA256
./scripts/update-cask.sh --local

# Install via Homebrew
brew install --cask ./homebrew/weakup.rb
```

## Updating

```bash
brew upgrade --cask weakup
```

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
   - Replace `yourusername` with actual GitHub username
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
