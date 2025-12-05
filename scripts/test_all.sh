#!/bin/bash

# Test Orchestration Script for Strangler Studio
# Validates: Requirements 9.3
#
# This script runs all test suites (smoke, golden, property-based)
# and aggregates the results into a comprehensive summary.

set +e  # Don't exit on first failure - we want to run all tests

# Configuration
GATEWAY_URL="${GATEWAY_URL:-http://localhost}"
export GATEWAY_URL

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Test suite tracking
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

# Individual test tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test results storage
declare -a SUITE_RESULTS
declare -a SUITE_NAMES

# Function to print section header
print_header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

# Function to print subsection
print_subsection() {
    echo ""
    echo -e "${CYAN}${BOLD}>>> $1${NC}"
    echo ""
}

# Function to run a test suite and capture results
run_test_suite() {
    local suite_name="$1"
    local test_script="$2"
    local suite_type="$3"  # "bash" or "python"
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    SUITE_NAMES+=("$suite_name")
    
    print_subsection "Running: $suite_name"
    
    # Check if test script exists
    if [ ! -f "$test_script" ]; then
        echo -e "${RED}ERROR:${NC} Test script not found: $test_script"
        SUITE_RESULTS+=("MISSING")
        FAILED_SUITES=$((FAILED_SUITES + 1))
        return 1
    fi
    
    # Make sure script is executable
    chmod +x "$test_script" 2>/dev/null
    
    # Run the test suite and capture output
    local temp_output=$(mktemp)
    local start_time=$(date +%s)
    
    if [ "$suite_type" = "bash" ]; then
        bash "$test_script" > "$temp_output" 2>&1
        local exit_code=$?
    elif [ "$suite_type" = "python" ]; then
        # Run Python tests with pytest
        cd "$(dirname "$test_script")" || exit 1
        python -m pytest "$(basename "$test_script")" -v > "$temp_output" 2>&1
        local exit_code=$?
        cd - > /dev/null || exit 1
    else
        echo -e "${RED}ERROR:${NC} Unknown test suite type: $suite_type"
        rm -f "$temp_output"
        SUITE_RESULTS+=("ERROR")
        FAILED_SUITES=$((FAILED_SUITES + 1))
        return 1
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Display the output
    cat "$temp_output"
    
    # Parse results from output
    local passed=0
    local failed=0
    
    if [ "$suite_type" = "bash" ]; then
        # Extract pass/fail counts from bash test output
        passed=$(grep -o "Passed: [0-9]*" "$temp_output" | grep -o "[0-9]*" | tail -1)
        failed=$(grep -o "Failed: [0-9]*" "$temp_output" | grep -o "[0-9]*" | tail -1)
        
        # Default to 0 if not found
        passed=${passed:-0}
        failed=${failed:-0}
    elif [ "$suite_type" = "python" ]; then
        # Extract pass/fail counts from pytest output
        if grep -q "passed" "$temp_output"; then
            passed=$(grep -o "[0-9]* passed" "$temp_output" | grep -o "[0-9]*" | tail -1)
            passed=${passed:-0}
        fi
        if grep -q "failed" "$temp_output"; then
            failed=$(grep -o "[0-9]* failed" "$temp_output" | grep -o "[0-9]*" | tail -1)
            failed=${failed:-0}
        fi
    fi
    
    # Update totals
    TOTAL_TESTS=$((TOTAL_TESTS + passed + failed))
    PASSED_TESTS=$((PASSED_TESTS + passed))
    FAILED_TESTS=$((FAILED_TESTS + failed))
    
    # Clean up temp file
    rm -f "$temp_output"
    
    # Record result
    if [ $exit_code -eq 0 ]; then
        SUITE_RESULTS+=("PASS")
        PASSED_SUITES=$((PASSED_SUITES + 1))
        echo ""
        echo -e "${GREEN}✓ $suite_name completed successfully${NC} (${duration}s)"
        return 0
    else
        SUITE_RESULTS+=("FAIL")
        FAILED_SUITES=$((FAILED_SUITES + 1))
        echo ""
        echo -e "${RED}✗ $suite_name failed${NC} (${duration}s)"
        return 1
    fi
}

