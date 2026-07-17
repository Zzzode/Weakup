#!/bin/bash
set -e

SWIFT_CMD=${SWIFT_CMD:-"xcrun swift"}
SWIFT_VERSION_FILE="$(pwd)/.swift-version"

version_at_least() {
    local current="$1"
    local required="$2"
    local current_major current_minor current_patch
    local required_major required_minor required_patch

    IFS=. read -r current_major current_minor current_patch <<< "$current"
    IFS=. read -r required_major required_minor required_patch <<< "$required"

    (( current_major > required_major )) ||
        (( current_major == required_major && current_minor > required_minor )) ||
        (( current_major == required_major && current_minor == required_minor && current_patch >= required_patch ))
}

if [ -f "$SWIFT_VERSION_FILE" ]; then
    MINIMUM_SWIFT_VERSION=$(tr -d '[:space:]' < "$SWIFT_VERSION_FILE")
    CURRENT_SWIFT_VERSION=$($SWIFT_CMD --version | awk '/Apple Swift version/ {print $4}')
    if ! version_at_least "$CURRENT_SWIFT_VERSION" "$MINIMUM_SWIFT_VERSION"; then
        echo "Swift version too old. Minimum: $MINIMUM_SWIFT_VERSION, Current: $CURRENT_SWIFT_VERSION"
        echo "Set SWIFT_CMD to a Swift $MINIMUM_SWIFT_VERSION or later toolchain"
        exit 1
    fi
fi

# Read version from VERSION file
VERSION_FILE="$(pwd)/VERSION"
if [ -f "$VERSION_FILE" ]; then
    APP_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
else
    APP_VERSION="1.0.0"
fi

# Extract version components
VERSION_MAJOR=$(echo "$APP_VERSION" | cut -d. -f1)
VERSION_MINOR=$(echo "$APP_VERSION" | cut -d. -f2)
VERSION_PATCH=$(echo "$APP_VERSION" | cut -d. -f3)

# Build number (can be overridden via BUILD_NUMBER env var)
BUILD_NUMBER="${BUILD_NUMBER:-1}"

echo "Building Weakup v$APP_VERSION (build $BUILD_NUMBER)..."

# Build project
$SWIFT_CMD build -c release --disable-sandbox

# Create app bundle
APP_NAME="Weakup.app"
APP_PATH="$(pwd)/$APP_NAME"
BINARY_PATH=".build/release/weakup"

echo "Creating app bundle..."

# Remove existing app
rm -rf "$APP_PATH"

# Create app bundle structure
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Copy localization files
LANGUAGES=("en" "zh-Hans" "zh-Hant" "ja" "ko" "fr" "de" "es")
for lang in "${LANGUAGES[@]}"; do
    mkdir -p "$APP_PATH/Contents/Resources/${lang}.lproj"
    cp "Sources/Weakup/${lang}.lproj/Localizable.strings" "$APP_PATH/Contents/Resources/${lang}.lproj/"
done

# Copy binary
cp "$BINARY_PATH" "$APP_PATH/Contents/MacOS/weakup"
chmod +x "$APP_PATH/Contents/MacOS/weakup"

# Generate the native macOS icon from the tracked 1024 px source asset.
echo "Generating app icon..."
ICON_SOURCE="$(pwd)/Assets/AppIcon.png"
ICONSET_PATH="$APP_PATH/Contents/Resources/AppIcon.iconset"
if [ ! -f "$ICON_SOURCE" ]; then
    echo "Error: App icon source not found at $ICON_SOURCE"
    exit 1
fi

mkdir -p "$ICONSET_PATH"
sips -z 16 16 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_16x16.png" >/dev/null
sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_16x16@2x.png" >/dev/null
sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_32x32.png" >/dev/null
sips -z 64 64 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_32x32@2x.png" >/dev/null
sips -z 128 128 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_128x128.png" >/dev/null
sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_128x128@2x.png" >/dev/null
sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_256x256.png" >/dev/null
sips -z 512 512 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_512x512.png" >/dev/null
cp "$ICON_SOURCE" "$ICONSET_PATH/icon_512x512@2x.png"
iconutil -c icns "$ICONSET_PATH" -o "$APP_PATH/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET_PATH"

# Create Info.plist
cat > "$APP_PATH/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>weakup</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.weakup.app</string>
    <key>CFBundleName</key>
    <string>Weakup</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$APP_VERSION</string>
    <key>CFBundleVersion</key>
    <string>$BUILD_NUMBER</string>
    <key>CFBundleLocalizations</key>
    <array>
        <string>en</string>
        <string>zh-Hans</string>
        <string>zh-Hant</string>
        <string>ja</string>
        <string>ko</string>
        <string>fr</string>
        <string>de</string>
        <string>es</string>
    </array>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Code signing (optional)
# Set CODESIGN_IDENTITY to sign the app, e.g.:
#   CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./build.sh
# Or use "-" for ad-hoc signing (local testing only)
if [ -n "$CODESIGN_IDENTITY" ]; then
    echo "Signing app with identity: $CODESIGN_IDENTITY"

    # Sign the binary first
    codesign --force --options runtime --timestamp \
        --sign "$CODESIGN_IDENTITY" \
        "$APP_PATH/Contents/MacOS/weakup"

    # Sign the app bundle
    codesign --force --options runtime --timestamp \
        --sign "$CODESIGN_IDENTITY" \
        "$APP_PATH"

    # Verify signature
    echo "Verifying signature..."
    codesign --verify --verbose=2 "$APP_PATH"

    echo "App signed successfully!"
else
    echo "Note: App is not code signed. Set CODESIGN_IDENTITY to sign."
    echo "  For ad-hoc signing: CODESIGN_IDENTITY='-' ./build.sh"
    echo "  For distribution:   CODESIGN_IDENTITY='Developer ID Application: ...' ./build.sh"
fi

echo ""
echo "Done! App created at: $APP_PATH"
echo "You can now run it with: open $APP_PATH"
