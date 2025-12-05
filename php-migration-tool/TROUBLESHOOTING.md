# 🔧 Troubleshooting Guide

## Common Issues and Solutions

### 1. Logo Not Showing

**Symptoms:**
- Logo image missing on deployed site
- 404 error for `/frankshtein.png` in console

**Solutions:**

#### A. Hard Refresh Browser
```bash
# Windows/Linux
Ctrl + Shift + R

# Mac
Cmd + Shift + R
```

#### B. Verify File Exists
```bash
ls -la php-migration-tool/frontend/public/frankshtein.png
```

Should show: `326369 bytes`

#### C. Check Vercel Build Logs
1. Go to Vercel Dashboard
2. Select frontend project
3. Click latest deployment
4. Check "Build Logs"
5. Look for file copy errors

#### D. Rebuild Frontend
```bash
# In Vercel Dashboard
Deployments → Latest → Redeploy
```

---

### 2. CORS Errors

**Symptoms:**
- Console error: `Access to fetch at '...' has been blocked by CORS policy`
- API calls fail with CORS error
- Network tab shows preflight OPTIONS request failing

**Solutions:**

#### A. Verify Frontend URL in Backend
Edit `php-migration-tool/backend/main.py`:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://localhost:3000",
        "https://your-frontend-url.vercel.app",  # ← Check this!
        "https://*.vercel.app",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

#### B. Push Changes
```bash
git add php-migration-tool/backend/main.py
git commit -m "Fix CORS configuration"
git push origin main
```

#### C. Wait for Redeploy
- Vercel auto-deploys on push
- Wait 1-2 minutes
- Check deployment status in dashboard

#### D. Test Backend Directly
```bash
curl -I https://your-backend.vercel.app/
```

Should return `200 OK` with CORS headers.

---

### 3. Timeout Errors

**Symptoms:**
- Error: `Function execution timed out`
- GitHub clone fails
- Analysis takes too long
- 504 Gateway Timeout

**Cause:**
Vercel free tier has 10-second timeout.

**Solutions:**

#### A. Upgrade to Vercel Pro
- Cost: $20/month
- Timeout: 60 seconds
- Better for file operations

**How to upgrade:**
1. Vercel Dashboard → Settings
2. Billing → Upgrade to Pro
3. Redeploy projects

#### B. Use Railway for Backend (Free Alternative)

**Railway Setup:**
1. Go to https://railway.app
2. Sign up with GitHub
3. New Project → Deploy from GitHub
4. Select your repository
5. Set root directory: `php-migration-tool/backend`
6. Add environment variables:
   ```
   PORT=8000
   PYTHONUNBUFFERED=1
   ```
7. Deploy

**Update Frontend:**
Edit `frontend/vercel.json`:
```json
"destination": "https://your-app.railway.app/api/:path*"
```

#### C. Optimize Backend
- Use shallow git clones
- Limit analysis depth
- Cache results
- Process in chunks

---

### 4. API Not Working

**Symptoms:**
- API calls return 404
- Backend not responding
- Network errors

**Solutions:**

#### A. Test Backend Health
```bash
curl https://your-backend.vercel.app/
```

**Expected response:**
```json
{
  "status": "healthy",
  "service": "PHP Migration Tool API",
  "version": "1.0.0"
}
```

#### B. Check Backend URL in Frontend
Edit `frontend/vercel.json`:
```json
{
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "https://your-backend.vercel.app/api/:path*"
    }
  ]
}
```

Verify URL is correct (no typos).

#### C. Check Vercel Function Logs
1. Vercel Dashboard → Backend Project
2. Deployments → Latest
3. Functions tab
4. View logs for errors

#### D. Test API Endpoints
```bash
# Test root
curl https://your-backend.vercel.app/

# Test health check
curl https://your-backend.vercel.app/health

# Test with verbose
curl -v https://your-backend.vercel.app/
```

---

### 5. Build Failures

**Symptoms:**
- Deployment fails
- Build errors in logs
- Red X on deployment

**Solutions:**

#### A. Check Build Logs
1. Vercel Dashboard
2. Failed deployment
3. View "Build Logs"
4. Look for error messages

#### B. Common Build Errors

**Frontend - Missing Dependencies:**
```bash
# In frontend/package.json, verify all deps listed
npm install
npm run build  # Test locally
```

**Backend - Python Errors:**
```bash
# In backend/requirements.txt, verify all deps listed
pip install -r requirements.txt
python -m main  # Test locally
```

**Wrong Root Directory:**
- Frontend: `php-migration-tool/frontend`
- Backend: `php-migration-tool/backend`

#### C. Clear Build Cache
In Vercel Dashboard:
1. Settings → General
2. Scroll to "Build & Development Settings"
3. Clear build cache
4. Redeploy

---

### 6. Environment Variables Missing

**Symptoms:**
- Backend errors about missing config
- Features not working
- Import errors

**Solutions:**

#### A. Add Environment Variables
Vercel Dashboard → Project → Settings → Environment Variables

**Backend:**
```
PYTHONUNBUFFERED=1
GIT_PYTHON_REFRESH=quiet
```

**Frontend (if needed):**
```
VITE_API_URL=https://your-backend.vercel.app
```

#### B. Redeploy After Adding
Environment changes require redeploy:
1. Deployments → Latest
2. Click "..." menu
3. Redeploy

---

### 7. GitHub Clone Fails

**Symptoms:**
- Error: "Failed to clone repository"
- Git command not found
- Authentication errors

**Solutions:**

#### A. Public Repositories Only
Vercel serverless functions can only clone public repos.