# Function to print final summary
print_summary() {
    print_header "Test Execution Summary"
    
    echo ""
    echo -e "${BOLD}Test Suites:${NC}"
    echo -e "  Total:  $TOTAL_SUITES"
    echo -e "  ${GREEN}Passed: $PASSED_SUITES${NC}"
    echo -e "  ${RED}Failed: $FAILED_SUITES${NC}"
    
    echo ""
    echo -e "${BOLD}Individual Tests:${NC}"
    echo -e "  Total:  $TOTAL_TESTS"
    echo -e "  ${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "  ${RED}Failed: $FAILED_TESTS${NC}"
    
    echo ""
    echo -e "${BOLD}Suite Results:${NC}"
    for i in "${!SUITE_NAMES[@]}"; do
        local name="${SUITE_NAMES[$i]}"
        local result="${SUITE_RESULTS[$i]}"
        
        case "$result" in
            "PASS")
                echo -e "  ${GREEN}✓${NC} $name"
                ;;
            "FAIL")
                echo -e "  ${RED}✗${NC} $name"
                ;;
            "MISSING")
                echo -e "  ${YELLOW}?${NC} $name (script not found)"
                ;;
            "ERROR")
                echo -e "  ${RED}!${NC} $name (execution error)"
                ;;
        esac
    done
    
    echo ""
    echo "=========================================="
    
    if [ $FAILED_SUITES -eq 0 ]; then
        echo -e "${GREEN}${BOLD}✓ ALL TESTS PASSED!${NC}"
        echo ""
        echo "All test suites completed successfully."
        echo "The Strangler Studio application is ready for deployment."
        return 0
    else
        echo -e "${RED}${BOLD}✗ SOME TESTS FAILED${NC}"
        echo ""
        echo "Please review the failures above and fix the issues."
        echo ""
        echo "Common troubleshooting steps:"
        echo "  1. Ensure Docker Compose services are running: docker-compose up -d"
        echo "  2. Check service health: docker-compose ps"
        echo "  3. Review service logs: docker-compose logs"
        echo "  4. Verify OpenAPI contract: scripts/validate_openapi.sh"
        return 1
    fi
}

# Main execution
main() {
    print_header "Strangler Studio - Test Orchestration"
    
    echo ""
    echo "This script runs all test suites and aggregates results:"
    echo "  • Smoke tests (critical user paths)"
    echo "  • Golden tests (data equivalence)"
    echo "  • UI content tests (Halloween theme, typography, accessibility)"
    echo "  • Property-based tests (gateway routing, API correctness)"
    echo ""
    echo "Gateway URL: $GATEWAY_URL"
    echo ""
    
    # Check if gateway is accessible
    echo "Checking gateway accessibility..."
    if ! curl -s -o /dev/null -w "%{http_code}" "${GATEWAY_URL}/" >/dev/null 2>&1; then
        echo -e "${RED}ERROR:${NC} Gateway is not accessible at $GATEWAY_URL"
        echo ""
        echo "Please ensure Docker Compose services are running:"
        echo "  docker-compose up -d"
        echo ""
        echo "Then wait for services to be ready and try again."
        exit 1
    fi
    echo -e "${GREEN}✓${NC} Gateway is accessible"
    
    # Run smoke tests
    run_test_suite "Smoke Tests" "tests/test_smoke.sh" "bash"
    
    # Run golden tests
    run_test_suite "Golden Tests" "tests/test_golden.sh" "bash"
    
    # Run UI content tests
    run_test_suite "UI Content Tests" "tests/test_ui_content.sh" "bash"
    
    # Run property-based tests (bash)
    run_test_suite "Property Test: Gateway Routing" "tests/test_property_gateway_routing.sh" "bash"
    run_test_suite "Property Test: Data Equivalence" "tests/test_property_data_equivalence.sh" "bash"
    
    # Run property-based tests (Python)
    run_test_suite "Property Test: API ID Lookup" "new-api/tests/test_property_id_lookup.py" "python"
    run_test_suite "Property Test: API Response Completeness" "new-api/tests/test_property_response_completeness.py" "python"
    run_test_suite "Property Test: OpenAPI Contract Compliance" "new-api/tests/test_property_contract_compliance.py" "python"
    
    # Print final summary
    print_summary
    local summary_exit=$?
    
    echo ""
    
    # Exit with appropriate code
    if [ $summary_exit -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"
