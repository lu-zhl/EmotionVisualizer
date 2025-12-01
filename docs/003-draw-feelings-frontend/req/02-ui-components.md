# UI Components Specification (Version 2.0)

## 1. Cloud Components

### 1.1 Cloud Shape Definition

All cloud components share a common organic, fluffy cloud shape. The cloud must appear as a **solid filled shape**, NOT as outlined circles.

**IMPORTANT**: The cloud should look like a real fluffy cloud with:
- **Solid fill color** (no transparency, 100% opaque)
- **Smooth, continuous silhouette** created by overlapping circles that are merged/unified
- **No visible internal circle borders** - only the outer edge of the cloud shape should be visible
- Soft drop shadow for depth (`color: #000000, opacity: 0.1, radius: 10, y: 4`)

**Correct Implementation**:
```swift
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        // Create cloud by combining multiple overlapping ellipses
        // The result should be a SINGLE unified path with solid fill
        // Do NOT stroke individual circles - only fill the combined shape
    }
}

// Usage - Cloud should be filled, not stroked
CloudShape()
    .fill(Color.cloudFill)  // Solid fill color
    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
```

---

### 1.2 Cloud #0 - Initial Cloud

**Purpose**: Entry point that invites user interaction

**Visual Specifications**:
- Size: 280pt width × 160pt height (approximate, maintains aspect ratio)
- Background: Solid fill with gradient from `#ADD8E6` to `#E0F4FF`
- Border: None
- Shadow: Soft drop shadow
- Opacity: 100% (fully opaque)

**Content**:
- Text: "How are you feeling?"
- Font: System, 20pt, Semibold
- Color: `#333333`
- Alignment: Center (horizontally and vertically)

**Interaction**:
- Tappable entire cloud area
- On tap: Subtle scale animation (0.95 → 1.0) then transition to questionnaire

**Accessibility**:
- Label: "How are you feeling? Tap to express your emotions"
- Trait: `.button`

---

### 1.3 Cloud #1 - Free Text Input Cloud

**Purpose**: Allow users to share the story behind their feelings (appears after feeling visualization)

**Visual Specifications**:
- Size: 320pt width × 200pt height
- Background: Solid white `#FFFFFF` or `#F8FCFF`
- Border: 1pt stroke, `#ADD8E6` on outer silhouette only
- Shadow: Medium drop shadow
- Opacity: 100% (fully opaque)

**Content**:
- Placeholder text: "Tell me more about your feelings..."
- Font: System, 16pt, Regular
- Text color: `#333333`
- Placeholder color: `#999999`

**Text Input Area**:
- Multi-line `TextEditor`
- Character limit: 5000 characters
- Minimum required: 50 characters
- Character counter displayed at bottom right: "0 / 5000"
- Counter color: `#999999`, changes to `#E74C3C` when > 4500

**Interaction**:
- Tap to focus and show keyboard
- Scrollable when content exceeds visible area

**Accessibility**:
- Label: "Tell me more about your feelings. Text input area."
- Hint: "Minimum 50 characters, maximum 5000 characters"

---

## 2. Questionnaire Components

### 2.1 Level 1 - Feel Good?

**Layout**:
```
┌─────────────────────────────────────────┐
│            "Feel good?"                 │
│                                         │
│     ┌─────────┐    ┌─────────┐         │
│     │  Good   │    │   Bad   │         │
│     └─────────┘    └─────────┘         │
│                                         │
│          ┌──────────────┐              │
│          │   Not Sure   │              │
│          └──────────────┘              │
│                                         │
│  [Back]                  [Start over]   │
└─────────────────────────────────────────┘
```

**Title**:
- Text: "Feel good?"
- Font: System, 24pt, Semibold
- Color: `#333333`

**Option Buttons**:
- Size: 120pt × 100pt
- Corner radius: 20pt
- Background (default): `#F5FAFD`
- Background (selected): `#E0F4FF`
- Border (default): 1pt `#D0E4EF`
- Border (selected): 2pt `#87CEEB`

---

### 2.2 Level 2 - Emotion Selection

