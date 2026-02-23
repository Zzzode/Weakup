#!/bin/bash
#
# Generate Coverage Report
#
# This script generates a coverage report for WeakupCore (business logic only).
# UI code (Sources/Weakup/**) is excluded as it's tested via XCUITest separately.
#
# Usage:
#   ./scripts/generate_coverage.sh
#

set -e

echo "🧪 Running tests with coverage..."
swift test --enable-code-coverage --filter WeakupTests

echo ""
echo "📊 Generating coverage report..."

TEST_BINARY=$(find .build -name "WeakupPackageTests.xctest" -type d | head -1)

if [ -z "$TEST_BINARY" ]; then
    echo "❌ Error: Test binary not found"
    exit 1
fi

if [ ! -f ".build/debug/codecov/default.profdata" ]; then
    echo "❌ Error: Coverage data not found"
    exit 1
fi

# Generate LCOV report (WeakupCore only)
echo ""
echo "=== Generating LCOV report (WeakupCore only) ==="
xcrun llvm-cov export \
    "$TEST_BINARY/Contents/MacOS/WeakupPackageTests" \
    -instr-profile=.build/debug/codecov/default.profdata \
    -format=lcov \
    -ignore-filename-regex='\.build/|Tests/|Sources/Weakup/' \
    > coverage.lcov 2>/dev/null

echo "✅ LCOV report generated: coverage.lcov"

# Generate text report
echo ""
echo "=== WeakupCore Coverage Report ==="
xcrun llvm-cov report \
    "$TEST_BINARY/Contents/MacOS/WeakupPackageTests" \
    -instr-profile=.build/debug/codecov/default.profdata \
    -ignore-filename-regex='\.build/|Tests/|Sources/Weakup/' \
    2>/dev/null

# Calculate coverage percentage
COVERAGE=$(xcrun llvm-cov report \
    "$TEST_BINARY/Contents/MacOS/WeakupPackageTests" \
    -instr-profile=.build/debug/codecov/default.profdata \
    -ignore-filename-regex='\.build/|Tests/|Sources/Weakup/' \
    2>/dev/null | grep "TOTAL" | awk '{print $4}' | tr -d '%')

echo ""
echo "=== Summary ==="
echo "WeakupCore Coverage: ${COVERAGE}%"

# Verify LCOV contains only WeakupCore files
TOTAL_FILES=$(grep "^SF:" coverage.lcov | wc -l | xargs)
CORE_FILES=$(grep "^SF:" coverage.lcov | grep "WeakupCore" | wc -l | xargs)
UI_FILES=$(grep "^SF:" coverage.lcov | grep "Sources/Weakup/" | grep -v "WeakupCore" | wc -l | xargs)

echo "Files in LCOV report:"
echo "  - Total: $TOTAL_FILES"
echo "  - WeakupCore: $CORE_FILES"
echo "  - Weakup UI: $UI_FILES"

if [ "$UI_FILES" -gt 0 ]; then
    echo ""
    echo "⚠️  Warning: UI files found in coverage report!"
    echo "These files should be excluded:"
    grep "^SF:" coverage.lcov | grep "Sources/Weakup/" | grep -v "WeakupCore"
    exit 1
fi

# Generate HTML report (optional)
if [ "$1" == "--html" ]; then
    echo ""
    echo "=== Generating HTML report ==="
    mkdir -p coverage_report
    xcrun llvm-cov show \
        "$TEST_BINARY/Contents/MacOS/WeakupPackageTests" \
        -instr-profile=.build/debug/codecov/default.profdata \
        -format=html \
        -output-dir=coverage_report \
        -ignore-filename-regex='\.build/|Tests/|Sources/Weakup/' \
        2>/dev/null
    echo "✅ HTML report generated: coverage_report/index.html"
    open coverage_report/index.html
fi

echo ""
echo "✅ Coverage report generation complete!"
