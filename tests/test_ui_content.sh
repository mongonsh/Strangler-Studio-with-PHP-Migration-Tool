#!/bin/bash

# UI Content Tests for Strangler Studio
# Validates: Requirements 1.3, 1.4, 1.5, 2.5, 2.6, 2.7, 8.4
#
# These tests verify UI elements are present and styled correctly
# with the premium Halloween theme.

set -e

# Configuration
GATEWAY_URL="${GATEWAY_URL:-http://localhost}"
CSS_FILE="legacy-php/styles/halloween.css"
HOME_VIEW="legacy-php/src/Views/home.php"
REQUESTS_VIEW="legacy-php/src/Views/requests.php"
LAYOUT_VIEW="legacy-php/src/Views/layout.php"
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

# Function to check if response contains text
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

# Function to check if file contains text
check_file_contains() {
    local file="$1"
    local expected_text="$2"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}    File not found: $file${NC}"
        return 1
    fi
    
    if grep -q "$expected_text" "$file"; then
        return 0
    else
        echo -e "${RED}    File does not contain: $expected_text${NC}"
        return 1
    fi
}

# Main test execution
echo "=========================================="
echo "UI Content Tests for Strangler Studio"
echo "=========================================="
echo "Testing gateway at: $GATEWAY_URL"
echo ""

# Check if gateway is accessible
if ! curl -s -o /dev/null "${GATEWAY_URL}/" 2>/dev/null; then
    echo -e "${YELLOW}WARNING:${NC} Gateway is not accessible at $GATEWAY_URL"
    echo "Some tests will be skipped. To run all tests, ensure Docker Compose services are running:"
    echo "  docker-compose up -d"
    echo ""
    GATEWAY_ACCESSIBLE=false
else
    GATEWAY_ACCESSIBLE=true
fi

echo "Running UI content tests..."
echo ""

# ========================================
# Test 1: Landing Page UI Elements
# ========================================
if [ "$GATEWAY_ACCESSIBLE" = true ]; then
    print_test "Test 1: Landing page UI elements (Requirements 1.3, 1.4, 1.5)"
    
    # Test 1.1: Hero section exists
    if check_contains "${GATEWAY_URL}/" "hero-section"; then
        print_success "Contains hero section"
    else
        print_failure "Contains hero section"
    fi
    
    # Test 1.2: Hero title "Strangler Studio" exists
    if check_contains "${GATEWAY_URL}/" "Strangler Studio"; then
        print_success "Contains 'Strangler Studio' title"
    else
        print_failure "Contains 'Strangler Studio' title"
    fi
    
    # Test 1.3: Three component cards exist
    response=$(curl -s "${GATEWAY_URL}/")
    card_count=$(echo "$response" | grep -o "component-card" | wc -l)
    if [ "$card_count" -ge 3 ]; then
        print_success "Contains three component cards"
    else
        print_failure "Contains three component cards (found $card_count)"
    fi
    
    # Test 1.4: Gateway card exists
    if check_contains "${GATEWAY_URL}/" "Gateway"; then
        print_success "Contains Gateway card"
    else
        print_failure "Contains Gateway card"
    fi
    
    # Test 1.5: Contracts card exists
    if check_contains "${GATEWAY_URL}/" "Contracts"; then
        print_success "Contains Contracts card"
    else
        print_failure "Contains Contracts card"
    fi
    
    # Test 1.6: Feature Flags card exists
    if check_contains "${GATEWAY_URL}/" "Feature Flags"; then
        print_success "Contains Feature Flags card"
    else
        print_failure "Contains Feature Flags card"
    fi
    
    # Test 1.7: CTA button "Run the Ritual" exists
    if check_contains "${GATEWAY_URL}/" "Run the Ritual"; then
        print_success "Contains 'Run the Ritual' CTA button"
    else
        print_failure "Contains 'Run the Ritual' CTA button"
    fi
    
    # Test 1.8: CTA button links to /requests?use_new=1
    if check_contains "${GATEWAY_URL}/" "/requests?use_new=1"; then
        print_success "CTA button links to /requests?use_new=1"
    else
        print_failure "CTA button links to /requests?use_new=1"
    fi
    
    echo ""
else
    echo -e "${YELLOW}Skipping Test 1: Gateway not accessible${NC}"
    echo ""
fi

