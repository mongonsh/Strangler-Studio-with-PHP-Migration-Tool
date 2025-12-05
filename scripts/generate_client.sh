#!/bin/bash

# generate_client.sh
# Generates typed client from OpenAPI contract
# Exit code 0 on success, 1 on failure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OPENAPI_FILE="contracts/openapi.yaml"
OUTPUT_DIR="generated/client"
GENERATOR="python"  # Can be changed to typescript, javascript, etc.

echo "🚀 Generating client from OpenAPI specification..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if OpenAPI file exists
if [ ! -f "$OPENAPI_FILE" ]; then
    echo -e "${RED}❌ Error: OpenAPI file not found at $OPENAPI_FILE${NC}"
    echo -e "${YELLOW}💡 Tip: Run from project root directory${NC}"
    exit 1
fi

echo "📄 Input: $OPENAPI_FILE"
echo "📁 Output: $OUTPUT_DIR"
echo "🔧 Generator: $GENERATOR"
echo ""

# Validate OpenAPI file first
echo "🔍 Validating OpenAPI specification first..."
if [ -f "scripts/validate_openapi.sh" ]; then
    if bash scripts/validate_openapi.sh > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Validation passed${NC}"
    else
        echo -e "${RED}❌ Error: OpenAPI validation failed${NC}"
        echo -e "${YELLOW}💡 Run 'bash scripts/validate_openapi.sh' for details${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Warning: validate_openapi.sh not found, skipping validation${NC}"
fi

echo ""

# Check if openapi-generator-cli is installed
if ! command -v openapi-generator-cli &> /dev/null; then
    echo -e "${YELLOW}⚠️  'openapi-generator-cli' not found${NC}"
    echo ""
    echo "Installing openapi-generator-cli via npm..."
    
    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}❌ Error: npm is not installed${NC}"
        echo ""
        echo "Please install Node.js and npm, then install openapi-generator-cli:"
        echo "  npm install -g @openapitools/openapi-generator-cli"
        echo ""
        echo "Alternatively, use Docker:"
        echo "  docker run --rm -v \${PWD}:/local openapitools/openapi-generator-cli generate \\"
        echo "    -i /local/$OPENAPI_FILE \\"
        echo "    -g $GENERATOR \\"
        echo "    -o /local/$OUTPUT_DIR"
        exit 1
    fi
    
    npm install -g @openapitools/openapi-generator-cli || {
        echo -e "${RED}❌ Error: Failed to install openapi-generator-cli${NC}"
        exit 1
    }
fi

# Create output directory
echo "📁 Creating output directory..."
mkdir -p "$OUTPUT_DIR"

# Generate client
echo "⚙️  Generating client code..."
echo ""

openapi-generator-cli generate \
    -i "$OPENAPI_FILE" \
    -g "$GENERATOR" \
    -o "$OUTPUT_DIR" \
    --additional-properties=packageName=strangler_studio_client,projectName=strangler-studio-client \
    2>&1 | while IFS= read -r line; do
        # Filter out verbose output, show only important messages
        if [[ "$line" =~ (Successfully|Error|Warning|writing) ]]; then
            echo "  $line"
        fi
    done

# Check if generation was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}✅ Client generated successfully!${NC}"
    echo ""
    echo "📦 Generated files:"
    
    # List key generated files
    if [ -d "$OUTPUT_DIR" ]; then
        FILE_COUNT=$(find "$OUTPUT_DIR" -type f | wc -l)
        echo "  Total files: $FILE_COUNT"
        echo ""
        echo "  Key files:"
        
        # Show some key files based on generator type
        if [ "$GENERATOR" == "python" ]; then
            [ -f "$OUTPUT_DIR/setup.py" ] && echo "    - setup.py"
            [ -f "$OUTPUT_DIR/README.md" ] && echo "    - README.md"
            [ -d "$OUTPUT_DIR/strangler_studio_client" ] && echo "    - strangler_studio_client/ (package)"
        elif [ "$GENERATOR" == "typescript-fetch" ] || [ "$GENERATOR" == "typescript-axios" ]; then
            [ -f "$OUTPUT_DIR/package.json" ] && echo "    - package.json"
            [ -f "$OUTPUT_DIR/README.md" ] && echo "    - README.md"
            [ -d "$OUTPUT_DIR/api" ] && echo "    - api/ (API clients)"
        fi
    fi
    
    echo ""
    echo -e "${BLUE}📖 Usage:${NC}"
    if [ "$GENERATOR" == "python" ]; then
        echo "  cd $OUTPUT_DIR"
        echo "  pip install -e ."
        echo "  python -c 'from strangler_studio_client import ApiClient, Configuration, RequestsApi'"
    elif [ "$GENERATOR" == "typescript-fetch" ] || [ "$GENERATOR" == "typescript-axios" ]; then
        echo "  cd $OUTPUT_DIR"
        echo "  npm install"
        echo "  import { RequestsApi } from './$OUTPUT_DIR'"
    fi
    
    exit 0
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${RED}❌ Client generation failed${NC}"
    echo ""
    echo -e "${YELLOW}💡 Troubleshooting:${NC}"
    echo "  1. Verify OpenAPI file is valid: bash scripts/validate_openapi.sh"
    echo "  2. Check generator name is correct (python, typescript-fetch, etc.)"
    echo "  3. Review error messages above"
    exit 1
fi
