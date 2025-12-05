# Project Overview - Complete Understanding Guide

## What You Have: Two Separate Projects

You actually have **TWO DIFFERENT PROJECTS** in this repository:

### 1. Strangler Studio (Main Demo)
**Location:** Root directory  
**Purpose:** A demonstration of the Strangler Fig migration pattern  
**What it does:** Shows how to gradually migrate from legacy PHP to modern Python

### 2. PHP Migration Tool (Frankenstein Laboratory)
**Location:** `php-migration-tool/` directory  
**Purpose:** An AI-powered tool to help migrate ANY PHP project to Python  
**What it does:** Analyzes PHP code and generates Python/FastAPI equivalents

---

## Project 1: Strangler Studio Demo

### What Is It?

A **working example** of migrating a legacy PHP application to modern Python/FastAPI using the Strangler Fig pattern.

### Architecture

```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│  Gateway (nginx) - Port 8888        │
│  Routes traffic based on URL        │
└──────┬──────────────────────┬───────┘
       │                      │
       ▼                      ▼
┌──────────────┐      ┌──────────────┐
│ Legacy PHP   │      │  New API     │
│ Port 8080    │      │  (Python)    │
│ Old system   │      │  Port 8000   │
└──────────────┘      └──────────────┘
```

### How It Works

1. **Gateway (nginx)** receives all requests on port 8888
2. **Routes traffic:**
   - `/` and `/requests` → Legacy PHP app
   - `/api/*` → New Python API
3. **Feature Flag:** The PHP app can call the new API when `use_new=1`
4. **Gradual Migration:** You can switch between old and new without downtime

### Key Files

```
strangler-studio/
├── gateway/
│   ├── nginx.conf          # Routing rules
│   └── Dockerfile
├── legacy-php/             # OLD PHP APPLICATION
│   ├── public/index.php    # Entry point
│   ├── src/
│   │   ├── Controllers/    # PHP controllers
│   │   ├── Services/       # API client
│   │   └── Views/          # HTML templates
│   └── styles/             # Halloween CSS
├── new-api/                # NEW PYTHON API
│   ├── app/
│   │   ├── main.py         # FastAPI app
│   │   ├── models.py       # Data models
│   │   └── data/           # Seed data
│   └── tests/              # Property-based tests
├── contracts/
│   └── openapi.yaml        # API contract (source of truth)
└── docker-compose.yml      # Orchestrates everything
```

### How to Use It

```bash
# Start the demo
docker-compose up -d

# Access via gateway (recommended)
open http://localhost:8888/

# Access legacy PHP directly
open http://localhost:8080/

# Test the feature flag
open http://localhost:8888/requests?use_new=0  # Legacy data
open http://localhost:8888/requests?use_new=1  # New API data

# Stop the demo
docker-compose down
```

### What You Can Learn

- How to route traffic with nginx
- How to implement feature flags
- How to gradually migrate without downtime
- How to use OpenAPI contracts
- How to write property-based tests

---

## Project 2: PHP Migration Tool (Frankenstein Laboratory)

### What Is It?

A **tool** that helps you migrate ANY PHP project to Python/FastAPI automatically.

### Architecture

```
┌─────────────────────────────────────┐
│  React Frontend (Port 3000)         │
│  - Upload PHP project               │
│  - View analysis                    │
│  - Download Python code             │
└──────────────┬──────────────────────┘
               │ HTTP/REST
               ▼
┌─────────────────────────────────────┐
│  FastAPI Backend (Port 8000)        │
│  - Clone GitHub repos               │
│  - Analyze PHP code                 │
│  - Generate OpenAPI specs           │
│  - Generate Python/FastAPI code     │
│  - Generate tests                   │
└─────────────────────────────────────┘
```

### How It Works

1. **Input:** You provide a GitHub URL of a PHP project
2. **Clone:** Tool clones the repository
3. **Analyze:** Parses PHP code to understand:
   - Routes and endpoints
   - Models and data structures
   - Business logic
   - Dependencies
