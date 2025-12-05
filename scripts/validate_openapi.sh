#!/bin/bash

# validate_openapi.sh
# Validates OpenAPI YAML syntax and OpenAPI 3.0+ compliance
# Exit code 0 on success, 1 on failure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
OPENAPI_FILE="contracts/openapi.yaml"
REQUIRED_VERSION="3.0"

echo "🔍 Validating OpenAPI specification..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if OpenAPI file exists
if [ ! -f "$OPENAPI_FILE" ]; then
    echo -e "${RED}❌ Error: OpenAPI file not found at $OPENAPI_FILE${NC}"
    exit 1
fi

echo "📄 File: $OPENAPI_FILE"

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Error: python3 not found${NC}"
    exit 1
fi

# Install PyYAML if not available
echo -n "🔧 Checking dependencies... "
python3 -c "import yaml" 2>/dev/null || {
    echo -e "${YELLOW}Installing PyYAML...${NC}"
    pip3 install --break-system-packages PyYAML > /dev/null 2>&1 || {
        echo -e "${RED}❌ Error: Failed to install PyYAML${NC}"
        echo -e "${YELLOW}💡 Try: pip3 install --break-system-packages PyYAML${NC}"
        exit 1
    }
}
echo -e "${GREEN}✓${NC}"

# Create a Python script to validate YAML and extract fields
PYTHON_VALIDATOR=$(cat <<'EOF'
import sys
import yaml

try:
    with open(sys.argv[1], 'r') as f:
        data = yaml.safe_load(f)
    
    # Check if data is valid
    if data is None:
        print("ERROR: Empty YAML file")
        sys.exit(1)
    
    # Get the field requested
    if len(sys.argv) > 2:
        field = sys.argv[2]
        parts = field.split('.')
        value = data
        for part in parts:
            if isinstance(value, dict) and part in value:
                value = value[part]
            else:
                print("null")
                sys.exit(0)
        
        if isinstance(value, dict):
            print(len(value))
        else:
            print(value if value is not None else "null")
    else:
        print("OK")
        
except yaml.YAMLError as e:
    print(f"YAML_ERROR: {e}")
    sys.exit(1)
except Exception as e:
    print(f"ERROR: {e}")
    sys.exit(1)
EOF
)

# Validate YAML syntax
echo -n "🔧 Checking YAML syntax... "
RESULT=$(echo "$PYTHON_VALIDATOR" | python3 - "$OPENAPI_FILE" 2>&1)
if [[ "$RESULT" == "OK" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo -e "${RED}❌ Error: Invalid YAML syntax${NC}"
    echo "$RESULT"
    exit 1
fi

# Check OpenAPI version
echo -n "📋 Checking OpenAPI version... "
OPENAPI_VERSION=$(echo "$PYTHON_VALIDATOR" | python3 - "$OPENAPI_FILE" "openapi")
if [[ -z "$OPENAPI_VERSION" || "$OPENAPI_VERSION" == "null" ]]; then
    echo -e "${RED}✗${NC}"
    echo -e "${RED}❌ Error: 'openapi' field not found${NC}"
    exit 1
fi

# Verify version is 3.0 or higher
if [[ ! "$OPENAPI_VERSION" =~ ^3\. ]]; then
    echo -e "${RED}✗${NC}"
    echo -e "${RED}❌ Error: OpenAPI version must be 3.0 or higher (found: $OPENAPI_VERSION)${NC}"
    exit 1
fi
echo -e "${GREEN}✓ $OPENAPI_VERSION${NC}"

# Check required top-level fields
echo "🔍 Checking required fields..."

REQUIRED_FIELDS=("info" "paths")
for field in "${REQUIRED_FIELDS[@]}"; do
    echo -n "  - $field: "
    FIELD_VALUE=$(echo "$PYTHON_VALIDATOR" | python3 - "$OPENAPI_FILE" "$field")
    if [[ "$FIELD_VALUE" == "null" ]]; then
        echo -e "${RED}✗ Missing${NC}"
        exit 1
    else
        echo -e "${GREEN}✓${NC}"
    fi
done

# Check info fields
echo -n "  - info.title: "
INFO_TITLE=$(echo "$PYTHON_VALIDATOR" | python3 - "$OPENAPI_FILE" "info.title")
if [[ -z "$INFO_TITLE" || "$INFO_TITLE" == "null" ]]; then
    echo -e "${RED}✗ Missing${NC}"
    exit 1
else
    echo -e "${GREEN}✓${NC}"
fi

echo -n "  - info.version: "
INFO_VERSION=$(echo "$PYTHON_VALIDATOR" | python3 - "$OPENAPI_FILE" "info.version")
if [[ -z "$INFO_VERSION" || "$INFO_VERSION" == "null" ]]; then
    echo -e "${RED}✗ Missing${NC}"
    exit 1
else
    echo -e "${GREEN}✓${NC}"
fi

# Check if paths are defined
echo -n "  - paths (count): "
PATHS_COUNT=$(echo "$PYTHON_VALIDATOR" | python3 - "$OPENAPI_FILE" "paths")
if [[ "$PATHS_COUNT" -eq 0 ]]; then
    echo -e "${RED}✗ No paths defined${NC}"
    exit 1
else
    echo -e "${GREEN}✓ $PATHS_COUNT${NC}"
fi

# Validate with openapi-spec-validator if available
if command -v openapi-spec-validator &> /dev/null; then
    echo -n "🔬 Running OpenAPI spec validator... "
    if openapi-spec-validator "$OPENAPI_FILE" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${RED}❌ OpenAPI specification validation failed:${NC}"
        openapi-spec-validator "$OPENAPI_FILE" 2>&1
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Note: 'openapi-spec-validator' not installed. Skipping deep validation.${NC}"
    echo -e "${YELLOW}   Install with: pip install openapi-spec-validator${NC}"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ OpenAPI specification is valid!${NC}"
exit 0
