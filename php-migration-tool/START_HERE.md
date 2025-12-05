# 🚀 START HERE - PHP Migration Tool

## The Fastest Way to Get Started

### 1️⃣ Start the Application (One Command!)

```bash
docker-compose up --build
```

### 2️⃣ Open Your Browser

```
http://localhost
```

### 3️⃣ Upload Your PHP Project

- Create a ZIP of your PHP project
- Drag & drop into the web UI
- Click "Upload & Continue"

### 4️⃣ Done! 🎉

The tool will:
- ✅ Analyze your PHP code
- ✅ Generate Python/FastAPI code
- ✅ Create OpenAPI specification
- ✅ Generate tests
- ✅ Package everything as ZIP

---

## Visual Guide

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Step 1: Upload PHP Project (ZIP)                          │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  📦 Drag & Drop your PHP project here              │  │
│  │     or click to browse                              │  │
│  └─────────────────────────────────────────────────────┘  │
│                          ↓                                  │
│  Step 2: Analyze (Automatic)                               │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  🔍 Found:                                          │  │
│  │     • 15 Routes                                     │  │
│  │     • 8 Models                                      │  │
│  │     • 42 PHP Files                                  │  │
│  └─────────────────────────────────────────────────────┘  │
│                          ↓                                  │
│  Step 3: Generate Python Code                              │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  ⚙️ Generating:                                     │  │
│  │     ✓ OpenAPI Spec                                  │  │
│  │     ✓ FastAPI Routes                                │  │
│  │     ✓ Pydantic Models                               │  │
│  │     ✓ Test Suite                                    │  │
│  └─────────────────────────────────────────────────────┘  │
│                          ↓                                  │
│  Step 4: Download & Run                                    │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  📥 Download Complete Project                       │  │
│  │                                                      │  │
│  │  Then run:                                          │  │
│  │  $ pip install -r requirements.txt                  │  │
│  │  $ uvicorn main:app --reload                        │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Commands

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# View logs
docker-compose logs -f

# Restart
docker-compose restart

# Clean everything
docker-compose down -v
```

---

## With Makefile (Even Easier!)

```bash
make up      # Start
make down    # Stop
make logs    # View logs
make clean   # Clean all
make help    # Show all commands
```

---

## Access Points

| Service | URL | Description |
|---------|-----|-------------|
| **Web UI** | http://localhost | Main application |
| **Backend API** | http://localhost:8000 | REST API |
| **API Docs** | http://localhost:8000/docs | Interactive API docs |

---

## Test with Example

Want to test immediately? Use the legacy PHP from Strangler Studio:

```bash
# Create ZIP
cd ..
zip -r legacy-php.zip legacy-php/

# Start tool
cd php-migration-tool
docker-compose up -d

# Open browser and upload legacy-php.zip
open http://localhost
```

---

## Need Help?

📖 **Documentation:**
- [GETTING_STARTED.md](GETTING_STARTED.md) - Detailed walkthrough
- [DOCKER.md](DOCKER.md) - Docker guide
- [README.md](README.md) - Project overview

🐛 **Troubleshooting:**
```bash
# View logs
docker-compose logs

# Rebuild
docker-compose build --no-cache

# Reset everything
docker-compose down -v
docker-compose up --build
```

---

## What You Get

After migration, you'll have a complete Python project with:

```
migrated-python-api/
├── main.py              # FastAPI application
├── routes.py            # API endpoints
├── models.py            # Pydantic models
├── test_api.py          # Test suite
├── openapi.yaml         # API specification
├── requirements.txt     # Dependencies
└── README.md            # Documentation
```

---

## System Requirements

- **Docker Desktop** (recommended)
- OR **Python 3.11+** and **Node.js 18+** for local dev

---

## That's It!

You're ready to migrate PHP to Python! 🎉

```bash
docker-compose up --build
```

Then open: **http://localhost**

---

**Questions?** Check the docs or open an issue!

**License:** MIT - Free to use and modify
