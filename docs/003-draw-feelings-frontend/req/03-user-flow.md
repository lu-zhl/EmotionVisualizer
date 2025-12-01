# User Flow and Interactions

## 1. Complete User Journey

### 1.1 Flow Diagram (Version 2.0)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              APP LAUNCH                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INITIAL STATE (Cloud #0)                             │
│                        "How are you feeling?"                                │
│                              [Tap Cloud]                                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           QUESTIONNAIRE                                      │
│                                                                              │
│  Level 1: "Feel good?"                                                       │
│  [Good]  [Bad]                                                               │
│     [Not Sure]                                                               │
│                                                                              │
│  [Back]                                              [Start over]            │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Select option
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        QUESTIONNAIRE - Level 2                               │
│                                                                              │
│  "I feel like:"                                                              │
│  [Icon] [Icon] [Icon]  ← Multi-select                                        │
│  [Icon] [Icon] [Icon]                                                        │
│                                                                              │
│  [Back]                    [Done]                    [Start over]            │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Tap "Done"
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           GENERATING STATE                                   │
│                                                                              │
│                    [Cloud animation + loading text]                          │
│                    "Drawing your feelings..."                                │
│                                                                              │
│                              [Cancel]                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Generation complete
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     FEELING VISUALIZATION RESULT                             │
│                                                                              │
│                 "I feel cozy, content and fuming."                           │
│                                                                              │
│                    ┌─────────────────────────┐                               │
│                    │                         │                               │
│                    │    "Draw Feeling"       │                               │
│                    │    Visualization        │                               │
│                    │                         │                               │
│                    └─────────────────────────┘                               │
│                                                                              │
│  [Let it out!]                  [Know more about my feeling]                 │
│                                                                              │
│                          [Start over]                                        │
└─────────────────────────────────────────────────────────────────────────────┘
          │                              │
          │ Tap "Let it out!"            │ Tap "Know more about my feeling"
          ▼                              ▼
┌──────────────────────┐    ┌─────────────────────────────────────────────────┐
│  Firework Animation  │    │                FREE TEXT INPUT                   │
│  (in visualization   │    │                                                  │
│   colors)            │    │  Cloud #1 appears with text input:               │
│                      │    │  "Tell me more about your feelings..."           │
│  Can tap multiple    │    │                                                  │
│  times!              │    │  [Text area - min 50 chars]                      │
└──────────────────────┘    │                                                  │
                            │  [Draw my story - disabled until 50+ chars]      │
                            │                                                  │
                            │                          [Start over]            │
                            └─────────────────────────────────────────────────┘
                                                │
                                                │ Enter 50+ chars, tap "Draw my story"
                                                ▼
                            ┌─────────────────────────────────────────────────┐
                            │              GENERATING STATE                    │
                            │                                                  │
                            │       "Understanding your story..."              │
                            │                                                  │
                            │                  [Cancel]                        │
                            └─────────────────────────────────────────────────┘
                                                │
                                                │ Generation complete
                                                ▼
                            ┌─────────────────────────────────────────────────┐
                            │          STORY VISUALIZATION RESULT              │
                            │                                                  │
                            │     ┌─────────────────────────┐                  │
                            │     │                         │                  │
                            │     │    "Draw Story"         │                  │
                            │     │    Visualization        │                  │
                            │     │                         │                  │
                            │     └─────────────────────────┘                  │
                            │                                                  │
                            │               [Let it out!]                     │
                            │                                                  │
                            │               [Start over]                       │
                            └─────────────────────────────────────────────────┘
                                                │
                                                │ Tap "Start over"
                                                ▼
                            ┌─────────────────────────────────────────────────┐
                            │              Return to Cloud #0                  │
                            │              All state cleared                   │
                            └─────────────────────────────────────────────────┘