4. **Generate:**
   - OpenAPI specification
   - Python/FastAPI code
   - Pydantic models
   - Property-based tests
5. **Download:** You get a complete Python project

### Key Files

```
php-migration-tool/
├── frontend/               # React UI (Frankenstein theme)
│   ├── src/
│   │   ├── App.jsx         # Main app
│   │   ├── components/     # UI components
│   │   │   ├── Input.jsx   # GitHub URL input
│   │   │   ├── Analysis.jsx
│   │   │   ├── Generate.jsx
│   │   │   └── Download.jsx
│   │   └── frankenstein-theme.css
│   └── Dockerfile
├── backend/                # FastAPI backend
│   ├── main.py             # API endpoints
│   ├── analyzers/
│   │   └── php_analyzer.py # PHP code parser
│   ├── generators/
│   │   ├── openapi_generator.py
│   │   ├── fastapi_generator.py
│   │   └── test_generator.py
│   └── Dockerfile
└── docker-compose.yml      # Separate from main project
```

### How to Use It

```bash
# Navigate to the tool
cd php-migration-tool

# Start the tool
docker-compose up -d

# Access the UI
open http://localhost:3000/

# Use the tool:
# 1. Enter GitHub URL (e.g., https://github.com/laravel/laravel)
# 2. Click "Begin Experiment"
# 3. Review analysis
# 4. Generate Python code
# 5. Download the result

# Stop the tool
docker-compose down
```

### What You Can Do With It

- Migrate your own PHP projects to Python
- Analyze PHP code structure
- Generate OpenAPI specifications
- Get Python/FastAPI code automatically
- Generate property-based tests

---

## How They Relate

```
┌─────────────────────────────────────────────────────────┐
│  Strangler Studio (Demo)                                │
│  Shows the END RESULT of a migration                    │
│  - Legacy PHP app                                       │
│  - New Python API                                       │
│  - Gateway routing                                      │
│  - Feature flags                                        │
└─────────────────────────────────────────────────────────┘
                          ▲
                          │
                          │ This is what you get after using...
                          │
┌─────────────────────────────────────────────────────────┐
│  PHP Migration Tool (Tool)                              │
│  Helps you CREATE a migration                           │
│  - Analyzes PHP code                                    │
│  - Generates Python code                                │
│  - Creates OpenAPI specs                                │
│  - Generates tests                                      │
└─────────────────────────────────────────────────────────┘
```

**Think of it this way:**
- **Strangler Studio** = The finished product (a migrated app)
- **Migration Tool** = The factory that helps you create your own migrated app

---

## Port Reference

### Strangler Studio Demo
| Service | Port | URL |
|---------|------|-----|
| Gateway | 8888 | http://localhost:8888/ |
| Legacy PHP | 8080 | http://localhost:8080/ |
| New API | 8000 | Internal only |

### PHP Migration Tool
| Service | Port | URL |
|---------|------|-----|
| Frontend | 3000 | http://localhost:3000/ |
| Backend | 8000 | http://localhost:8000/ |

---

## Quick Start Guide

### To See the Demo (Strangler Studio)

```bash
# From root directory
docker-compose up -d
open http://localhost:8888/
```

### To Use the Migration Tool

```bash
# From root directory
cd php-migration-tool
docker-compose up -d
open http://localhost:3000/
```

### To Migrate Your Own PHP Project

1. Start the migration tool (see above)
2. Enter your PHP project's GitHub URL
3. Click "Begin Experiment"
4. Review the analysis
5. Generate Python code
6. Download and use the generated code

---

## Common Workflows

### Workflow 1: Learn the Strangler Pattern

1. Start Strangler Studio demo
2. Open http://localhost:8888/
3. Click "Run the Ritual"
4. Toggle between "Legacy Curse" and "Modern Magic"
5. See how traffic routes between old and new

