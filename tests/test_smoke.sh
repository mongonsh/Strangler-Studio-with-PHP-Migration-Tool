#!/bin/bash

# Smoke Tests for Strangler Studio
# Validates: Requirements 5.1, 5.2, 5.3
#
# These tests verify critical user paths return successful responses
# with expected content.

set -e

# Configuration
GATEWAY_URL="${GATEWAY_URL:-http://localhost}"
FAILED=0
PASSED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print test header
print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# Function to print success
print_success() {
    echo -e "${GREEN}  ✓ $1${NC}"
    PASSED=$((PASSED + 1))
}

# Function to print failure
print_failure() {
    echo -e "${RED}  ✗ $1${NC}"
    FAILED=$((FAILED + 1))
}

# Function to check HTTP status code
check_status() {
    local url="$1"
    local expected_status="$2"
    local actual_status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$actual_status" = "$expected_status" ]; then
        return 0
    else
        echo -e "${RED}    Expected status $expected_status, got $actual_status${NC}"
        return 1
    fi
}

# Function to check response contains text
check_contains() {
    local url="$1"
    local expected_text="$2"
    local response=$(curl -s "$url")
    
    if echo "$response" | grep -q "$expected_text"; then
        return 0
    else
        echo -e "${RED}    Response does not contain: $expected_text${NC}"
        return 1
    fi
}

# Function to check response is valid JSON
check_valid_json() {
    local url="$1"
    local response=$(curl -s "$url")
    
    if echo "$response" | jq . >/dev/null 2>&1; then
        return 0
    else
        echo -e "${RED}    Response is not valid JSON${NC}"
        echo -e "${RED}    Response: $response${NC}"
        return 1
    fi
}

# Function to check response is JSON array
check_json_array() {
    local url="$1"
    local response=$(curl -s "$url")
    
    if echo "$response" | jq -e 'type == "array"' >/dev/null 2>&1; then
        return 0
    else
        echo -e "${RED}    Response is not a JSON array${NC}"
        return 1
    fi
}

# Function to check response is JSON object
check_json_object() {
    local url="$1"
    local response=$(curl -s "$url")
    
    if echo "$response" | jq -e 'type == "object"' >/dev/null 2>&1; then
        return 0
    else
        echo -e "${RED}    Response is not a JSON object${NC}"
        return 1
    fi
}

# Main test execution
echo "=========================================="
echo "Smoke Tests for Strangler Studio"
echo "=========================================="
echo "Testing gateway at: $GATEWAY_URL"
echo ""

# Check if gateway is accessible
if ! curl -s -o /dev/null "${GATEWAY_URL}/" 2>/dev/null; then
    echo -e "${RED}ERROR:${NC} Gateway is not accessible at $GATEWAY_URL"
    echo "Please ensure Docker Compose services are running:"
    echo "  docker-compose up -d"
    exit 1
fi

echo "Running smoke tests..."
echo ""

# Test 1: GET / returns 200 and contains "Strangler Studio" title
print_test "Test 1: Landing page (GET /)"
if check_status "${GATEWAY_URL}/" "200"; then
    print_success "Returns HTTP 200"
else
    print_failure "Returns HTTP 200"
fi

if check_contains "${GATEWAY_URL}/" "Strangler Studio"; then
    print_success "Contains 'Strangler Studio' title"
else
    print_failure "Contains 'Strangler Studio' title"
fi
echo ""

# Test 2: GET /requests?use_new=1 returns 200 and contains data from API
print_test "Test 2: Requests page with new API (GET /requests?use_new=1)"
if check_status "${GATEWAY_URL}/requests?use_new=1" "200"; then
    print_success "Returns HTTP 200"
else
    print_failure "Returns HTTP 200"
fi

# Check for data indicators (student names, status badges, etc.)
if check_contains "${GATEWAY_URL}/requests?use_new=1" "student"; then
    print_success "Contains student data from API"
else
    print_failure "Contains student data from API"
fi
echo ""

# Test 3: GET /api/requests returns 200 and valid JSON array
print_test "Test 3: API list endpoint (GET /api/requests)"
if check_status "${GATEWAY_URL}/api/requests" "200"; then
    print_success "Returns HTTP 200"
else
    print_failure "Returns HTTP 200"
fi

if check_valid_json "${GATEWAY_URL}/api/requests"; then
    print_success "Returns valid JSON"
else
    print_failure "Returns valid JSON"
fi

if check_json_array "${GATEWAY_URL}/api/requests"; then
    print_success "Returns JSON array"
else
    print_failure "Returns JSON array"
fi
echo ""

# Test 4: GET /api/requests/1 returns 200 and valid JSON object
print_test "Test 4: API detail endpoint (GET /api/requests/1)"
if check_status "${GATEWAY_URL}/api/requests/1" "200"; then
    print_success "Returns HTTP 200"
else
    print_failure "Returns HTTP 200"
fi

if check_valid_json "${GATEWAY_URL}/api/requests/1"; then
    print_success "Returns valid JSON"
else
    print_failure "Returns valid JSON"
fi

if check_json_object "${GATEWAY_URL}/api/requests/1"; then
    print_success "Returns JSON object"
else
    print_failure "Returns JSON object"
fi

# Additional assertion: Check that the object has required fields
response=$(curl -s "${GATEWAY_URL}/api/requests/1")
required_fields=("id" "student_name" "school" "status" "created_at" "priority")
all_fields_present=true

for field in "${required_fields[@]}"; do
    if ! echo "$response" | jq -e "has(\"$field\")" >/dev/null 2>&1; then
        print_failure "Contains required field: $field"
        all_fields_present=false
    fi
done

if [ "$all_fields_present" = true ]; then
    print_success "Contains all required fields (id, student_name, school, status, created_at, priority)"
fi
echo ""

# Summary
echo "=========================================="
echo "Test Results"
echo "=========================================="
echo -e "Total assertions: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All smoke tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some smoke tests failed${NC}"
    exit 1
fi
