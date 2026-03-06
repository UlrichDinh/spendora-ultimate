# Neumorphism Smart Home Design System

## Design Style Overview

This design uses **Neumorphism** (Soft UI) combined with **Glassmorphism** elements in a **dark mode aesthetic**.

### Primary Characteristics
- Soft, extruded 3D effects - elements emerge from or sink into background
- Subtle shadows and highlights using dual-layer shadows
- Monochromatic/muted color palettes
- Low contrast for tactile appearance
- Rounded corners and smooth shapes
- Frosted glass effects for modals
- Orange accent color for CTAs and active states

## Rules must follow
- For every neumorphic card/button:
- Use TWO nested containers:
  - Outer: light shadow (top-left).
  - Inner: dark shadow (bottom-right).
Do NOT use a single shadow or only elevation.
If you skip this, the design will look flat.

For the [X, Y, Z] panels, you MUST:
- Use BlurView / backdrop-filter.
- Use a semi-transparent background (rgba(..., 0.7–0.85)).
- Add a 1px translucent white border.

If BlurView is not available, emulate glass with:
- 80% opacity background
- Inner highlight border

Match the visual style of the attached smart‑home UI:
- Scene buttons: soft, pill-shaped, clear dual shadows.
- Bottom bar: strong orange, subtle glow.
- Listening modal / main cards: glassmorphic panels with blur.

Do NOT simplify the design into a flat dark UI.
If something in the spec is hard (dual shadows, blur),
approximate it with extra wrappers/components instead of removing it.

---

## Color Palette

```css
:root {
  /* Backgrounds */
  --bg-primary: #0f172a;      /* Main background */
  --bg-elevated: #1e293b;     /* Cards, buttons */
  --bg-surface: #334155;      /* Lighter surfaces */
  
  /* Accent */
  --accent-primary: #FF6B35;  /* Orange CTA */
  --accent-secondary: #FF7E50; /* Lighter orange */
  --accent-glow: rgba(255, 107, 53, 0.4);
  
  /* Text */
  --text-primary: #f1f5f9;    /* Main text */
  --text-secondary: #94a3b8;  /* Muted text */
  --text-tertiary: #64748b;   /* Dimmed text */
  
  /* Shadows (Neumorphism) */
  --shadow-dark: rgba(0, 0, 0, 0.4);
  --shadow-light: rgba(255, 255, 255, 0.03);
  --shadow-inset-dark: rgba(0, 0, 0, 0.5);
  --shadow-inset-light: rgba(255, 255, 255, 0.05);
  
  /* Glassmorphism */
  --glass-bg: rgba(15, 23, 42, 0.85);
  --glass-border: rgba(255, 255, 255, 0.1);
}
```

---

## Neumorphism Base Configuration

### For neumorphism.io Generator:
```
Background Color: #1e293b
Shape Color: #1e293b (must match background)
Border Radius: 24px - 30px (buttons), 16px - 20px (cards)
Distance: 12px - 16px
Intensity: 0.15 - 0.25
Blur: 24px - 32px
```

### Key Principles for Dark Mode:
1. **Dark shadows stronger** (0.4 - 0.5 opacity) than light shadows (0.02 - 0.05)
2. **Light source from top-left** - shadows cast bottom-right
3. **Background = Element color** - True neumorphism uses same base
4. **Subtle gradients add depth** - `linear-gradient(145deg, ...)`
5. **Blur radius 2x distance** - Distance 12px → Blur 24px
6. **Pressed states invert** - Outer shadows become inset

---

## Component CSS Values

### 1. Neumorphic Buttons (Scene Modes)

**Use Case:** Morning, Relax, Guest, Night, Auto buttons

```css
.neomorphic-button {
  background: linear-gradient(145deg, #212d3d, #1b2533);
  border-radius: 28px;
  box-shadow: 
    12px 12px 24px rgba(0, 0, 0, 0.4),
    -12px -12px 24px rgba(255, 255, 255, 0.03);
  padding: 20px;
  transition: all 0.3s ease;
}

.neomorphic-button:active {
  box-shadow: 
    inset 8px 8px 16px rgba(0, 0, 0, 0.4),
    inset -8px -8px 16px rgba(255, 255, 255, 0.02);
}
```

**React Native:**
```javascript
const neomorphicButton = {
  backgroundColor: '#1e293b',
  borderRadius: 28,
  shadowColor: '#000',
  shadowOffset: { width: 12, height: 12 },
  shadowOpacity: 0.4,
  shadowRadius: 24,
  elevation: 12,
  padding: 20,
};

// iOS requires separate light shadow layer
const buttonLightShadow = {
  shadowColor: '#fff',
  shadowOffset: { width: -12, height: -12 },
  shadowOpacity: 0.03,
  shadowRadius: 24,
};
```

