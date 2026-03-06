---
name: Material Design 3 - Design Tokens, Typography, Color & Spacing System
description: >
  Comprehensive Material 3 design tokens system for building modern, accessible Android/React Native UI.
  Covers color roles, typography scale, spacing, shapes, elevation, and dynamic color guidance.
  Enforces token-based theming for consistency and cross-platform maintainability.
triggers:
  - "material 3 design"
  - "design tokens"
  - "color roles"
  - "typography scale"
  - "spacing system"
  - "dynamic color"
  - "theme setup"
  - "ios look on android"
  - "polish ui"
inputs:
  - "Target platform (React Native / native Android Compose / Flutter)"
  - "UI library in use (React Native Paper / Tamagui / NativeWind / native Material3)"
  - "Brand constraints (primary color, font, accessibility requirements)"
  - "Screens or components to theme/polish"
outputs:
  - "Token mapping table (semantic roles to actual values)"
  - "Theme configuration file structure"
  - "Implementation guidance for given stack"
  - "Accessibility checklist (contrast, touch targets, text scaling)"
---

# Material Design 3 - Complete Design Tokens System

## Overview

Material Design 3 (M3) uses **design tokens**—named, reusable design decisions that form a design system's visual style. Tokens are the "design API" and replace hardcoded values.

**Core principle:** Never use raw hex colors, arbitrary font sizes, or random spacing in components. Always reference semantic tokens.

**References:**
- Material 3 Design Tokens: https://m3.material.io/foundations/design-tokens
- Color Roles: https://m3.material.io/styles/color/roles
- Typography: https://m3.material.io/styles/typography/overview
- Dynamic Color: https://m3.material.io/styles/color/dynamic/choosing-a-source
- Android Implementation: https://developer.android.com/develop/ui/compose/designsystems/material3

---

## Color System

Material 3 defines **26 standard color roles** organized into 6 groups: Primary, Secondary, Tertiary, Error, Surface, and Outline.

### Color Role Groups

#### 1. Primary (Brand & Key Actions)
Base color for main components like FABs, prominent buttons, active states.

- `primary` - Key brand/action color
- `onPrimary` - Text/icons on primary (must meet 4.5:1 contrast)
- `primaryContainer` - Tonal button surfaces, less prominent brand areas
- `onPrimaryContainer` - Text/icons on primaryContainer

#### 2. Secondary (Supporting Emphasis)
Less prominent components, filters, chips, secondary actions.

- `secondary` - Supporting differentiation color
- `onSecondary` - Text/icons on secondary
- `secondaryContainer` - Tonal surfaces (filter chips, secondary buttons)
- `onSecondaryContainer` - Text/icons on secondaryContainer

#### 3. Tertiary (Contrasting Accent)
Extra accent for data visualization, input fields, balancing primary/secondary. Designer discretion—use sparingly.

- `tertiary` - Complementary accent color
- `onTertiary` - Text/icons on tertiary
- `tertiaryContainer` - Complementary container (input fields, accents)
- `onTertiaryContainer` - Text/icons on tertiaryContainer

#### 4. Error (Destructive States)
Critical states, alerts, validation errors.

- `error` - Error/destructive actions
- `onError` - Text/icons on error
- `errorContainer` - Error banners, alert surfaces
- `onErrorContainer` - Text/icons on errorContainer

#### 5. Surface & Background (Neutral Layers)
Backgrounds, cards, sheets, navigation surfaces.

- `background` - App background
- `onBackground` - Content on background
- `surface` - Cards, sheets, dialogs, nav surfaces
- `onSurface` - Text/icons on surface (high emphasis)
- `surfaceVariant` - Subtle surface differentiation
- `onSurfaceVariant` - Low-emphasis content (dividers, inactive icons)

**Surface Containers (Elevation/Depth):**
Material 3 uses tone-based elevation (replaces old opacity overlays).

- `surfaceContainerLowest` - Lowest emphasis container
- `surfaceContainerLow` - Low emphasis
- `surfaceContainer` - Default container (most common)
- `surfaceContainerHigh` - High emphasis
- `surfaceContainerHighest` - Highest emphasis

