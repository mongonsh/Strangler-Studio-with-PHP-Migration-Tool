# Halloween Theme Design Guidelines

## Overview

The Strangler Studio Halloween theme is premium and cinematic, evoking a modern horror film aesthetic with sophisticated visual effects. This document provides comprehensive guidelines for maintaining visual consistency across the application.

## Design Philosophy

### Core Principles

- **Premium, not cheap**: Avoid generic Halloween clichés
- **Cinematic**: Think modern horror films, not party decorations
- **Sophisticated**: Elegant typography and refined effects
- **Memorable**: Create a lasting impression through polish
- **Functional**: Beauty serves usability, not vice versa

### Mood Board

Visual references:
- Modern horror films (Hereditary, The Witch, Midsommar)
- Premium dark mode interfaces (Stripe, Linear, Vercel)
- Glassmorphism design trend
- Neon noir aesthetics

## Color Palette

### Primary Colors

```css
/* Background */
--color-bg-primary: #0a0a0a;      /* Deep black */
--color-bg-secondary: #1a1a1a;    /* Charcoal */
--color-bg-elevated: #242424;     /* Elevated surfaces */

/* Surface */
--color-surface: rgba(26, 26, 26, 0.7);  /* Glassmorphism base */
```

### Accent Colors

```css
/* Primary Accent - Pumpkin Orange */
--color-accent-primary: #ff6b35;
--color-accent-primary-hover: #ff8555;
--color-accent-primary-glow: rgba(255, 107, 53, 0.3);

/* Secondary Accent - Ghostly Cyan */
--color-accent-secondary: #4ecdc4;
--color-accent-secondary-hover: #6eddd4;
--color-accent-secondary-glow: rgba(78, 205, 196, 0.3);

/* Tertiary Accent - Blood Red */
--color-accent-tertiary: #c1121f;
--color-accent-tertiary-hover: #d1222f;
--color-accent-tertiary-glow: rgba(193, 18, 31, 0.3);

/* Text */
--color-text-primary: #f8f9fa;    /* Bone white */
--color-text-secondary: #b8b9ba;  /* Muted gray */
--color-text-tertiary: #6c757d;   /* Subtle gray */
```

### Semantic Colors

```css
/* Status Colors */
--color-success: #4ecdc4;         /* Summoned - Cyan */
--color-warning: #ff6b35;         /* Possessed - Orange */
--color-error: #c1121f;           /* Banished - Red */
--color-neutral: #6c757d;         /* Pending - Gray */
```

### Usage Guidelines