---

### 2. Sensor Data Pills

**Use Case:** Temperature, Humidity, Energy displays

```css
.sensor-pill {
  background: rgba(30, 41, 59, 0.6);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 20px;
  box-shadow: 
    8px 8px 16px rgba(0, 0, 0, 0.3),
    -4px -4px 12px rgba(255, 255, 255, 0.02);
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}
```

**React Native:**
```javascript
const sensorPill = {
  backgroundColor: 'rgba(30, 41, 59, 0.6)',
  borderRadius: 20,
  borderWidth: 1,
  borderColor: 'rgba(255, 255, 255, 0.08)',
  shadowColor: '#000',
  shadowOffset: { width: 8, height: 8 },
  shadowOpacity: 0.3,
  shadowRadius: 16,
  paddingVertical: 12,
  paddingHorizontal: 16,
};
```

---

### 3. Device Control Cards

**Use Case:** Light control, AC control, smart lock screens

```css
.device-card {
  background: #1e293b;
  border-radius: 24px;
  box-shadow: 
    14px 14px 28px rgba(0, 0, 0, 0.5),
    -14px -14px 28px rgba(255, 255, 255, 0.03);
  padding: 32px;
}

.device-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.device-icon-active {
  background: linear-gradient(145deg, #1b2533, #212d3d);
  box-shadow: 
    inset 6px 6px 12px rgba(0, 0, 0, 0.5),
    inset -6px -6px 12px rgba(255, 255, 255, 0.05);
}
```

---

### 4. Glassmorphic Listening Modal

**Use Case:** Voice command modal, AI listening screen

```css
.glass-modal {
  background: rgba(15, 23, 42, 0.85);
  backdrop-filter: blur(24px) saturate(180%);
  -webkit-backdrop-filter: blur(24px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 32px;
  box-shadow: 
    0 8px 32px rgba(0, 0, 0, 0.6),
    inset 0 1px 0 rgba(255, 255, 255, 0.1);
  padding: 40px;
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 1000;
}

.glass-modal-backdrop {
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(8px);
  position: fixed;
  inset: 0;
  z-index: 999;
}
```

**React Native (requires expo-blur):**
```javascript
import { BlurView } from 'expo-blur';

<BlurView 
  intensity={80} 
  tint="dark"
  style={{
    backgroundColor: 'rgba(15, 23, 42, 0.85)',
    borderRadius: 32,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    padding: 40,
  }}
>
  {/* Modal content */}
</BlurView>
```

---

### 5. Animated Waveform Circle

**Use Case:** Listening indicator, voice feedback animation

```css
.waveform-circle {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  background: radial-gradient(
    circle,
    rgba(255, 107, 53, 0.3) 0%,
    rgba(255, 107, 53, 0.1) 50%,
    transparent 100%
  );
  box-shadow: 
    0 0 60px rgba(255, 107, 53, 0.4),
    0 0 100px rgba(255, 107, 53, 0.2),
    inset 0 0 40px rgba(255, 107, 53, 0.1);
  position: relative;
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
    opacity: 1;
  }
  50% {
    transform: scale(1.05);
    opacity: 0.8;
  }
}

/* Radial lines animation */
.waveform-lines {
  position: absolute;
  inset: 20px;
  border-radius: 50%;
  background: conic-gradient(
    from 0deg,
    transparent 0deg,
    rgba(255, 107, 53, 0.1) 10deg,
    transparent 20deg,
    rgba(255, 107, 53, 0.1) 30deg,
    transparent 40deg
  );
  animation: rotate 3s linear infinite;
}

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
```

---

### 6. Orange CTA Button

**Use Case:** "Add new device", primary actions

```css
.cta-button {
  background: linear-gradient(135deg, #FF7E50 0%, #FF5722 100%);
  border: none;
  border-radius: 50px;
  box-shadow: 
    0 12px 24px rgba(255, 107, 53, 0.4),
    0 4px 8px rgba(0, 0, 0, 0.3),
    inset 0 1px 0 rgba(255, 255, 255, 0.2);
  padding: 18px 32px;
  color: #fff;
  font-weight: 600;
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.cta-button:hover {
  box-shadow: 
    0 16px 32px rgba(255, 107, 53, 0.5),
    0 6px 12px rgba(0, 0, 0, 0.3);
  transform: translateY(-2px);
}

.cta-button:active {
  transform: translateY(0);
  box-shadow: 
    0 8px 16px rgba(255, 107, 53, 0.3),
    0 2px 4px rgba(0, 0, 0, 0.3);
}
```

