# Frankenstein Laboratory Theme - Complete Transformation

## What's Been Changed

### 1. Premium Gothic Laboratory Theme
- ✅ Removed all cheap emojis
- ✅ Sophisticated Frankenstein/laboratory aesthetic
- ✅ Electric blue and toxic green color scheme
- ✅ Gothic typography (Cinzel + Crimson Text)
- ✅ Lightning effects and laboratory grid patterns
- ✅ Glass laboratory containers with electric glow

### 2. GitHub Repository Input
- ✅ Clone directly from GitHub (no ZIP upload needed)
- ✅ Support for branch selection
- ✅ Automatic repository cloning via GitPython

### 3. Live PHP Preview
- ✅ Input field for localhost port (e.g., 8080)
- ✅ Test connection button
- ✅ Embedded iframe showing live PHP project
- ✅ Real-time preview of running PHP application

### 4. New UI Components

**Color Palette:**
- Void Black: #0a0a0a
- Electric Blue: #00d4ff (primary accent)
- Lightning: #4dd0e1
- Toxic Green: #76ff03 (success states)
- Blood Red: #b71c1c (errors)
- Bone White: #f5f5f5 (text)
- Brass: #b8860b (accents)

**Typography:**
- Titles: Cinzel (Gothic serif, all caps, letter-spaced)
- Body: Crimson Text (Elegant serif, italic for subtitles)
- No emojis, only sophisticated text

**Effects:**
- Electric glow on active elements
- Pulse animations for charging states
- Laboratory grid background
- Lightning pulse effects
- Glass panels with backdrop blur

### 5. Renamed Steps
- Upload → **Source** (Specimen Acquisition)
- Analyze → **Analyze** (Examination)
- Generate → **Transform** (Reanimation)
- Download → **Extract** (Extraction)

## How to Use

### Start the Application
```bash
docker-compose up --build
```

### Access
http://localhost

### Input GitHub Repository
1. Enter repository URL: `https://github.com/username/repo`
2. Specify branch (default: main)
3. Optional: Enter localhost port for live preview
4. Click "Begin Experiment"

### Live PHP Preview
If your PHP project is running locally:
1. Start your PHP server: `php -S localhost:8080`
2. Enter port `8080` in the preview field
3. Click "Test Connection"
4. See live preview in embedded iframe

## Theme Features

### Laboratory Container
```css
.lab-container {
  background: rgba(26, 26, 26, 0.85);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(0, 212, 255, 0.2);
  box-shadow: deep shadows + electric glow;
}
```

### Experiment Stages (Progress Steps)
- Circular indicators with electric borders
- Pulse ring animation on active stage
- Toxic green for completed stages
- Electric blue for current stage

### Laboratory Buttons
```css
.btn-laboratory {
  font-family: Cinzel;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border: 2px solid electric-blue;
  electric glow on hover;
}
```

### Input Fields
```css
.input-laboratory {
  background: dark with electric border;
  focus: electric glow effect;
  placeholder: italic, faded;
}
```

## Backend Changes

### New Endpoints

**POST /api/clone-github**
```json
{
  "repo_url": "https://github.com/user/repo",
  "branch": "main"
}
```
Response:
```json
{
  "upload_id": "abc123",
  "repo_url": "...",
  "branch": "main",
  "status": "cloned"
}
```

**POST /api/check-php-server**
```json
{
  "port": 8080,
  "project_id": "preview"
}
```
Response:
```json
{
  "accessible": true,
  "status_code": 200,
  "port": 8080
}
```

### New Dependencies
- gitpython: Clone GitHub repositories
- requests: Check PHP server accessibility
- httpx: Async HTTP client

## File Structure

```
php-migration-tool/
├── frontend/
│   └── src/
│       ├── frankenstein-theme.css  ✨ NEW
│       ├── App.jsx                 ✨ UPDATED
│       ├── index.css               ✨ UPDATED
│       └── components/
│           ├── Input.jsx           ✨ NEW (replaces Upload)
│           ├── Analysis.jsx        (needs update)
│           ├── Generate.jsx        (needs update)
│           └── Download.jsx        (needs update)
│
└── backend/
    ├── main.py                     ✨ UPDATED
    └── requirements.txt            ✨ UPDATED
```

## Design Philosophy

### No Cheap Elements
- ❌ No generic emojis
- ❌ No bright gradients
- ❌ No rounded bubbly designs
- ❌ No playful animations

### Premium Gothic Laboratory
- ✅ Sophisticated typography
- ✅ Electric/lightning effects
- ✅ Laboratory equipment aesthetic
- ✅ Gothic horror atmosphere
- ✅ Scientific precision
- ✅ Frankenstein's laboratory vibe

## Quotes & Atmosphere

Footer quote:
> "It's alive! It's alive!" — Dr. Victor Frankenstein

Section titles:
- "Specimen Acquisition"
- "Laboratory Notes"
- "Experiment Stages"
- "Reanimation Process"

## Next Steps

To complete the transformation, update:
1. Analysis.jsx - Add laboratory examination theme
2. Generate.jsx - Add reanimation/transformation theme
3. Download.jsx - Add extraction/completion theme

All components should follow the established Frankenstein laboratory aesthetic with:
- Electric blue accents
- Gothic typography
- Laboratory terminology
- No emojis
- Sophisticated animations
