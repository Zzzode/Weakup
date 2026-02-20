#!/bin/bash
# Format and lint Swift code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Check if SwiftFormat is installed
if command -v swiftformat &> /dev/null; then
    echo "Running SwiftFormat..."
    swiftformat Sources --config .swiftformat
    echo "SwiftFormat completed."
else
    echo "SwiftFormat not installed. Install with: brew install swiftformat"
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
