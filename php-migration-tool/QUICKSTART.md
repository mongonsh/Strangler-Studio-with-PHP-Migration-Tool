# Quick Start Guide

## Setup

### 1. Backend Setup

```bash
cd php-migration-tool/backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run backend
python main.py
```

Backend will run on: http://localhost:8000

### 2. Frontend Setup

```bash
cd php-migration-tool/frontend

# Install dependencies
npm install

# Run frontend
npm run dev
```

Frontend will run on: http://localhost:5173

## Usage

1. **Open Browser**: Navigate to http://localhost:5173

2. **Upload PHP Project**:
   - Create a ZIP file of your PHP project
   - Upload it through the web interface

3. **Analyze**:
   - Tool automatically analyzes your PHP code
   - Extracts routes, models, and dependencies

4. **Generate**:
   - Click "Generate Python Code"
   - Creates FastAPI project with:
     - OpenAPI specification
     - FastAPI routes
     - Pydantic models
     - Test suite

5. **Download**:
   - Preview generated files
   - Download complete Python project as ZIP

6. **Run Migrated Project**:
   ```bash
   unzip migrated-python-api-*.zip
   cd migrated-python-api-*
   pip install -r requirements.txt
   uvicorn main:app --reload
   ```

## Test with Example

Use the existing `legacy-php` folder from Strangler Studio:

```bash
# Create ZIP of legacy-php
cd ..
zip -r legacy-php.zip legacy-php/

# Upload this ZIP through the web UI
```

## API Endpoints

- `POST /api/upload` - Upload PHP project ZIP
- `POST /api/analyze/{upload_id}` - Analyze PHP code
- `POST /api/generate/{upload_id}` - Generate Python code
- `GET /api/download/{output_id}` - Download generated project
- `GET /api/preview/{output_id}/{filename}` - Preview file

## Features

✅ Extracts routes from Laravel, Slim, Symfony, and plain PHP
✅ Converts PHP classes to Pydantic models
✅ Generates OpenAPI 3.0 specifications
✅ Creates FastAPI endpoints
✅ Generates pytest test suite
✅ Beautiful web UI with progress tracking
✅ File preview before download

## Troubleshooting

**Backend won't start:**
- Check Python version (3.9+)
- Ensure all dependencies installed
- Check port 8000 is available

**Frontend won't start:**
- Check Node.js version (16+)
- Run `npm install` again
- Check port 5173 is available

**Upload fails:**
- Ensure file is a valid ZIP
- Check file size (< 100MB recommended)
- Verify backend is running

## Next Steps

- Add AI integration (OpenAI GPT-4) for complex logic
- Implement more PHP framework support
- Add database migration tools
- Create deployment scripts
- Add more test generation patterns

## License

MIT
