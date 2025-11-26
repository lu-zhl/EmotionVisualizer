# Visual Design Specification

## 1. Color System

### 1.1 Primary Palette

```swift
extension Color {
    // Primary Blues
    static let skyBlue = Color(hex: "87CEEB")        // Primary accent
    static let lightBlue = Color(hex: "ADD8E6")      // Secondary elements
    static let paleBlue = Color(hex: "B0E0E6")       // Transitions
    static let aliceBlue = Color(hex: "F0F8FF")      // Backgrounds

    // Interaction States
    static let skyBluePressed = Color(hex: "6BB8D9") // Button pressed
    static let skyBlueDisabled = Color(hex: "D0D0D0") // Disabled state

    // Text Colors
    static let textPrimary = Color(hex: "333333")
    static let textSecondary = Color(hex: "666666")
    static let textPlaceholder = Color(hex: "999999")

    // Semantic Colors
    static let success = Color(hex: "4CAF50")        // Checkmarks, valid
    static let warning = Color(hex: "E74C3C")        // Character limit warning
}
```

### 1.2 Cloud Fill Colors

**IMPORTANT**: All clouds must be rendered as **solid filled shapes**, not outlined circles. The cloud should look like a real fluffy cloud with a continuous silhouette.

```swift
extension Color {
    // Cloud Fill Colors (100% opaque, solid fill)
    static let cloudFillWhite = Color(hex: "FFFFFF")      // White cloud fill
    static let cloudFillLight = Color(hex: "F8FCFF")      // Very light blue-white
    static let cloudFillBlue = Color(hex: "E8F4FC")       // Light blue cloud fill

    // Cloud Border (optional, outer edge only)
    static let cloudBorder = Color(hex: "ADD8E6")         // Light blue border
    static let cloudBorderLight = Color(hex: "D0E8F0")    // Very subtle border
}
```

**Cloud Rendering Rules**:
- Fill: Solid color or gradient (NO transparency)
- Border: Optional 1pt stroke on **outer edge only** (not on internal construction circles)
- Shadow: Soft drop shadow for depth
- The internal circle construction lines must NOT be visible

**Cloud #1 (Free Text Input)**:
- Fill: `#FFFFFF` (white) or `#F8FCFF` (very light blue-white)
- Border: 1pt `#ADD8E6` on outer silhouette only
- This creates the appearance of a clean white cloud

**Cloud #2 (Questionnaire)**:
- Fill: Gradient from `#E8F4FC` to `#F5FAFD`
- Border: 1pt `#B0E0E6` on outer silhouette only

### 1.3 Gradients

```swift
extension LinearGradient {
    // Cloud #0 and general cloud background (100% opaque)
    static let cloudGradient = LinearGradient(
        colors: [Color(hex: "ADD8E6"), Color(hex: "E0F4FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Cloud #2 (Questionnaire) background (100% opaque)
    static let questionnaireCloudGradient = LinearGradient(
        colors: [Color(hex: "E8F4FC"), Color(hex: "F5FAFD")],
        startPoint: .top,
        endPoint: .bottom
    )

    // Primary button gradient
    static let buttonGradient = LinearGradient(
        colors: [Color(hex: "87CEEB"), Color(hex: "6BB8D9")],
        startPoint: .top,
        endPoint: .bottom
    )

    // Screen background
    static let screenBackground = LinearGradient(
        colors: [Color(hex: "F0F8FF"), Color(hex: "FFFFFF")],
        startPoint: .top,
        endPoint: .bottom
    )
}
```

---

## 2. Typography

### 2.1 Type Scale

| Style Name | Size | Weight | Line Height | Use Case |
|------------|------|--------|-------------|----------|
| title | 24pt | Semibold | 32pt | Screen titles |
| headline | 20pt | Semibold | 28pt | Cloud #0 text |
| body | 17pt | Regular | 24pt | Body text, input |
| buttonLarge | 18pt | Semibold | 24pt | Primary buttons |
| buttonSmall | 16pt | Medium | 22pt | Secondary buttons |
| caption | 14pt | Regular | 20pt | Character counter |
| label | 15pt | Medium | 20pt | Form labels |

### 2.2 SwiftUI Implementation

```swift
extension Font {
    static let dmfTitle = Font.system(size: 24, weight: .semibold)
    static let dmfHeadline = Font.system(size: 20, weight: .semibold)
    static let dmfBody = Font.system(size: 17, weight: .regular)
    static let dmfButtonLarge = Font.system(size: 18, weight: .semibold)
    static let dmfButtonSmall = Font.system(size: 16, weight: .medium)
    static let dmfCaption = Font.system(size: 14, weight: .regular)
    static let dmfLabel = Font.system(size: 15, weight: .medium)
}
```

---

## 3. Spacing System

### 3.1 Base Unit

Base unit: **4pt**

### 3.2 Spacing Scale

| Token | Value | Use Case |
|-------|-------|----------|
| xxs | 4pt | Icon padding, tight spacing |
| xs | 8pt | Related element spacing |
| sm | 12pt | Component internal padding |
| md | 16pt | Standard spacing |
| lg | 24pt | Section spacing |
| xl | 32pt | Major section spacing |
| xxl | 48pt | Screen edge margins |

### 3.3 Screen Layout

