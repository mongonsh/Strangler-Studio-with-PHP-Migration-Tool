#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     REBUILDING BACKEND CONTAINER WITH GIT SUPPORT         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Navigate to php-migration-tool directory
cd "$(dirname "$0")"

echo "1. Stopping containers..."
docker-compose down

echo ""
echo "2. Removing old backend image..."
docker-compose rm -f backend
docker rmi php-migration-tool-backend 2>/dev/null || true

echo ""
echo "3. Rebuilding backend with --no-cache..."
docker-compose build --no-cache backend

echo ""
echo "4. Starting services..."
docker-compose up -d

echo ""
echo "5. Waiting for services to be ready..."
sleep 5

echo ""
echo "6. Verifying git installation..."
docker-compose exec backend git --version

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ SUCCESS! Backend container rebuilt with git support"
    echo ""
    echo "You can now use GitHub repository cloning:"
    echo "  - Open http://localhost:3000"
    echo "  - Enter a GitHub repository URL"
    echo "  - Click 'Begin Experiment'"
    echo ""
    echo "Example repositories to try:"
    echo "  - https://github.com/laravel/laravel"
    echo "  - https://github.com/mongonsh/legacy-project-trae"
else
    echo ""
    echo "✗ ERROR: Git verification failed"
    echo "Please check the logs: docker-compose logs backend"
fi
