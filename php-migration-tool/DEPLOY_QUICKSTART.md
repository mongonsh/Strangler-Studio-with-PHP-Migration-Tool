# Deploy to Vercel - Quick Start

## TL;DR

1. Push code to GitHub
2. Deploy backend to Railway (not Vercel - better for Python)
3. Deploy frontend to Vercel
4. Update API URL
5. Done!

## Step-by-Step (5 minutes)

### 1. Push to GitHub

```bash
git add .
git commit -m "Ready for deployment"
git push origin main
```

### 2. Deploy Backend to Railway

**Why Railway?** Vercel has 10-second timeout - too short for GitHub cloning and file processing.

1. Go to https://railway.app
2. Click "Start a New Project"
3. Select "Deploy from GitHub repo"
4. Choose your repo
5. Select `php-migration-tool/backend` as root directory
6. Click "Deploy"
7. Copy your backend URL (e.g., `https://abc123.up.railway.app`)

### 3. Update Frontend API URL

Edit `php-migration-tool/frontend/vercel.json`:

```json
{
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "https://YOUR-RAILWAY-URL.up.railway.app/api/:path*"
    }
  ]
}
```

Replace `YOUR-RAILWAY-URL` with your actual Railway URL.

```bash
git add .
git commit -m "Update API URL for deployment"
git push
```

### 4. Deploy Frontend to Vercel

1. Go to https://vercel.com/new
2. Import your GitHub repository
3. Configure:
   - **Root Directory:** `php-migration-tool/frontend`
   - **Framework:** Vite
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
4. Click "Deploy"
5. Wait 2-3 minutes
6. Get your URL (e.g., `https://your-app.vercel.app`)

### 5. Update CORS in Backend

Edit `php-migration-tool/backend/main.py`:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://your-app.vercel.app",  # Your Vercel URL
        "https://*.vercel.app",  # All Vercel previews
        "http://localhost:3000",  # Local development
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

```bash
git add .
git commit -m "Update CORS"
git push
```

Railway will auto-redeploy.

### 6. Test It!

Open `https://your-app.vercel.app` and test:
- Logo shows and animates ✓
- GitHub clone works ✓
- Analysis works ✓
- Generation works ✓
- Download works ✓

## Done! 🎉

Your app is live:
- **Frontend:** https://your-app.vercel.app
- **Backend:** https://your-backend.up.railway.app

## Costs

- **Vercel:** Free (Hobby plan)
- **Railway:** $5/month credit (free tier)

Total: **$0-5/month**

## Troubleshooting

### API calls fail
- Check CORS settings
- Verify API URL in `vercel.json`
- Check Railway logs

### Logo not showing
- Verify `public/frankshtein.png` exists
- Rebuild frontend on Vercel

### Slow performance
- Railway free tier is slower
- Upgrade to paid tier for better performance

## Need Help?

See `VERCEL_DEPLOYMENT.md` for detailed guide.
