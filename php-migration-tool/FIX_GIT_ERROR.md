# Fix: "Bad git executable" Error

## Error Message
```
ImportError: Bad git executable.
The git executable must be specified in one of the following ways:
    - be included in your $PATH
    - be set via $GIT_PYTHON_GIT_EXECUTABLE
    - explicitly set via git.refresh()
```

## Root Cause
GitPython cannot find the git executable in the Docker container.

## Solution

### Quick Fix (Recommended)

```bash
cd php-migration-tool
./fix-github-clone.sh
```

### Manual Fix

**Step 1: Stop services**
```bash
docker-compose down
```

**Step 2: Rebuild backend**
```bash
docker-compose build --no-cache backend
```

**Step 3: Start services**
```bash
docker-compose up -d
```

**Step 4: Verify**
```bash
# Check backend logs
docker-compose logs backend

# Verify git is installed
docker-compose exec backend git --version

# Should output: git version 2.x.x
```

## What Was Fixed

### 1. Dockerfile Updates
Added environment variables:
```dockerfile
ENV GIT_PYTHON_REFRESH=quiet
ENV GIT_PYTHON_GIT_EXECUTABLE=/usr/bin/git
```

### 2. Python Code Updates
Set environment before importing GitPython:
```python
os.environ['GIT_PYTHON_REFRESH'] = 'quiet'
os.environ['GIT_PYTHON_GIT_EXECUTABLE'] = '/usr/bin/git'

try:
    import git
    GIT_AVAILABLE = True
except Exception as e:
    GIT_AVAILABLE = False
```

### 3. Graceful Degradation
If Git is not available, the API returns a helpful error:
```json
{
  "detail": "Git is not available. Please rebuild the backend container"
}
```

## Verification Steps

### 1. Check Git Installation
```bash
docker-compose exec backend git --version
```
Expected output: `git version 2.x.x`

### 2. Check GitPython
```bash
docker-compose exec backend python -c "import git; print(git.__version__)"
```
Expected output: `3.1.40` (or similar)

### 3. Test Clone Endpoint
```bash
curl -X POST http://localhost:8000/api/clone-github \
  -H "Content-Type: application/json" \
  -d '{"repo_url":"https://github.com/laravel/laravel","branch":"10.x"}'
```

Expected response:
```json
{
  "upload_id": "tmpXXXXXX",
  "repo_url": "https://github.com/laravel/laravel",
  "branch": "10.x",
  "status": "cloned",
  "php_files_found": 150
}
```

## Still Getting Errors?

### Error: "git: command not found"

Git is not installed in the container.

**Solution:**
```bash
# Rebuild with no cache
docker-compose build --no-cache backend
docker-compose up -d
```

### Error: "Permission denied"

**Solution:**
```bash
# Fix permissions
docker-compose exec backend chmod 777 uploads outputs
```

### Error: Backend won't start

**Solution:**
```bash
# Check logs
docker-compose logs backend

# Complete reset
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

## Testing the Fix

### Test 1: Health Check
```bash
curl http://localhost:8000/
```
Should return: `{"status":"healthy",...}`

### Test 2: Git Version
```bash
docker-compose exec backend git --version
```
Should return: `git version 2.x.x`

### Test 3: Clone Repository
```bash
curl -X POST http://localhost:8000/api/clone-github \
  -H "Content-Type: application/json" \
  -d '{
    "repo_url": "https://github.com/laravel/laravel",
    "branch": "10.x"
  }'
```

### Test 4: Frontend
1. Open http://localhost
2. Enter: `https://github.com/laravel/laravel`
3. Branch: `10.x`
4. Click "Begin Experiment"
5. Should see: "Successfully cloned repository"

## Complete Reset (Nuclear Option)

If nothing works:

```bash
# Stop everything
docker-compose down -v

# Remove all data
rm -rf backend/uploads/* backend/outputs/*

# Rebuild everything
docker-compose build --no-cache

# Start fresh
docker-compose up

# Wait 10 seconds
sleep 10

# Test
curl http://localhost:8000/
```

## Environment Variables

The following environment variables are now set:

```bash
GIT_PYTHON_REFRESH=quiet
GIT_PYTHON_GIT_EXECUTABLE=/usr/bin/git
```

These tell GitPython where to find git and suppress warnings.

## Debugging

### Enter Backend Container
```bash
docker-compose exec backend /bin/bash
```

### Inside Container
```bash
# Check git
which git
git --version

# Check Python
python --version

# Check GitPython
python -c "import git; print(git.__version__)"

# Test git operations
cd /tmp
git clone https://github.com/laravel/laravel test-repo
ls test-repo
```

### View Real-time Logs
```bash
# All logs
docker-compose logs -f

# Just backend
docker-compose logs -f backend | grep -i git
```

## Success Indicators

✅ Backend starts without errors
✅ `git --version` works in container
✅ GitPython imports successfully
✅ Clone endpoint returns success
✅ Frontend can clone repositories

## Next Steps

After fixing:
1. Access http://localhost
2. Enter a GitHub repository URL
3. Click "Begin Experiment"
4. Watch the magic happen!

## Example Repositories

Try these public PHP repositories:
- `https://github.com/laravel/laravel`
- `https://github.com/symfony/demo`
- `https://github.com/WordPress/WordPress`
- `https://github.com/slimphp/Slim`

## Support

If you're still having issues:
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. View logs: `docker-compose logs backend`
3. Try complete reset (see above)
4. Check Docker has enough resources (4GB+ RAM recommended)
