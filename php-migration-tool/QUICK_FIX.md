# ⚡ Quick Fix - Git Error

## The Problem
```
ImportError: Bad git executable
```

## The Solution (30 seconds)

```bash
cd php-migration-tool
docker-compose down
docker-compose build --no-cache backend
docker-compose up -d
```

Wait 10 seconds, then test:
```bash
curl http://localhost:8000/
```

## Or Use the Script

```bash
./fix-github-clone.sh
```

## What This Does

1. Stops all services
2. Rebuilds backend with:
   - Git installed
   - Environment variables set
   - GitPython configured
3. Starts services
4. Tests everything

## Verify It Worked

```bash
# Should show git version
docker-compose exec backend git --version

# Should return healthy status
curl http://localhost:8000/
```

## Test GitHub Clone

Open http://localhost and try:
```
Repository: https://github.com/laravel/laravel
Branch: 10.x
```

Click "Begin Experiment" - should work!

## Still Broken?

See [FIX_GIT_ERROR.md](FIX_GIT_ERROR.md) for detailed troubleshooting.

## Why This Happened

GitPython couldn't find git in the Docker container. We fixed it by:
1. Installing git in Dockerfile
2. Setting `GIT_PYTHON_GIT_EXECUTABLE` environment variable
3. Adding graceful error handling

That's it! 🚀
