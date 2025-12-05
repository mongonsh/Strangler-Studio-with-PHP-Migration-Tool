#!/bin/bash

# Strangler Studio Demo Script
# Validates: Requirements 9.4
#
# This script demonstrates the complete Strangler Fig pattern migration workflow.
# It starts all services, executes demo scenarios, and displays formatted output.

set -e

# Configuration
GATEWAY_URL="${GATEWAY_URL:-http://localhost:8888}"
MAX_WAIT=60  # Maximum seconds to wait for services to be ready
CLEANUP_ON_EXIT=true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Emoji/symbols for visual appeal
SKULL="💀"
PUMPKIN="🎃"
GHOST="👻"
SPARKLES="✨"
ROCKET="🚀"
CHECK="✓"
CROSS="✗"

# Function to print section header
print_header() {
    echo ""
    echo -e "${MAGENTA}${BOLD}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}"
    echo ""
}

# Function to print step
print_step() {
    echo -e "${CYAN}${BOLD}▶ $1${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}  ${CHECK} $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}  ${CROSS} $1${NC}"
}

# Function to print info
print_info() {
    echo -e "${BLUE}  ℹ $1${NC}"
}

# Function to print demo output
print_demo_output() {
    local title="$1"
    local content="$2"
    
    echo -e "${YELLOW}${BOLD}┌─────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}${BOLD}│ $title${NC}"
    echo -e "${YELLOW}${BOLD}└─────────────────────────────────────────┘${NC}"
    echo "$content" | head -20  # Limit output to first 20 lines
    if [ $(echo "$content" | wc -l) -gt 20 ]; then
        echo -e "${YELLOW}  ... (output truncated)${NC}"
    fi
    echo ""
}

# Function to wait for service health
wait_for_service() {
    local service_name="$1"
    local health_url="$2"
    local elapsed=0
    
    print_step "Waiting for $service_name to be healthy..."
    
    while [ $elapsed -lt $MAX_WAIT ]; do
        if curl -s -f "$health_url" >/dev/null 2>&1; then
            print_success "$service_name is healthy"
            return 0
        fi
        
        sleep 2
        elapsed=$((elapsed + 2))
        echo -ne "${BLUE}  ⏳ Waiting... ${elapsed}s / ${MAX_WAIT}s\r${NC}"
    done
    
    echo ""
    print_error "$service_name failed to become healthy within ${MAX_WAIT}s"
    return 1
}

# Function to cleanup on exit
cleanup() {
    if [ "$CLEANUP_ON_EXIT" = true ]; then
        print_header "${SKULL} Cleaning Up"
        print_step "Stopping Docker Compose services..."
        docker-compose down
        print_success "Services stopped"
    fi
}

# Trap exit to ensure cleanup
trap cleanup EXIT

# Main demo execution
clear
echo -e "${MAGENTA}${BOLD}"
cat << "EOF"
   _____ _                        _             _____ _             _ _       
  / ____| |                      | |           / ____| |           | (_)      
 | (___ | |_ _ __ __ _ _ __   __ _| | ___ _ __| (___ | |_ _   _  __| |_  ___  
  \___ \| __| '__/ _` | '_ \ / _` | |/ _ \ '__\___ \| __| | | |/ _` | |/ _ \ 
  ____) | |_| | | (_| | | | | (_| | |  __/ |  ____) | |_| |_| | (_| | | (_) |
 |_____/ \__|_|  \__,_|_| |_|\__, |_|\___|_| |_____/ \__|\__,_|\__,_|_|\___/ 
                              __/ |                                           
                             |___/                                            
EOF
echo -e "${NC}"
echo -e "${CYAN}${BOLD}A demonstration of the Strangler Fig pattern for legacy migration${NC}"
echo -e "${YELLOW}${PUMPKIN} Premium Halloween Edition ${PUMPKIN}${NC}"
echo ""

# Step 1: Start Docker Compose services
print_header "${ROCKET} Starting Services"
print_step "Starting Docker Compose services..."

if docker-compose up -d; then
    print_success "Docker Compose services started"
else
    print_error "Failed to start Docker Compose services"
    exit 1
fi

# Step 2: Wait for health checks
print_header "${SPARKLES} Health Checks"

# Wait for new-api service
if ! wait_for_service "New API Service" "${GATEWAY_URL}/api/health"; then
    print_error "New API Service is not healthy. Exiting."
    exit 1
fi

# Wait for gateway (check root path)
if ! wait_for_service "Gateway" "${GATEWAY_URL}/"; then
    print_error "Gateway is not healthy. Exiting."
    exit 1
fi

print_success "All services are healthy and ready!"

# Step 3: Execute demo scenarios
print_header "${GHOST} Demo Scenarios"

# Scenario 1: Show landing page
print_step "Scenario 1: Landing Page (GET /)"
print_info "This demonstrates the legacy PHP app serving the Halloween-themed landing page"
response=$(curl -s "${GATEWAY_URL}/")
print_demo_output "Landing Page Response" "$response"

# Scenario 2: Show legacy requests
print_step "Scenario 2: Legacy Requests (GET /requests?use_new=0)"
print_info "This shows the legacy stub data path (use_new=0)"
response=$(curl -s "${GATEWAY_URL}/requests?use_new=0")
print_demo_output "Legacy Requests Response" "$response"

# Scenario 3: Show new API requests
print_step "Scenario 3: New API Requests (GET /requests?use_new=1)"
print_info "This shows the new API path through the legacy app (use_new=1)"
response=$(curl -s "${GATEWAY_URL}/requests?use_new=1")
print_demo_output "New API Requests Response" "$response"

# Scenario 4: Show API directly
print_step "Scenario 4: Direct API Access (GET /api/requests)"
print_info "This demonstrates direct access to the new API service through the gateway"
response=$(curl -s "${GATEWAY_URL}/api/requests")
print_demo_output "Direct API Response (JSON)" "$response"

# Additional scenario: Show single request
print_step "Scenario 5: Single Request Detail (GET /api/requests/1)"
print_info "This demonstrates fetching a single Student Request by ID"
response=$(curl -s "${GATEWAY_URL}/api/requests/1")
print_demo_output "Single Request Response (JSON)" "$response"

# Step 4: Summary
print_header "${PUMPKIN} Demo Complete!"

echo -e "${GREEN}${BOLD}The Strangler Fig pattern demonstration is complete!${NC}"
echo ""
echo -e "${CYAN}Key Takeaways:${NC}"
echo -e "  ${CHECK} Gateway routes traffic to appropriate services"
echo -e "  ${CHECK} Feature flag (use_new) toggles between legacy and new implementations"
echo -e "  ${CHECK} Legacy PHP app can call the new API service"
echo -e "  ${CHECK} New API service provides contract-first REST endpoints"
echo -e "  ${CHECK} Premium Halloween theme applied throughout"
echo ""
echo -e "${YELLOW}${BOLD}Next Steps:${NC}"
echo -e "  1. Open ${BLUE}http://localhost:8888${NC} in your browser"
echo -e "  2. Click the ${MAGENTA}'Run the Ritual'${NC} button"
echo -e "  3. Toggle the ${CYAN}'Witch Switch'${NC} to see the migration in action"
echo ""
echo -e "${MAGENTA}${BOLD}Services will be stopped automatically on exit.${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the demo and clean up services.${NC}"
echo ""

# Keep services running and wait for user interrupt
print_info "Services are running. Press Ctrl+C to stop..."
read -r -d '' _ </dev/tty || true
