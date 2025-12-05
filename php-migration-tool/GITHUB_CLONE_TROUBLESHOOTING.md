# GitHub Clone Troubleshooting Guide

## Error: "Cmd('git') not found"

### Problem
When trying to clone a GitHub repository, you see this error:
```
Unexpected error: Cmd('git') not found due to: FileNotFoundError('[Errno 2] No such file or directory: 'git'')
```

### Root Cause
The backend Docker container doesn't have git installed, or the container was built before git was added to the Dockerfile.

### Solution

**Option 1: Quick Rebuild (Recommended)**

Run the rebuild script:
```bash
cd php-migration-tool
./REBUILD_BACKEND.sh
```

This script will:
1. Stop all containers
2. Remove the old backend image
3. Rebuild the backend with `--no-cache`
4. Start services
5. Verify git is installed

**Option 2: Manual Rebuild**

```bash
cd php-migration-tool

# Stop containers
docker-compose down

# Rebuild backend without cache
docker-compose build --no-cache backend

# Start services
docker-compose up -d

# Verify git is installed
docker-compose exec backend git --version
```

**Option 3: Use Makefile**

```bash
cd php-migration-tool
make rebuild
```

### Verification

After rebuilding, verify git is working:

```bash
# Check git version in container
docker-compose exec backend git --version

# Should output something like:
# git version 2.39.2
```

### Testing GitHub Clone

Try cloning a public repository:

1. Open http://localhost:3000
2. Enter a GitHub URL: `https://github.com/laravel/laravel`
3. Click "Begin Experiment"
4. You should see the analysis results

### Common Issues

#### Issue: "Repository not found"
**Cause**: The repository URL is incorrect or the repository is private.

**Solution**: 
- Verify the URL is correct
- Ensure the repository is public
- Try a different repository like `https://github.com/laravel/laravel`

#### Issue: "No PHP files found"
**Cause**: The repository doesn't contain PHP files.

**Solution**: Use a PHP project repository like:
- `https://github.com/laravel/laravel`
- `https://github.com/symfony/symfony`
- `https://github.com/mongonsh/legacy-project-trae`

#### Issue: Container keeps restarting
**Cause**: Build error or missing dependencies.

**Solution**:
```bash
# Check logs
docker-compose logs backend

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

#### Issue: "Permission denied" when cloning
**Cause**: Docker volume permissions issue.

**Solution**:
```bash
# Stop containers
docker-compose down

# Remove volumes
docker volume prune -f

# Restart
docker-compose up -d
```

### Environment Variables

The backend Dockerfile sets these environment variables for GitPython:

```dockerfile
ENV GIT_PYTHON_REFRESH=quiet
ENV GIT_PYTHON_GIT_EXECUTABLE=/usr/bin/git
```

These ensure GitPython can find and use the git executable.

### Dockerfile Configuration

The backend Dockerfile includes:

```dockerfile
# Install system dependencies including git
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set git environment variable for GitPython
ENV GIT_PYTHON_REFRESH=quiet
ENV GIT_PYTHON_GIT_EXECUTABLE=/usr/bin/git

# Verify git is accessible
RUN git --version
```

### Backend Code Configuration

The backend `main.py` sets environment variables before importing GitPython:

```python
import os
os.environ['GIT_PYTHON_REFRESH'] = 'quiet'
os.environ['GIT_PYTHON_GIT_EXECUTABLE'] = '/usr/bin/git'

try:
    from git import Repo
    GIT_AVAILABLE = True
except ImportError:
    GIT_AVAILABLE = False
```

### Testing the Fix

After rebuilding, test with this curl command:

```bash
curl -X POST http://localhost:8000/api/clone-github \
  -H "Content-Type: application/json" \
  -d '{"repo_url": "https://github.com/laravel/laravel"}'
```

Expected response:
```json
{
  "message": "Repository cloned successfully",
  "session_id": "...",
  "php_files_found": true
}
```

### Still Having Issues?

1. **Check Docker logs**:
   ```bash
   docker-compose logs backend
   ```

2. **Verify git installation**:
   ```bash
   docker-compose exec backend which git
   docker-compose exec backend git --version
   ```

3. **Check Python environment**:
   ```bash
   docker-compose exec backend python -c "import git; print(git.__version__)"
   ```

4. **Rebuild everything from scratch**:
   ```bash
   docker-compose down -v
   docker system prune -f
   docker-compose build --no-cache
   docker-compose up -d
   ```

### Prevention

To avoid this issue in the future:

1. Always rebuild containers after Dockerfile changes:
   ```bash
   docker-compose build --no-cache
   ```

2. Use the provided scripts:
   - `./REBUILD_BACKEND.sh` - Quick rebuild
   - `./fix-github-clone.sh` - Complete fix with verification

3. Check git is installed before deploying:
   ```bash
   docker-compose exec backend git --version
   ```

### Related Files

- `backend/Dockerfile` - Contains git installation
- `backend/main.py` - GitPython configuration
- `backend/requirements.txt` - GitPython dependency
- `REBUILD_BACKEND.sh` - Quick rebuild script
- `fix-github-clone.sh` - Complete fix script

### Support

If you continue to have issues:

1. Check the logs: `docker-compose logs backend`
2. Verify the Dockerfile has git installation
3. Ensure you've rebuilt the container
4. Try a fresh clone of the repository
5. Check Docker has enough resources (memory, disk space)
