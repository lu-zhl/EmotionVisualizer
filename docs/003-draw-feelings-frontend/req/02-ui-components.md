# UI Components Specification

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

**Incorrect (Current Issue)**:
- Drawing individual circles with borders visible
- Transparent or semi-transparent fill
- Visible construction lines inside the cloud

**Correct**:
- Single unified cloud silhouette
- Solid opaque fill (white or light blue gradient)
- Only the outer fluffy edge is visible

### 1.2 Cloud #0 - Initial Cloud

**Purpose**: Entry point that invites user interaction

**Visual Specifications**:
- Size: 280pt width × 160pt height (approximate, maintains aspect ratio)
- Background: Gradient from `#ADD8E6` to `#E0F4FF`
- Border: None
- Shadow: Soft drop shadow

**Content**:
- Text: "How are you feeling?"
- Font: System, 20pt, Semibold
- Color: `#333333`
- Alignment: Center (horizontally and vertically)

**Interaction**:
- Tappable entire cloud area
- On tap: Subtle scale animation (0.95 → 1.0) then transition to input mode

**Accessibility**:
- Label: "How are you feeling? Tap to express your emotions"
- Trait: `.button`

---

### 1.3 Cloud #1 - Free Text Input Cloud

**Purpose**: Allow users to freely type their feelings

**Visual Specifications**:
- Size: 320pt width × 200pt height
- Background: White with subtle blue tint (`#FAFCFF`)
- Border: 1pt stroke, `#ADD8E6`
- Shadow: Medium drop shadow

**Content**:
- Placeholder text: "Type how you're feeling..."
- Font: System, 16pt, Regular
- Text color: `#333333`
- Placeholder color: `#999999`

**Text Input Area**:
- Multi-line `TextEditor`
- Character limit: 5000 characters
- Character counter displayed at bottom right: "0 / 5000"
- Counter color: `#999999`, changes to `#E74C3C` when > 4500

**Interaction**:
- Tap to focus and show keyboard
- Scrollable when content exceeds visible area
- State persists when swiping between clouds

**Accessibility**:
- Label: "Free text input. Type how you're feeling."
- Hint: "Maximum 5000 characters"

---

### 1.4 Cloud #2 - Questionnaire Cloud

**Purpose**: Provide guided emotion selection entry point and display selection summary

