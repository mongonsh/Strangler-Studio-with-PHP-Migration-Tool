# Vercel Deployment Checklist

## Before You Start

- [ ] Code is on GitHub
- [ ] Vercel account created
- [ ] Logo file exists at `frontend/public/frankshtein.png`

## Deploy Backend (Project 1)

- [ ] Go to https://vercel.com/new
- [ ] Import your GitHub repository
- [ ] Set root directory: `php-migration-tool/backend`
- [ ] Framework: Other
- [ ] Click Deploy
- [ ] Wait for deployment
- [ ] Copy backend URL: `https://__________.vercel.app`

## Update Frontend

- [ ] Edit `frontend/vercel.json`
- [ ] Replace backend URL in rewrites section
- [ ] Commit: `git commit -m "Update API URL"`
- [ ] Push: `git push`

## Deploy Frontend (Project 2)

- [ ] Go to https://vercel.com/new again
- [ ] Import same GitHub repository
- [ ] Set root directory: `php-migration-tool/frontend`
- [ ] Framework: Vite
- [ ] Build command: `npm run build`
- [ ] Output directory: `dist`
- [ ] Click Deploy
- [ ] Wait for deployment
- [ ] Copy frontend URL: `https://__________.vercel.app`

## Update CORS

- [ ] Edit `backend/main.py`
- [ ] Add frontend URL to `allow_origins`
- [ ] Commit: `git commit -m "Update CORS"`
- [ ] Push: `git push`
- [ ] Wait for auto-redeploy

## Test

- [ ] Open frontend URL
- [ ] Logo shows and animates
- [ ] Try GitHub clone feature
- [ ] Check browser console (no errors)
- [ ] Test all features work

## Done! 🎉

Your app is live:
- Frontend: https://__________.vercel.app
- Backend: https://__________.vercel.app

## If Something Breaks

1. Check Vercel deployment logs
2. Check browser console
3. Verify CORS settings
4. Test backend URL directly
5. See `VERCEL_BOTH_DEPLOYMENT.md` for troubleshooting

## Upgrade to Pro?

If you get timeout errors (>10 seconds):
- Upgrade to Vercel Pro ($20/month)
- Get 60-second timeout
- Or use Railway for backend (free tier)
