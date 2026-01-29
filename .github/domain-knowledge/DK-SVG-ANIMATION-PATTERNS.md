# Domain Knowledge: SVG Animation Patterns

**Domain**: Visual Design / Web Graphics
**Expertise Level**: Practitioner
**Last Updated**: January 28, 2026
**Source**: Hands-on banner creation for markdown-to-pdf project

## Overview

SMIL (Synchronized Multimedia Integration Language) animations provide declarative, XML-native animations for SVG elements without requiring JavaScript or CSS. This knowledge captures practical patterns for creating polished, artifact-free animations.

## Core Patterns

### 1. Delayed Fade-In (Artifact-Free)

**Problem**: Elements with delayed animations often flash visible before animation starts.

**Solution**: Set initial `opacity="0"` on the element, not just in the animation.

```xml
<!-- ✅ Correct: Element hidden until animation -->
<g opacity="0">
  <rect .../>
  <animate attributeName="opacity" from="0" to="1" begin="0.5s" dur="0.4s" fill="freeze"/>
</g>

<!-- ❌ Wrong: Element briefly visible before animation starts -->
<g>
  <rect .../>
  <animate attributeName="opacity" from="0" to="1" begin="0.5s" dur="0.4s" fill="freeze"/>
</g>
```

### 2. Gradient Strokes on Lines

**Problem**: `stroke="url(#gradient)"` may not render in some viewers (VS Code preview, certain browsers).

**Solution**: Use solid colors for critical elements, or provide fallback.

```xml
<!-- Safer: Solid color -->
<line x1="100" y1="50" x2="200" y2="50" stroke="#e94560" stroke-width="3"/>

<!-- Riskier: Gradient (may not render everywhere) -->
<line x1="100" y1="50" x2="200" y2="50" stroke="url(#accent)" stroke-width="3"/>
```

### 3. One-Time vs Looping Animations

**Pattern**: Background elements loop, foreground plays once.

```xml
<!-- Background: Continuous ambient animation -->
<circle r="50" fill="url(#glow)">
  <animate attributeName="opacity" values="0.5;0.8;0.5" dur="5s" repeatCount="indefinite"/>
</circle>

<!-- Foreground: Play once and freeze -->
<g opacity="0">
  <animate attributeName="opacity" from="0" to="1" dur="0.5s" fill="freeze"/>
</g>
```

### 4. Z-Order Control

SVG renders elements in document order (later = on top). Use this for layering:

```xml
<!-- Background layer (rendered first, appears behind) -->
<rect width="800" height="200" fill="url(#bg)"/>

<!-- Arrow line (rendered before gear, appears behind it) -->
<line x1="100" y1="100" x2="300" y2="100" stroke="#e94560"/>

<!-- Gear (rendered after line, appears on top) -->
<circle cx="200" cy="100" r="20" fill="#1a1a2e"/>
```

### 5. Ambient Background Effects

**Pattern**: Soft glowing orbs with radial gradients and blur filters.

```xml
<defs>
  <radialGradient id="glow1" cx="50%" cy="50%" r="50%">
    <stop offset="0%" stop-color="#4ecdc4" stop-opacity="0.2"/>
    <stop offset="100%" stop-color="#4ecdc4" stop-opacity="0"/>
  </radialGradient>
  <filter id="blur">
    <feGaussianBlur in="SourceGraphic" stdDeviation="10"/>
  </filter>
</defs>

<circle cx="60" cy="150" r="70" fill="url(#glow1)" filter="url(#blur)">
  <animate attributeName="opacity" values="0.7;1;0.7" dur="5s" repeatCount="indefinite"/>
  <animate attributeName="r" values="70;85;70" dur="7s" repeatCount="indefinite"/>
</circle>
```

### 6. Floating Particles

Small dots that drift and pulse create depth:

```xml
<circle cx="120" cy="35" r="2" fill="#4ecdc4" opacity="0.4">
  <animate attributeName="cy" values="35;25;35" dur="4s" repeatCount="indefinite"/>
  <animate attributeName="opacity" values="0.4;0.7;0.4" dur="4s" repeatCount="indefinite"/>
</circle>
```

## Animation Timing Guidelines

| Element Type | Duration | Timing |
|-------------|----------|--------|
| Fade-in (documents) | 0.5-0.6s | Immediate |
| Fade-in (arrows) | 0.3-0.4s | Staggered (0.3s intervals) |
| Rotating gear | 4-6s | Continuous |
| Background breathing | 4-8s | Continuous, varied |
| Badge cascade | 0.3-0.4s each | Staggered (0.1s intervals) |

## Common Pitfalls

1. **stroke-dasharray artifacts**: Drawing animations can leave visual residue. Prefer opacity animations.
2. **Missing initial state**: Always set `opacity="0"` on elements with delayed `begin`.
3. **Gradient compatibility**: Test in target environments; VS Code preview may differ from browsers.
4. **Overly busy animations**: More is not better. Limit continuous animations to background.
5. **Timing conflicts**: Ensure delayed elements don't have conflicting durations.

## Synapses

### Connection Mapping

- [DK-ADVANCED-DIAGRAMMING.md] (High, Extends, Bidirectional) - "SVG animation complements diagramming skills"
- [bootstrap-learning.instructions.md] (Medium, Demonstrates, Forward) - "Iterative learning through hands-on creation"

### Activation Patterns

- SVG animation request → Apply artifact-free patterns
- Banner/hero image creation → Use ambient background + one-shot foreground
- Visual polish needed → Check z-order, timing, initial states

---

*Domain knowledge captured from markdown-to-pdf banner creation session*