**Layout**:
```
┌─────────────────────────────────────────┐
│            "I feel like:"               │
│                                         │
│  ┌─────┐  ┌─────┐  ┌─────┐             │
│  │Icon │  │Icon │  │Icon │             │
│  │Label│  │Label│  │Label│             │
│  └─────┘  └─────┘  └─────┘             │
│  ┌─────┐  ┌─────┐  ┌─────┐             │
│  │Icon │  │Icon │  │Icon │             │
│  │Label│  │Label│  │Label│             │
│  └─────┘  └─────┘  └─────┘             │
│                                         │
│  [Back]      [Done]      [Start over]   │
└─────────────────────────────────────────┘
```

**Title**:
- Text: "I feel like:"
- Font: System, 24pt, Semibold
- Color: `#333333`

**Emotion Grid**:
- 3 columns
- Icon size: 60pt × 60pt
- Grid spacing: 16pt horizontal, 20pt vertical

**Done Button**:
- Disabled until at least one emotion selected
- Same style as primary action buttons

---

## 3. Result Screen Components

### 3.1 Feeling Visualization Result

**Layout**:
```
┌─────────────────────────────────────────┐
│                                         │
│    "I feel cozy, content and fuming."   │
│                                         │
│         ┌─────────────────┐             │
│         │                 │             │
│         │   Generated     │             │
│         │   Image         │             │
│         │                 │             │
│         └─────────────────┘             │
│                                         │
│  [Let it out!]     [Know more about...]  │
│                                         │
│             [Start over]                │
└─────────────────────────────────────────┘
```

**Summary Text**:
- Text: "I feel [emotions]."
- Font: System, 20pt, Medium
- Color: `#333333`
- Alignment: Center

**Visualization Image**:
- Size: Screen width - 48pt margins, square aspect ratio
- Corner radius: 20pt
- Shadow: Medium drop shadow

---

### 3.2 Story Visualization Result

**Layout**:
```
┌─────────────────────────────────────────┐
│                                         │
│         ┌─────────────────┐             │
│         │                 │             │
│         │   Story         │             │
│         │   Visualization │             │
│         │   (minimalist   │             │
│         │   2D cartoon)   │             │
│         │                 │             │
│         └─────────────────┘             │
│                                         │
│      ┌─────────────────────────┐        │
│      │  Central Stressor       │        │
│      │  • Factor 1             │        │
│      │  • Factor 2             │        │
│      │  • Factor 3             │        │
│      └─────────────────────────┘        │
│                                         │
│             [Let it out!]               │
│                                         │
│             [Start over]                │
└─────────────────────────────────────────┘
```

**Story Analysis Display**:
- Shows the `story_analysis` data from API response
- Central stressor as header
- 3-5 psychological factors as bullet list
- Displayed below or alongside the visualization image
- Font: System, 16pt for stressor, 14pt for factors
- Color: `#333333`

**Image Style**:
- Minimalist 2D cartoon with symmetrical composition
- Central icon for main stressor, surrounded by factor icons
- No text labels in the image (labels displayed separately by iOS app)

---

### 3.3 Future Expansion: "Understand More" Feature

> **Note**: This feature is planned for a future version.

**Purpose**: Allow users to explore their psychological factors in more depth.

**Planned Features**:
- Tap on a factor to see detailed explanation
- Show why AI identified this factor from the user's story
- Pattern recognition across multiple stories ("You often mention Fear of Judgment")
- Educational content about each psychological factor
- Root cause exploration prompts

**Placeholder UI** (future):
```
┌─────────────────────────────────────────┐
│      [Story Visualization + Factors]    │
│                                         │
│  "Would you like to understand more?"   │
│                                         │
│         [Understand more]               │
│                                         │
│             [Let it out!]               │
│             [Start over]                │
└─────────────────────────────────────────┘
```

---

## 4. Action Buttons

### 4.1 "Let it out!" Button

**Purpose**: Trigger firework animation for emotional release (works for both positive and negative feelings)

**Visual Specifications**:
- Size: 140pt × 48pt
- Corner radius: 24pt (pill shape)
- Background: Linear gradient `#FFD700` to `#FFA500` (golden/warm)
- Text: "Let it out!"
- Text color: White
- Font: 16pt, Semibold
- Shadow: Soft drop shadow

**States**:
- Default: Full opacity
- Pressed: Scale to 0.95, slightly darker

**Location**:
- Feeling Result screen: Left side, next to "Know more about my feeling"
- Story Result screen: Centered

---

### 4.2 "Know more about my feeling" Button

**Purpose**: Navigate to free text input to explore feelings deeper

