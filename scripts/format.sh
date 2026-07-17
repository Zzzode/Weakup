#!/bin/bash
# Format and lint Swift code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

SWIFT_VERSION_FILE="$PROJECT_DIR/.swift-version"

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
    CURRENT_SWIFT_VERSION=$(swift --version | awk '/Apple Swift version/ {print $4}')
    if ! version_at_least "$CURRENT_SWIFT_VERSION" "$MINIMUM_SWIFT_VERSION"; then
        echo "Swift version too old. Minimum: $MINIMUM_SWIFT_VERSION, Current: $CURRENT_SWIFT_VERSION"
        echo "Use mise: mise install swift@$MINIMUM_SWIFT_VERSION && mise use swift@$MINIMUM_SWIFT_VERSION"
        exit 1
    fi
fi

if command -v swiftformat &> /dev/null; then
    echo "Running SwiftFormat..."
    swiftformat Sources --config .swiftformat
    echo "SwiftFormat completed."
else
    echo "SwiftFormat not installed."
    if command -v brew &> /dev/null; then
        echo "Attempting to install SwiftFormat via Homebrew..."
        set +e
        brew install swiftformat
        INSTALL_STATUS=$?
        brew postinstall swiftformat
        brew link swiftformat
        set -e
        if command -v swiftformat &> /dev/null; then
            if [ $INSTALL_STATUS -ne 0 ]; then
                echo "SwiftFormat installed with warnings. Running formatter..."
            else
                echo "SwiftFormat installed. Running formatter..."
            fi
            swiftformat Sources --config .swiftformat
            echo "SwiftFormat completed."
        else
            echo "Failed to install SwiftFormat automatically."
            echo "Please install manually: brew install swiftformat"
        fi
    else
        echo "Homebrew not found. Please install SwiftFormat manually:"
        echo "  1) Install Homebrew: https://brew.sh"
        echo "  2) Run: brew install swiftformat"
    fi
fi

# Check if SwiftLint is installed
if command -v swiftlint &> /dev/null; then
    echo "Running SwiftLint..."
    swiftlint lint Sources --config .swiftlint.yml
    echo "SwiftLint completed."
else
    echo "SwiftLint not installed. Install with: brew install swiftlint"
fi

echo "Done!"