- `surfaceTint` - Overlay color for elevation indication
- `surfaceBright` / `surfaceDim` - Light/dark surface variants

#### 6. Outline & Borders
Dividers, strokes, borders.

- `outline` - Dividers, text field borders
- `outlineVariant` - Subtle dividers, decorative borders

#### 7. Inverse (High-Contrast Overlays)
Dark top bars on light themes, snackbars, tooltips.

- `inverseSurface` - High-contrast surface (e.g., dark bar on light theme)
- `inverseOnSurface` - Text/icons on inverseSurface
- `inversePrimary` - Primary color inverted for high-contrast overlays

### Color Accessibility Rules

- All `on*` colors must meet **4.5:1 contrast** with their base (WCAG AA standard for normal text)
- Large text (18pt+) requires **3:1 minimum**
- Use `onPrimary` on `primary`, `onSurface` on `surface`, etc.—never arbitrary pairings
- M3 color system guarantees accessible pairings when roles are used correctly

### Dynamic Color (Material You)

**Android 12+ feature:** Generates tonal palettes at runtime from user wallpaper/theme.

**Implementation guidance:**
- Enable dynamic color where possible for modern Android feel
- Provide static fallback scheme for Android <12
- Choose seed color (typically brand primary) to influence palette generation
- Dynamic color automatically creates harmonious schemes with 5 tonal values per role

**When to use static:**
- Strict brand identity requirements
- Precise color control needed
- Supporting older Android versions only

**Reference:** https://m3.material.io/styles/color/dynamic/choosing-a-source

---

## Typography System

Material 3 defines **15 text styles** organized into 5 roles (Display, Headline, Title, Body, Label), each with 3 sizes (Large, Medium, Small).

### Type Scale (Roboto Default)

#### Display (Largest Text)
Reserved for short, important text or numerals. Best on large screens.

| Token | Size | Line Height | Weight | Use Case |
|-------|------|-------------|--------|----------|
| `displayLarge` | 57sp (57px) | 64sp | Regular (400) | Hero numbers, splash screens |
| `displayMedium` | 45sp (45px) | 52sp | Regular (400) | Large feature titles |
| `displaySmall` | 36sp (36px) | 44sp | Regular (400) | Section intro titles |

#### Headline (High-Emphasis Short Text)
Best for short, high-emphasis text on smaller screens. Primary passages, important regions.

| Token | Size | Line Height | Weight | Use Case |
|-------|------|-------------|--------|----------|
| `headlineLarge` | 32sp (32px) | 40sp | Regular (400) | Top-level screen titles |
| `headlineMedium` | 28sp (28px) | 36sp | Regular (400) | Prominent section headers |
| `headlineSmall` | 24sp (24px) | 32sp | Regular (400) | Card titles, dialog titles |

#### Title (Medium-Emphasis)
Smaller than headlines, for medium-emphasis shorter text. Way-finding (page/section titles).

| Token | Size | Line Height | Weight | Use Case |
|-------|------|-------------|--------|----------|
| `titleLarge` | 22sp (22px) | 28sp | Medium (500) | App bar titles, list section headers |
| `titleMedium` | 16sp (16px) | 24sp | Medium (500) | List item titles, card subtitles |
| `titleSmall` | 14sp (14px) | 20sp | Medium (500) | Sub-section titles, dense lists |

#### Body (Longer Text)
Longer passages of text. Default text style for most content.

| Token | Size | Line Height | Weight | Use Case |
|-------|------|-------------|--------|----------|
| `bodyLarge` | 16sp (16px) | 24sp | Regular (400) | Long-form article text, descriptions |
| `bodyMedium` | 14sp (14px) | 20sp | Regular (400) | **Default text style**, body paragraphs |
| `bodySmall` | 12sp (12px) | 16sp | Regular (400) | Dense body text, supporting content |

#### Label (Component-Level Text)
Smaller, utilitarian styles for UI components and captions.

