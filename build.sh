#!/bin/bash
set -e

# Build project
echo "Building Weakup..."
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
mkdir -p "$APP_PATH/Contents/Resources/en.lproj"
mkdir -p "$APP_PATH/Contents/Resources/zh-Hans.lproj"
cp "Sources/Weakup/en.lproj/Localizable.strings" "$APP_PATH/Contents/Resources/en.lproj/"
cp "Sources/Weakup/zh-Hans.lproj/Localizable.strings" "$APP_PATH/Contents/Resources/zh-Hans.lproj/"

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
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleLocalizations</key>
    <array>
        <string>en</string>
        <string>zh-Hans</string>
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

echo "Done! App created at: $APP_PATH"
echo "You can now run it with: open $APP_PATH"
