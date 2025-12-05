# Logo Animations Documentation

## Frankenstein PHP Logo

The animated Frankenstein PHP logo is the centerpiece of the laboratory interface, featuring multiple sophisticated animations that create a living, electric atmosphere.

## Location

- **Image File:** `php-migration-tool/frontend/public/frankshtein.png`
- **Component:** `php-migration-tool/frontend/src/App.jsx`
- **Styles:** `php-migration-tool/frontend/src/frankenstein-theme.css`

## Animations

### 1. Float Animation (6s loop)
The logo gently floats up and down with subtle rotation, creating a levitating effect.

```css
@keyframes float-logo {
  0%, 100% { translateY(0px) rotate(0deg) }
  25% { translateY(-15px) rotate(-2deg) }
  50% { translateY(-10px) rotate(0deg) }
  75% { translateY(-20px) rotate(2deg) }
}
```

**Effect:** Smooth, continuous floating motion with gentle rotation

### 2. Glow Pulse (3s loop)
Electric blue and toxic green glow pulses around the logo, simulating electrical energy.

```css
@keyframes glow-pulse-logo {
  0%, 100% { 
    drop-shadow: 30px blue, 60px green 
  }
  50% { 
    drop-shadow: 50px blue, 100px green 
  }
}
```

**Effect:** Breathing glow effect that intensifies and fades

### 3. Electric Spark (8s loop)
Occasional bright electric sparks flash around the logo, like lightning strikes.

```css
@keyframes electric-spark {
  0%, 90%, 100% { normal glow }
  92%, 94%, 96% { intense flash }
}
```

**Effect:** Random-looking electric sparks every 8 seconds

### 4. Hover Shake (0.5s on hover)
When hovering, the logo shakes as if charged with electricity.

```css
@keyframes shake-logo {
  10%, 30%, 50%, 70%, 90% { translateX(-5px) rotate(-3deg) }
  20%, 40%, 60%, 80% { translateX(5px) rotate(3deg) }
}
```

**Effect:** Rapid vibration effect on hover

### 5. Rotating Rings
Two concentric rings rotate around the logo at different speeds.

- **Inner Ring:** 20s clockwise rotation
- **Outer Ring:** 15s counter-clockwise rotation

**Effect:** Creates a dynamic energy field around the logo

### 6. Ring Pulse (3-4s loop)
The rings pulse in and out, creating a radar-like effect.

```css
@keyframes pulse-ring-logo {
  0%, 100% { scale(1), opacity(0.3) }
  50% { scale(1.1), opacity(0.6) }
}
```

**Effect:** Expanding and contracting energy rings

## Interactive Effects

### Hover State
When you hover over the logo:
- **Scale:** Grows to 110%
- **Rotation:** Tilts 5 degrees
- **Glow:** Intensifies dramatically
- **Animation Speed:** Glow pulse doubles in speed
- **Shake:** Triggers vibration effect

### Colors
- **Primary Glow:** Electric Blue (#00d4ff)
- **Secondary Glow:** Toxic Green (#76ff03)
- **Accent:** White flash during sparks

## Technical Details

### CSS Properties Used
- `filter: drop-shadow()` - Multiple layered glows
- `transform` - Position, rotation, scale
- `animation` - Multiple simultaneous animations
- `transition` - Smooth hover effects

### Performance
- **GPU Accelerated:** Uses transform and opacity
- **Optimized:** Animations run on compositor thread
- **Smooth:** 60fps on modern browsers

### Browser Support
- ✓ Chrome/Edge (full support)
- ✓ Firefox (full support)
- ✓ Safari (full support)
- ⚠ IE11 (degraded, no backdrop-filter)

## Customization

### Adjust Animation Speed

```css
/* Slower floating */
animation: float-logo 10s ease-in-out infinite;

/* Faster glow pulse */
animation: glow-pulse-logo 1.5s ease-in-out infinite;

/* More frequent sparks */
animation: electric-spark 4s ease-in-out infinite;
```

### Change Glow Colors

```css
.frankenstein-logo {
  filter: drop-shadow(0 0 30px rgba(255, 0, 0, 0.6))  /* Red */
          drop-shadow(0 0 60px rgba(255, 255, 0, 0.3)); /* Yellow */
}
```

### Adjust Size

```css
.frankenstein-logo {
  width: 200px;  /* Larger */
  width: 150px;  /* Smaller */
}
```

### Disable Animations

```css
.frankenstein-logo {
  animation: none;
}

.logo-container::before,
.logo-container::after {
  animation: none;
}
```

## Animation Layers

The logo has multiple animation layers working together:

```
Layer 1: Logo Image
  ├─ Float (vertical movement)
  ├─ Glow Pulse (intensity)
  ├─ Electric Spark (flashes)
  └─ Hover Effects (scale, rotate, shake)

Layer 2: Inner Ring (::before)
  ├─ Rotate (20s clockwise)
  ├─ Pulse (4s scale)
  └─ Electric Blue glow

Layer 3: Outer Ring (::after)
  ├─ Rotate (15s counter-clockwise)
  ├─ Pulse (3s scale)
  └─ Toxic Green glow
```

## Accessibility

### Reduced Motion
For users who prefer reduced motion:

```css
@media (prefers-reduced-motion: reduce) {
  .frankenstein-logo {
    animation: none;
  }
  
  .logo-container::before,
  .logo-container::after {
    animation: none;
  }
}
```

### Screen Readers
The logo includes proper alt text:

```jsx
<img 
  src="/frankshtein.png" 
  alt="Frankenstein PHP Logo" 
  className="frankenstein-logo"
/>
```

## Examples

### Minimal Animation (Performance Mode)
```css
.frankenstein-logo {
  animation: float-logo 6s ease-in-out infinite;
  /* Only floating, no glow effects */
}
```

### Maximum Drama (Full Effect)
```css
.frankenstein-logo {
  animation: 
    float-logo 6s ease-in-out infinite,
    glow-pulse-logo 3s ease-in-out infinite,
    electric-spark 8s ease-in-out infinite,
    rotate-logo 30s linear infinite;
}
```

### Static (No Animation)
```css
.frankenstein-logo {
  animation: none;
  filter: drop-shadow(0 0 20px rgba(0, 212, 255, 0.5));
}
```

## Troubleshooting

### Logo Not Showing
1. Check file path: `/frankshtein.png` (in public folder)
2. Verify image exists: `ls php-migration-tool/frontend/public/`
3. Check browser console for 404 errors

### Animations Not Working
1. Verify CSS is loaded
2. Check browser DevTools for CSS errors
3. Ensure animations aren't disabled by user preferences

### Performance Issues
1. Reduce number of simultaneous animations
2. Disable electric-spark animation (most intensive)
3. Remove rotating rings
4. Use simpler drop-shadow values

## Future Enhancements

Potential additions:
- Lightning bolt particles
- Electric arc effects between logo and rings
- Color shift based on experiment stage
- Intensity increase during processing
- Sound effects on hover (optional)

## Credits

- **Design:** Frankenstein Laboratory Theme
- **Colors:** Electric Blue (#00d4ff), Toxic Green (#76ff03)
- **Typography:** Cinzel (titles), Crimson Text (body)
- **Inspiration:** Classic horror films, laboratory equipment, electrical experiments