- **Background**: Use deep black (#0a0a0a) for main background
- **Surfaces**: Use charcoal (#1a1a1a) for cards and elevated elements
- **Accents**: Use sparingly for CTAs, highlights, and status indicators
- **Text**: Bone white (#f8f9fa) for primary text, ensure 4.5:1 contrast minimum

## Typography

### Font Families

```css
/* Headings - Elegant, slightly gothic */
--font-heading: 'Cinzel', serif;

/* Body - Modern, highly readable */
--font-body: 'Inter', sans-serif;

/* Monospace - For code snippets */
--font-mono: 'Fira Code', monospace;
```

### Import Fonts

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700&family=Inter:wght@300;400;500;600;700&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
```

### Type Scale

```css
/* Hero Title */
--text-hero: 4rem;           /* 64px */
--text-hero-weight: 700;
--text-hero-line-height: 1.1;

/* Section Heading */
--text-h1: 2.5rem;           /* 40px */
--text-h1-weight: 600;
--text-h1-line-height: 1.2;

/* Card Title */
--text-h2: 1.5rem;           /* 24px */
--text-h2-weight: 600;
--text-h2-line-height: 1.3;

/* Subheading */
--text-h3: 1.25rem;          /* 20px */
--text-h3-weight: 600;
--text-h3-line-height: 1.4;

/* Body */
--text-body: 1rem;           /* 16px */
--text-body-weight: 400;
--text-body-line-height: 1.6;

/* Small */
--text-small: 0.875rem;      /* 14px */
--text-small-weight: 400;
--text-small-line-height: 1.5;

/* Tiny */
--text-tiny: 0.75rem;        /* 12px */
--text-tiny-weight: 400;
--text-tiny-line-height: 1.4;
```

### Typography Usage

```css
/* Hero Title */
.hero-title {
    font-family: var(--font-heading);
    font-size: var(--text-hero);
    font-weight: var(--text-hero-weight);
    line-height: var(--text-hero-line-height);
    letter-spacing: -0.02em;
}

/* Section Heading */
.section-heading {
    font-family: var(--font-heading);
    font-size: var(--text-h1);
    font-weight: var(--text-h1-weight);
    line-height: var(--text-h1-line-height);
}

/* Body Text */
.body-text {
    font-family: var(--font-body);
    font-size: var(--text-body);
    font-weight: var(--text-body-weight);
    line-height: var(--text-body-line-height);
}
```

## Visual Effects

### Glassmorphism

Create frosted glass effect for cards and surfaces:

```css
.glass-card {
    background: rgba(26, 26, 26, 0.7);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 16px;
}
```

### Glow Effects

Add atmospheric glow to interactive elements:

```css
/* Primary Glow - Orange */
.glow-primary {
    box-shadow: 
        0 0 20px rgba(255, 107, 53, 0.3),
        0 0 40px rgba(255, 107, 53, 0.1);
}

/* Secondary Glow - Cyan */
.glow-secondary {
    box-shadow: 
        0 0 20px rgba(78, 205, 196, 0.3),
        0 0 40px rgba(78, 205, 196, 0.1);
}

/* Text Glow */
.text-glow {
    text-shadow: 
        0 0 10px rgba(255, 107, 53, 0.5),
        0 0 20px rgba(255, 107, 53, 0.3),
        0 0 30px rgba(255, 107, 53, 0.1);
}
```

### Gradient Borders

Animated gradient borders for premium feel:

```css
.gradient-border {
    position: relative;
    border-radius: 16px;
    padding: 2px;
    background: linear-gradient(135deg, #ff6b35, #4ecdc4);
    animation: gradient-shift 3s ease infinite;
}

.gradient-border::before {
    content: '';
    position: absolute;
    inset: 2px;
    background: #1a1a1a;
    border-radius: 14px;
    z-index: -1;
}

@keyframes gradient-shift {
    0%, 100% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
}
```

### Grain Texture

Add subtle film grain for cinematic feel:

```css
.grain-overlay {
    position: relative;
}

.grain-overlay::after {
    content: '';
    position: absolute;
    inset: 0;
    background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.05'/%3E%3C/svg%3E");
    pointer-events: none;
    opacity: 0.05;
}
```

### Vignette Effect

Subtle darkening at edges:

```css
.vignette {
    position: relative;
}

.vignette::before {
    content: '';
    position: absolute;
    inset: 0;
    background: radial-gradient(
        circle at center,
        transparent 0%,
        rgba(10, 10, 10, 0.3) 100%
    );
    pointer-events: none;
}
```

## Component Styles

### Hero Section

```css
.hero {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(180deg, #0a0a0a 0%, #1a1a1a 100%);
    position: relative;
}

.hero-title {
    font-family: 'Cinzel', serif;
    font-size: 4rem;
    font-weight: 700;
    color: #f8f9fa;
    text-shadow: 
        0 0 10px rgba(255, 107, 53, 0.5),
        0 0 20px rgba(255, 107, 53, 0.3);
    animation: glow-pulse 3s ease-in-out infinite;
}

@keyframes glow-pulse {
    0%, 100% { text-shadow: 0 0 10px rgba(255, 107, 53, 0.5); }
    50% { text-shadow: 0 0 20px rgba(255, 107, 53, 0.8); }
}
```

### Component Cards

```css
.component-card {
    background: rgba(26, 26, 26, 0.7);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 16px;
    padding: 2rem;
    transition: all 300ms cubic-bezier(0.4, 0.0, 0.2, 1);
}

.component-card:hover {
    transform: translateY(-8px);
    box-shadow: 
        0 0 20px rgba(255, 107, 53, 0.3),
        0 20px 40px rgba(0, 0, 0, 0.5);
    border-color: rgba(255, 107, 53, 0.3);
}
```

### Buttons

```css
/* Primary Button */
.btn-primary {
    background: linear-gradient(135deg, #ff6b35, #ff8555);
    color: #f8f9fa;
    padding: 0.75rem 2rem;
    border-radius: 8px;
    border: none;
    font-family: 'Inter', sans-serif;
    font-weight: 600;
    font-size: 1rem;
    cursor: pointer;
    transition: all 300ms ease;
    box-shadow: 0 0 20px rgba(255, 107, 53, 0.3);
}

.btn-primary:hover {
    transform: scale(1.05);
    box-shadow: 0 0 30px rgba(255, 107, 53, 0.5);
}

.btn-primary:active {
    transform: scale(0.98);
}

/* Secondary Button */
.btn-secondary {
    background: transparent;
    color: #4ecdc4;
    padding: 0.75rem 2rem;
    border-radius: 8px;
    border: 2px solid #4ecdc4;
    font-family: 'Inter', sans-serif;
    font-weight: 600;
    font-size: 1rem;
    cursor: pointer;
    transition: all 300ms ease;
}

.btn-secondary:hover {
    background: #4ecdc4;
    color: #0a0a0a;
    box-shadow: 0 0 20px rgba(78, 205, 196, 0.3);
}
```

### Status Badges

```css
.status-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    border-radius: 9999px;
    font-size: 0.875rem;
    font-weight: 600;
    font-family: 'Inter', sans-serif;
}

.status-possessed {
    background: rgba(255, 107, 53, 0.2);
    color: #ff6b35;
    box-shadow: 0 0 10px rgba(255, 107, 53, 0.2);
}

.status-banished {
    background: rgba(193, 18, 31, 0.2);
    color: #c1121f;
    box-shadow: 0 0 10px rgba(193, 18, 31, 0.2);
}

.status-summoned {
    background: rgba(78, 205, 196, 0.2);
    color: #4ecdc4;
    box-shadow: 0 0 10px rgba(78, 205, 196, 0.2);
}

.status-pending {
    background: rgba(108, 117, 125, 0.2);
    color: #6c757d;
}
```

### Witch Switch (Toggle)

```css
.witch-switch {
    position: relative;
    width: 200px;
    height: 40px;
    background: rgba(26, 26, 26, 0.7);
    border-radius: 20px;
    border: 1px solid rgba(255, 255, 255, 0.1);
    cursor: pointer;
    transition: all 300ms ease;
}

.witch-switch-slider {
    position: absolute;
    top: 4px;
    left: 4px;
    width: 32px;
    height: 32px;
    background: linear-gradient(135deg, #ff6b35, #4ecdc4);
    border-radius: 50%;
    transition: all 300ms cubic-bezier(0.4, 0.0, 0.2, 1);
    box-shadow: 0 0 20px rgba(255, 107, 53, 0.5);
}

.witch-switch.active .witch-switch-slider {
    left: calc(100% - 36px);
    box-shadow: 0 0 20px rgba(78, 205, 196, 0.5);
}
```

### Data Table

```css
.data-table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0 0.5rem;
}

.data-table thead th {
    background: rgba(26, 26, 26, 0.9);
    backdrop-filter: blur(10px);
    padding: 1rem;
    text-align: left;
    font-family: 'Inter', sans-serif;
    font-weight: 600;
    color: #f8f9fa;
    position: sticky;
    top: 0;
    z-index: 10;
}

.data-table tbody tr {
    background: rgba(26, 26, 26, 0.7);
    backdrop-filter: blur(10px);
    transition: all 300ms ease;
}

.data-table tbody tr:hover {
    background: rgba(36, 36, 36, 0.8);
    box-shadow: 0 0 20px rgba(255, 107, 53, 0.2);
    transform: scale(1.01);
}

.data-table tbody td {
    padding: 1rem;
    border-top: 1px solid rgba(255, 255, 255, 0.05);
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}
```

## Animation Guidelines

### Timing Functions

```css
/* Standard easing */
--ease-standard: cubic-bezier(0.4, 0.0, 0.2, 1);

/* Decelerate (enter) */
--ease-decelerate: cubic-bezier(0.0, 0.0, 0.2, 1);

/* Accelerate (exit) */
--ease-accelerate: cubic-bezier(0.4, 0.0, 1, 1);
```

### Duration

```css
/* Fast - Micro-interactions */
--duration-fast: 150ms;

/* Medium - Hover states, toggles */
--duration-medium: 300ms;

/* Slow - Page transitions, reveals */
--duration-slow: 600ms;
```

### Common Animations

```css
/* Fade In */
@keyframes fade-in {
    from { opacity: 0; }
    to { opacity: 1; }
}

/* Slide Up */
@keyframes slide-up {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

/* Glow Pulse */
@keyframes glow-pulse {
    0%, 100% {
        box-shadow: 0 0 20px rgba(255, 107, 53, 0.3);
    }
    50% {
        box-shadow: 0 0 40px rgba(255, 107, 53, 0.6);
    }
}
```

## Responsive Design

### Breakpoints

```css
/* Mobile */
@media (max-width: 639px) {
    :root {
        --text-hero: 2.5rem;
        --text-h1: 2rem;
        --text-h2: 1.25rem;
    }
}

/* Tablet */
@media (min-width: 640px) and (max-width: 1023px) {
    :root {
        --text-hero: 3rem;
        --text-h1: 2.25rem;
        --text-h2: 1.5rem;
    }
}

/* Desktop */
@media (min-width: 1024px) {
    /* Default values */
}
```

### Mobile Adaptations

- Single column layouts
- Larger touch targets (min 44px)
- Simplified animations (respect prefers-reduced-motion)
- Reduced glow effects for performance
- Simplified glassmorphism (less blur)

## Accessibility

### Color Contrast

- Body text: Minimum 4.5:1 contrast ratio
- Large text (18px+): Minimum 3:1 contrast ratio
- Interactive elements: Minimum 3:1 contrast ratio

### Focus Indicators

```css
*:focus-visible {
    outline: 2px solid #ff6b35;
    outline-offset: 2px;
    border-radius: 4px;
}
```

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
    }
}
```

### Semantic HTML

- Use proper heading hierarchy (h1 → h2 → h3)
- Use semantic elements (nav, main, article, section)
- Add ARIA labels for interactive elements
- Ensure keyboard navigation works

## Implementation Checklist

When implementing Halloween theme:

- [ ] Import Cinzel and Inter fonts
- [ ] Set up CSS custom properties for colors
- [ ] Apply grain texture overlay to body
- [ ] Implement glassmorphism for cards
- [ ] Add glow effects to interactive elements
- [ ] Create gradient borders for premium elements
- [ ] Style status badges with appropriate colors
- [ ] Implement witch switch toggle
- [ ] Add hover microinteractions
- [ ] Test color contrast ratios
- [ ] Add focus indicators
- [ ] Implement reduced motion support
- [ ] Test responsive breakpoints
- [ ] Verify accessibility with screen reader

## Resources

- [Google Fonts - Cinzel](https://fonts.google.com/specimen/Cinzel)
- [Google Fonts - Inter](https://fonts.google.com/specimen/Inter)
- [Glassmorphism Generator](https://hype4.academy/tools/glassmorphism-generator)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
