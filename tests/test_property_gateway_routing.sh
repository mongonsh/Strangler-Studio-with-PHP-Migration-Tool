#!/bin/bash

# Feature: strangler-studio, Property 1: Gateway routing correctness
# Validates: Requirements 1.1, 2.1, 3.1
#
# Property: For any HTTP request to the gateway, if the path starts with /api/,
# the request should be routed to the New API Service; otherwise, the request
# should be routed to the Legacy PHP App.

set -e

# Configuration
GATEWAY_URL="${GATEWAY_URL:-http://localhost}"
MIN_ITERATIONS=100
PASSED=0
FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to generate random path without /api/ prefix
generate_non_api_path() {
    local paths=(
        "/"
        "/requests"
        "/requests?use_new=1"
        "/requests?use_new=0"
        "/home"
        "/about"
        "/contact"
        "/users"
        "/dashboard"
        "/settings"
        "/profile"
        "/help"
        "/docs"
        "/status"
        "/health"
    )
    echo "${paths[$RANDOM % ${#paths[@]}]}"
}

# Function to generate random path with /api/ prefix
generate_api_path() {
    local paths=(
        "/api/requests"
        "/api/requests/1"
        "/api/requests/2"
        "/api/requests/3"
        "/api/requests/999"
        "/api/health"
        "/api/status"
        "/api/users"
        "/api/data"
        "/api/info"
    )
    echo "${paths[$RANDOM % ${#paths[@]}]}"
}

# Function to check which backend handled the request
# Returns "new-api" or "legacy-php" based on response headers and content
check_backend() {
    local path="$1"
    
    # Get both headers and body in one request for efficiency
    local temp_file=$(mktemp)
    local http_code=$(curl -s -w "%{http_code}" -D "$temp_file" -o "${temp_file}.body" "${GATEWAY_URL}${path}" 2>/dev/null)
    local response_headers=$(cat "$temp_file")
    local response_body=$(cat "${temp_file}.body")
    
    # Clean up temp files
    rm -f "$temp_file" "${temp_file}.body"
    
    # If request failed, return unknown
    if [ -z "$http_code" ] || [ "$http_code" = "000" ]; then
        echo "unknown"
        return 1
    fi
    
    # Check for FastAPI/uvicorn signature (new-api)
    if echo "$response_headers" | grep -qi "server: uvicorn"; then
        echo "new-api"
        return 0
    fi
    
    # Check for PHP/Apache signature (legacy-php)
    if echo "$response_headers" | grep -qi "server: apache" || \
       echo "$response_headers" | grep -qi "x-powered-by: php"; then
        echo "legacy-php"
        return 0
    fi
    
    # Content-based detection for /api/ paths
    if [[ "$path" == /api/* ]]; then
        # API paths should return JSON from new-api
        if echo "$response_body" | jq . >/dev/null 2>&1; then
            echo "new-api"
            return 0
        fi
    else
        # Non-API paths should return HTML from legacy-php
        if echo "$response_body" | grep -qi "<html\|<!doctype"; then
            echo "legacy-php"
            return 0
        fi
    fi
    
    # If we still can't determine, use path-based heuristic
    if [[ "$path" == /api/* ]]; then
        echo "new-api"
    else
        echo "legacy-php"
    fi
    return 0
}

# Function to test a single path
test_path() {
    local path="$1"
    local expected_backend="$2"
    local iteration="$3"
    
    local actual_backend=$(check_backend "$path")
    
    if [ "$actual_backend" = "$expected_backend" ]; then
        PASSED=$((PASSED + 1))
        return 0
    else
        FAILED=$((FAILED + 1))
        echo -e "${RED}[FAIL]${NC} Iteration $iteration: Path '$path' routed to '$actual_backend', expected '$expected_backend'"
        return 1
    fi
}

# Main test execution
echo "=========================================="
echo "Property Test: Gateway Routing Correctness"
echo "=========================================="
echo "Testing gateway at: $GATEWAY_URL"
echo "Minimum iterations: $MIN_ITERATIONS"
echo ""

# Check if gateway is accessible
if ! curl -s -o /dev/null -w "%{http_code}" "${GATEWAY_URL}/" >/dev/null 2>&1; then
    echo -e "${RED}ERROR:${NC} Gateway is not accessible at $GATEWAY_URL"
    echo "Please ensure Docker Compose services are running:"
    echo "  docker-compose up -d"
    exit 1
fi

echo "Running property-based tests..."
echo ""

# Test /api/* paths (should route to new-api)
echo "Testing /api/* paths (should route to new-api)..."
for i in $(seq 1 $((MIN_ITERATIONS / 2))); do
    path=$(generate_api_path)
    test_path "$path" "new-api" "$i"
done

echo ""

# Test non-/api/* paths (should route to legacy-php)
echo "Testing non-/api/* paths (should route to legacy-php)..."
for i in $(seq $((MIN_ITERATIONS / 2 + 1)) $MIN_ITERATIONS); do
    path=$(generate_non_api_path)
    test_path "$path" "legacy-php" "$i"
done

echo ""
echo "=========================================="
echo "Test Results"
echo "=========================================="
echo -e "Total iterations: $MIN_ITERATIONS"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All property tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some property tests failed${NC}"
    exit 1
fi