---

### 7. Circular Device Icons

**Use Case:** Floor plan device indicators

```css
.floor-plan-device {
  background: #1e293b;
  border-radius: 50%;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 
    6px 6px 12px rgba(0, 0, 0, 0.4),
    -4px -4px 10px rgba(255, 255, 255, 0.03);
  position: relative;
  cursor: pointer;
  transition: all 0.2s ease;
}

.floor-plan-device:active {
  box-shadow: 
    inset 4px 4px 8px rgba(0, 0, 0, 0.4),
    inset -2px -2px 6px rgba(255, 255, 255, 0.02);
}

/* Active indicator dot */
.floor-plan-device.active::after {
  content: '';
  position: absolute;
  width: 8px;
  height: 8px;
  background: #FF6B35;
  border-radius: 50%;
  bottom: 4px;
  right: 4px;
  box-shadow: 0 0 12px rgba(255, 107, 53, 0.8);
  animation: blink 2s ease-in-out infinite;
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
```

---

### 8. Toggle Switches

**Use Case:** Schedule on/off, device states

```css
.neomorphic-toggle {
  background: #0f172a;
  border-radius: 50px;
  box-shadow: 
    inset 4px 4px 8px rgba(0, 0, 0, 0.5),
    inset -4px -4px 8px rgba(255, 255, 255, 0.02);
  width: 60px;
  height: 32px;
  position: relative;
  cursor: pointer;
  transition: all 0.3s ease;
}

.neomorphic-toggle-thumb {
  background: linear-gradient(145deg, #2d3748, #1a202c);
  border-radius: 50%;
  width: 28px;
  height: 28px;
  position: absolute;
  top: 2px;
  left: 2px;
  box-shadow: 
    4px 4px 8px rgba(0, 0, 0, 0.4),
    -2px -2px 6px rgba(255, 255, 255, 0.03);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.neomorphic-toggle.active .neomorphic-toggle-thumb {
  left: calc(100% - 30px);
  background: linear-gradient(135deg, #FF7E50, #FF5722);
  box-shadow: 
    0 0 16px rgba(255, 107, 53, 0.6),
    4px 4px 8px rgba(0, 0, 0, 0.3);
}
```

**React Native:**
```javascript
const toggleContainer = {
  backgroundColor: '#0f172a',
  borderRadius: 50,
  width: 60,
  height: 32,
  shadowColor: '#000',
  shadowOffset: { width: 0, height: 0 },
  shadowOpacity: 0.5,
  shadowRadius: 8,
  elevation: 8,
};

// Use Animated.View for thumb
const toggleThumb = {
  backgroundColor: '#2d3748',
  borderRadius: 14,
  width: 28,
  height: 28,
  shadowColor: '#000',
  shadowOffset: { width: 4, height: 4 },
  shadowOpacity: 0.4,
  shadowRadius: 8,
};
```

---

### 9. Schedule Cards

**Use Case:** Time-based automation cards

```css
.schedule-card {
  background: rgba(30, 41, 59, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 16px;
  box-shadow: 
    8px 8px 16px rgba(0, 0, 0, 0.3),
    -4px -4px 12px rgba(255, 255, 255, 0.02);
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.schedule-day {
  font-weight: 600;
  color: #f1f5f9;
  font-size: 16px;
}

.schedule-time {
  color: #94a3b8;
  font-size: 14px;
  display: flex;
  gap: 16px;
}
```

---

### 10. Circular Slider (Dimmer Control)

**Use Case:** Light brightness, temperature control

```css
.circular-slider {
  width: 280px;
  height: 280px;
  border-radius: 50%;
  background: #1e293b;
  box-shadow: 
    16px 16px 32px rgba(0, 0, 0, 0.5),
    -16px -16px 32px rgba(255, 255, 255, 0.03);
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.circular-slider-track {
  position: absolute;
  inset: -8px;
  border-radius: 50%;
  background: conic-gradient(
    from 0deg,
    #FF6B35 0deg,
    #FF6B35 calc(var(--percentage) * 3.6deg),
    transparent calc(var(--percentage) * 3.6deg),
    transparent 360deg
  );
  padding: 8px;
}

.circular-slider-inner {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: #1e293b;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.circular-slider-value {
  font-size: 48px;
  font-weight: 700;
  color: #f1f5f9;
}
```

