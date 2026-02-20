# Code Signing Guide

This guide explains how to code sign Weakup for distribution.

## Overview

macOS requires apps to be code signed for:
- **Gatekeeper**: Allows users to run the app without security warnings
- **Notarization**: Required for distribution outside the Mac App Store on macOS 10.15+
- **Hardened Runtime**: Security feature that protects against code injection

## Quick Start

### Local Development (Ad-hoc Signing)

For local testing, use ad-hoc signing:

```bash
CODESIGN_IDENTITY='-' ./build.sh
```

Or use the signing script:

```bash
./scripts/sign.sh --adhoc
```

### Distribution Signing

For distribution, you need an Apple Developer account and a "Developer ID Application" certificate.

1. **Get a Developer ID Certificate**:
   - Join the [Apple Developer Program](https://developer.apple.com/programs/)
   - In Xcode: Preferences > Accounts > Manage Certificates > + > Developer ID Application

2. **Sign the app**:
   ```bash
   # Auto-detect certificate
   ./scripts/sign.sh

   # Or specify identity
   CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./build.sh
   ```

## Notarization

Notarization is required for distribution on macOS 10.15+. Apple scans your app for malware and issues a "ticket" that Gatekeeper recognizes.

### Prerequisites

1. **Apple ID** with two-factor authentication enabled
2. **App-specific password**: Create at [appleid.apple.com](https://appleid.apple.com) > Security > App-Specific Passwords
3. **Team ID**: Found in your Apple Developer account

### Notarize the App

```bash
export APPLE_ID="your@email.com"
export APPLE_PASSWORD="xxxx-xxxx-xxxx-xxxx"  # App-specific password
export APPLE_TEAM_ID="XXXXXXXXXX"

./scripts/sign.sh --notarize
```

The script will:
1. Sign the app with hardened runtime
2. Create a ZIP archive
3. Submit to Apple for notarization
4. Wait for approval (usually 5-15 minutes)
5. Staple the notarization ticket to the app

### Manual Notarization

If you prefer manual control:

```bash
# Create ZIP
ditto -c -k --keepParent Weakup.app Weakup.zip

# Submit for notarization
xcrun notarytool submit Weakup.zip \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_PASSWORD" \
    --team-id "$APPLE_TEAM_ID" \
    --wait

# Staple the ticket
xcrun stapler staple Weakup.app
```

## Verification

### Check Signature

```bash
# Verify code signature
codesign --verify --verbose=2 Weakup.app

# Show signature details
codesign -dv --verbose=4 Weakup.app
```

### Check Gatekeeper

```bash
# Check if Gatekeeper will allow the app
spctl --assess --type execute --verbose=2 Weakup.app
```

### Check Notarization

```bash
# Verify notarization ticket is stapled
xcrun stapler validate Weakup.app
```

## CI/CD Integration

For GitHub Actions, store your credentials as secrets:

- `APPLE_CERTIFICATE_BASE64`: Base64-encoded .p12 certificate
- `APPLE_CERTIFICATE_PASSWORD`: Password for the .p12 file
- `APPLE_ID`: Your Apple ID
- `APPLE_PASSWORD`: App-specific password
- `APPLE_TEAM_ID`: Your team ID

See `.github/workflows/release.yml` for the release workflow.

### Exporting Your Certificate

```bash
# Export from Keychain (will prompt for password)
security export -k ~/Library/Keychains/login.keychain-db \
    -t identities -f pkcs12 -o certificate.p12

# Base64 encode for GitHub secrets
base64 -i certificate.p12 | pbcopy
```

## Troubleshooting

### "App is damaged and can't be opened"

This usually means the app isn't properly signed or notarized:

```bash
# Remove quarantine attribute (for testing only)
xattr -cr Weakup.app

# Re-sign the app
./scripts/sign.sh
```

### "Developer cannot be verified"

The app is signed but not notarized. Either:
- Notarize the app: `./scripts/sign.sh --notarize`
- Users can allow it: System Preferences > Security & Privacy > "Open Anyway"

### Notarization Fails

Check the notarization log:

```bash
xcrun notarytool log <submission-id> \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_PASSWORD" \
    --team-id "$APPLE_TEAM_ID"
```

Common issues:
- Missing hardened runtime
- Unsigned nested code
- Invalid entitlements

## Entitlements

Weakup uses minimal entitlements defined in `Sources/Weakup/Weakup.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
</dict>
</plist>
```

**Note**: App Sandbox is disabled because the IOPMAssertion API (used to prevent sleep) requires direct system access.

## Resources

- [Apple Code Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/)
- [Notarizing macOS Software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Hardened Runtime](https://developer.apple.com/documentation/security/hardened_runtime)