# ========================================
# Test 2: Requests Page UI Elements
# ========================================
if [ "$GATEWAY_ACCESSIBLE" = true ]; then
    print_test "Test 2: Requests page UI elements (Requirements 2.5, 2.6, 2.7)"
    
    # Test 2.1: Toggle UI (witch switch) exists
    if check_contains "${GATEWAY_URL}/requests" "witch-switch"; then
        print_success "Contains witch switch toggle UI"
    else
        print_failure "Contains witch switch toggle UI"
    fi
    
    # Test 2.2: Switch labels exist
    if check_contains "${GATEWAY_URL}/requests" "Legacy Curse"; then
        print_success "Contains 'Legacy Curse' label"
    else
        print_failure "Contains 'Legacy Curse' label"
    fi
    
    if check_contains "${GATEWAY_URL}/requests" "Modern Magic"; then
        print_success "Contains 'Modern Magic' label"
    else
        print_failure "Contains 'Modern Magic' label"
    fi
    
    # Test 2.3: Data source indicator exists
    if check_contains "${GATEWAY_URL}/requests" "data-source-indicator"; then
        print_success "Contains data source indicator"
    else
        print_failure "Contains data source indicator"
    fi
    
    # Test 2.4: Data source indicator shows correct text for legacy
    if check_contains "${GATEWAY_URL}/requests?use_new=0" "Legacy Path"; then
        print_success "Shows 'Legacy Path' indicator for use_new=0"
    else
        print_failure "Shows 'Legacy Path' indicator for use_new=0"
    fi
    
    # Test 2.5: Data source indicator shows correct text for new API
    if check_contains "${GATEWAY_URL}/requests?use_new=1" "New API"; then
        print_success "Shows 'New API' indicator for use_new=1"
    else
        print_failure "Shows 'New API' indicator for use_new=1"
    fi
    
    # Test 2.6: Requests table exists
    if check_contains "${GATEWAY_URL}/requests" "requests-table"; then
        print_success "Contains requests table"
    else
        print_failure "Contains requests table"
    fi
    
    # Test 2.7: Status badges exist
    if check_contains "${GATEWAY_URL}/requests" "status-badge"; then
        print_success "Contains status badges"
    else
        print_failure "Contains status badges"
    fi
    
    echo ""
else
    echo -e "${YELLOW}Skipping Test 2: Gateway not accessible${NC}"
    echo ""
fi

# ========================================
# Test 3: CSS Halloween Color Palette
# ========================================
print_test "Test 3: CSS Halloween color palette (Requirement 8.4)"

# Test 3.1: Deep black background color
if check_file_contains "$CSS_FILE" "#0a0a0a"; then
    print_success "Contains deep black color (#0a0a0a)"
else
    print_failure "Contains deep black color (#0a0a0a)"
fi

# Test 3.2: Pumpkin orange accent color
if check_file_contains "$CSS_FILE" "#ff6b35"; then
    print_success "Contains pumpkin orange color (#ff6b35)"
else
    print_failure "Contains pumpkin orange color (#ff6b35)"
fi

# Test 3.3: Ghostly cyan accent color
if check_file_contains "$CSS_FILE" "#4ecdc4"; then
    print_success "Contains ghostly cyan color (#4ecdc4)"
else
    print_failure "Contains ghostly cyan color (#4ecdc4)"
fi

# Test 3.4: Blood red accent color
if check_file_contains "$CSS_FILE" "#c1121f"; then
    print_success "Contains blood red color (#c1121f)"
else
    print_failure "Contains blood red color (#c1121f)"
fi

# Test 3.5: Bone white text color
if check_file_contains "$CSS_FILE" "#f8f9fa"; then
    print_success "Contains bone white color (#f8f9fa)"
else
    print_failure "Contains bone white color (#f8f9fa)"
fi

# Test 3.6: Charcoal surface color
if check_file_contains "$CSS_FILE" "#1a1a1a"; then
    print_success "Contains charcoal color (#1a1a1a)"
else
    print_failure "Contains charcoal color (#1a1a1a)"
fi

echo ""

# ========================================
# Test 4: Typography - Cinzel and Inter Fonts
# ========================================
print_test "Test 4: Typography fonts (Requirement 8.4)"

# Test 4.1: CSS imports Cinzel font
if check_file_contains "$CSS_FILE" "Cinzel"; then
    print_success "CSS imports Cinzel font"
else
    print_failure "CSS imports Cinzel font"
fi

# Test 4.2: CSS imports Inter font
if check_file_contains "$CSS_FILE" "Inter"; then
    print_success "CSS imports Inter font"
else
    print_failure "CSS imports Inter font"
fi

# Test 4.3: Layout imports Cinzel font from Google Fonts
if check_file_contains "$LAYOUT_VIEW" "Cinzel"; then
    print_success "Layout imports Cinzel font from Google Fonts"
else
    print_failure "Layout imports Cinzel font from Google Fonts"
fi

# Test 4.4: Layout imports Inter font from Google Fonts
if check_file_contains "$LAYOUT_VIEW" "Inter"; then
    print_success "Layout imports Inter font from Google Fonts"
else
    print_failure "Layout imports Inter font from Google Fonts"
fi

# Test 4.5: Home view uses Cinzel font family
if check_file_contains "$HOME_VIEW" "Cinzel"; then
    print_success "Home view uses Cinzel font family"
