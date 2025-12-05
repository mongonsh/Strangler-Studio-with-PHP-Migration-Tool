#!/bin/bash

echo "⚡ Frankenstein Laboratory - Reanimation Protocol"
echo "=================================================="
echo ""

echo "Step 1: Shutting down laboratory..."
docker-compose down

echo ""
echo "Step 2: Rebuilding backend with Git capabilities..."
docker-compose build --no-cache backend

echo ""
echo "Step 3: Reanimating services..."
docker-compose up -d

echo ""
echo "Step 4: Charging the equipment..."
sleep 10

echo ""
echo "Step 5: Testing laboratory systems..."
echo "Backend health check:"
curl -s http://localhost:8000/ | python3 -m json.tool 2>/dev/null || echo "Backend not ready yet, wait a moment..."

echo ""
echo "Step 6: Verifying Git installation..."
docker-compose exec -T backend git --version

echo ""
echo "Step 7: Testing specimen acquisition (GitHub clone)..."
curl -X POST http://localhost:8000/api/clone-github \
  -H "Content-Type: application/json" \
  -d '{"repo_url":"https://github.com/laravel/laravel","branch":"10.x"}' \
  2>/dev/null | python3 -m json.tool 2>/dev/null || echo "Clone test failed - check logs"

echo ""
echo "=================================================="
echo "⚡ IT'S ALIVE! Laboratory is operational!"
echo "=================================================="
echo ""
echo "Access the laboratory at: http://localhost"
echo ""
echo "If issues persist:"
echo "  - Check logs: docker-compose logs backend"
echo "  - Verify Git: docker-compose exec backend git --version"
echo "  - Full reset: docker-compose down -v && docker-compose up --build"