---

## Typography

```css
.text-primary {
  color: #f1f5f9;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
}

.text-secondary {
  color: #94a3b8;
}

.text-tertiary {
  color: #64748b;
}

/* Headings */
.heading-xl {
  font-size: 32px;
  font-weight: 700;
  line-height: 1.2;
}

.heading-lg {
  font-size: 24px;
  font-weight: 600;
  line-height: 1.3;
}

.heading-md {
  font-size: 18px;
  font-weight: 600;
  line-height: 1.4;
}

/* Body */
.body-lg {
  font-size: 16px;
  line-height: 1.5;
}

.body-md {
  font-size: 14px;
  line-height: 1.5;
}

.body-sm {
  font-size: 12px;
  line-height: 1.4;
}
```

---

## Spacing System

```css
:root {
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 12px;
  --space-lg: 16px;
  --space-xl: 24px;
  --space-2xl: 32px;
  --space-3xl: 40px;
  --space-4xl: 48px;
}
```

---

## Border Radius System

```css
:root {
  --radius-sm: 12px;   /* Small cards, inputs */
  --radius-md: 16px;   /* Medium cards */
  --radius-lg: 24px;   /* Large cards, buttons */
  --radius-xl: 32px;   /* Modals */
  --radius-full: 9999px; /* Pills, circular */
}
```

---

## Animation Guidelines

### Transition Timing
```css
:root {
  --transition-fast: 150ms;
  --transition-base: 250ms;
  --transition-slow: 350ms;
  --ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

### Common Animations
```css
/* Fade in */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Scale press */
@keyframes scalePress {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(0.97);
  }
}

/* Glow pulse */
@keyframes glowPulse {
  0%, 100% {
    box-shadow: 0 0 20px rgba(255, 107, 53, 0.4);
  }
  50% {
    box-shadow: 0 0 40px rgba(255, 107, 53, 0.6);
  }
}
```

---

## React Native Implementation Notes

### Required Libraries
```bash
npm install react-native-reanimated
npm install react-native-svg
npm install expo-blur
npm install react-native-linear-gradient
npx expo install expo-haptics
```

### Shadow Utility Function
```javascript
/**
 * Generates neumorphic shadow styles for React Native
 * @param {Object} options - Shadow configuration
 * @returns {Object} Platform-specific shadow styles
 */
export const createNeumorphicShadow = ({
  distance = 12,
  intensity = 0.4,
  blur = 24,
  lightIntensity = 0.03,
  pressed = false,
}) => {
  if (pressed) {
    // Inset shadows for pressed state
    return {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 0 },
      shadowOpacity: intensity,
      shadowRadius: blur / 2,
      elevation: -distance / 2,
    };
  }

  // Normal elevated state
  return {
    shadowColor: '#000',
    shadowOffset: { width: distance, height: distance },
    shadowOpacity: intensity,
    shadowRadius: blur,
    elevation: distance,
  };
};

// Usage example:
const buttonStyle = {
  ...createNeumorphicShadow({ distance: 12, blur: 24 }),
  backgroundColor: '#1e293b',
  borderRadius: 28,
  padding: 20,
};
```

### Glassmorphism Component
```javascript
import { BlurView } from 'expo-blur';
import { StyleSheet } from 'react-native';

export const GlassCard = ({ children, intensity = 80 }) => {
  return (
    <BlurView 
      intensity={intensity}
      tint="dark"
      style={styles.glassContainer}
    >
      {children}
    </BlurView>
  );
};

const styles = StyleSheet.create({
  glassContainer: {
    backgroundColor: 'rgba(15, 23, 42, 0.85)',
    borderRadius: 32,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    padding: 40,
    overflow: 'hidden',
  },
});
```

### Animated Toggle Component
```javascript
import React, { useRef } from 'react';
import { Pressable, Animated } from 'react-native';
import * as Haptics from 'expo-haptics';

export const NeumorphicToggle = ({ value, onValueChange }) => {
  const animation = useRef(new Animated.Value(value ? 1 : 0)).current;

  const handlePress = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    
    const newValue = !value;
    onValueChange(newValue);

    Animated.spring(animation, {
      toValue: newValue ? 1 : 0,
      useNativeDriver: true,
      tension: 50,
      friction: 7,
    }).start();
  };

  const thumbTranslate = animation.interpolate({
    inputRange: [0, 1],
    outputRange: [2, 30], // Adjust based on toggle width
  });

  return (
    <Pressable onPress={handlePress} style={styles.toggleContainer}>
      <Animated.View
        style={[
          styles.toggleThumb,
          {
            transform: [{ translateX: thumbTranslate }],
            backgroundColor: animation.interpolate({
              inputRange: [0, 1],
              outputRange: ['#2d3748', '#FF6B35'],
            }),
          },
        ]}
      />
    </Pressable>
  );
};

