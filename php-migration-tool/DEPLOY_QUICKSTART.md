# 🚀 5-Minute Vercel Deployment

## What You're Deploying

**PHP Migration Tool** - A Frankenstein-themed tool that converts PHP projects to Python/FastAPI.

## Prerequisites ✓

- [x] Code on GitHub
- [x] Vercel account (free)
- [x] 15 minutes of time

## The Plan

Deploy TWO separate Vercel projects:
1. **Backend** (Python API) → Get URL
2. **Frontend** (React UI) → Use backend URL

---

## 🎯 Step-by-Step

### 1️⃣ Deploy Backend (5 min)

**Go to:** https://vercel.com/new

**Settings:**
```
Project Name: php-migration-backend
Framework: Other
Root Directory: php-migration-tool/backend
```

**Click Deploy** → Wait 2-3 minutes

**Copy URL:** `https://php-migration-backend-xyz.vercel.app`

---

### 2️⃣ Update Frontend Config (2 min)

**Edit:** `php-migration-tool/frontend/vercel.json`

**Find this line:**
```json
"destination": "https://your-backend-url.vercel.app/api/:path*"
```

**Replace with your backend URL:**
```json
"destination": "https://php-migration-backend-xyz.vercel.app/api/:path*"
```

**Save and push:**
```bash
git add php-migration-tool/frontend/vercel.json
git commit -m "Add backend URL"
git push
```

---

### 3️⃣ Deploy Frontend (5 min)

**Go to:** https://vercel.com/new

**Settings:**
```
Project Name: php-migration-tool
Framework: Vite
Root Directory: php-migration-tool/frontend
Build Command: npm run build
Output Directory: dist
```

**Click Deploy** → Wait 2-3 minutes

**Copy URL:** `https://php-migration-tool-xyz.vercel.app`

---

### 4️⃣ Update Backend CORS (2 min)

**Edit:** `php-migration-tool/backend/main.py`

**Find this section:**
```python
allow_origins=[
    "http://localhost:5173",
    "http://localhost:3000",
],
```

**Add your frontend URL:**
```python
allow_origins=[
    "http://localhost:5173",
    "http://localhost:3000",
    "https://php-migration-tool-xyz.vercel.app",  # Your frontend
    "https://*.vercel.app",  # All Vercel previews
],
```

**Save and push:**
```bash
git add php-migration-tool/backend/main.py
git commit -m "Add CORS for frontend"
git push
```

Backend will auto-redeploy (1-2 minutes).

---

### 5️⃣ Test (1 min)

**Open:** `https://php-migration-tool-xyz.vercel.app`

**You should see:**
- ✓ Animated Frankenstein logo
- ✓ "Frankenstein Laboratory" title
- ✓ Four experiment stages
- ✓ No errors in console (F12)

**Try it:**
1. Enter a GitHub repo URL
2. Click "Begin Experiment"
3. Should clone and analyze

---

## ✅ Success!

Your app is live:
- **Frontend:** https://php-migration-tool-xyz.vercel.app
- **Backend:** https://php-migration-backend-xyz.vercel.app

---

## 🐛 Troubleshooting

### Logo Not Showing
- Hard refresh: `Ctrl+Shift+R` (Mac: `Cmd+Shift+R`)
- Check console for 404 errors

### CORS Error
- Verify frontend URL in `backend/main.py`
- Wait for backend to redeploy
- Check Vercel dashboard

### Timeout Error
- Vercel free = 10 second limit
- Upgrade to Pro ($20/month) = 60 seconds
- Or use Railway for backend (free)

### API Not Working
Test backend directly:
```bash
curl https://php-migration-backend-xyz.vercel.app/
```

Should return:
```json
{"status":"healthy","service":"PHP Migration Tool API","version":"1.0.0"}
```

---

## 📚 More Help

- **Detailed Guide:** `VERCEL_BOTH_DEPLOYMENT.md`
- **Step-by-Step:** `START_HERE.md`
- **Quick Reference:** `QUICKSTART.md`
- **Simple Checklist:** `VERCEL_CHECKLIST.md`

---

## 💡 Pro Tips

1. **Test backend first** - `curl` the URL before deploying frontend
2. **Use Vercel CLI** - `npm i -g vercel` for faster deploys
3. **Check logs** - Vercel dashboard → Functions → View logs
4. **Auto-deploy** - Every `git push` updates production
5. **Preview deploys** - Every PR gets a preview URL

---

## 🎉 What's Next?

### Custom Domain
1. Vercel Dashboard → Your Project
2. Settings → Domains
3. Add domain: `migration-tool.yourdomain.com`

### Monitoring
- Check Vercel Analytics
- Monitor function execution times
- Set up error alerts

### Upgrade (Optional)
- **Vercel Pro:** $20/month
  - 60-second timeout
  - Better performance
  - Priority support

---

## 📊 Deployment Summary

| Step | Time | Status |
|------|------|--------|
| Backend Deploy | 3 min | ⏳ |
| Update Frontend | 2 min | ⏳ |
| Frontend Deploy | 3 min | ⏳ |
| Update CORS | 2 min | ⏳ |
| Testing | 1 min | ⏳ |
| **Total** | **~15 min** | |

---

## 🔄 Future Updates

After initial setup, just:
```bash
git add .
git commit -m "Update feature"
git push
```

Vercel auto-deploys both projects!

---

**Ready to deploy?** Follow the steps above or use `START_HERE.md` for more details.

Good luck! 🚀
