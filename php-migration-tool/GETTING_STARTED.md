# Getting Started with PHP Migration Tool

## Prerequisites

- Docker Desktop installed ([Download](https://www.docker.com/products/docker-desktop))
- OR Node.js 18+ and Python 3.11+ for local development

## Installation

### Method 1: Docker (Easiest) 🐳

1. **Clone or download the project**
   ```bash
   cd php-migration-tool
   ```

2. **Start the application**
   ```bash
   docker-compose up --build
   ```
   
   Or use the Makefile:
   ```bash
   make up
   ```

3. **Access the application**
   - Open your browser to: http://localhost
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

4. **Stop the application**
   ```bash
   docker-compose down
   ```
   
   Or:
   ```bash
   make down
   ```

### Method 2: Local Development

**Backend:**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

**Frontend (in another terminal):**
```bash
cd frontend
npm install
npm run dev
```

Access at: http://localhost:5173

## First Migration

### Step 1: Prepare Your PHP Project

Create a ZIP file of your PHP project:

```bash
# Example: Using the legacy-php from Strangler Studio
cd ..
zip -r my-php-project.zip legacy-php/
```

### Step 2: Upload

1. Open http://localhost in your browser
2. Drag and drop your ZIP file or click to browse
3. Click "Upload & Continue"

### Step 3: Analyze

The tool will automatically:
- Extract routes (GET, POST, PUT, DELETE)
- Find models and classes
- Identify dependencies
- Count PHP files

Review the analysis results showing:
- Number of routes found
- Number of models/classes
- Total PHP files analyzed

### Step 4: Generate

Click "Generate Python Code" to create:
- ✅ OpenAPI 3.0 specification
- ✅ FastAPI routes
- ✅ Pydantic models
- ✅ pytest test suite
- ✅ requirements.txt
- ✅ README.md

### Step 5: Download

1. Preview generated files in the browser
2. Click "Download Complete Project"
3. Extract the ZIP file

### Step 6: Run Your Migrated Project

```bash
# Extract and navigate
unzip migrated-python-api-*.zip
cd migrated-python-api-*

# Install dependencies
pip install -r requirements.txt

# Run the API
uvicorn main:app --reload

# Access at http://localhost:8000
# API docs at http://localhost:8000/docs
```

## Example Workflow

Here's a complete example using the Strangler Studio legacy PHP:

```bash
# 1. Create ZIP of PHP project
cd ..
zip -r legacy-php.zip legacy-php/

# 2. Start migration tool
cd php-migration-tool
docker-compose up -d

# 3. Open browser
open http://localhost

# 4. Upload legacy-php.zip through the UI

# 5. Review analysis (should show routes like /requests, /)

# 6. Generate Python code

# 7. Download and test
unzip ~/Downloads/migrated-python-api-*.zip
cd migrated-python-api-*
pip install -r requirements.txt
uvicorn main:app --reload

# 8. Test the migrated API
curl http://localhost:8000/
curl http://localhost:8000/requests
```

## Makefile Commands

If you have `make` installed:

```bash
make help          # Show all commands
make up            # Start services
make down          # Stop services
make logs          # View logs
make restart       # Restart services
make clean         # Clean everything
make rebuild       # Rebuild from scratch
make backup        # Backup data
make shell-backend # Open backend shell
```

## Supported PHP Frameworks

The tool can analyze:
- ✅ Laravel (Route::get, Route::post, etc.)
- ✅ Slim Framework ($app->get, $app->post, etc.)
- ✅ Symfony
- ✅ Plain PHP (with routing logic)

## What Gets Generated

### OpenAPI Specification (openapi.yaml)
```yaml
openapi: 3.0.3
info:
  title: Migrated API
  version: 1.0.0
paths:
  /requests:
    get:
      summary: GET /requests
      responses:
        '200':
          description: Successful response
```

### FastAPI Code (main.py, routes.py, models.py)
```python
from fastapi import FastAPI
from routes import router

app = FastAPI()
app.include_router(router)

@app.get("/")
async def root():
    return {"status": "healthy"}
```

### Tests (test_api.py)
```python
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
```

## Troubleshooting

### Docker Issues

**Port already in use:**
```bash
# Edit docker-compose.yml and change ports
ports:
  - "8080:80"  # Instead of 80:80
```

**Services won't start:**
```bash
# View logs
docker-compose logs

# Rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up
```

**Out of disk space:**
```bash
docker system prune -a
docker volume prune
```

### Upload Issues

**File too large:**
- Maximum recommended size: 100MB
- For larger projects, split into modules

**Invalid ZIP:**
- Ensure ZIP contains PHP files
- Check ZIP is not corrupted

### Generation Issues

**No routes found:**
- Check if PHP uses supported framework
- Verify routing patterns in code

**Missing models:**
- Tool looks for `class` definitions
- Ensure classes are in PHP files

## Advanced Usage

### Custom Configuration

Create `.env` file:
```env
BACKEND_PORT=8000
FRONTEND_PORT=80
MAX_UPLOAD_SIZE=100MB
```

### API Integration

Use the REST API directly:

```bash
# Upload
curl -X POST -F "file=@project.zip" http://localhost:8000/api/upload

# Analyze
curl -X POST http://localhost:8000/api/analyze/{upload_id}

# Generate
curl -X POST http://localhost:8000/api/generate/{upload_id} \
  -H "Content-Type: application/json" \
  -d '{"analysis": {...}, "options": {}}'

# Download
curl -O http://localhost:8000/api/download/{output_id}
```

### Development Mode

For hot-reload during development:

```bash
# Backend with volume mount
docker-compose up backend

# Frontend locally
cd frontend
npm run dev
```

## Next Steps

1. ✅ Test with your PHP project
2. ✅ Review generated code
3. ✅ Customize as needed
4. ✅ Add business logic
5. ✅ Deploy to production

## Resources

- [Docker Documentation](DOCKER.md)
- [API Documentation](http://localhost:8000/docs)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [Pydantic Docs](https://docs.pydantic.dev/)

## Support

Having issues? Check:
1. Docker is running
2. Ports 80 and 8000 are available
3. Logs: `docker-compose logs`
4. Health: `docker-compose ps`

## License

MIT License - Free to use and modify