```

---

## 2. State Transitions

### 2.1 Initial → Questionnaire

**Trigger**: Tap on Cloud #0

**Animation Sequence** (duration: 0.5s):
1. Cloud #0 scales down slightly (0.95) with fade out (0.3s)
2. Level 1 questionnaire fades in and slides up (0.3s, starts at 0.2s)
3. "Start over" button fades in (0.2s, starts at 0.3s)

**Easing**: `easeOut` for exits, `easeOut` for entrances

---

### 2.2 Questionnaire Level 1 → Level 2

**Trigger**: Tap any option (Good / Bad / Not Sure)

**Animation Sequence** (duration: 0.4s):
1. Selected option scales up briefly (1.1) with highlight
2. All Level 1 content slides left and fades (0.3s)
3. Level 2 content slides in from right (0.3s)
4. Emotion icons animate in with stagger (0.05s delay each)

---

### 2.3 Questionnaire Level 2 → Back to Level 1

**Trigger**: Tap "Back" on Level 2

**Animation** (duration: 0.4s):
1. Level 2 slides right and fades out
2. Level 1 slides in from left
3. Previous Level 1 selection is preserved (highlighted)

---

### 2.4 Questionnaire → Generating (Draw Feeling)

**Trigger**: Tap "Done" on Level 2

**Animation Sequence** (duration: 0.5s):
1. Questionnaire fades out and slides down (0.3s)
2. Loading view fades in with cloud floating animation
3. Loading text: "Drawing your feelings..."

---

### 2.5 Generating → Feeling Visualization Result

**Trigger**: "Draw Feeling" generation complete

**Animation Sequence** (duration: 0.8s):
1. Loading cloud floats up and fades out (0.3s)
2. Brief pause (0.1s)
3. Summary text fades in: "I feel cozy, content and fuming." (0.3s)
4. Generated image fades in from center, subtle scale from 0.95 to 1.0 (0.5s)
5. Action buttons fade in below image (0.3s, staggered)
   - "Let it out!" and "Know more about my feeling" appear side by side
   - "Start over" appears below

---

### 2.6 Feeling Result → Free Text Input

**Trigger**: Tap "Know more about my feeling"

**Animation Sequence** (duration: 0.5s):
1. Current view (image + buttons) fades out and slides left (0.3s)
2. Cloud #1 (free text input) slides in from right (0.3s)
3. Text input area is focused, keyboard appears
4. "Draw my story" button appears (disabled state)
5. "Start over" button remains visible

---

### 2.7 Free Text → Generating (Draw Story)

**Trigger**: Tap "Draw my story" (requires 50+ characters)

**Animation Sequence** (duration: 0.5s):
1. Cloud #1 fades out and floats up (0.3s)
2. Loading view fades in with cloud floating animation
3. Loading text: "Understanding your story..."

---

### 2.8 Generating → Story Visualization Result

**Trigger**: "Draw Story" generation complete

**Animation Sequence** (duration: 0.8s):
1. Loading cloud floats up and fades out (0.3s)
2. Brief pause (0.1s)
3. Story visualization image fades in from center (0.5s)
4. "Let it out!" button fades in (0.3s)
5. "Start over" button fades in below (0.2s)

---

### 2.9 "Let it out!" Animation

**Trigger**: Tap "Let it out!" button (available on both result screens)

**Animation**:
1. Button shows brief press state (scale 0.95)
2. Firework animation launches from bottom center
3. Firework colors match the visualization's color palette
4. Animation duration: 2 seconds
5. Multiple taps = multiple fireworks (can overlap)
6. No sound effects
7. Does not block other interactions

**Firework Behavior**:
- Each tap triggers a new firework burst
- Fireworks can be triggered in rapid succession
- Colors are extracted from the current visualization
- Animation plays as overlay, does not navigate away

---

### 2.10 Any State → Initial (Start Over)

**Trigger**: Tap "Start over" button (available on all screens after Cloud #0)

**Animation Sequence** (duration: 0.5s):
1. Current view fades out (0.3s)
2. All state is cleared:
   - Questionnaire selections → cleared
   - Generated visualizations → discarded
   - Free text input → empty
3. Cloud #0 fades in with gentle float-down animation (0.3s)

---

## 3. State Management

### 3.1 Application States

```swift
enum DrawMyFeelingsState {
    case initial                    // Showing Cloud #0
    case questionnaireLevel1        // Choosing Good/Bad/Not Sure
    case questionnaireLevel2        // Selecting specific emotions
    case generatingFeeling          // Creating feeling visualization
    case feelingResult              // Showing feeling visualization
    case freeTextInput              // Entering story text
    case generatingStory            // Creating story visualization
    case storyResult                // Showing story visualization
}
```

### 3.2 Data Model

```swift
struct UserJourneyData {
    // Questionnaire data
    var feelingCategory: FeelingCategory?
    var selectedEmotions: [Emotion] = []

