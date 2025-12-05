# Vercel Deployment Guide

## Overview

This guide will help you deploy the PHP Migration Tool to Vercel. Since the app has both frontend (React) and backend (FastAPI), we'll deploy them as separate projects.

## Architecture on Vercel

```
Frontend (Vercel)          Backend (Vercel/Railway/Render)
     ↓                              ↓
React + Vite              FastAPI + Python
Port: 443 (HTTPS)         Port: 443 (HTTPS)
     ↓                              ↓
  Static Site             Serverless Functions
```

## Prerequisites

1. **GitHub Account** - Your code must be on GitHub
2. **Vercel Account** - Sign up at https://vercel.com
3. **Git Repository** - Push your code to GitHub first

## Step 1: Push to GitHub

If you haven't already:

```bash
# Initialize git (if not done)
git init
git add .
git commit -m "Initial commit"

# Add remote
git remote add origin https://github.com/YOUR_USERNAME/strangler-studio.git

# Push
git push -u origin main
```

## Step 2: Deploy Backend (Option A - Vercel)

### 2.1 Create Backend Deployment

1. Go to https://vercel.com/new
2. Import your GitHub repository
3. Configure:
   - **Framework Preset:** Other
   - **Root Directory:** `php-migration-tool/backend`
   - **Build Command:** Leave empty
   - **Output Directory:** Leave empty
   - **Install Command:** `pip install -r requirements.txt`

4. Add Environment Variables (if needed):
   - Click "Environment Variables"
   - Add any required variables

5. Click "Deploy"

### 2.2 Note Your Backend URL

After deployment, you'll get a URL like:
```
https://your-backend-abc123.vercel.app
```

**Save this URL!** You'll need it for the frontend.

### ⚠️ Important: Vercel Limitations for Backend

Vercel has limitations for Python backends:
- **10 second timeout** for serverless functions
- **Limited file system access**
- **No persistent storage**

