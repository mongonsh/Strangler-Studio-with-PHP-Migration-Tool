# Port Changes Summary

## Issues Fixed

1. **Port 80 conflict** - Changed gateway from port 80 to 8888
2. **Docker Compose version warning** - Removed obsolete `version: '3.8'` field
3. **Legacy PHP port** - Now exposed on port 8080 for direct access

## New Port Configuration

| Service | Port | Access URL |
|---------|------|------------|
| Gateway (nginx) | 8888 | http://localhost:8888/ |
| Legacy PHP (direct) | 8080 | http://localhost:8080/ |
| New API (internal) | 8000 | Via gateway at /api/* |

## Access URLs

### Via Gateway (Recommended)
- Landing page: http://localhost:8888/
- Legacy requests: http://localhost:8888/requests?use_new=0
- New API requests: http://localhost:8888/requests?use_new=1
- API direct: http://localhost:8888/api/requests

### Direct Legacy PHP Access
- Landing page: http://localhost:8080/
- Requests page: http://localhost:8080/requests

## Apply Changes

Run these commands to apply the port changes:

```bash
# Stop existing containers
docker-compose down

# Start with new configuration
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

## Verify Services

```bash
# Test gateway
curl http://localhost:8888/

# Test legacy PHP direct
curl http://localhost:8080/

# Test API through gateway
curl http://localhost:8888/api/requests
```

## Files Updated

- `docker-compose.yml` - Port mappings and removed version field
- `README.md` - All documentation updated with new ports
- `scripts/demo.sh` - Gateway URL updated to :8888
- All committed to git

## Troubleshooting

### If port 8888 is also in use:

```bash
# Find what's using the port
sudo lsof -i :8888

# Or change to another port in docker-compose.yml
services:
  gateway:
    ports:
      - "9999:80"  # Use any available port
```

### If services won't start:

```bash
# Clean up everything
docker-compose down -v
docker system prune -f

# Rebuild and start
docker-compose up --build -d
```

## Git Status

All changes committed:
```
f0ee737 Fix port conflicts: change gateway to 8888, remove obsolete version
1f8f1b3 Expose legacy-php service on port 8080
ad7b350 Add GitHub clone troubleshooting and rebuild script
```

## Next Steps

1. Run `docker-compose up -d` to start services
2. Access http://localhost:8888/ to see the landing page
3. Access http://localhost:8080/ to see legacy PHP directly
4. Test the feature flag toggle at http://localhost:8888/requests
