.PHONY: help build up down restart logs clean test

help: ## Show this help message
	@echo "PHP Migration Tool - Docker Commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker images
	docker-compose build

up: ## Start all services
	docker-compose up -d
	@echo ""
	@echo "✅ Services started!"
	@echo "Frontend: http://localhost"
	@echo "Backend:  http://localhost:8000"
	@echo "API Docs: http://localhost:8000/docs"

down: ## Stop all services
	docker-compose down

restart: ## Restart all services
	docker-compose restart

logs: ## View logs (all services)
	docker-compose logs -f

logs-backend: ## View backend logs
	docker-compose logs -f backend

logs-frontend: ## View frontend logs
	docker-compose logs -f frontend

ps: ## Show running containers
	docker-compose ps

clean: ## Stop and remove all containers, volumes, and images
	docker-compose down -v
	docker system prune -f

rebuild: ## Rebuild and restart everything
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d

shell-backend: ## Open shell in backend container
	docker-compose exec backend /bin/bash

shell-frontend: ## Open shell in frontend container
	docker-compose exec frontend /bin/sh

test: ## Run backend tests
	docker-compose exec backend pytest

backup: ## Backup volumes
	@mkdir -p backups
	docker run --rm -v php-migration-tool_backend-uploads:/data -v $(PWD)/backups:/backup alpine tar czf /backup/uploads-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	docker run --rm -v php-migration-tool_backend-outputs:/data -v $(PWD)/backups:/backup alpine tar czf /backup/outputs-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	@echo "✅ Backup complete in ./backups/"

dev: ## Start in development mode with logs
	docker-compose up --build

prod: ## Start in production mode (detached)
	docker-compose up -d --build
	@echo "✅ Production mode started"
	@echo "Frontend: http://localhost"
	@echo "Backend:  http://localhost:8000"