For a production app with file uploads and GitHub cloning, consider:
- **Railway** (https://railway.app) - Better for Python backends
- **Render** (https://render.com) - Free tier available
- **Fly.io** (https://fly.io) - Good for Docker deployments

## Step 2 Alternative: Deploy Backend to Railway (Recommended)

Railway is better suited for this backend:

1. Go to https://railway.app
2. Sign in with GitHub
3. Click "New Project"
4. Select "Deploy from GitHub repo"
5. Choose your repository
6. Configure:
   - **Root Directory:** `php-migration-tool/backend`
   - **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`
7. Add Environment Variables:
   - `PORT`: 8000
8. Deploy

Railway will give you a URL like:
```
https://your-backend.up.railway.app
```

## Step 3: Deploy Frontend to Vercel

### 3.1 Update API URL

Before deploying frontend, update the API URL:

**Edit `php-migration-tool/frontend/vercel.json`:**

```json
{
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "https://YOUR-BACKEND-URL.vercel.app/api/:path*"
    }
  ]
}
```

Replace `YOUR-BACKEND-URL` with your actual backend URL.

**Or update `vite.config.js` for build:**

```javascript
export default defineConfig({
  plugins: [react()],
  define: {
    'import.meta.env.VITE_API_URL': JSON.stringify(
      process.env.VITE_API_URL || 'https://your-backend-url.vercel.app'
    )
  }
})
```

### 3.2 Commit Changes

```bash
git add .
git commit -m "Configure for Vercel deployment"
git push
```

### 3.3 Deploy Frontend

1. Go to https://vercel.com/new
2. Import your GitHub repository again
3. Configure:
   - **Framework Preset:** Vite
   - **Root Directory:** `php-migration-tool/frontend`
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
   - **Install Command:** `npm install`

4. Add Environment Variables:
   - `VITE_API_URL`: Your backend URL

5. Click "Deploy"

### 3.4 Your Frontend URL

After deployment, you'll get a URL like:
```
https://your-app-abc123.vercel.app
```

## Step 4: Configure CORS

Update your backend to allow requests from your Vercel frontend:

**Edit `php-migration-tool/backend/main.py`:**

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost",
        "https://your-app-abc123.vercel.app",  # Add your Vercel URL
        "https://*.vercel.app"  # Allow all Vercel preview deployments
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

Commit and push:
```bash
git add .
git commit -m "Update CORS for Vercel"
git push
```

Vercel will automatically redeploy.

## Step 5: Test Your Deployment

1. Open your frontend URL: `https://your-app.vercel.app`
2. Try the GitHub clone feature
3. Check browser console for errors
4. Test all features

## Troubleshooting

### Frontend shows but API calls fail

**Problem:** CORS or wrong API URL

**Solution:**
1. Check browser console for CORS errors
2. Verify API URL in `vercel.json` or environment variables
3. Update CORS settings in backend
4. Redeploy both frontend and backend

### Backend timeout errors

**Problem:** Vercel's 10-second limit

**Solution:**
- Use Railway or Render for backend instead
- Or optimize backend to respond faster
- Or use Vercel's Pro plan (60-second limit)

### Logo not showing

**Problem:** Public folder not included in build

**Solution:**
- Verify `php-migration-tool/frontend/public/frankshtein.png` exists
- Check Vite includes public folder in build
- Rebuild and redeploy

### GitHub clone fails

**Problem:** Serverless functions can't clone repos

**Solution:**
- Deploy backend to Railway/Render (not Vercel)
- Or use Vercel's Edge Functions with limitations
- Or implement client-side GitHub API calls

## Environment Variables

### Frontend (.env)
```env
VITE_API_URL=https://your-backend-url.vercel.app
```

### Backend (.env)
```env
# Add any API keys or secrets here
GITHUB_TOKEN=your_github_token  # If needed for private repos
```

## Custom Domain (Optional)

### Add Custom Domain to Frontend

1. Go to your Vercel project
2. Click "Settings" → "Domains"
3. Add your domain (e.g., `migration-tool.yourdomain.com`)
4. Follow DNS configuration instructions

### Add Custom Domain to Backend

Same process for backend project.

## Automatic Deployments

Vercel automatically deploys when you push to GitHub:

- **Production:** Pushes to `main` branch
- **Preview:** Pushes to other branches or PRs

## Monitoring

### View Logs

1. Go to your Vercel project
2. Click "Deployments"
3. Click on a deployment
4. View "Functions" or "Build Logs"

### Analytics

Vercel provides:
- Page views
- Performance metrics
- Error tracking

Enable in Project Settings → Analytics

## Cost

### Vercel Pricing

- **Hobby (Free):**
  - 100 GB bandwidth/month
  - Unlimited deployments
  - 10-second function timeout

- **Pro ($20/month):**
  - 1 TB bandwidth/month
  - 60-second function timeout
  - Better performance

### Railway Pricing

- **Free Tier:**
  - $5 credit/month
  - Good for small projects

- **Paid:**
  - Pay for what you use
  - ~$5-10/month for this app

## Production Checklist

Before going live:

- [ ] Backend deployed and accessible
- [ ] Frontend deployed and accessible
- [ ] CORS configured correctly
- [ ] Environment variables set
- [ ] Logo and assets loading
- [ ] All features tested
- [ ] Custom domain configured (optional)
- [ ] Analytics enabled (optional)
- [ ] Error monitoring set up

## Alternative: Deploy Everything to Railway

If you want to keep frontend and backend together:

1. Deploy to Railway
2. Use Docker Compose
3. Railway will handle both services
4. Single deployment, easier management

See `RAILWAY_DEPLOYMENT.md` for details.

## Quick Commands Reference

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy frontend
cd php-migration-tool/frontend
vercel

# Deploy backend
cd php-migration-tool/backend
vercel

# Check deployment status
vercel ls

# View logs
vercel logs
```

## Support

- **Vercel Docs:** https://vercel.com/docs
- **Railway Docs:** https://docs.railway.app
- **Vite Docs:** https://vitejs.dev/guide/
- **FastAPI Docs:** https://fastapi.tiangolo.com/deployment/

## Summary

1. **Push code to GitHub**
2. **Deploy backend** (Railway recommended)
3. **Update frontend** with backend URL
4. **Deploy frontend** to Vercel
5. **Configure CORS**
6. **Test everything**
7. **Go live!**

Your app will be live at:
- Frontend: `https://your-app.vercel.app`
- Backend: `https://your-backend.railway.app`

Enjoy your deployed PHP Migration Tool! 🚀
