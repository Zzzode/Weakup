#!/bin/bash
# Code signing and notarization script for Weakup
#
# Usage:
#   ./scripts/sign.sh                    # Sign with default identity
#   ./scripts/sign.sh --notarize         # Sign and notarize for distribution
#   ./scripts/sign.sh --adhoc            # Ad-hoc signing (local testing)
#
# Environment variables:
#   CODESIGN_IDENTITY    - Signing identity (default: searches for "Developer ID Application")
#   APPLE_ID             - Apple ID for notarization
#   APPLE_PASSWORD       - App-specific password for notarization
#   APPLE_TEAM_ID        - Team ID for notarization

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_PATH="$PROJECT_DIR/Weakup.app"

# Parse arguments
NOTARIZE=false
ADHOC=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --notarize)
            NOTARIZE=true
            shift
            ;;
        --adhoc)
            ADHOC=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--notarize] [--adhoc]"
            exit 1
            ;;
    esac
done

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "Error: Weakup.app not found. Run ./build.sh first."
    exit 1
fi

# Determine signing identity
if [ "$ADHOC" = true ]; then
    IDENTITY="-"
    echo "Using ad-hoc signing (local testing only)"
elif [ -n "$CODESIGN_IDENTITY" ]; then
    IDENTITY="$CODESIGN_IDENTITY"
else
    # Try to find a Developer ID Application certificate
    IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed 's/.*"\(.*\)".*/\1/' || true)
    if [ -z "$IDENTITY" ]; then
        echo "Error: No signing identity found."
        echo "Set CODESIGN_IDENTITY or use --adhoc for local testing."
        echo ""
        echo "Available identities:"
        security find-identity -v -p codesigning
        exit 1
    fi
fi

echo "=== Weakup Code Signing ==="
echo "App: $APP_PATH"
echo "Identity: $IDENTITY"
echo ""

# Remove existing signatures
echo "Removing existing signatures..."
codesign --remove-signature "$APP_PATH" 2>/dev/null || true

# Sign the binary
echo "Signing binary..."
codesign --force --options runtime --timestamp \
    --sign "$IDENTITY" \
    --entitlements "$PROJECT_DIR/Sources/Weakup/Weakup.entitlements" \
    "$APP_PATH/Contents/MacOS/weakup"

# Sign the app bundle
echo "Signing app bundle..."
codesign --force --options runtime --timestamp \
    --sign "$IDENTITY" \
    --entitlements "$PROJECT_DIR/Sources/Weakup/Weakup.entitlements" \
    "$APP_PATH"

# Verify signature
echo ""
echo "Verifying signature..."
codesign --verify --verbose=2 "$APP_PATH"

# Check Gatekeeper assessment (skip for ad-hoc)
if [ "$ADHOC" != true ]; then
    echo ""
    echo "Checking Gatekeeper assessment..."
    spctl --assess --type execute --verbose=2 "$APP_PATH" 2>&1 || echo "Note: Gatekeeper check may fail without notarization"
fi

echo ""
echo "Signature details:"
codesign -dv --verbose=4 "$APP_PATH" 2>&1 | head -20

# Notarization
if [ "$NOTARIZE" = true ]; then
    echo ""
    echo "=== Notarization ==="

    # Check required environment variables
    if [ -z "$APPLE_ID" ] || [ -z "$APPLE_PASSWORD" ] || [ -z "$APPLE_TEAM_ID" ]; then
        echo "Error: Notarization requires APPLE_ID, APPLE_PASSWORD, and APPLE_TEAM_ID"
        echo "  APPLE_ID       - Your Apple ID email"
        echo "  APPLE_PASSWORD - App-specific password (create at appleid.apple.com)"
        echo "  APPLE_TEAM_ID  - Your team ID"
        exit 1
    fi

    # Create ZIP for notarization
    ZIP_PATH="$PROJECT_DIR/Weakup-notarize.zip"
    echo "Creating ZIP for notarization..."
    ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

    # Submit for notarization
    echo "Submitting for notarization..."
    xcrun notarytool submit "$ZIP_PATH" \
        --apple-id "$APPLE_ID" \
        --password "$APPLE_PASSWORD" \
        --team-id "$APPLE_TEAM_ID" \
        --wait

    # Staple the notarization ticket
    echo "Stapling notarization ticket..."
    xcrun stapler staple "$APP_PATH"

    # Verify stapling
    echo "Verifying stapled app..."
    xcrun stapler validate "$APP_PATH"

    # Clean up
    rm -f "$ZIP_PATH"

    echo ""
    echo "Notarization complete!"
fi

echo ""
echo "=== Done ==="
echo "Signed app: $APP_PATH"
