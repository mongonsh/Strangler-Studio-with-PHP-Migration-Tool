# GitHub Clone Fix

## Problem
"Failed to clone repository" error when clicking "Begin Experiment"

## Root Cause
Git was not installed in the Docker backend container.

## Solution

### Quick Fix (Automated)
```bash
cd php-migration-tool
./fix-github-clone.sh
```

### Manual Fix

1. **Stop services**
   ```bash
   docker-compose down
   ```

2. **Rebuild backend with Git**
   ```bash
   docker-compose build --no-cache backend
   ```

3. **Start services**
   ```bash
   docker-compose up -d
   ```

4. **Verify**
   ```bash
   # Check backend health
   curl http://localhost:8000/
   
   # Test GitHub clone
   curl -X POST http://localhost:8000/api/clone-github \
     -H "Content-Type: application/json" \
     -d '{"repo_url":"https://github.com/laravel/laravel","branch":"10.x"}'
   ```

## What Was Changed

### 1. Backend Dockerfile
Added Git installation:
```dockerfile
# Install system dependencies including git
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*
```

### 2. Improved Error Handling
Added better error messages in `main.py`:
- Repository not found
- Branch not found
- Private repository detection
- No PHP files found
- Invalid URL format

### 3. URL Validation
- Checks for http:// or https://
- Automatically adds .git extension
- Validates repository contains PHP files

## Testing

### Test with Public Repository
```bash
# Laravel
https://github.com/laravel/laravel

# Symfony Demo
https://github.com/symfony/demo

# WordPress
https://github.com/WordPress/WordPress
```

### Expected Response
```json
{
  "upload_id": "tmp_abc123",
  "repo_url": "https://github.com/laravel/laravel",
  "branch": "10.x",
  "status": "cloned",
  "php_files_found": 150
}
```

## Supported Repository Formats

✅ **Supported:**
- `https://github.com/username/repository`
- `https://github.com/username/repository.git`
- `http://github.com/username/repository`

❌ **Not Supported (Yet):**
- `git@github.com:username/repository.git` (SSH)
- Private repositories
- GitLab/Bitbucket (coming soon)

## Common Errors

### "Repository or branch 'X' not found"
- Check branch name (case-sensitive)
- Try `main` instead of `master` or vice versa
- Verify repository exists

### "Repository is private or requires authentication"
- Make repository public, or
- Wait for private repo support

### "No PHP files found in repository"
- Verify repository contains PHP code
- Check correct branch selected

## Verification Steps

After running the fix:

1. **Check Git is installed**
   ```bash
   docker-compose exec backend git --version
   ```

2. **Check GitPython is installed**
   ```bash
   docker-compose exec backend pip list | grep -i git
   ```

3. **Test clone endpoint**
   ```bash
   curl -X POST http://localhost:8000/api/clone-github \
     -H "Content-Type: application/json" \
     -d '{"repo_url":"https://github.com/laravel/laravel","branch":"10.x"}'
   ```

4. **Check logs**
   ```bash
   docker-compose logs backend
   ```

## Still Having Issues?

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more solutions.

### Quick Diagnostics
```bash
# Check all services
docker-compose ps

# View backend logs
docker-compose logs backend | tail -50

# Enter backend container
docker-compose exec backend /bin/bash

# Inside container, test git
git --version
python -c "import git; print(git.__version__)"
```

## Next Steps

After fixing:
1. Access http://localhost
2. Enter a GitHub repository URL
3. Click "Begin Experiment"
4. Watch it clone and analyze!

## Example Repositories to Try

```
https://github.com/laravel/laravel
https://github.com/symfony/demo
https://github.com/WordPress/WordPress
https://github.com/slimphp/Slim
https://github.com/cakephp/cakephp
```