    // Visualization data
    var feelingVisualization: UIImage?
    var feelingVisualizationColors: [Color] = []  // For firework animation

    // Free text data
    var storyText: String = ""

    // Story visualization
    var storyVisualization: UIImage?
    var storyVisualizationColors: [Color] = []

    // Computed
    var summaryText: String {
        // "I feel cozy, content and fuming."
    }

    var canDrawStory: Bool {
        storyText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 50
    }
}
```

---

## 4. Input Validation

### 4.1 Questionnaire Validation

- Level 1: Must select one option (Good/Bad/Not Sure)
- Level 2: Must select at least one emotion
- "Done" button disabled until at least one emotion selected

### 4.2 Free Text Validation

| Character Count | "Draw my story" Button | Counter Color |
|-----------------|------------------------|---------------|
| 0-49 | Disabled | `#999999` |
| 50-4500 | Enabled | `#999999` |
| 4501-5000 | Enabled | `#E74C3C` (warning) |
| 5000+ | Enabled (truncated) | `#E74C3C` |

**Minimum**: 50 characters (roughly one sentence)
**Maximum**: 5000 characters

---

## 5. Error States

### 5.1 Feeling Generation Failure

**When**: Backend returns error or timeout during "Draw Feeling" generation

**Display**:
- Error message overlay (same position as loading)
- Cloud icon with sad expression
- Text: "Oops! We couldn't draw your feelings."
- Secondary text: "Please try again."
- Buttons: "Try again" (primary), "Start over" (secondary)

### 5.2 Story Generation Failure

**When**: Backend returns error or timeout during "Draw Story" generation

**Display**:
- Error message overlay
- Text: "Oops! We couldn't understand your story."
- Secondary text: "Please try again."
- Buttons: "Try again" (primary), "Start over" (secondary)

### 5.3 Network Unavailable

**When**: No network connection detected

**Display**:
- Alert: "No internet connection. Please check your connection and try again."
- Action buttons remain enabled for retry

---

## 6. Gesture Summary

| Gesture | Location | Action |
|---------|----------|--------|
| Tap | Cloud #0 | Start questionnaire |
| Tap | Level 1 option | Select and proceed to Level 2 |
| Tap | Level 2 emotion | Toggle selection |
| Tap | "Done" | Generate feeling visualization |
| Tap | "Back" | Return to previous step |
| Tap | "Let it out!" | Trigger firework animation |
| Tap | "Know more about my feeling" | Go to free text input |
| Tap | Text area (Cloud #1) | Focus and show keyboard |
| Tap | "Draw my story" | Generate story visualization |
| Tap | "Start over" | Reset to Cloud #0 |
| Tap | Outside keyboard | Dismiss keyboard |

---

## 7. Screen Inventory

| Screen | Key Elements | Navigation Options |
|--------|--------------|-------------------|
| Cloud #0 | Cloud with "How are you feeling?" | Tap → Questionnaire |
| Questionnaire L1 | 3 options, Back, Start over | Option → L2, Back → Cloud #0 |
| Questionnaire L2 | Emotion grid, Done, Back, Start over | Done → Generate, Back → L1 |
| Feeling Result | Summary, Image, Let it out!, Know more, Start over | Let it out!, Know more, Start over |
| Free Text Input | Cloud #1, Text area, Draw my story, Start over | Draw → Generate, Start over |
| Story Result | Image, Let it out!, Start over | Let it out!, Start over |
