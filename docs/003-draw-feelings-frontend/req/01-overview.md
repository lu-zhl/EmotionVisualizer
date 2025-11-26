# Draw My Feelings - Frontend Design Document

## 1. Overview

### 1.1 Purpose

This document provides comprehensive design specifications for the "Draw My Feelings" frontend feature of the EmotionVisualizer iOS application. This feature allows users to express their emotions through free-text input, guided questionnaire selection, or a combination of both, resulting in a personalized minimalist visualization.

### 1.2 Scope

This milestone covers the frontend implementation only, including:
- User interface components
- User interactions and animations
- State management
- Input validation
- Visual design specifications

Backend integration for image generation will be addressed in a subsequent milestone.

### 1.3 Reference Documents

- Organic Requirement: `docs/organic/req003.md`
- Backend Infrastructure: `docs/002-backend/`

---

## 2. Design Principles

### 2.1 Visual Philosophy

The design embodies a **calm, soothing atmosphere** that encourages emotional expression without overwhelming the user.

#### Primary Color Palette

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Sky Blue | `#87CEEB` | Primary accent, interactive elements |
| Light Blue | `#ADD8E6` | Secondary elements, backgrounds |
| Pale Blue | `#B0E0E6` | Transitional elements |
| Alice Blue | `#F0F8FF` | Background, light surfaces |
| White | `#FFFFFF` | Text backgrounds, clean spaces |

#### Gradient Transitions

Use smooth gradients within the blue spectrum (`#ADD8E6` to `#F0F8FF`) to create depth and visual interest while maintaining the calming aesthetic.

### 2.2 Shape Language

- **All corners must be rounded** - No sharp 90-degree angles anywhere in the UI
- **Minimum corner radius**: 12pt for small elements (buttons, inputs)
- **Standard corner radius**: 20pt for medium elements (cards, containers)
- **Large corner radius**: 32pt+ for major elements (clouds, modals)

### 2.3 Typography

- **Font**: System default (San Francisco on iOS)
- **Weights**: Regular for body text, Medium/Semibold for emphasis
- **Colors**: Dark gray (`#333333`) for primary text, medium gray (`#666666`) for secondary text

### 2.4 Imagery Constraints

Generated visualizations must adhere to:
- **Maximum 4 colors** per visualization
- **Low saturation** (muted/pastel tones)
- **Minimalist 2D Cartoon style**
- **Symmetrical Composition**

---

## 3. Architecture Overview

### 3.1 Component Hierarchy

```
DrawMyFeelingsView (Root)
├── InitialCloudView (Cloud #0)
├── InputCloudsView
│   ├── CloudCarousel
│   │   ├── FreeTextCloudView (Cloud #1)
│   │   └── QuestionnaireCloudView (Cloud #2)
│   └── DrawButton
├── QuestionnaireFlow
│   ├── Level1View (Good/Bad/Not Sure)
│   └── Level2View (Specific Emotions)
└── VisualizationResultView
```

### 3.2 State Management

The feature uses a ViewModel pattern with the following state:

```swift
enum DrawMyFeelingsState {
    case initial                    // Showing Cloud #0
    case inputMode                  // Showing Cloud #1 and Cloud #2
    case questionnaire(level: Int)  // In questionnaire flow
    case generating                 // Creating visualization
    case result                     // Showing generated image
}
```

### 3.3 Data Model

```swift
struct EmotionInput {
    var freeText: String?           // From Cloud #1 (max 5000 chars)
    var feelingCategory: FeelingCategory?  // Good/Bad/Not Sure
    var selectedEmotions: [Emotion] // Multi-select from Level 2
}

enum FeelingCategory {
    case good
    case bad
    case notSure
}

struct Emotion: Identifiable {
    let id: UUID
    let name: String
    let icon: String      // SF Symbol or custom asset name
    let category: FeelingCategory
}
```
