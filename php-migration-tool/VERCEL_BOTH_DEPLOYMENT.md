# Deploy Both Frontend and Backend to Vercel

## Overview

This guide shows you how to deploy both the frontend and backend to Vercel as separate projects.

## ⚠️ Important Limitations

Vercel's serverless functions have limitations:
- **Free Plan:** 10-second timeout
- **Pro Plan:** 60-second timeout (requires $20/month)
- **Limited file system access**
- **No persistent storage**

For GitHub cloning and file processing, you may need the Pro plan or consider alternatives.

## Architecture

```
Frontend (Vercel Project 1)     Backend (Vercel Project 2)
        ↓                               ↓
   React + Vite                  FastAPI (Serverless)
   Static Site                   Python Functions
        ↓                               ↓
   your-app.vercel.app          your-api.vercel.app
```

## Prerequisites

1. **Vercel Account** - Sign up at https://vercel.com
2. **GitHub Repository** - Code must be on GitHub
3. **Vercel CLI** (optional) - `npm install -g vercel`

## Step 1: Push to GitHub

```bash
# Add all files
git add .

# Commit
git commit -m "Ready for Vercel deployment"

# Push to GitHub
git push origin main
```

## Step 2: Deploy Backend to Vercel

### 2.1 Create Backend Project

1. Go to https://vercel.com/new
2. Click "Import Project"
3. Select your GitHub repository
4. Configure:
   - **Project Name:** `php-migration-backend` (or your choice)
   - **Framework Preset:** Other
   - **Root Directory:** `php-migration-tool/backend`
   - **Build Command:** Leave empty
   - **Output Directory:** Leave empty
   - **Install Command:** `pip install -r requirements.txt`

### 2.2 Environment Variables

Add these if needed:
- `PYTHONUNBUFFERED`: `1`
- `GIT_PYTHON_REFRESH`: `quiet`

### 2.3 Deploy

Click "Deploy" and wait 2-3 minutes.

### 2.4 Get Your Backend URL

After deployment, you'll see:
```
https://php-migration-backend-abc123.vercel.app
```

**Copy this URL!** You'll need it for the frontend.

### 2.5 Test Backend

```bash
curl https://php-migration-backend-abc123.vercel.app/
```

Should return: `{"message": "PHP Migration Tool API"}`

## Step 3: Update Frontend Configuration

### 3.1 Update API URL in vercel.json

Edit `php-migration-tool/frontend/vercel.json`:

```json
{
  "version": 2,
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "framework": "vite",
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "https://php-migration-backend-abc123.vercel.app/api/:path*"
    }
  ]
}
```

Replace `php-migration-backend-abc123` with your actual backend URL.

### 3.2 Commit Changes

```bash
git add php-migration-tool/frontend/vercel.json
git commit -m "Configure frontend for Vercel backend"
git push
```

## Step 4: Deploy Frontend to Vercel

### 4.1 Create Frontend Project

1. Go to https://vercel.com/new again
2. Click "Import Project"
3. Select your GitHub repository again
4. Configure:
   - **Project Name:** `php-migration-tool` (or your choice)
   - **Framework Preset:** Vite
   - **Root Directory:** `php-migration-tool/frontend`
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
   - **Install Command:** `npm install`

### 4.2 Environment Variables (Optional)

Add if you want to override:
- `VITE_API_URL`: Your backend URL

### 4.3 Deploy

Click "Deploy" and wait 2-3 minutes.

### 4.4 Get Your Frontend URL

After deployment:
```
https://php-migration-tool-abc123.vercel.app
```

## Step 5: Update CORS in Backend

### 5.1 Edit Backend CORS

Edit `php-migration-tool/backend/main.py`:

```python
# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",  # Local dev
        "http://localhost:3000",  # Local dev
        "https://php-migration-tool-abc123.vercel.app",  # Your frontend URL
        "https://*.vercel.app",  # All Vercel preview deployments
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 5.2 Commit and Push

```bash
git add php-migration-tool/backend/main.py
git commit -m "Update CORS for Vercel frontend"
git push
```

Vercel will automatically redeploy the backend.

## Step 6: Test Your Deployment

1. Open your frontend URL: `https://php-migration-tool-abc123.vercel.app`
2. Check if logo shows and animates
3. Try entering a GitHub URL
4. Test the analysis feature
5. Check browser console for errors

## Troubleshooting

### Backend Timeout Errors

**Problem:** Functions timeout after 10 seconds

