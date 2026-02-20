#!/bin/bash
set -e

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
swift build -c release

# Create app bundle
APP_NAME="Weakup.app"
APP_PATH="$(pwd)/$APP_NAME"
BINARY_PATH=".build/release/weakup"

echo "Creating app bundle..."

# Remove existing app
rm -rf "$APP_PATH"

# Create app bundle structure
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources/Assets.xcassets/AppIcon.appiconset"

# Copy localization files
LANGUAGES=("en" "zh-Hans" "zh-Hant" "ja" "ko" "fr" "de" "es")
for lang in "${LANGUAGES[@]}"; do
    mkdir -p "$APP_PATH/Contents/Resources/${lang}.lproj"
    cp "Sources/Weakup/${lang}.lproj/Localizable.strings" "$APP_PATH/Contents/Resources/${lang}.lproj/"
done

# Copy binary
cp "$BINARY_PATH" "$APP_PATH/Contents/MacOS/weakup"
chmod +x "$APP_PATH/Contents/MacOS/weakup"

# Generate icons
echo "Generating icons..."
cat > /tmp/weakup_icon.svg << 'EOF'
<svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
  <rect width="1024" height="1024" fill="#1E1E1E" rx="200"/>
  <circle cx="512" cy="512" r="350" fill="#4CAF50" stroke="#3C3C3C" stroke-width="20"/>
  <text x="512" y="580" font-family="Arial" font-size="400" font-weight="bold" fill="#1E1E1E" text-anchor="middle">W</text>
</svg>
EOF

qlmanage -t -s 1024 -o "$APP_PATH/Contents/Resources/Assets.xcassets/AppIcon.appiconset" /tmp/weakup_icon.svg >/dev/null 2>&1
mv "$APP_PATH/Contents/Resources/Assets.xcassets/AppIcon.appiconset/weakup_icon.svg.png" \
   "$APP_PATH/Contents/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024.png" 2>/dev/null || true

# Generate all sizes
SIZES=(16 32 64 128 256 512 1024)
for size in "${SIZES[@]}"; do
    sips -z $size $size "$APP_PATH/Contents/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024.png" \
        --out "$APP_PATH/Contents/Resources/Assets.xcassets/AppIcon.appiconset/icon_${size}.png" >/dev/null 2>&1
done

# Create Contents.json for AppIcon
cat > "$APP_PATH/Contents/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {"idiom" : "mac", "scale" : "1x", "size" : "16x16", "filename" : "icon_16.png"},
    {"idiom" : "mac", "scale" : "2x", "size" : "16x16", "filename" : "icon_32.png"},
    {"idiom" : "mac", "scale" : "1x", "size" : "32x32", "filename" : "icon_32.png"},
    {"idiom" : "mac", "scale" : "2x", "size" : "32x32", "filename" : "icon_64.png"},
    {"idiom" : "mac", "scale" : "1x", "size" : "128x128", "filename" : "icon_128.png"},
    {"idiom" : "mac", "scale" : "2x", "size" : "128x128", "filename" : "icon_256.png"},
    {"idiom" : "mac", "scale" : "1x", "size" : "256x256", "filename" : "icon_256.png"},
    {"idiom" : "mac", "scale" : "2x", "size" : "256x256", "filename" : "icon_512.png"},
    {"idiom" : "mac", "scale" : "1x", "size" : "512x512", "filename" : "icon_512.png"},
    {"idiom" : "mac", "scale" : "2x", "size" : "512x512", "filename" : "icon_1024.png"}
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

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

# Clean up temp file
rm -f /tmp/weakup_icon.svg

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
