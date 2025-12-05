# Connection Test Guide

## Understanding the "Test Connection" Feature

The "Test Connection" button in the PHP Migration Tool is used to **preview a PHP project** that you want to migrate. It's NOT for testing the migration tool itself.

## How It Works

1. **Enter GitHub URL**: You provide a GitHub repository URL
2. **Clone Repository**: The tool clones the PHP project
3. **Enter Port**: You specify where the PHP project is running
4. **Test Connection**: The tool tries to load that PHP application in an iframe

## Common Scenarios

### Scenario 1: Testing the Strangler Studio Demo

If you want to see the Strangler Studio legacy PHP app:

```
Port: 8080
URL: http://localhost:8080
```

This will show the Strangler Studio Halloween-themed PHP application.

### Scenario 2: Testing Your Own PHP Project

If you have your own PHP project running:

```bash
# Start your PHP project on a port (e.g., 9000)
cd your-php-project
php -S localhost:9000

# Then in the migration tool:
Port: 9000
URL: http://localhost:9000
```

### Scenario 3: Testing a Cloned GitHub Project

If you cloned a GitHub repository through the migration tool:

1. The tool clones the repository
2. You need to **manually start** the PHP project
3. Then test the connection to where it's running

## Why "Cannot Connect" Happens

### Reason 1: PHP Project Not Running

The most common reason - the PHP project isn't actually running on that port.

**Solution:**
```bash
# Check what's running on the port
lsof -i :8080

# If nothing, start your PHP project
cd your-project
php -S localhost:8080
```

### Reason 2: Wrong Port Number

You entered a port where nothing is running.

**Solution:**
- Verify the correct port
- Check `docker-compose ps` if using Docker
- Try common ports: 8080, 8000, 3000, 9000

### Reason 3: CORS Issues

The browser blocks the iframe due to security policies.

**Solution:**
- This is expected for some projects
- The migration tool can still analyze the code
- You just won't see the preview

### Reason 4: Project Needs Database

The PHP project requires a database that isn't running.

**Solution:**
- Set up the database first
- Or skip the preview and proceed with code analysis

## Testing the Strangler Studio Demo

The Strangler Studio demo IS running and accessible:

```bash
# Test from command line
curl http://localhost:8080/

# Or open in browser
open http://localhost:8080/
```

**Ports:**
- 8888 → Gateway (nginx)
- 8080 → Legacy PHP (direct access)

## Testing the Migration Tool Itself

The migration tool has its own ports:

```bash
# Frontend (React UI)
http://localhost:3000

# Backend (FastAPI)
http://localhost:8000

# Check if running
cd php-migration-tool
docker-compose ps
```

## Troubleshooting Steps

### Step 1: Verify Services Are Running

```bash
# Check Strangler Studio
docker-compose ps

# Check Migration Tool
cd php-migration-tool
docker-compose ps
```

### Step 2: Test Connections

```bash
# Test Strangler Studio
curl http://localhost:8080/

# Test Migration Tool
curl http://localhost:3000/
curl http://localhost:8000/
```

### Step 3: Check Logs

```bash
# Strangler Studio logs
docker-compose logs legacy-php

# Migration Tool logs
cd php-migration-tool
docker-compose logs frontend
docker-compose logs backend
```

### Step 4: Restart Services

```bash
# Restart Strangler Studio
docker-compose restart

# Restart Migration Tool
cd php-migration-tool
docker-compose restart
```

## Example: Complete Workflow

### Using Strangler Studio as Test Subject

1. **Start Strangler Studio:**
   ```bash
   docker-compose up -d
   ```

2. **Verify it's running:**
   ```bash
   curl http://localhost:8080/
   ```

3. **Open Migration Tool:**
   ```bash
   cd php-migration-tool
   docker-compose up -d
   open http://localhost:3000
   ```

4. **In the Migration Tool UI:**
   - Enter GitHub URL: `https://github.com/your-username/strangler-studio`
   - Click "Begin Experiment"
   - Enter port: `8080`
   - Click "Test Connection"
   - You should see the Strangler Studio UI in the preview

## Quick Reference

| Service | Port | URL | Purpose |
|---------|------|-----|---------|
| Gateway | 8888 | http://localhost:8888/ | Strangler Studio gateway |
| Legacy PHP | 8080 | http://localhost:8080/ | Strangler Studio PHP app |
| Migration Frontend | 3000 | http://localhost:3000/ | Migration tool UI |
| Migration Backend | 8000 | http://localhost:8000/ | Migration tool API |

## Still Having Issues?

Run the connection test script:

```bash
./test-connection.sh
```

This will verify all services are working correctly.