**Visual Specifications**:
- Size: 320pt width × 200pt height (same as Cloud #1)
- Background: Solid fill `#FFFFFF` (white) with gradient from `#E8F4FC` to `#F5FAFD`
- Border: 1pt stroke, `#B0E0E6` on outer silhouette only
- Shadow: Medium drop shadow

#### State 1: Before Selection (Default)

**Content**:
- Button: "Tap your moods"
- Button style: Rounded rectangle (corner radius 16pt)
- Button background: `#87CEEB`
- Button text: White, 18pt, Semibold
- Button size: 200pt × 50pt

**Interaction**:
- Tap button to start questionnaire flow
- Button has hover/press state (darker blue `#6BB8D9`)

**Accessibility**:
- Button label: "Tap your moods. Start guided questionnaire."

#### State 2: After Selection (With Summary)

**Content**:
- Summary text displayed on the cloud: "I feel cozy, content and fuming."
- Text style: System, 18pt, Medium
- Text color: `#333333`
- Text alignment: Center (horizontally and vertically within cloud)
- Multi-line wrapping if text is long

**Summary Text Formatting**:
- Single emotion: "I feel content."
- Two emotions: "I feel content and chill."
- Three+ emotions: "I feel cozy, content and fuming."
- Emotion names displayed in **lowercase**

**Interaction**:
- Tap anywhere on cloud (or summary text) to re-enter questionnaire
- This allows users to modify their selections
- Checkmark badge remains visible (top-right)

**Accessibility**:
- Label: "Your mood selection: [summary]. Tap to modify."

---

## 2. Cloud Carousel

### 2.1 Layout

**Structure**:
- Container holds both Cloud #1 and Cloud #2
- Clouds overlap with Cloud #1 in front initially
- Visible portion of back cloud: ~30pt peek on the right edge

**Visual Indicators**:
- Page dots below clouds (2 dots)
- Active dot: `#87CEEB`, 8pt diameter
- Inactive dot: `#D0D0D0`, 6pt diameter
- Dot spacing: 12pt

### 2.2 Swipe Behavior

**Gesture**:
- Horizontal swipe (left/right) to switch between clouds
- Swipe threshold: 50pt horizontal movement
- Animation: Spring animation (response: 0.4, dampingFraction: 0.8)

**Transitions**:
- Front cloud slides out in swipe direction
- Back cloud slides in from opposite side
- Deck-of-cards visual effect with slight scale difference
- Front cloud: scale 1.0
- Back cloud: scale 0.95, slight vertical offset (+10pt)

---

## 3. Action Buttons

### 3.1 "Draw my feelings" Button (Main Action)

**Location**: Fixed at bottom of screen, below cloud carousel

**Visual Specifications**:
- Size: Screen width - 48pt margins × 56pt height
- Corner radius: 28pt (pill shape)
- Background (enabled): Linear gradient `#87CEEB` to `#6BB8D9`
- Background (disabled): `#D0D0D0`
- Text: "Draw my feelings"
- Text color (enabled): White
- Text color (disabled): `#999999`
- Font: 18pt, Semibold
- Shadow: Subtle drop shadow when enabled

**States**:
- **Disabled**: No input provided (neither text nor questionnaire)
- **Enabled**: At least one input source has content
- Transition between states: 0.3s ease animation

**Interaction**:
- Tap to generate visualization
- Press state: Scale to 0.97, darker background

---

### 3.2 "Start over" Button

**Location**:
- During input mode: Top-left corner of screen (in navigation area)
- On visualization result: Bottom of screen, below the image

**Visual Specifications**:
- Style: Text button (during input) / Secondary button (on result)
- During input:
  - Text only: "Start over"
  - Color: `#666666`
  - Font: 16pt, Regular
  - With left-arrow icon (SF Symbol: `arrow.counterclockwise`)
- On result screen:
  - Rounded rectangle button
  - Background: `#F0F8FF`
  - Border: 1pt, `#ADD8E6`
  - Text: "Start over"
  - Text color: `#333333`
  - Size: 140pt × 44pt

**Interaction**:
- Tap to reset all state and return to Cloud #0
- Confirmation alert NOT required (quick action)

---

### 3.3 "Back" Button (Questionnaire)

**Location**: Top-left of questionnaire views

**Visual Specifications**:
- Icon: SF Symbol `chevron.left`
- Size: 44pt × 44pt tap target
- Icon size: 20pt
- Color: `#333333`

**Interaction**:
- Level 2 → Level 1: Preserves Level 1 selection
- Level 1 → Cloud #2: Exits questionnaire, returns to carousel

---

## 4. Input Validation Indicators

### 4.1 Character Counter (Cloud #1)

**Location**: Bottom-right inside Cloud #1

**Display Format**: "current / 5000"

**Color States**:
- 0-4500 characters: `#999999`
- 4501-5000 characters: `#E74C3C` (warning red)

### 4.2 Input Status Indicator

**Location**: Small badge on each cloud in carousel

**States**:
- Empty: No indicator
- Has content: Small checkmark badge
  - Circle background: `#4CAF50`
  - Checkmark: White
  - Size: 24pt diameter
  - Position: Top-right corner of cloud

---

## 5. Loading State

### 5.1 Generation Loading View

**Displayed**: After tapping "Draw my feelings" while waiting for visualization

**Visual**:
- Full screen overlay with semi-transparent background (`#FFFFFF` at 90% opacity)
- Centered cloud icon with gentle floating animation
- Text below: "Creating your visualization..."
- Animated dots after text (typing indicator style)
- Cancel button at bottom: "Cancel" (returns to input mode)

**Animation**:
- Cloud gently bobs up and down (3pt movement, 2s duration, ease-in-out)
- Optional: Soft pulsing glow effect
