#!/bin/bash
# Release script for Weakup
#
# Usage:
#   ./scripts/release.sh patch    # 1.0.0 -> 1.0.1
#   ./scripts/release.sh minor    # 1.0.0 -> 1.1.0
#   ./scripts/release.sh major    # 1.0.0 -> 2.0.0
#   ./scripts/release.sh 1.2.3    # Set specific version

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_DIR/VERSION"

# Read current version
if [ -f "$VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
else
    CURRENT_VERSION="1.0.0"
fi

# Parse current version
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Determine new version
case "$1" in
    patch)
        PATCH=$((PATCH + 1))
        NEW_VERSION="$MAJOR.$MINOR.$PATCH"
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        NEW_VERSION="$MAJOR.$MINOR.$PATCH"
        ;;
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        NEW_VERSION="$MAJOR.$MINOR.$PATCH"
        ;;
    "")
        echo "Usage: $0 <patch|minor|major|version>"
        echo ""
        echo "Current version: $CURRENT_VERSION"
        exit 1
        ;;
    *)
        # Validate version format
        if [[ ! "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "Error: Invalid version format. Use X.Y.Z"
            exit 1
        fi
        NEW_VERSION="$1"
        ;;
esac

echo "=== Weakup Release ==="
echo "Current version: $CURRENT_VERSION"
echo "New version:     $NEW_VERSION"
echo ""

# Confirm
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Update VERSION file
echo "$NEW_VERSION" > "$VERSION_FILE"
echo "Updated VERSION file"

# Update CHANGELOG.md - rename [Unreleased] to [version]
if [ -f "$PROJECT_DIR/CHANGELOG.md" ]; then
    DATE=$(date +%Y-%m-%d)
    sed -i '' "s/## \[Unreleased\]/## [$NEW_VERSION] - $DATE/" "$PROJECT_DIR/CHANGELOG.md"

    # Add new Unreleased section at the top
    sed -i '' "/^# Changelog/a\\
\\
## [Unreleased]\\
" "$PROJECT_DIR/CHANGELOG.md"
    echo "Updated CHANGELOG.md"
fi

# Git operations
cd "$PROJECT_DIR"

echo ""
echo "Creating git commit and tag..."

git add VERSION CHANGELOG.md
git commit -m "Release v$NEW_VERSION"
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

echo ""
echo "=== Done ==="
echo ""
echo "To publish the release:"
echo "  git push origin main"
echo "  git push origin v$NEW_VERSION"
echo ""
echo "This will trigger the GitHub Actions release workflow."