const styles = StyleSheet.create({
  toggleContainer: {
    width: 60,
    height: 32,
    borderRadius: 50,
    backgroundColor: '#0f172a',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.5,
    shadowRadius: 8,
    elevation: 8,
  },
  toggleThumb: {
    width: 28,
    height: 28,
    borderRadius: 14,
    shadowColor: '#000',
    shadowOffset: { width: 4, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 8,
    elevation: 4,
  },
});
```

---

## Accessibility Considerations

### Contrast Issues
Neumorphism has inherent low-contrast problems. Mitigate with:

```css
/* Ensure sufficient text contrast */
.text-primary {
  color: #f1f5f9; /* WCAG AAA on #0f172a background */
}

.text-secondary {
  color: #94a3b8; /* WCAG AA on #0f172a background */
}

/* Add focus states for keyboard navigation */
.interactive-element:focus-visible {
  outline: 2px solid #FF6B35;
  outline-offset: 4px;
}

/* Increase contrast on hover */
.neomorphic-button:hover {
  background: linear-gradient(145deg, #242f41, #1e2835);
}
```

### Alternative High-Contrast Mode
```css
@media (prefers-contrast: high) {
  .neomorphic-button {
    border: 2px solid #94a3b8;
    box-shadow: none;
  }
  
  .sensor-pill {
    border: 1px solid #94a3b8;
  }
}
```

---

## Performance Optimization

### CSS Optimization
```css
/* Use will-change for animated elements */
.waveform-circle {
  will-change: transform, opacity;
}

/* Use transform instead of positional properties */
.neomorphic-button:active {
  transform: scale(0.98);
  /* Better than: top: 2px; */
}

/* Reduce shadow complexity on low-end devices */
@media (prefers-reduced-motion: reduce) {
  .neomorphic-button {
    box-shadow: 
      8px 8px 16px rgba(0, 0, 0, 0.3);
    /* Single shadow instead of dual */
  }
}
```

### React Native Optimization
```javascript
// Use shouldComponentUpdate or React.memo
export const NeumorphicButton = React.memo(({ onPress, children }) => {
  return (
    <Pressable onPress={onPress} style={styles.button}>
      {children}
    </Pressable>
  );
});

// Cache shadow styles
const shadowCache = new Map();

export const getCachedShadow = (key, options) => {
  if (!shadowCache.has(key)) {
    shadowCache.set(key, createNeumorphicShadow(options));
  }
  return shadowCache.get(key);
};
```

---

## Testing Checklist

- [ ] Shadows render correctly on both iOS and Android
- [ ] Glassmorphism blur works (requires native modules)
- [ ] Touch states provide haptic feedback
- [ ] Animations run at 60fps
- [ ] Text contrast meets WCAG AA minimum
- [ ] Focus states visible for keyboard navigation
- [ ] Works in both light and dark system modes
- [ ] Reduced motion respected
- [ ] High contrast mode supported

---

## Prompt Template for AI Coding

```
Create a [COMPONENT_NAME] component for React Native with neumorphic design:

Design Requirements:
- Background: #1e293b
- Border radius: [VALUE]px
- Neumorphic shadows: dual shadows (dark bottom-right, light top-left)
- Dark shadow: 12px offset, 0.4 opacity, 24px blur
- Light shadow: -12px offset, 0.03 opacity, 24px blur
- Pressed state: invert to inset shadows
- Orange accent (#FF6B35) for active states

Functional Requirements:
- [LIST FUNCTIONALITY]
- Haptic feedback on press
- Smooth animations using Reanimated
- Accessible with proper focus states

Use the design system tokens from the attached neumorphism-design-rules.md file.
```

---

## Additional Resources

- Neumorphism Generator: https://neumorphism.io
- React Native Shadow Generator: https://ethercreative.github.io/react-native-shadow-generator/
- Expo Blur Documentation: https://docs.expo.dev/versions/latest/sdk/blur-view/
- Reanimated Docs: https://docs.swmansion.com/react-native-reanimated/

---

## Version History

- v1.0 - Initial design system based on smart home app reference
- Created: March 3, 2026
- Last Updated: March 3, 2026
