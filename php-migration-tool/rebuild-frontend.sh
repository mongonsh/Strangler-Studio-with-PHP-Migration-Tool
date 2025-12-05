#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║        REBUILDING FRONTEND WITH LOGO                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Navigate to php-migration-tool directory
cd "$(dirname "$0")"

echo "1. Stopping frontend container..."
docker-compose stop frontend

echo ""
echo "2. Removing old frontend image..."
docker-compose rm -f frontend
docker rmi php-migration-tool-frontend 2>/dev/null || true

echo ""
echo "3. Rebuilding frontend with --no-cache..."
docker-compose build --no-cache frontend

echo ""
echo "4. Starting frontend..."
docker-compose up -d frontend

echo ""
echo "5. Waiting for frontend to be ready..."
sleep 5

echo ""
echo "6. Checking if logo is accessible..."
curl -I http://localhost/frankshtein.png 2>&1 | grep "HTTP"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ SUCCESS! Frontend rebuilt with logo"
    echo ""
    echo "Open http://localhost/ to see the animated logo!"
else
    echo ""
    echo "⚠ Logo might not be accessible yet, check logs:"
    echo "docker-compose logs frontend"
fi