**For private repos:**
- Use personal access token
- Add to environment variables
- Update clone logic

#### B. Check Repository URL
```bash
# Valid formats
https://github.com/username/repo
https://github.com/username/repo.git

# Invalid
git@github.com:username/repo.git  # SSH not supported
```

#### C. Verify Git is Available
Check backend logs for git errors.

**If git missing:**
- Rebuild backend
- Verify Dockerfile installs git
- Check requirements.txt has gitpython

#### D. Use Shallow Clone
Backend already uses shallow clone:
```python
git.Repo.clone_from(
    repo_url,
    extract_dir,
    depth=1,  # Shallow clone
    single_branch=True
)
```

---

### 8. Animations Not Working

**Symptoms:**
- Logo shows but doesn't animate
- No glow effects
- Static appearance

**Solutions:**

#### A. Check CSS Loaded
1. Open browser DevTools (F12)
2. Network tab
3. Refresh page
4. Look for `frankenstein-theme.css`
5. Should return 200 OK

#### B. Check for CSS Errors
1. Console tab
2. Look for CSS parsing errors
3. Fix any syntax errors

#### C. Check Browser Support
Animations use modern CSS:
- Chrome/Edge: ✓ Full support
- Firefox: ✓ Full support
- Safari: ✓ Full support
- IE11: ✗ Limited support

#### D. Disable Reduced Motion
Some users have "reduce motion" enabled:

**Check:**
```css
@media (prefers-reduced-motion: reduce) {
  /* Animations disabled */
}
```

**Test:**
- System Settings → Accessibility
- Disable "Reduce motion"

---

### 9. Slow Performance

**Symptoms:**
- Slow page loads
- Laggy animations
- High CPU usage

**Solutions:**

#### A. Optimize Images
```bash
# Compress logo
# Use tools like TinyPNG or ImageOptim
```

#### B. Reduce Animation Complexity
Edit `frankenstein-theme.css`:
```css
/* Disable intensive animations */
.frankenstein-logo {
  animation: float-logo 6s ease-in-out infinite;
  /* Remove electric-spark for better performance */
}
```

#### C. Enable Caching
Frontend already has caching headers in `vercel.json`.

#### D. Use CDN
Vercel automatically uses CDN for static assets.

---

### 10. Deployment Not Updating

**Symptoms:**
- Changes not showing
- Old version still live
- Cache issues

**Solutions:**

#### A. Hard Refresh
```bash
# Clear browser cache
Ctrl + Shift + R (Windows/Linux)
Cmd + Shift + R (Mac)
```

#### B. Check Deployment Status
1. Vercel Dashboard
2. Deployments tab
3. Verify latest is "Ready"
4. Check timestamp

#### C. Force Redeploy
1. Deployments → Latest
2. Click "..." menu
3. Redeploy
4. Wait for completion

#### D. Clear Vercel Cache
```bash
# Using Vercel CLI
vercel --force
```

---

## Debugging Checklist

When something goes wrong:

- [ ] Check browser console (F12)
- [ ] Check Network tab for failed requests
- [ ] Check Vercel deployment logs
- [ ] Check Vercel function logs
- [ ] Test backend URL directly
- [ ] Verify environment variables
- [ ] Check CORS configuration
- [ ] Try hard refresh
- [ ] Test in incognito mode
- [ ] Check git status
- [ ] Verify latest code pushed

---

## Getting More Help

### 1. Check Documentation
- `START_HERE.md` - Step-by-step guide
- `DEPLOY_QUICKSTART.md` - Quick reference
- `VERCEL_BOTH_DEPLOYMENT.md` - Comprehensive guide

### 2. Check Vercel Logs
- Dashboard → Project → Deployments
- Click deployment → View logs
- Functions tab for runtime logs

### 3. Test Locally
```bash
# Frontend
cd php-migration-tool/frontend
npm run dev

# Backend
cd php-migration-tool/backend
uvicorn main:app --reload
```

### 4. Vercel Support
- Docs: https://vercel.com/docs
- Support: https://vercel.com/support
- Community: https://github.com/vercel/vercel/discussions

### 5. Check GitHub Issues
Search for similar issues in:
- Vercel repository
- FastAPI repository
- Your project issues

---

## Prevention Tips

### Before Deploying
- [ ] Test locally first
- [ ] Verify all files committed
- [ ] Check git status clean
- [ ] Review configuration files
- [ ] Test in production mode locally

### After Deploying
- [ ] Test all features
- [ ] Check browser console
- [ ] Monitor Vercel logs
- [ ] Test on different browsers
- [ ] Test on mobile devices

### Regular Maintenance
- [ ] Monitor function execution times
- [ ] Check error rates
- [ ] Update dependencies
- [ ] Review Vercel analytics
- [ ] Optimize slow endpoints

---

## Quick Reference

### Test Backend
```bash
curl https://your-backend.vercel.app/
```

### Test Frontend
```
https://your-frontend.vercel.app/
```

### View Logs
```bash
vercel logs <deployment-url>
```

### Redeploy
```bash
vercel --prod
```

### Check Status
```bash
vercel ls
```

---

## Common Error Messages

### "Function execution timed out"
→ Upgrade to Pro or use Railway

### "CORS policy blocked"
→ Update backend CORS with frontend URL

### "404 Not Found"
→ Check API URL in frontend config

### "Git not found"
→ Rebuild backend with git installed

### "Module not found"
→ Check requirements.txt / package.json

### "Build failed"
→ Check build logs for specific error

---

**Still stuck?** Check the comprehensive guides in `php-migration-tool/` directory!
