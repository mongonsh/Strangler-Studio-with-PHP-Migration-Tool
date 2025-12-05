#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           CONNECTION TEST - STRANGLER STUDIO               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_url() {
    local url=$1
    local name=$2
    
    echo -n "Testing $name... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url" 2>&1)
    
    if [ "$response" = "200" ]; then
        echo -e "${GREEN}✓ OK${NC} (HTTP $response)"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC} (HTTP $response)"
        return 1
    fi
}

echo "Testing Strangler Studio Services:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test Gateway
test_url "http://localhost:8888/" "Gateway (port 8888)"

# Test Legacy PHP Direct
test_url "http://localhost:8080/" "Legacy PHP Direct (port 8080)"

# Test Gateway API
test_url "http://localhost:8888/api/requests" "API via Gateway"

# Test Legacy Requests
test_url "http://localhost:8888/requests" "Legacy Requests Page"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check Docker containers
echo "Docker Container Status:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker-compose ps

echo ""
echo "Port Mappings:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  8888 → Gateway (nginx)"
echo "  8080 → Legacy PHP (direct access)"
echo ""

# Test with actual content
echo "Sample Content Test:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Gateway landing page:"
curl -s http://localhost:8888/ | grep -o "<title>.*</title>" || echo "Could not fetch title"
echo ""

echo "Legacy PHP direct:"
curl -s http://localhost:8080/ | grep -o "<title>.*</title>" || echo "Could not fetch title"
echo ""

echo "API response:"
curl -s http://localhost:8888/api/requests | python3 -m json.tool 2>/dev/null | head -10 || echo "Could not parse JSON"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "If all tests pass, the services are working correctly!"
echo "Open in browser:"
echo "  - Gateway: http://localhost:8888/"
echo "  - Legacy PHP: http://localhost:8080/"