**Visual Specifications**:
- Size: 200pt × 48pt
- Corner radius: 24pt (pill shape)
- Background: Linear gradient `#87CEEB` to `#6BB8D9`
- Text: "Know more about my feeling"
- Text color: White
- Font: 16pt, Semibold
- Shadow: Soft drop shadow

**States**:
- Default: Full opacity
- Pressed: Scale to 0.97, darker background

---

### 4.3 "Draw my story" Button

**Purpose**: Submit free text and generate story visualization

**Visual Specifications**:
- Size: Screen width - 48pt margins × 56pt height
- Corner radius: 28pt (pill shape)
- Background (enabled): Linear gradient `#87CEEB` to `#6BB8D9`
- Background (disabled): `#D0D0D0`
- Text: "Draw my story"
- Text color (enabled): White
- Text color (disabled): `#999999`
- Font: 18pt, Semibold

**States**:
- **Disabled**: Less than 50 characters entered
- **Enabled**: 50+ characters entered
- Transition between states: 0.3s ease animation

---

### 4.4 "Done" Button (Questionnaire)

**Purpose**: Complete emotion selection and generate feeling visualization

**Visual Specifications**:
- Size: 120pt × 48pt
- Corner radius: 24pt
- Background (enabled): Linear gradient `#87CEEB` to `#6BB8D9`
- Background (disabled): `#D0D0D0`
- Text: "Done"
- Text color (enabled): White
- Text color (disabled): `#999999`
- Font: 16pt, Semibold

**States**:
- **Disabled**: No emotions selected
- **Enabled**: At least one emotion selected

---

### 4.5 "Start over" Button

**Purpose**: Reset all state and return to Cloud #0

**Visual Specifications**:
- Style: Text button with icon
- Text: "Start over"
- Color: `#666666`
- Font: 16pt, Regular
- Icon: SF Symbol `arrow.counterclockwise` (left of text)

**Location**: Bottom of screen on all screens after Cloud #0

---

### 4.6 "Back" Button

**Purpose**: Navigate to previous step

**Visual Specifications**:
- Icon: SF Symbol `chevron.left`
- Size: 44pt × 44pt tap target
- Icon size: 20pt
- Color: `#333333`

**Location**: Top-left of questionnaire screens

---

## 5. Firework Animation Component

### 5.1 Visual Specifications

**Animation Type**: Particle-based firework burst

**Trigger**: Tap "Let it out!" button

**Behavior**:
- Launch point: Bottom center of screen
- Burst point: Center of screen (or slightly above)
- Duration: 2 seconds per burst
- Multiple bursts can overlap (rapid tapping allowed)

**Colors**:
- Extracted from the current visualization image
- Use 3-4 dominant colors from the image
- Fallback colors: `#FFD700`, `#FF6B6B`, `#4ECDC4`, `#A78BFA`

**Particle Properties**:
- Count: 50-100 particles per burst
- Shape: Small circles or stars
- Size: 4-8pt
- Fade out over duration
- Physics: Gravity-affected fall after burst

**Sound**: None (silent animation)

**Interaction**:
- Does not block other UI interactions
- Plays as overlay on current screen
- Does not navigate away from current screen

### 5.2 Implementation Hint

```swift
struct FireworkView: View {
    let colors: [Color]
    @State private var particles: [Particle] = []

    func triggerFirework() {
        // Generate particles with colors from visualization
        // Animate burst and fall
    }
}
```

---

## 6. Loading States

### 6.1 Feeling Generation Loading

**Display**: After tapping "Done" on questionnaire

**Visual**:
- Full screen with background `#F0F8FF`
- Centered cloud icon with floating animation
- Text: "Drawing your feelings..."
- Animated dots after text
- Cancel button at bottom

### 6.2 Story Generation Loading

**Display**: After tapping "Draw my story"

**Visual**:
- Full screen with background `#F0F8FF`
- Centered cloud icon with floating animation
- Text: "Understanding your story..."
- Animated dots after text
- Cancel button at bottom

---

## 7. Character Counter Component

**Location**: Bottom-right inside Cloud #1 text area

**Display Format**: "current / 5000"

**Color States**:
- 0-49 characters: `#999999` (also shows "min 50")
- 50-4500 characters: `#999999`
- 4501-5000 characters: `#E74C3C` (warning red)

**Additional Indicator**:
- When < 50 chars: Show helper text "min 50 characters" below counter
- Fades out when minimum is reached
