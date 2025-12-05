# 🚀 Deploy to Vercel - Start Here

## Quick Overview

You have TWO separate apps to deploy:
1. **Backend** (Python/FastAPI) → Vercel Project 1
2. **Frontend** (React/Vite) → Vercel Project 2

## ⚠️ Important Note

Your code is ready! Just follow these steps in order.

---

## Step 1: Push Latest Changes to GitHub

```bash
# Make sure you're in the project root
cd ~/kiroween

# Push the latest Vercel configuration
git push origin main
```

---

## Step 2: Deploy Backend First

### 2.1 Go to Vercel
1. Open https://vercel.com/new
2. Click "Import Project"
3. Select your GitHub repository

### 2.2 Configure Backend
- **Project Name:** `php-migration-backend` (or any name you like)
- **Framework Preset:** Other
- **Root Directory:** Click "Edit" → Enter: `php-migration-tool/backend`
- **Build Command:** Leave empty
- **Output Directory:** Leave empty
- **Install Command:** `pip install -r requirements.txt`

### 2.3 Deploy
Click "Deploy" and wait 2-3 minutes.

### 2.4 Copy Your Backend URL
After deployment, you'll see something like:
```
https://php-migration-backend-abc123.vercel.app
```

**COPY THIS URL!** You need it for the next step.

---

## Step 3: Update Frontend Configuration

### 3.1 Edit vercel.json
Open `php-migration-tool/frontend/vercel.json` and replace the backend URL:

```json
{
  "version": 2,
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "framework": "vite",
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "https://YOUR-BACKEND-URL-HERE.vercel.app/api/:path*"
    }
  ]
}
```

Replace `YOUR-BACKEND-URL-HERE` with your actual backend URL from Step 2.4.

### 3.2 Commit and Push
```bash
git add php-migration-tool/frontend/vercel.json
git commit -m "Configure frontend API URL"
git push origin main
```

---

## Step 4: Deploy Frontend

### 4.1 Go to Vercel Again
1. Open https://vercel.com/new
2. Click "Import Project"
3. Select your GitHub repository again

### 4.2 Configure Frontend
- **Project Name:** `php-migration-tool` (or any name you like)
- **Framework Preset:** Vite
- **Root Directory:** Click "Edit" → Enter: `php-migration-tool/frontend`
- **Build Command:** `npm run build`
- **Output Directory:** `dist`
- **Install Command:** `npm install`

### 4.3 Deploy
Click "Deploy" and wait 2-3 minutes.

### 4.4 Copy Your Frontend URL
After deployment:
```
https://php-migration-tool-abc123.vercel.app
```

---

## Step 5: Update CORS in Backend

### 5.1 Edit main.py
Open `php-migration-tool/backend/main.py` and update the CORS section:

```python
# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://localhost:3000",
        "https://YOUR-FRONTEND-URL-HERE.vercel.app",  # Add your frontend URL
        "https://*.vercel.app",  # Allow all Vercel preview deployments
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

Replace `YOUR-FRONTEND-URL-HERE` with your actual frontend URL from Step 4.4.

### 5.2 Commit and Push
```bash
git add php-migration-tool/backend/main.py
git commit -m "Update CORS for production"
git push origin main
```

Vercel will automatically redeploy your backend.

---

## Step 6: Test Your Deployment

1. Open your frontend URL in a browser
2. You should see:
   - ✓ Animated Frankenstein logo
   - ✓ "Frankenstein Laboratory" title
   - ✓ Four experiment stages
3. Try the GitHub clone feature
4. Check browser console (F12) for any errors

---

## ⚠️ Known Limitations

### Timeout Issues
Vercel free tier has a **10-second timeout** for serverless functions.

**If you get timeout errors:**
- **Option 1:** Upgrade to Vercel Pro ($20/month) for 60-second timeout
- **Option 2:** Use Railway for backend (free tier, better for file operations)

See `VERCEL_DEPLOYMENT.md` for Railway setup instructions.

---

## 🎉 You're Done!

Your app is now live:
- **Frontend:** https://your-frontend.vercel.app
- **Backend:** https://your-backend.vercel.app

---

## Troubleshooting

### Logo Not Showing
The logo should show automatically. If not:
1. Check browser console for 404 errors
2. Verify `frontend/public/frankshtein.png` exists
3. Try hard refresh: Ctrl+Shift+R (Cmd+Shift+R on Mac)

### CORS Errors
If you see CORS errors in console:
1. Verify you updated `backend/main.py` with frontend URL
2. Check the URL is correct (no typos)
3. Wait for backend to redeploy (check Vercel dashboard)

### API Not Working
1. Test backend directly: `curl https://your-backend.vercel.app/`
2. Should return: `{"status":"healthy",...}`
3. Check Vercel logs for errors

### Need Help?
- See `VERCEL_BOTH_DEPLOYMENT.md` for detailed guide
- See `VERCEL_CHECKLIST.md` for simple checklist
- Check Vercel deployment logs in dashboard

---

## Next Steps

### Custom Domain (Optional)
1. Go to Vercel dashboard
2. Select your project
3. Settings → Domains
4. Add your custom domain

### Monitoring
- Check Vercel Analytics for usage
- Monitor function execution times
- Set up error notifications

---

## Summary

1. ✓ Push code to GitHub
2. ✓ Deploy backend to Vercel
3. ✓ Update frontend with backend URL
4. ✓ Deploy frontend to Vercel
5. ✓ Update CORS in backend
6. ✓ Test everything
7. ✓ Go live!

**Estimated Time:** 15-20 minutes

Good luck! 🚀
