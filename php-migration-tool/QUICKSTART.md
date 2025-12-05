# ⚡ Vercel Deployment - Quick Reference

## 📋 Checklist

- [ ] Code pushed to GitHub
- [ ] Backend deployed (Project 1)
- [ ] Backend URL copied
- [ ] Frontend vercel.json updated with backend URL
- [ ] Frontend deployed (Project 2)
- [ ] Frontend URL copied
- [ ] Backend main.py updated with frontend URL
- [ ] Changes pushed to GitHub
- [ ] Tested in browser

## 🔗 URLs to Fill In

### Backend URL (from Step 2):
```
https://________________________________.vercel.app
```

### Frontend URL (from Step 4):
```
https://________________________________.vercel.app
```

## 📝 Files to Edit

### 1. `frontend/vercel.json`
```json
"destination": "https://YOUR-BACKEND-URL.vercel.app/api/:path*"
```

### 2. `backend/main.py`
```python
allow_origins=[
    "http://localhost:5173",
    "http://localhost:3000",
    "https://YOUR-FRONTEND-URL.vercel.app",
    "https://*.vercel.app",
]
```

## 🚀 Deploy Commands

### Backend (Project 1)
- Root Directory: `php-migration-tool/backend`
- Framework: Other
- Install: `pip install -r requirements.txt`

### Frontend (Project 2)
- Root Directory: `php-migration-tool/frontend`
- Framework: Vite
- Build: `npm run build`
- Output: `dist`

## ✅ Test Checklist

- [ ] Frontend loads
- [ ] Logo shows and animates
- [ ] No console errors
- [ ] GitHub clone works
- [ ] Analysis works
- [ ] Download works

## 🆘 Quick Fixes

### CORS Error
```bash
# Update backend/main.py with frontend URL
git add backend/main.py
git commit -m "Fix CORS"
git push
```

### Logo Missing
- File should be at: `frontend/public/frankshtein.png`
- Check browser console for 404

### Timeout Error
- Upgrade to Vercel Pro ($20/month)
- Or use Railway for backend

## 📚 Full Guides

- **Detailed:** `VERCEL_BOTH_DEPLOYMENT.md`
- **Step-by-step:** `START_HERE.md`
- **Checklist:** `VERCEL_CHECKLIST.md`

## ⏱️ Time Estimate

- Backend deploy: 3 minutes
- Frontend deploy: 3 minutes
- Configuration: 5 minutes
- Testing: 5 minutes
- **Total: ~15 minutes**

## 🎯 Success Criteria

When everything works:
1. Frontend URL opens in browser
2. Animated logo visible
3. All 4 stages visible
4. Can enter GitHub URL
5. No errors in console

## 💡 Pro Tips

1. **Deploy backend first** - frontend needs backend URL
2. **Copy URLs immediately** - you'll need them
3. **Test backend directly** - `curl https://your-backend.vercel.app/`
4. **Use hard refresh** - Ctrl+Shift+R to clear cache
5. **Check Vercel logs** - if something fails

## 🔄 Auto-Deploy

After initial setup, every `git push` will:
- Auto-deploy to Vercel
- Create preview for branches
- Update production on main branch

## 📊 Monitoring

Check Vercel dashboard for:
- Deployment status
- Function logs
- Error rates
- Response times

---

**Ready?** Start with `START_HERE.md` for detailed instructions!
