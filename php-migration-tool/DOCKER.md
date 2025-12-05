# Docker Setup Guide

## Quick Start (Recommended)

The easiest way to run the PHP Migration Tool is with Docker Compose:

```bash
# Clone or navigate to the project
cd php-migration-tool

# Start all services
docker-compose up --build

# Access the application
# Frontend: http://localhost
# Backend API: http://localhost:8000
# API Docs: http://localhost:8000/docs
```

That's it! The tool is now running. 🚀

## Stopping the Services

```bash
# Stop services (keeps data)
docker-compose down

# Stop and remove all data
docker-compose down -v
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Network                        │
│                                                          │
│  ┌──────────────────┐         ┌──────────────────┐     │
│  │   Frontend       │         │    Backend       │     │
│  │   (nginx:alpine) │────────▶│   (Python 3.11)  │     │
│  │   Port: 80       │         │   Port: 8000     │     │
│  └──────────────────┘         └──────────────────┘     │
│                                                          │
│  Volumes:                                                │
│  - backend-uploads  (uploaded PHP projects)             │
│  - backend-outputs  (generated Python code)             │
└─────────────────────────────────────────────────────────┘
```

## Services

### Frontend (React + nginx)
- **Image**: Multi-stage build (Node.js → nginx)
- **Port**: 80
- **Features**:
  - Production-optimized build
  - Gzip compression
  - Static asset caching
  - API proxy to backend

### Backend (FastAPI + Python)
- **Image**: Python 3.11 slim
- **Port**: 8000
- **Features**:
  - PHP code analysis
  - Code generation
  - File management
  - REST API

## Development Mode

For development with hot-reload:

### Backend Development
```bash
cd backend
docker build -t migration-backend .
docker run -p 8000:8000 -v $(pwd):/app migration-backend
```

### Frontend Development
```bash
cd frontend
npm install
npm run dev
# Runs on http://localhost:5173
```

## Production Deployment

### Build Production Images

```bash
# Build both services
docker-compose build

# Or build individually
docker build -t migration-backend ./backend
docker build -t migration-frontend ./frontend
```

### Run in Production

```bash
# Start in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### Environment Variables

Create a `.env` file from `.env.example`:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:
```env
BACKEND_PORT=8000
FRONTEND_PORT=80
MAX_UPLOAD_SIZE=100MB
CORS_ORIGINS=http://localhost,http://yourdomain.com
```

## Volumes

### Persistent Data

The tool uses Docker volumes for data persistence:

- `backend-uploads`: Stores uploaded PHP projects
- `backend-outputs`: Stores generated Python code

### Backup Data

```bash
# Backup uploads
docker run --rm -v migration-tool_backend-uploads:/data -v $(pwd):/backup alpine tar czf /backup/uploads-backup.tar.gz -C /data .

# Backup outputs
docker run --rm -v migration-tool_backend-outputs:/data -v $(pwd):/backup alpine tar czf /backup/outputs-backup.tar.gz -C /data .
```

### Restore Data

```bash
# Restore uploads
docker run --rm -v migration-tool_backend-uploads:/data -v $(pwd):/backup alpine tar xzf /backup/uploads-backup.tar.gz -C /data

# Restore outputs
docker run --rm -v migration-tool_backend-outputs:/data -v $(pwd):/backup alpine tar xzf /backup/outputs-backup.tar.gz -C /data
```

## Networking

Services communicate via Docker network `migration-network`:

- Frontend → Backend: `http://backend:8000`
- External → Frontend: `http://localhost:80`
- External → Backend: `http://localhost:8000`

## Health Checks

Both services include health checks:

```bash
# Check service health
docker-compose ps

# View health check logs
docker inspect migration-tool-backend | grep -A 10 Health
docker inspect migration-tool-frontend | grep -A 10 Health
```

## Troubleshooting

### Port Already in Use

If port 80 or 8000 is already in use:

```yaml
# Edit docker-compose.yml
services:
  frontend:
    ports:
      - "8080:80"  # Change to 8080
  backend:
    ports:
      - "8001:8000"  # Change to 8001
```

### Container Won't Start

```bash
# View logs
docker-compose logs backend
docker-compose logs frontend

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Permission Issues

```bash
# Fix volume permissions
docker-compose down
docker volume rm migration-tool_backend-uploads migration-tool_backend-outputs
docker-compose up
```

### Out of Disk Space

```bash
# Clean up Docker
docker system prune -a
docker volume prune
```

## Scaling

To run multiple backend instances:

```bash
# Scale backend to 3 instances
docker-compose up --scale backend=3
```

Add a load balancer (nginx) in front for production.

## Security

### Production Checklist

- [ ] Change default ports
- [ ] Set up HTTPS/SSL
- [ ] Configure firewall rules
- [ ] Set resource limits
- [ ] Enable authentication
- [ ] Regular security updates
- [ ] Monitor logs

### Resource Limits

Add to `docker-compose.yml`:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

## Monitoring

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend

# Last 100 lines
docker-compose logs --tail=100
```

### Resource Usage

```bash
# Real-time stats
docker stats

# Specific container
docker stats migration-tool-backend
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build images
        run: docker-compose build
      
      - name: Run tests
        run: docker-compose run backend pytest
      
      - name: Deploy
        run: |
          docker-compose down
          docker-compose up -d
```

## Advanced Configuration

### Custom nginx Config

Edit `frontend/nginx.conf` for custom routing, caching, or security headers.

### Custom Python Packages

Add to `backend/requirements.txt` and rebuild:

```bash
docker-compose build backend
docker-compose up -d backend
```

## Support

For issues or questions:
- Check logs: `docker-compose logs`
- Verify health: `docker-compose ps`
- Rebuild: `docker-compose build --no-cache`
- Reset: `docker-compose down -v && docker-compose up`

## License

MIT