### Workflow 2: Migrate a PHP Project

1. Start the migration tool
2. Enter GitHub URL of PHP project
3. Let it analyze the code
4. Review the generated OpenAPI spec
5. Download the Python/FastAPI code
6. Set up your own Strangler pattern like the demo

### Workflow 3: Test the Demo as Migration Subject

1. Start Strangler Studio (port 8080)
2. Start Migration Tool (port 3000)
3. In migration tool, analyze the Strangler Studio PHP code
4. See how it would be migrated

---

## Key Concepts

### Strangler Fig Pattern

Named after strangler fig trees that grow around host trees:
1. Start with legacy system (the host tree)
2. Build new system alongside it (the strangler fig)
3. Gradually route traffic to new system
4. Eventually remove legacy system

### Feature Flags

Switches that control which code path to use:
```php
if ($_GET['use_new'] == 1) {
    // Use new API
    $data = $apiClient->fetchRequests();
} else {
    // Use legacy code
    $data = $this->stubData;
}
```

### Contract-First Design

Define the API contract (OpenAPI) first, then implement:
1. Write OpenAPI specification
2. Generate client code
3. Implement backend to match contract
4. Validate responses against contract

### Property-Based Testing

Instead of testing specific examples, test properties that should always hold:
```python
# Instead of: "When ID is 1, return user 1"
# Test: "For ANY valid ID, returned object should have matching ID"
@given(st.integers(min_value=1, max_value=7))
def test_api_returns_matching_id(request_id):
    response = client.get(f"/requests/{request_id}")
    assert response.json()["id"] == request_id
```

---

## Documentation Index

### Getting Started
- `README.md` - Main project overview
- `PROJECT_OVERVIEW.md` - This file
- `PORT_CHANGES_SUMMARY.md` - Port configuration

### Strangler Studio
- `.kiro/specs/strangler-studio/requirements.md` - Requirements
- `.kiro/specs/strangler-studio/design.md` - Design document
- `.kiro/specs/strangler-studio/tasks.md` - Implementation tasks
- `REPOSITORY_SETUP.md` - Git setup

### PHP Migration Tool
- `php-migration-tool/README.md` - Tool overview
- `php-migration-tool/GETTING_STARTED.md` - Detailed guide
- `php-migration-tool/DOCKER.md` - Docker setup
- `php-migration-tool/FRANKENSTEIN_THEME.md` - UI theme guide
- `php-migration-tool/CONNECTION_TEST_GUIDE.md` - Connection testing

### Troubleshooting
- `php-migration-tool/GITHUB_CLONE_TROUBLESHOOTING.md` - Git issues
- `php-migration-tool/TROUBLESHOOTING.md` - General issues
- `test-connection.sh` - Connection test script

### Code Quality
- `.kiro/steering/code-quality.md` - Code standards
- `.kiro/steering/testing-standards.md` - Testing guidelines
- `.kiro/steering/api-conventions.md` - API design
- `.kiro/steering/halloween-theme.md` - UI design

---

## Next Steps

### If You Want to Learn the Pattern
1. Read the Strangler Studio README
2. Start the demo
3. Explore the code in `legacy-php/` and `new-api/`
4. Read the design document

### If You Want to Migrate a Project
1. Read the Migration Tool README
2. Start the tool
3. Try it with a sample PHP project
4. Review the generated code

### If You Want to Contribute
1. Read the requirements and design docs
2. Check the tasks.md for completed work
3. Review the code quality standards
4. Run the tests

---

## Summary

You have:
1. **A working demo** showing how to migrate PHP to Python (Strangler Studio)
2. **A tool** to help you migrate your own PHP projects (Migration Tool)
3. **Complete documentation** for both
4. **Property-based tests** ensuring correctness
5. **Premium Halloween/Frankenstein themes** making it look awesome

Both projects are fully functional and ready to use!