| Token | Size | Line Height | Weight | Use Case |
|-------|------|-------------|--------|----------|
| `labelLarge` | 14sp (14px) | 20sp | Medium (500) | Button text, tab labels |
| `labelMedium` | 12sp (12px) | 16sp | Medium (500) | Small button text, chip labels |
| `labelSmall` | 11sp (11sp) | 16sp | Medium (500) | Captions, timestamps, metadata |

### Typography Principles

1. **Choose One Scale, Use Consistently**
   - Don't mix heading levels arbitrarily
   - Screen title → pick `headlineLarge` or `titleLarge`, stick to it
   - Body text → `bodyMedium` is default, use `bodyLarge` for readability emphasis

2. **Hierarchy Through Scale + Color**
   - Size: larger = more important
   - Color: `onSurface` (high emphasis) vs `onSurfaceVariant` (low emphasis)
   - Weight: Medium (500) for labels/titles, Regular (400) for body

3. **Never Invent Font Sizes**
   - Use only the 15 defined tokens
   - If unsure between two sizes, pick the smaller one for subtlety

4. **Letter Spacing & Line Height**
   - Display/Headline: tight letter spacing (-0.5px to 0px) for impact
   - Body: moderate spacing (0.15px - 0.5px) for readability
   - Label: wider spacing (0.1px - 1.25px) for clarity at small sizes
   - Line height values are built into tokens—don't override

5. **Font Family Customization**
   - Default is Roboto (Regular + Medium weights)
   - Can substitute brand font, but maintain same scale structure
   - Ensure brand font has Regular (400) and Medium (500) weights

**Reference:** https://m3.material.io/styles/typography/applying-type

---

## Spacing & Layout System

Material 3 uses **rhythmic spacing** based on 4dp/8dp increments for predictable, harmonious layouts.

### Spacing Scale (Recommended Tokens)

| Token Name | Value | Use Case |
|------------|-------|----------|
| `space-xxs` | 2dp/px | Hairline gaps, very tight spacing |
| `space-xs` | 4dp/px | Tight internal padding (small chips, dense lists) |
| `space-sm` | 8dp/px | Default internal padding (buttons, small cards) |
| `space-md` | 12dp/px | Moderate padding, comfortable spacing |
| `space-base` | 16dp/px | **Default spacing** (card padding, list item padding) |
| `space-lg` | 24dp/px | Section spacing, comfortable margins |
| `space-xl` | 32dp/px | Large section gaps, screen padding |
| `space-2xl` | 48dp/px | Major section separation |
| `space-3xl` | 64dp/px | Hero spacing, splash screens |

### Spacing Principles

1. **Use Multiples of 4 or 8**
   - Avoid random values like 15dp, 21dp, 37dp
   - Stick to 4/8/12/16/24/32/40/48/64

2. **Default Padding: 16dp**
   - Screen edges: 16dp horizontal padding
   - Card interiors: 16dp padding
   - List item vertical: 8-16dp

3. **Section Spacing: 24dp - 32dp**
   - Between major content blocks: 24dp+
   - Between screen sections: 32dp+

4. **Touch Targets: Minimum 48dp**
   - All interactive elements (buttons, icons, links) need ≥48dp tap area
   - Can use visual padding + invisible padding to reach 48dp

5. **Consistent Rhythm**
   - Within a component (e.g., card): use same spacing unit throughout
   - Across screens: maintain consistent spacing for similar elements

---

## Shape System

Material 3 defines **5 shape scales** for corner rounding, creating visual hierarchy and personality.

### Shape Scale

| Token | Default Radius | Use Case |
|-------|----------------|----------|
| `shapeExtraSmall` | 4dp | Small chips, text fields |
| `shapeSmall` | 8dp | Buttons, cards (default) |
| `shapeMedium` | 12dp | Larger cards, sheets |
| `shapeLarge` | 16dp | FABs, dialogs |
| `shapeExtraLarge` | 24dp | Hero cards, large surfaces |

### Shape Principles

1. **Consistency Per Component Type**
   - All buttons: `shapeSmall` (8dp)
   - All cards: `shapeSmall` or `shapeMedium` (pick one)
   - All dialogs: `shapeLarge` (16dp)

2. **Hierarchy Through Rounding**
   - More prominent = larger radius (up to a point)
   - Balance personality (rounded) with usability (too round = awkward)