**Solutions:**
1. **Upgrade to Vercel Pro** ($20/month) for 60-second timeout
2. **Optimize backend** to respond faster
3. **Use Railway/Render** for backend instead (see `VERCEL_DEPLOYMENT.md`)

### CORS Errors

**Problem:** Frontend can't access backend

**Solution:**
1. Check CORS settings in `main.py`
2. Verify frontend URL is in `allow_origins`
3. Redeploy backend after changes

### Logo Not Showing

**Problem:** Image not found

**Solution:**
1. Verify `php-migration-tool/frontend/public/frankshtein.png` exists
2. Rebuild frontend on Vercel
3. Check browser console for 404 errors

### API Calls Return 404

**Problem:** Wrong API URL

**Solution:**
1. Check `vercel.json` has correct backend URL
2. Verify rewrite rules
3. Test backend URL directly: `curl https://your-backend.vercel.app/`

### GitHub Clone Fails

**Problem:** Serverless functions can't clone large repos

**Solutions:**
1. **Upgrade to Pro** for longer timeout
2. **Optimize clone** (shallow clone, single branch)
3. **Use Railway** for backend (better for file operations)

## Vercel Pro Benefits

If you upgrade to Pro ($20/month):
- **60-second timeout** (vs 10 seconds)
- **Better performance**
- **More bandwidth**
- **Priority support**

This is recommended if you want to keep everything on Vercel.

## Automatic Deployments

Both projects will auto-deploy when you push to GitHub:

- **Production:** Pushes to `main` branch
- **Preview:** Pushes to other branches or PRs

## Monitoring

### View Logs

**Backend:**
1. Go to https://vercel.com/dashboard
2. Select backend project
3. Click "Deployments" → Select deployment
4. View "Functions" tab for logs

**Frontend:**
1. Select frontend project
2. Click "Deployments" → Select deployment
3. View "Build Logs"

### Check Function Duration

In backend project:
1. Go to "Analytics" → "Functions"
2. See execution time
3. If consistently > 10s, upgrade to Pro

## Environment Variables

### Backend

```env
PYTHONUNBUFFERED=1
GIT_PYTHON_REFRESH=quiet
```

### Frontend

```env
VITE_API_URL=https://your-backend.vercel.app
```

## Custom Domains

### Add Domain to Frontend

1. Go to frontend project
2. Settings → Domains
3. Add domain: `migration-tool.yourdomain.com`
4. Follow DNS instructions

### Add Domain to Backend

1. Go to backend project
2. Settings → Domains
3. Add domain: `api.yourdomain.com`
4. Update frontend `vercel.json` with new API domain

## Cost Breakdown

### Free Tier (Hobby)
- **2 projects** (frontend + backend)
- **100 GB bandwidth** per month
- **10-second timeout**
- **Cost:** $0/month

### Pro Tier
- **Unlimited projects**
- **1 TB bandwidth** per month
- **60-second timeout**
- **Cost:** $20/month

## Production Checklist

- [ ] Backend deployed and accessible
- [ ] Frontend deployed and accessible
- [ ] CORS configured correctly
- [ ] API URL updated in frontend
- [ ] Logo and assets loading
- [ ] All features tested
- [ ] Timeout limits acceptable
- [ ] Custom domains configured (optional)
- [ ] Analytics enabled

## Quick Commands

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy backend
cd php-migration-tool/backend
vercel --prod

# Deploy frontend
cd php-migration-tool/frontend
vercel --prod

# Check deployments
vercel ls

# View logs
vercel logs <deployment-url>
```

## Alternative: Monorepo Setup

You can also deploy as a monorepo:

1. Create `vercel.json` at root
2. Configure multiple projects
3. Single repository, multiple deployments

See Vercel docs for monorepo setup.

## Summary

1. ✓ Push code to GitHub
2. ✓ Deploy backend to Vercel (Project 1)
3. ✓ Get backend URL
4. ✓ Update frontend with backend URL
5. ✓ Deploy frontend to Vercel (Project 2)
6. ✓ Update CORS in backend
7. ✓ Test everything
8. ✓ Go live!

Your app is now live on Vercel:
- **Frontend:** https://your-app.vercel.app
- **Backend:** https://your-api.vercel.app

## Need Help?

- **Vercel Docs:** https://vercel.com/docs
- **Vercel Support:** https://vercel.com/support
- **Community:** https://github.com/vercel/vercel/discussions

Enjoy your deployed app! 🚀
