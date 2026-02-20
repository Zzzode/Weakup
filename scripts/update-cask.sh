#!/bin/bash
# Update Homebrew Cask formula with correct SHA256
#
# Usage:
#   ./scripts/update-cask.sh                    # Use version from VERSION file
#   ./scripts/update-cask.sh 1.2.3              # Specify version
#   ./scripts/update-cask.sh --local            # Use local ZIP file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CASK_FILE="$PROJECT_DIR/homebrew/weakup.rb"

# Parse arguments
LOCAL_MODE=false
VERSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --local)
            LOCAL_MODE=true
            shift
            ;;
        *)
            VERSION="$1"
            shift
            ;;
    esac
done

# Get version
if [ -z "$VERSION" ]; then
    if [ -f "$PROJECT_DIR/VERSION" ]; then
        VERSION=$(cat "$PROJECT_DIR/VERSION" | tr -d '[:space:]')
    else
        VERSION="1.0.0"
    fi
fi

echo "=== Update Homebrew Cask ==="
echo "Version: $VERSION"

# Get SHA256
if [ "$LOCAL_MODE" = true ]; then
    ZIP_FILE="$PROJECT_DIR/Weakup-${VERSION}.zip"
    if [ ! -f "$ZIP_FILE" ]; then
        echo "Error: $ZIP_FILE not found"
        echo "Run ./build.sh first, then create the ZIP:"
        echo "  ditto -c -k --keepParent Weakup.app Weakup-${VERSION}.zip"
        exit 1
    fi
    SHA256=$(shasum -a 256 "$ZIP_FILE" | cut -d' ' -f1)
    echo "Local ZIP: $ZIP_FILE"
else
    # Download from GitHub releases
    URL="https://github.com/yourusername/weakup/releases/download/v${VERSION}/Weakup-${VERSION}.zip"
    echo "Downloading: $URL"

    TEMP_FILE=$(mktemp)
    if curl -fsSL "$URL" -o "$TEMP_FILE" 2>/dev/null; then
        SHA256=$(shasum -a 256 "$TEMP_FILE" | cut -d' ' -f1)
        rm -f "$TEMP_FILE"
    else
        echo "Error: Could not download release ZIP"
        echo "Make sure the release exists at: $URL"
        echo ""
        echo "For local testing, use: $0 --local"
        rm -f "$TEMP_FILE"
        exit 1
    fi
fi

echo "SHA256: $SHA256"

# Update Cask file
sed -i '' "s/version \".*\"/version \"$VERSION\"/" "$CASK_FILE"
sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/" "$CASK_FILE"

echo ""
echo "Updated: $CASK_FILE"
echo ""
echo "To test locally:"
echo "  brew install --cask $CASK_FILE"
echo ""
echo "To submit to homebrew-cask:"
echo "  1. Fork https://github.com/Homebrew/homebrew-cask"
echo "  2. Copy $CASK_FILE to Casks/w/weakup.rb"
echo "  3. Submit a pull request"
