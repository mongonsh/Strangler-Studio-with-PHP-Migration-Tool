# PHP to Python Migration Tool

An AI-powered tool to migrate legacy PHP applications to modern Python/FastAPI services.

## Features

- 🔍 **Analyze PHP Code**: Parse and understand PHP project structure
- 🤖 **AI-Powered**: Uses LLM to understand business logic
- 📝 **Generate OpenAPI**: Creates contract-first API specifications
- 🐍 **Generate Python**: Produces FastAPI code from PHP
- 🎨 **Web UI**: Beautiful dashboard to manage migrations
- ✅ **Generate Tests**: Creates property-based tests automatically

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Web UI (React)                       │
│  Upload → Analyze → Review → Generate → Download       │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP/REST
┌────────────────────▼────────────────────────────────────┐
│              Backend API (FastAPI)                      │
│  - PHP Parser                                           │
│  - Route Extractor                                      │
│  - OpenAPI Generator                                    │
│  - Python Code Generator                                │
│  - LLM Integration                                      │
└─────────────────────────────────────────────────────────┘
```

## Quick Start

### Option 1: Docker (Recommended) 🐳

```bash
# Start everything with one command
docker-compose up --build

# Access the application
# Frontend: http://localhost
# Backend API: http://localhost:8000
# API Docs: http://localhost:8000/docs
```

See [DOCKER.md](DOCKER.md) for detailed Docker documentation.

### Option 2: Local Development

**Backend:**
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```

**Access:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

## Usage

1. **Upload PHP Project**: Zip your PHP project and upload
2. **Analyze**: Tool extracts routes, models, and business logic
3. **Review**: See analysis results and configure migration
4. **Generate**: Creates Python/FastAPI code, OpenAPI spec, tests
5. **Download**: Get complete migrated project

## Tech Stack

- **Frontend**: React + Vite + Tailwind CSS
- **Backend**: FastAPI + Python 3.9+
- **AI**: OpenAI GPT-4 (optional)
- **Parser**: php-parser-python
- **Testing**: pytest + Hypothesis

## Troubleshooting

### GitHub Clone Error: "Cmd('git') not found"

If you see this error when trying to clone a GitHub repository:

```bash
# Quick fix - rebuild the backend container
./REBUILD_BACKEND.sh
```

Or manually:
```bash
docker-compose down
docker-compose build --no-cache backend
docker-compose up -d
```

See [GITHUB_CLONE_TROUBLESHOOTING.md](GITHUB_CLONE_TROUBLESHOOTING.md) for detailed troubleshooting.

### Common Issues

**Container won't start:**
```bash
docker-compose logs backend
docker-compose down -v
docker-compose up --build
```

**Port already in use:**
```bash
# Change ports in docker-compose.yml
# Or stop conflicting services
```

**Permission errors:**
```bash
docker-compose down
docker volume prune -f
docker-compose up -d
```

## Documentation

- [DOCKER.md](DOCKER.md) - Docker setup and configuration
- [GETTING_STARTED.md](GETTING_STARTED.md) - Detailed getting started guide
- [GITHUB_CLONE_TROUBLESHOOTING.md](GITHUB_CLONE_TROUBLESHOOTING.md) - GitHub clone issues
- [FRANKENSTEIN_THEME.md](FRANKENSTEIN_THEME.md) - UI theme guidelines

## License

MIT
