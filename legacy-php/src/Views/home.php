<!-- Home Page View -->
<!-- Requirements: 1.3, 1.4, 1.5, 8.6 -->

<style>
    /* Hero Section Specific Styles */
    .hero-section {
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        text-align: center;
        padding: 3rem 1.5rem;
        position: relative;
        z-index: 1;
    }
    
    /* Animated Background Gradient */
    .hero-section::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: radial-gradient(
            ellipse at top,
            rgba(255, 107, 53, 0.1) 0%,
            transparent 50%
        ),
        radial-gradient(
            ellipse at bottom,
            rgba(78, 205, 196, 0.1) 0%,
            transparent 50%
        );
        z-index: -1;
        animation: pulse-gradient 8s ease-in-out infinite;
    }
    
    @keyframes pulse-gradient {
        0%, 100% {
            opacity: 0.5;
        }
        50% {
            opacity: 1;
        }
    }
    
    .hero-content {
        max-width: 1200px;
        width: 100%;
        animation: fade-in-up 0.8s ease-out;
    }
    
    @keyframes fade-in-up {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .hero-title {
        font-family: 'Cinzel', serif;
        font-size: 4rem;
        font-weight: 700;
        margin-bottom: 1.5rem;
        color: #ff6b35;
        text-shadow: 0 0 30px rgba(255, 107, 53, 0.6),
                     0 0 60px rgba(255, 107, 53, 0.4),
                     0 0 90px rgba(255, 107, 53, 0.2);
        letter-spacing: 0.02em;
        animation: glow-pulse-title 3s ease-in-out infinite;
    }
    
    @keyframes glow-pulse-title {
        0%, 100% {
            text-shadow: 0 0 30px rgba(255, 107, 53, 0.6),
                         0 0 60px rgba(255, 107, 53, 0.4),
                         0 0 90px rgba(255, 107, 53, 0.2);
        }
        50% {
            text-shadow: 0 0 40px rgba(255, 107, 53, 0.8),
                         0 0 80px rgba(255, 107, 53, 0.6),
                         0 0 120px rgba(255, 107, 53, 0.3);
        }
    }
    
    .hero-subtitle {
        font-size: 1.5rem;
        color: #4ecdc4;
        margin-bottom: 3rem;
        line-height: 1.6;
        animation: fade-in-up 0.8s ease-out 0.2s backwards;
        text-shadow: 0 0 20px rgba(78, 205, 196, 0.3);
    }
    
    /* Component Cards Grid */
    .component-cards {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 2rem;
        margin: 3rem 0;
        animation: fade-in-up 0.8s ease-out 0.4s backwards;
    }
    
    .component-card {
        background: rgba(26, 26, 26, 0.7);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 1rem;
        padding: 2rem;
        transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
        position: relative;
        overflow: hidden;
    }
    
    /* Animated gradient border effect */
    .component-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        border-radius: 1rem;
        padding: 2px;
        background: linear-gradient(135deg, var(--card-color-1), var(--card-color-2));
        -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
        -webkit-mask-composite: xor;
        mask-composite: exclude;
        opacity: 0;
        transition: opacity 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
        background-size: 200% 200%;
        animation: gradient-shift 3s ease infinite;
    }
    
    @keyframes gradient-shift {
        0% {
            background-position: 0% 50%;
        }
        50% {
            background-position: 100% 50%;
        }
        100% {
            background-position: 0% 50%;
        }
    }
    
    .component-card:hover {
        transform: translateY(-12px) scale(1.02);
        border-color: rgba(255, 255, 255, 0.2);
    }
    
    .component-card:hover::before {
        opacity: 1;
    }
    
    /* Card-specific colors */
    .card-gateway {
        --card-color-1: #ff6b35;
        --card-color-2: #ff8c5a;
    }
    
    .card-gateway:hover {
        box-shadow: 0 0 30px rgba(255, 107, 53, 0.3),
                    0 0 60px rgba(255, 107, 53, 0.15);
    }
    
    .card-contracts {
        --card-color-1: #4ecdc4;
        --card-color-2: #6ee7de;
    }
    
    .card-contracts:hover {
        box-shadow: 0 0 30px rgba(78, 205, 196, 0.3),
                    0 0 60px rgba(78, 205, 196, 0.15);
    }
    
    .card-flags {
        --card-color-1: #c1121f;
        --card-color-2: #e63946;
    }
    
    .card-flags:hover {
        box-shadow: 0 0 30px rgba(193, 18, 31, 0.3),
                    0 0 60px rgba(193, 18, 31, 0.15);
    }
    
    .card-icon {
        font-size: 3rem;
        margin-bottom: 1rem;
        display: block;
        filter: drop-shadow(0 0 10px currentColor);
        transition: transform 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
    }
    
    .component-card:hover .card-icon {
        transform: scale(1.1) rotate(5deg);
    }
    
    .card-title {
        font-family: 'Cinzel', serif;
        font-size: 1.5rem;
        font-weight: 600;
        margin-bottom: 1rem;
        transition: color 0.3s ease;
    }
    
    .card-gateway .card-title {
        color: #ff6b35;
    }
    
    .card-contracts .card-title {
        color: #4ecdc4;
    }
    
    .card-flags .card-title {
        color: #c1121f;
    }
    
    .card-description {
        color: #f8f9fa;
        line-height: 1.6;
        font-size: 1rem;
    }
    
    /* CTA Button */
    .cta-container {
        margin-top: 3rem;
        animation: fade-in-up 0.8s ease-out 0.6s backwards;
    }
    
    .cta-button {
        display: inline-block;
        background: linear-gradient(135deg, #ff6b35, #ff8c5a);
        color: #0a0a0a;
        padding: 1.25rem 3rem;
        border-radius: 0.75rem;
        text-decoration: none;
        font-size: 1.25rem;
        font-weight: 700;
        font-family: 'Cinzel', serif;
        letter-spacing: 0.05em;
        text-transform: uppercase;
        transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
        box-shadow: 0 0 30px rgba(255, 107, 53, 0.4),
                    0 4px 20px rgba(0, 0, 0, 0.3);
        position: relative;
        overflow: hidden;
    }
    
    .cta-button::before {
        content: '';
        position: absolute;
        top: 50%;
        left: 50%;
        width: 0;
        height: 0;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.3);
        transform: translate(-50%, -50%);
        transition: width 0.6s ease, height 0.6s ease;
    }
    
    .cta-button:hover {
        transform: scale(1.08) translateY(-2px);
        box-shadow: 0 0 50px rgba(255, 107, 53, 0.6),
                    0 0 100px rgba(255, 107, 53, 0.3),
                    0 8px 30px rgba(0, 0, 0, 0.4);
        background: linear-gradient(135deg, #ff8c5a, #ff6b35);
    }
    
    .cta-button:hover::before {
        width: 300px;
        height: 300px;
    }
    
    .cta-button:active {
        transform: scale(1.02) translateY(0);
    }
    
    .cta-button span {
        position: relative;
        z-index: 1;
    }
    
    /* Parallax effect on scroll */
    @media (prefers-reduced-motion: no-preference) {
        .parallax-layer {
            transition: transform 0.1s ease-out;
        }
    }
    
    /* Responsive Design */
    @media (max-width: 639px) {
        .hero-title {
            font-size: 2.5rem;
        }
        
        .hero-subtitle {
            font-size: 1.125rem;
            margin-bottom: 2rem;
        }
        
        .component-cards {
            grid-template-columns: 1fr;
            gap: 1.5rem;
            margin: 2rem 0;
        }
        
        .component-card {
            padding: 1.5rem;
        }
        
        .card-icon {
            font-size: 2.5rem;
        }
        
        .card-title {
            font-size: 1.25rem;
        }
        
        .cta-button {
            padding: 1rem 2rem;
            font-size: 1rem;
        }
    }
    
    @media (min-width: 640px) and (max-width: 1024px) {
        .hero-title {
            font-size: 3rem;
        }
        
        .hero-subtitle {
            font-size: 1.25rem;
        }
        
        .component-cards {
            grid-template-columns: repeat(2, 1fr);
        }
    }
    
    @media (min-width: 1025px) {
        .component-cards {
            grid-template-columns: repeat(3, 1fr);
        }
    }
    
    /* Accessibility - Reduced Motion */
    @media (prefers-reduced-motion: reduce) {
        .hero-section::before,
        .hero-title,
        .hero-subtitle,
        .component-cards,
        .cta-container,
        .hero-content {
            animation: none !important;
        }
        
        .component-card:hover {
            transform: translateY(-4px);
        }
        
        .cta-button:hover {
            transform: scale(1.02);
        }
    }
</style>

<div class="hero-section">
    <div class="hero-content">
        <!-- Hero Title with Glow Effect -->
        <h1 class="hero-title">
            Strangler Studio
        </h1>
        
        <!-- Hero Subtitle -->
        <p class="hero-subtitle">
            Migrate legacy systems without downtime using the Strangler Fig pattern
        </p>
        
        <!-- Component Cards with Glassmorphism -->
        <div class="component-cards">
            <!-- Gateway Card -->
            <div class="component-card card-gateway">
                <span class="card-icon" role="img" aria-label="Gateway">🚪</span>
                <h3 class="card-title">Gateway</h3>
                <p class="card-description">
                    nginx reverse proxy routes traffic to legacy or modern services based on URL paths
                </p>
            </div>
            
            <!-- Contracts Card -->
            <div class="component-card card-contracts">
                <span class="card-icon" role="img" aria-label="Contracts">📜</span>
                <h3 class="card-title">Contracts</h3>
                <p class="card-description">
                    OpenAPI specification serves as source of truth for API design and validation
                </p>
            </div>
            
            <!-- Feature Flags Card -->
            <div class="component-card card-flags">
                <span class="card-icon" role="img" aria-label="Feature Flags">🎃</span>
                <h3 class="card-title">Feature Flags</h3>
                <p class="card-description">
                    Toggle between legacy and modern implementations without code changes
                </p>
            </div>
        </div>
        
        <!-- CTA Button -->
        <div class="cta-container">
            <a href="/requests?use_new=1" class="cta-button" aria-label="Navigate to requests page with new API">
                <span>Run the Ritual</span>
            </a>
        </div>
    </div>
</div>
