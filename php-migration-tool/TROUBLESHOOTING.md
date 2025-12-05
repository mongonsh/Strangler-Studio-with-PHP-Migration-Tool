# Troubleshooting Guide

## GitHub Cloning Issues

### Error: "Failed to clone repository"

**Possible Causes:**

1. **Git not installed in Docker container**
   ```bash
   # Rebuild the backend with git
   docker-compose build --no-cache backend
   docker-compose up -d
   ```

2. **Invalid repository URL**
   - ✅ Correct: `https://github.com/username/repository`
   - ❌ Wrong: `github.com/username/repository`
   - ❌ Wrong: `git@github.com:username/repository.git`

3. **Private repository**
   - Currently only public repositories are supported
   - Private repo support coming soon

4. **Branch doesn't exist**
   - Check the branch name (case-sensitive)
   - Default is `main`, some repos use `master`

5. **Repository doesn't exist**
   - Verify the URL in your browser first
   - Check for typos

### Error: "No PHP files found in repository"

The repository was cloned but contains no PHP files.

**Solutions:**
- Verify the repository contains PHP code
- Check if PHP files are in a subdirectory
- Ensure you're cloning the correct branch

### Error: "Repository is private or requires authentication"

**Solutions:**
- Make the repository public, or
- Wait for private repository support (coming soon)

## Live PHP Preview Issues

### Error: "Cannot connect to localhost:PORT"

**Possible Causes:**

1. **PHP server not running**
   ```bash
   # Start PHP built-in server
   cd /path/to/php/project
   php -S localhost:8080
   ```

2. **Wrong port number**
   - Check which port your PHP server is running on
   - Common ports: 8080, 8000, 3000

3. **Docker network isolation**
   - If running in Docker, use `host.docker.internal` instead of `localhost`
   - Or run PHP server on host machine

4. **Firewall blocking**
   - Check firewall settings
   - Allow connections on the specified port

### Preview shows blank/white screen

**Solutions:**
- Check browser console for errors
- Verify PHP server is serving content
- Try accessing `http://localhost:PORT` directly in browser

## Docker Issues

### Container won't start

```bash
# Check logs
docker-compose logs backend
docker-compose logs frontend

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Port already in use

```bash
# Check what's using the port
lsof -i :80
lsof -i :8000

# Kill the process or change ports in docker-compose.yml
```

### Out of disk space

```bash
# Clean up Docker
docker system prune -a
docker volume prune
```

## Backend API Issues

### 500 Internal Server Error

```bash
# Check backend logs
docker-compose logs backend

# Restart backend
docker-compose restart backend
```

### CORS errors in browser

The backend should allow requests from the frontend. If you see CORS errors:

```python
# Check main.py has correct CORS origins
allow_origins=["http://localhost", "http://localhost:80"]
```

## Frontend Issues

### Blank screen

```bash
# Check frontend logs
docker-compose logs frontend

# Rebuild frontend
docker-compose build --no-cache frontend
docker-compose up -d frontend
```

### API calls failing

1. Check backend is running: `docker-compose ps`
2. Check backend health: `curl http://localhost:8000/`
3. Check browser console for errors

## Testing the Setup

### Test Backend

```bash
# Health check
curl http://localhost:8000/

# Should return:
# {"status":"healthy","service":"PHP Migration Tool API","version":"1.0.0"}
```

### Test GitHub Cloning

```bash
# Test with a public PHP repository
curl -X POST http://localhost:8000/api/clone-github \
  -H "Content-Type: application/json" \
  -d '{"repo_url":"https://github.com/laravel/laravel","branch":"10.x"}'
```

### Test PHP Preview

```bash
# Start a test PHP server
cd /tmp
echo "<?php echo 'Hello World'; ?>" > index.php
php -S localhost:8080

# Test connection
curl -X POST http://localhost:8000/api/check-php-server \
  -H "Content-Type: application/json" \
  -d '{"port":8080,"project_id":"test"}'
```

## Common Solutions

### Complete Reset

```bash
# Stop everything
docker-compose down -v

# Remove all data
rm -rf php-migration-tool/backend/uploads/*
rm -rf php-migration-tool/backend/outputs/*

# Rebuild and start
docker-compose build --no-cache
docker-compose up
```

### Check Dependencies

```bash
# Enter backend container
docker-compose exec backend /bin/bash

# Check git is installed
git --version

# Check Python packages
pip list | grep -i git
```

### View Real-time Logs

```bash
# All services
docker-compose logs -f

# Just backend
docker-compose logs -f backend

# Just frontend
docker-compose logs -f frontend
```

## Getting Help

If issues persist:

1. Check logs: `docker-compose logs`
2. Verify all services running: `docker-compose ps`
3. Test backend directly: `curl http://localhost:8000/`
4. Check browser console for frontend errors
5. Try a complete rebuild: `docker-compose build --no-cache`

## Known Issues

### Issue: GitPython not found
**Solution:** Rebuild backend container with `docker-compose build --no-cache backend`

### Issue: Permission denied on uploads directory
**Solution:** 
```bash
docker-compose exec backend chmod 777 uploads outputs
```

### Issue: Frontend can't reach backend
**Solution:** Check nginx.conf proxy settings and CORS configuration

## Quick Fixes

```bash
# Fix 1: Rebuild everything
docker-compose down && docker-compose build --no-cache && docker-compose up

# Fix 2: Clear volumes
docker-compose down -v && docker-compose up

# Fix 3: Restart services
docker-compose restart

# Fix 4: Check service health
docker-compose ps
curl http://localhost:8000/
curl http://localhost/
```