3. **Brand Expression**
   - Can customize radius values for brand personality
   - Keep relationships consistent (Small < Medium < Large)

**Reference:** https://developer.android.com/develop/ui/compose/designsystems/material3

---

## Elevation System

Material 3 uses **tonal elevation** (color-based depth) instead of shadows alone.

### Elevation Principles

1. **Surface Tint**
   - Higher elevation = more `surfaceTint` (primary color) blended into surface
   - Creates subtle color shift for depth perception

2. **Shadow Elevation**
   - Use sparingly; tonal color is primary depth indicator
   - High emphasis elements can have subtle shadow (4dp - 8dp)

3. **Elevation Levels**
   - Level 0: Base surface (`surface`)
   - Level 1: `surfaceContainerLow` (subtle elevation)
   - Level 2: `surfaceContainer` (default)
   - Level 3: `surfaceContainerHigh` (elevated)
   - Level 4: `surfaceContainerHighest` (highest emphasis)

4. **Avoid Excessive Depth**
   - Material 3 favors flat, tonal layers over deep drop shadows
   - Use color differentiation over shadow depth

---

## Implementation Workflow

### When User Requests UI Changes

1. **Audit Current Implementation**
   - Identify all hardcoded colors, font sizes, spacing values
   - Map to equivalent M3 tokens

2. **Create Token Mapping Table**
   | Current | M3 Token | Rationale |
   |---------|----------|-----------|
   | `#1976D2` | `primary` | Brand blue → primary role |
   | `#FFFFFF` | `surface` | Card background → surface |
   | `rgba(0,0,0,0.87)` | `onSurface` | High-emphasis text |
   | `16px` | `bodyMedium` | Body text → 14sp token |
   | `24px` padding | `space-lg` | Section spacing |

3. **Define Theme Structure**
   - Colors: light + dark schemes with all 26 roles
   - Typography: 15 text styles with brand font
   - Spacing: 4/8/12/16/24/32/48/64 scale
   - Shapes: 5 radius values

4. **Apply Systematically**
   - Replace hardcoded values with token references
   - Ensure all text uses type scale tokens
   - Verify spacing uses defined increments
   - Check all interactive states (pressed, disabled, focused)