```
┌─────────────────────────────────────────┐
│            Safe Area Top                │
├─────────────────────────────────────────┤
│  ← 24pt →                    ← 24pt →   │
│                                         │
│         [Navigation Area]               │  ← 44pt height
│         "Start over" button             │
│                                         │
│  ← 24pt padding                         │
│                                         │
│         ┌───────────────┐               │
│         │               │               │
│         │    Clouds     │               │  ← Centered vertically
│         │               │               │     in available space
│         └───────────────┘               │
│                                         │
│         [Page Indicator]                │  ← 32pt below clouds
│                                         │
│                                         │
│  ← 24pt →                    ← 24pt →   │
│     ┌───────────────────────┐           │
│     │  "Draw my feelings"   │           │  ← 56pt height
│     └───────────────────────┘           │
│                                         │  ← 24pt bottom padding
├─────────────────────────────────────────┤
│            Safe Area Bottom             │
└─────────────────────────────────────────┘
```

---

## 4. Corner Radius

### 4.1 Radius Scale

| Size | Value | Use Case |
|------|-------|----------|
| small | 12pt | Small buttons, badges, inputs |
| medium | 20pt | Cards, containers |
| large | 28pt | Pill buttons |
| xlarge | 32pt+ | Clouds, major elements |

### 4.2 Implementation

```swift
extension CGFloat {
    static let radiusSmall: CGFloat = 12
    static let radiusMedium: CGFloat = 20
    static let radiusLarge: CGFloat = 28
    static let radiusXLarge: CGFloat = 32
}
```

**Rule**: No element should have 0 corner radius. Even subtle roundings (4pt minimum) should be applied.

---

## 5. Shadows

### 5.1 Shadow Definitions

```swift
extension View {
    func shadowSoft() -> some View {
        self.shadow(
            color: Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    func shadowMedium() -> some View {
        self.shadow(
            color: Color.black.opacity(0.12),
            radius: 12,
            x: 0,
            y: 6
        )
    }

    func shadowStrong() -> some View {
        self.shadow(
            color: Color.black.opacity(0.16),
            radius: 16,
            x: 0,
            y: 8
        )
    }
}
```

### 5.2 Usage Guidelines

| Element | Shadow Type |
|---------|-------------|
| Cloud #0 | Soft |
| Cloud #1, #2 | Medium |
| Primary button (enabled) | Soft |
| Primary button (disabled) | None |
| Modal overlays | Strong |
| Emotion icon buttons | Soft |

---

## 6. Animation Specifications

### 6.1 Timing Functions

```swift
extension Animation {
    // Quick interactions (buttons, toggles)
    static let quick = Animation.easeOut(duration: 0.2)

    // Standard transitions
    static let standard = Animation.easeInOut(duration: 0.3)

    // Emphasis animations (clouds, major transitions)
    static let emphasis = Animation.easeOut(duration: 0.4)

    // Spring for natural movement
    static let springy = Animation.spring(response: 0.4, dampingFraction: 0.8)

    // Slow, gentle animations (loading states)
    static let gentle = Animation.easeInOut(duration: 0.6)
}
```

### 6.2 Stagger Animations

For lists of items (emotion icons):
- Base delay: 0.05s per item
- Maximum total stagger: 0.3s
- Animation per item: 0.25s

```swift
ForEach(emotions.indices, id: \.self) { index in
    EmotionIconView(emotion: emotions[index])
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .animation(
            .easeOut(duration: 0.25)
            .delay(Double(index) * 0.05),
            value: isVisible
        )
}
```

---

## 7. Iconography

### 7.1 SF Symbols Used

| Purpose | Symbol Name | Configuration |
|---------|-------------|---------------|
| Back navigation | `chevron.left` | Regular, 20pt |
| Start over | `arrow.counterclockwise` | Regular, 16pt |
| Checkmark badge | `checkmark` | Bold, 12pt |
| Close/Cancel | `xmark` | Medium, 16pt |

### 7.2 Custom Icons

Emotion icons are custom illustrations (see 05-emotions.md). They should:
- Be designed at 60pt × 60pt base size
- Use the muted color palette
- Have consistent stroke width (2pt)
- Include both outline and filled variants for selection states

---

## 8. Responsive Considerations

### 8.1 Device Sizes

| Device | Cloud Width | Horizontal Margin |
|--------|-------------|-------------------|
| iPhone SE | 280pt | 20pt |
| iPhone 14 | 320pt | 24pt |
| iPhone 14 Pro Max | 340pt | 28pt |

### 8.2 Dynamic Type Support

- Support Dynamic Type for all text
- Minimum touch target: 44pt × 44pt
- Cloud height adjusts to content when using larger text sizes
- Text truncation not allowed; use scrolling or wrapping

### 8.3 Landscape Mode

- Not supported for initial release
- Lock to portrait orientation

---

## 9. Dark Mode

### 9.1 Initial Release

Dark mode is **NOT** supported in the initial release. The calming blue/white palette is specifically designed for light mode.

### 9.2 Future Consideration

If dark mode is added later:
- Background: Deep blue-gray (`#1A1F2E`)
- Cloud backgrounds: Dark blue-gray with slight transparency
- Maintain the same blue accent colors
- Adjust text colors for contrast