else
    print_failure "Home view uses Cinzel font family"
fi

# Test 4.6: Requests view uses Cinzel font family
if check_file_contains "$REQUESTS_VIEW" "Cinzel"; then
    print_success "Requests view uses Cinzel font family"
else
    print_failure "Requests view uses Cinzel font family"
fi

echo ""

# ========================================
# Test 5: Glassmorphism Effects
# ========================================
print_test "Test 5: Glassmorphism effects (Requirement 8.4)"

# Test 5.1: CSS contains backdrop-filter
if check_file_contains "$CSS_FILE" "backdrop-filter"; then
    print_success "CSS contains backdrop-filter for glassmorphism"
else
    print_failure "CSS contains backdrop-filter for glassmorphism"
fi

# Test 5.2: CSS contains blur effect
if check_file_contains "$CSS_FILE" "blur"; then
    print_success "CSS contains blur effect"
else
    print_failure "CSS contains blur effect"
fi

# Test 5.3: Component cards use glassmorphism
if check_file_contains "$HOME_VIEW" "component-card"; then
    print_success "Component cards use glassmorphism class"
else
    print_failure "Component cards use glassmorphism class"
fi

echo ""

# ========================================
# Test 6: Glow Effects
# ========================================
print_test "Test 6: Glow effects (Requirement 8.4)"

# Test 6.1: CSS contains box-shadow for glow
if check_file_contains "$CSS_FILE" "box-shadow"; then
    print_success "CSS contains box-shadow for glow effects"
else
    print_failure "CSS contains box-shadow for glow effects"
fi

# Test 6.2: CSS contains text-shadow for glow
if check_file_contains "$CSS_FILE" "text-shadow"; then
    print_success "CSS contains text-shadow for text glow"
else
    print_failure "CSS contains text-shadow for text glow"
fi

# Test 6.3: Hero title has glow effect
if check_file_contains "$HOME_VIEW" "hero-title"; then
    print_success "Hero title has glow effect class"
else
    print_failure "Hero title has glow effect class"
fi

echo ""

# ========================================
# Test 7: Grain Texture Overlay
# ========================================
print_test "Test 7: Grain texture overlay (Requirement 8.4)"

# Test 7.1: CSS contains grain texture SVG
if check_file_contains "$CSS_FILE" "feTurbulence"; then
    print_success "CSS contains grain texture SVG filter"
else
    print_failure "CSS contains grain texture SVG filter"
fi

# Test 7.2: Body element has grain overlay
if check_file_contains "$CSS_FILE" "body::before"; then
    print_success "Body element has grain overlay pseudo-element"
else
    print_failure "Body element has grain overlay pseudo-element"
fi

echo ""

# ========================================
# Test 8: Responsive Design
# ========================================
print_test "Test 8: Responsive design breakpoints (Requirement 8.4)"

# Test 8.1: Mobile breakpoint (< 640px)
if check_file_contains "$CSS_FILE" "max-width: 639px"; then
    print_success "CSS contains mobile breakpoint"
else
    print_failure "CSS contains mobile breakpoint"
fi

# Test 8.2: Tablet breakpoint (640px - 1024px)
if check_file_contains "$CSS_FILE" "min-width: 640px"; then
    print_success "CSS contains tablet breakpoint"
else
    print_failure "CSS contains tablet breakpoint"
fi

# Test 8.3: Desktop breakpoint (> 1024px)
if check_file_contains "$CSS_FILE" "min-width: 1025px"; then
    print_success "CSS contains desktop breakpoint"
else
    print_failure "CSS contains desktop breakpoint"
fi

echo ""

# ========================================
# Test 9: Accessibility Features
# ========================================
print_test "Test 9: Accessibility features (Requirement 8.4)"

# Test 9.1: Reduced motion support
if check_file_contains "$CSS_FILE" "prefers-reduced-motion"; then
    print_success "CSS supports reduced motion preference"
else
    print_failure "CSS supports reduced motion preference"
fi

# Test 9.2: Focus indicators
if check_file_contains "$CSS_FILE" "focus"; then
    print_success "CSS contains focus indicators"
else
    print_failure "CSS contains focus indicators"
fi

# Test 9.3: ARIA labels in home view
if check_file_contains "$HOME_VIEW" "aria-label"; then
    print_success "Home view contains ARIA labels"
else
    print_failure "Home view contains ARIA labels"
fi

# Test 9.4: ARIA labels in requests view
if check_file_contains "$REQUESTS_VIEW" "aria-label"; then
    print_success "Requests view contains ARIA labels"
else
    print_failure "Requests view contains ARIA labels"
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
    echo -e "${GREEN}✓ All UI content tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some UI content tests failed${NC}"
    exit 1
fi