5. **Accessibility Validation**
   - Run contrast checker: all `on*` colors meet 4.5:1 minimum
   - Verify touch targets ≥48dp
   - Test with large text settings (1.5x - 2x scale)
   - Check color-blind simulation (don't rely on color alone)

### Stack-Specific Guidance

#### React Native + React Native Paper
- Use Paper's `MD3LightTheme` / `MD3DarkTheme` as base
- Customize via `colors`, `fonts` props in `PaperProvider`
- Paper components automatically consume theme tokens
- Example:
  ```javascript
  const theme = {
    ...MD3LightTheme,
    colors: {
      ...MD3LightTheme.colors,
      primary: '#6750A4',
      onPrimary: '#FFFFFF',
      // ... customize all 26 roles
    },
  };
  ```

#### React Native + NativeWind
- Define M3 tokens in `tailwind.config.js` under `theme.extend.colors`
- Use semantic class names: `bg-surface text-on-surface`
- Create spacing scale in `theme.extend.spacing`
- Typography via `theme.extend.fontSize` + `fontFamily`

#### Native Android Compose
- Define `ColorScheme` in `Theme.kt` with all 26 roles
- Define `Typography` with 15 text styles
- Define `Shapes` with 5 corner radii
- Use `MaterialTheme(colorScheme, typography, shapes) { }` wrapper

#### Flutter Material 3
- Use `ThemeData(useMaterial3: true)`
- Define `ColorScheme` with all roles
- Define `TextTheme` with 15 styles
- Flutter Material widgets auto-consume theme

---

## Non-Negotiable Rules

1. **No Raw Colors in Components**
   - ❌ `color: '#1976D2'`
   - ✅ `color: theme.colors.primary`

2. **No Arbitrary Font Sizes**
   - ❌ `fontSize: 18px`
   - ✅ `style: theme.typography.titleMedium`

3. **No Random Spacing**
   - ❌ `padding: 13px`
   - ✅ `padding: theme.spacing.md` (12dp)

4. **All Interactive Elements Need States**
   - Default, Pressed, Disabled, Focused states
   - Use state layer colors (`primary` with 12% opacity for pressed)

5. **Accessibility Is Mandatory**
   - Contrast: 4.5:1 minimum
   - Touch targets: 48dp minimum
   - Text scaling: support 1.5x - 2x

6. **Surface Layering Over Shadows**
   - Prefer `surfaceContainer*` tonal elevation
   - Minimize shadow usage; when needed, keep subtle (≤8dp)

7. **Consistent Component Theming**
   - All buttons use same shape scale (e.g., `shapeSmall`)
   - All cards use consistent surface role
   - All text of same purpose uses same type token

---

## Deliverable Format

When generating themed UI code:

1. **Design Rationale** (2-4 bullets)
   - Why this color role chosen
   - Why this type scale chosen
   - How it achieves "iOS polish" feel

2. **Token Mapping Table**
   - Current → M3 Token → Reason

3. **Theme Configuration Code**
   - Complete color scheme (light + dark if needed)
   - Typography scale
   - Spacing/shape definitions
   - Stack-specific format (e.g., `theme.js` for RN Paper)

4. **Component Implementation Examples**
   - Before/After code showing token usage
   - Key components (Button, Card, Text, Input)

5. **Accessibility Checklist**
   - [ ] Contrast ratios verified (tool: WebAIM, Stark)
   - [ ] Touch targets ≥48dp
   - [ ] Text scales with system font size settings
   - [ ] Color-blind safe (tested with simulator)
   - [ ] Focus indicators visible

---

## Canonical References

- **Material 3 Design Tokens:** https://m3.material.io/foundations/design-tokens
- **Color Roles:** https://m3.material.io/styles/color/roles
- **Dynamic Color:** https://m3.material.io/styles/color/dynamic/choosing-a-source
- **Typography Overview:** https://m3.material.io/styles/typography/overview
- **Applying Typography:** https://m3.material.io/styles/typography/applying-type
- **Android M3 in Compose:** https://developer.android.com/develop/ui/compose/designsystems/material3
- **Android Dynamic Color (AOSP):** https://source.android.com/docs/core/display/dynamic-color

---

## Quick Reference Tables

### Color Roles Cheat Sheet
```
Brand & Actions:
  primary / onPrimary / primaryContainer / onPrimaryContainer

Support:
  secondary / onSecondary / secondaryContainer / onSecondaryContainer

Accent:
  tertiary / onTertiary / tertiaryContainer / onTertiaryContainer

States:
  error / onError / errorContainer / onErrorContainer

Surfaces:
  background / onBackground
  surface / onSurface
  surfaceVariant / onSurfaceVariant
  surfaceContainer[Lowest|Low||High|Highest]
  surfaceTint / surfaceBright / surfaceDim

Borders:
  outline / outlineVariant

Inverse:
  inverseSurface / inverseOnSurface / inversePrimary
```

### Typography Roles Quick Pick
```
Screen Title → headlineLarge (32sp) OR titleLarge (22sp)
Section Header → headlineMedium (28sp) OR titleMedium (16sp)
Card Title → headlineSmall (24sp) OR titleLarge (22sp)
Body Text → bodyMedium (14sp) [DEFAULT]
Caption/Meta → bodySmall (12sp) OR labelSmall (11sp)
Button Text → labelLarge (14sp)
```

### Spacing Quick Pick
```
Internal padding (buttons, small cards): 8-12dp
Default padding (cards, list items): 16dp
Section spacing: 24-32dp
Screen edge padding: 16dp
Minimum touch target: 48dp
```

---

## Agent Behavior

When user says "make this look modern" or "polish this UI" or "ios-like feel":

1. Ask for current stack/library if not provided
2. Generate token mapping for existing code
3. Propose theme configuration file
4. Show before/after component examples
5. Include accessibility validation checklist
6. Explain rationale for each token choice

**Goal:** Produce token-based, accessible, polished UI that feels consistent and premium while staying true to Material 3 conventions.
