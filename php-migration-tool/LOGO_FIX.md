# Logo Not Showing - Quick Fix

## Problem
The logo image was added after the Docker container was built, so it's not included in the running container.

## Solution

You need to rebuild the frontend container to include the new logo image.

### Option 1: Quick Rebuild Script (Easiest)

```bash
cd php-migration-tool
./rebuild-frontend.sh
```

### Option 2: Manual Rebuild

```bash
cd php-migration-tool

# Stop and remove frontend
docker-compose stop frontend
docker-compose rm -f frontend

# Rebuild without cache
docker-compose build --no-cache frontend

# Start frontend
docker-compose up -d frontend

# Wait a few seconds
sleep 5

# Test if logo is accessible
curl -I http://localhost/frankshtein.png
```

### Option 3: Rebuild Everything

```bash
cd php-migration-tool

# Stop all services
docker-compose down

# Rebuild all
docker-compose build --no-cache

# Start all services
docker-compose up -d
```

## Verify It Works

After rebuilding, check:

1. **Logo file is accessible:**
   ```bash
   curl -I http://localhost/frankshtein.png
   ```
   Should return `HTTP/1.1 200 OK`

2. **Open in browser:**
   ```
   http://localhost/
   ```
   You should see the animated Frankenstein PHP logo at the top!

## What Should You See

When it works, you'll see:
- Purple Frankenstein character with green hair
- "PHP" text on the shirt
- Floating animation (gentle up/down movement)
- Electric blue and toxic green glow
- Rotating rings around the logo
- Occasional lightning sparks
- On hover: shake effect and intensified glow

## Troubleshooting

### Logo still not showing after rebuild

1. **Check if file exists in container:**
   ```bash
   docker-compose exec frontend ls -la /usr/share/nginx/html/frankshtein.png
   ```

2. **Check browser console:**
   - Open browser DevTools (F12)
   - Go to Console tab
   - Look for 404 errors for frankshtein.png

3. **Check nginx logs:**
   ```bash
   docker-compose logs frontend | grep frankshtein
   ```

### Image shows but no animations

1. **Check CSS is loaded:**
   - Open browser DevTools
   - Go to Network tab
   - Refresh page
   - Look for `frankenstein-theme.css`

2. **Check for CSS errors:**
   - Open browser DevTools
   - Go to Console tab
   - Look for CSS parsing errors

3. **Try hard refresh:**
   - Chrome/Edge: Ctrl+Shift+R (Cmd+Shift+R on Mac)
   - Firefox: Ctrl+F5 (Cmd+Shift+R on Mac)

### Port conflict (port 80 in use)

If you see "port 80 already in use":

```bash
# Check what's using port 80
sudo lsof -i :80

# Option 1: Stop the conflicting service
# Option 2: Change port in docker-compose.yml
ports:
  - "3000:80"  # Use port 3000 instead

# Then access at http://localhost:3000/
```

## Files Involved

- **Logo Image:** `php-migration-tool/frontend/public/frankshtein.png`
- **Component:** `php-migration-tool/frontend/src/App.jsx`
- **Styles:** `php-migration-tool/frontend/src/frankenstein-theme.css`
- **Dockerfile:** `php-migration-tool/frontend/Dockerfile`

## Why This Happened

Docker containers are immutable - when you build a container, it captures the files at that moment. Adding files later doesn't automatically update the running container. You must rebuild to include new files.

## Prevention

In development, you can use volume mounts to avoid rebuilding:

```yaml
# In docker-compose.yml (for development only)
services:
  frontend:
    volumes:
      - ./frontend/public:/usr/share/nginx/html
```

But for production builds, always rebuild when adding new assets.
