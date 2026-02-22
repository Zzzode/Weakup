#!/bin/bash
# Format and lint Swift code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

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
