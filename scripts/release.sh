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
cd "$PROJECT_DIR"

ONE_CLICK=false
TAG_NOW=false
PACKAGE_DMG=false
BRANCH_PREFIX="release"
POSITIONAL=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --one-click)
            ONE_CLICK=true
            shift
            ;;
        --tag-now)
            TAG_NOW=true
            shift
            ;;
        --package-dmg)
            PACKAGE_DMG=true
            shift
            ;;
        --branch-prefix)
            if [ -z "$2" ]; then
                echo "Error: --branch-prefix requires a value"
                exit 1
            fi
            BRANCH_PREFIX="$2"
            shift 2
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL[@]}"

if [ -n "$(git status --porcelain)" ]; then
    echo "Error: Working tree is not clean."
    exit 1
fi

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
        echo "Usage: $0 [options] <patch|minor|major|version>"
        echo ""
        echo "Options:"
        echo "  --one-click"
        echo "  --tag-now"
        echo "  --branch-prefix <name>"
        echo "  --package-dmg"
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

RELEASE_BRANCH="$BRANCH_PREFIX/$NEW_VERSION"
BASE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if [ "$ONE_CLICK" = true ]; then
    if [ "$BASE_BRANCH" = "$RELEASE_BRANCH" ]; then
        echo "Using existing release branch: $RELEASE_BRANCH"
    else
        if git show-ref --verify --quiet "refs/heads/$RELEASE_BRANCH"; then
            git checkout "$RELEASE_BRANCH"
        else
            git checkout -b "$RELEASE_BRANCH"
        fi
    fi
    echo ""
fi

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

if [ "$PACKAGE_DMG" = true ]; then
    if [ -z "$APPLE_ID" ] || [ -z "$APPLE_PASSWORD" ] || [ -z "$APPLE_TEAM_ID" ]; then
        echo "Error: DMG notarization requires APPLE_ID, APPLE_PASSWORD, and APPLE_TEAM_ID"
        exit 1
    fi
    ./build.sh
    ./scripts/sign.sh --notarize
    DMG_PATH="$PROJECT_DIR/Weakup-$NEW_VERSION.dmg"
    hdiutil create -volname "Weakup" -srcfolder "$PROJECT_DIR/Weakup.app" -ov -format UDZO "$DMG_PATH"
    xcrun notarytool submit "$DMG_PATH" \
        --apple-id "$APPLE_ID" \
        --password "$APPLE_PASSWORD" \
        --team-id "$APPLE_TEAM_ID" \
        --wait
    xcrun stapler staple "$DMG_PATH"
    xcrun stapler validate "$DMG_PATH"
    echo ""
    echo "DMG created: $DMG_PATH"
    echo ""
fi

echo ""
echo "Creating git commit..."

git add VERSION CHANGELOG.md
git commit -m "Release v$NEW_VERSION"

if [ "$TAG_NOW" = true ]; then
    git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"
fi

echo ""
echo "=== Done ==="
echo ""

if [ "$ONE_CLICK" = true ]; then
    git push -u origin "$RELEASE_BRANCH"
    if ! command -v gh >/dev/null 2>&1; then
        echo "Error: GitHub CLI (gh) not found. Install gh or complete PR/merge/tag manually."
        exit 1
    fi
    if ! gh pr view "$RELEASE_BRANCH" >/dev/null 2>&1; then
        gh pr create --base main --head "$RELEASE_BRANCH" --fill
    fi
    gh pr merge --rebase --delete-branch
    git fetch origin main
    git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION" "origin/main"
    git push origin "v$NEW_VERSION"
    echo ""
    echo "Release published via tag v$NEW_VERSION."
    exit 0
fi

if [ "$TAG_NOW" = true ]; then
    echo "To publish the release:"
    echo "  git push origin $BASE_BRANCH"
    echo "  git push origin v$NEW_VERSION"
    echo ""
    echo "Pushing the tag will trigger the GitHub Actions release workflow."
    exit 0
fi

echo "To publish the release with rebase-merge:"
echo "  git push origin $BASE_BRANCH"
echo "  Open PR: $BASE_BRANCH -> main and merge (rebase)"
echo "  git fetch origin main"
echo "  git tag -a \"v$NEW_VERSION\" -m \"Release v$NEW_VERSION\" origin/main"
echo "  git push origin v$NEW_VERSION"
echo ""
echo "Pushing the tag will trigger the GitHub Actions release workflow."
