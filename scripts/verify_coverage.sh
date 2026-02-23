#!/bin/bash
# Coverage Verification Script for Task #11
# This script runs tests with coverage and validates against target metrics

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Target coverage percentages
declare -A TARGETS=(
    ["WeakupCore"]="75"
    ["NotificationManager"]="70"
    ["TimeFormatter"]="70"
    ["UserDefaultsKeys"]="70"
    ["L10n"]="85"
    ["ActivityHistoryManager"]="80"
    ["Logger"]="75"
)

echo "=========================================="
echo "Coverage Verification Script"
echo "=========================================="
echo ""

# Step 1: Run tests with coverage
echo "Step 1: Running tests with coverage..."
swift test --enable-code-coverage 2>&1 | tee test_output.txt

# Check if tests passed
if grep -q "Test run.*failed" test_output.txt; then
    echo -e "${RED}ERROR: Some tests failed. Please fix failing tests before verification.${NC}"
    grep -A 5 "failed" test_output.txt
    exit 1
fi

# Count tests
TOTAL_TESTS=$(grep -oE "Test run with [0-9]+ tests" test_output.txt | grep -oE "[0-9]+")
echo -e "${GREEN}All $TOTAL_TESTS tests passed!${NC}"
echo ""

# Step 2: Find test binary and profdata
echo "Step 2: Locating coverage data..."
TEST_BINARY=$(find .build -name "WeakupPackageTests.xctest" -type d | head -1)
PROFDATA=".build/debug/codecov/default.profdata"

if [ -z "$TEST_BINARY" ] || [ ! -f "$PROFDATA" ]; then
    echo -e "${RED}ERROR: Coverage data not found${NC}"
    echo "TEST_BINARY: $TEST_BINARY"
    echo "PROFDATA exists: $([ -f "$PROFDATA" ] && echo 'yes' || echo 'no')"
    exit 1
fi

echo "TEST_BINARY: $TEST_BINARY"
echo "PROFDATA: $PROFDATA"
echo ""

# Step 3: Generate overall coverage report
echo "Step 3: Generating coverage report..."
echo ""

xcrun llvm-cov report \
    "$TEST_BINARY/Contents/MacOS/WeakupPackageTests" \
    -instr-profile="$PROFDATA" \
    -ignore-filename-regex='\.build/|Tests/' \
    2>/dev/null | tee coverage_report.txt

echo ""

# Step 4: Extract overall coverage
OVERALL_COVERAGE=$(grep "TOTAL" coverage_report.txt | awk '{print $4}' | tr -d '%')
echo "=========================================="
echo "Overall WeakupCore Coverage: ${OVERALL_COVERAGE}%"
echo "Target: ${TARGETS[WeakupCore]}%"
echo "=========================================="

if (( $(echo "$OVERALL_COVERAGE >= ${TARGETS[WeakupCore]}" | bc -l) )); then
    echo -e "${GREEN}PASS: Overall coverage meets target${NC}"
else
    echo -e "${RED}FAIL: Overall coverage below target${NC}"
fi
echo ""

# Step 5: Check per-file coverage
echo "=========================================="
echo "Per-Component Coverage Analysis"
echo "=========================================="
echo ""

# Function to check component coverage
check_component() {
    local component=$1
    local target=$2
    local pattern=$3

    local coverage=$(grep "$pattern" coverage_report.txt | awk '{print $4}' | tr -d '%' | head -1)

    if [ -z "$coverage" ]; then
        echo -e "${YELLOW}$component: No coverage data found${NC}"
        return
    fi

    if (( $(echo "$coverage >= $target" | bc -l) )); then
        echo -e "${GREEN}$component: ${coverage}% (target: ${target}%) - PASS${NC}"
    else
        echo -e "${RED}$component: ${coverage}% (target: ${target}%) - FAIL${NC}"
    fi
}

check_component "NotificationManager" "${TARGETS[NotificationManager]}" "NotificationManager.swift"
check_component "TimeFormatter" "${TARGETS[TimeFormatter]}" "TimeFormatter.swift"
check_component "UserDefaultsKeys" "${TARGETS[UserDefaultsKeys]}" "UserDefaultsStore.swift"
check_component "L10n" "${TARGETS[L10n]}" "L10n.swift"
check_component "ActivityHistoryManager" "${TARGETS[ActivityHistoryManager]}" "ActivityHistoryManager.swift"
check_component "Logger" "${TARGETS[Logger]}" "Logger.swift"

echo ""

# Step 6: Generate LCOV report for CI
echo "Step 6: Generating LCOV report..."
xcrun llvm-cov export \
    "$TEST_BINARY/Contents/MacOS/WeakupPackageTests" \
    -instr-profile="$PROFDATA" \
    -format=lcov \
    -ignore-filename-regex='\.build/|Tests/' \
    > coverage.lcov 2>/dev/null

echo "LCOV report saved to: coverage.lcov"
echo ""

# Step 7: Summary
echo "=========================================="
echo "Verification Summary"
echo "=========================================="
echo "Total Tests: $TOTAL_TESTS"
echo "Overall Coverage: ${OVERALL_COVERAGE}%"
echo "Target Coverage: ${TARGETS[WeakupCore]}%"
echo ""

if (( $(echo "$OVERALL_COVERAGE >= ${TARGETS[WeakupCore]}" | bc -l) )); then
    echo -e "${GREEN}VERIFICATION PASSED${NC}"
    exit 0
else
    echo -e "${RED}VERIFICATION FAILED - Coverage below target${NC}"
    exit 1
fi
