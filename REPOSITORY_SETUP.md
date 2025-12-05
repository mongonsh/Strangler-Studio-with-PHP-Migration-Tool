# Repository Setup Guide

This document describes the repository structure and setup for Strangler Studio.

## Repository Initialization

The repository has been initialized with:
- Git repository on `main` branch
- Comprehensive `.gitignore` file
- MIT License
- Initial commit with all project files

## .gitignore Configuration

The `.gitignore` file excludes:

### Python
- `__pycache__/`, `*.pyc`, `*.pyo`
- Virtual environments: `venv/`, `env/`, `.venv`
- Build artifacts: `build/`, `dist/`, `*.egg-info/`
- Testing: `.pytest_cache/`, `.hypothesis/`, `.coverage`

### PHP
- `vendor/`
- `composer.lock`
- `*.cache`

### Node.js
- `node_modules/`
- `package-lock.json`
- `dist/`, `build/`
- Log files

### Environment & Secrets
- `.env`, `.env.local`, `.env.*.local`

### Generated Files
- `generated/` (OpenAPI client code)
- `**/cloned_repos/` (PHP migration tool)
- `**/uploads/` (PHP migration tool)
- `**/generated_projects/` (PHP migration tool)

### IDE & OS
- `.vscode/`, `.idea/`
- `.DS_Store`, `Thumbs.db`
- Swap files: `*.swp`, `*.swo`

### Important: .kiro Directory
The `.kiro/` directory is **NOT ignored** and must be committed. It contains:
- Specifications (`specs/`)
- Steering rules (`steering/`)
- Agent hooks (`hooks/`)

## Fresh Clone Workflow

To verify the repository works after a fresh clone:

```bash
# Clone the repository
git clone <repository-url>
cd strangler-studio

# Verify all files are present
ls -la .kiro/

# Start the main demo
docker-compose up -d

# Or start the PHP migration tool
cd php-migration-tool
docker-compose up -d
```

## Repository Structure

```
strangler-studio/
├── .gitignore              # Git exclusions
├── LICENSE                 # MIT License
├── README.md               # Main documentation
├── docker-compose.yml      # Main demo orchestration
│
├── .kiro/                  # Kiro IDE configuration (MUST BE COMMITTED)
│   ├── specs/              # Project specifications
│   ├── steering/           # Code quality rules
│   └── hooks/              # Agent hooks
│
├── contracts/              # OpenAPI specifications
│   └── openapi.yaml
│
├── gateway/                # Nginx reverse proxy
│   ├── Dockerfile
│   └── nginx.conf
│
├── legacy-php/             # Legacy PHP application
│   ├── Dockerfile
│   ├── public/
│   ├── src/
│   └── styles/
│
├── new-api/                # Modern Python/FastAPI
│   ├── Dockerfile
│   ├── app/
│   ├── tests/
│   └── requirements.txt
│
├── php-migration-tool/     # PHP to Python migration tool
│   ├── docker-compose.yml
│   ├── backend/            # FastAPI backend
│   ├── frontend/           # React frontend
│   └── Makefile
│
├── scripts/                # Utility scripts
│   ├── demo.sh
│   ├── test_all.sh
│   └── validate_openapi.sh
│
└── tests/                  # Integration tests
    ├── test_smoke.sh
    ├── test_golden.sh
    └── test_property_*.sh
```

## Verification Checklist

Before pushing to remote:

- [x] `.gitignore` properly excludes build artifacts
- [x] `.gitignore` properly excludes dependencies (node_modules, venv)
- [x] `.gitignore` properly excludes secrets (.env)
- [x] `.kiro/` directory is tracked and committed
- [x] LICENSE file is present (MIT)
- [x] README.md is comprehensive
- [x] All docker-compose.yml files are valid
- [x] Fresh clone workflow works
- [x] No sensitive data in repository

## Testing the Setup

Run the verification script:

```bash
# Test that all required files are present
./scripts/test_all.sh

# Test fresh clone workflow
git clone <repo-url> /tmp/test-clone
cd /tmp/test-clone
docker-compose config  # Should succeed
```

## Common Issues

### .kiro directory not tracked
If `.kiro/` is not in the repository:
```bash
git add -f .kiro/
git commit -m "Add .kiro directory"
```

### Unwanted files tracked
If files that should be ignored are tracked:
```bash
git rm --cached <file>
git commit -m "Remove tracked file that should be ignored"
```

### Docker build fails
Ensure all Dockerfiles are present:
```bash
find . -name "Dockerfile" -type f
```

## Next Steps

1. Push to remote repository:
   ```bash
   git remote add origin <repository-url>
   git push -u origin main
   ```

2. Set up CI/CD pipeline (optional)

3. Add branch protection rules (optional)

4. Configure GitHub Actions for automated testing (optional)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
