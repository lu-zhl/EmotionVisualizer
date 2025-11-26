# User Flow and Interactions

## 1. Complete User Journey

### 1.1 Flow Diagram

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
│                           INPUT MODE                                         │
│  ┌─────────────────┐    ┌─────────────────┐                                 │
│  │    Cloud #1     │◄──►│    Cloud #2     │   ← Swipe left/right            │
│  │  (Free Text)    │    │ (Questionnaire) │                                 │
│  └─────────────────┘    └─────────────────┘                                 │
│                                                                              │
│  [Start over]                        ["Draw my feelings" - disabled]         │
└─────────────────────────────────────────────────────────────────────────────┘
          │                                    │
          │ Type text                          │ Tap "Draw my feelings" button
          ▼                                    ▼
┌──────────────────────┐         ┌─────────────────────────────────────────────┐
│  Text entered        │         │              QUESTIONNAIRE                   │
│  Button enables      │         │                                              │
│                      │         │  Level 1: "Feel good?"                       │
│  Can also do         │         │  [Good]  [Bad]                               │
│  questionnaire       │         │     [Not Sure]                               │
└──────────────────────┘         │                                              │
          │                      │  [Back]                    [Start over]      │
          │                      └─────────────────────────────────────────────┘
          │                                    │
          │                                    │ Select option
          │                                    ▼
          │                      ┌─────────────────────────────────────────────┐
          │                      │  Level 2: "I feel like:"                     │
          │                      │                                              │
          │                      │  [Icon] [Icon] [Icon]  ← Multi-select        │
          │                      │  [Icon] [Icon] [Icon]                        │
          │                      │                                              │
          │                      │  [Back]      [Done]       [Start over]       │
          │                      └─────────────────────────────────────────────┘
          │                                    │
          │                                    │ Tap "Done"
          │                                    ▼
          │                      ┌─────────────────────────────────────────────┐
          │                      │     RETURN TO INPUT MODE (Cloud Carousel)    │
          │                      │                                              │
          │                      │  Cloud #2 now displays summary on the cloud: │
          │                      │  "I feel cozy, content and fuming."          │
          │                      │                                              │
          │                      │  Questionnaire selections saved              │
          │                      │  "Draw my feelings" button enabled           │
          └──────────────────────┼─────────────────────────────────────────────┘
                                 │
                                 │ Tap "Draw my feelings"
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           GENERATING STATE                                   │
│                                                                              │
│                    [Cloud animation + loading text]                          │
│                    "Creating your visualization..."                          │
│                                                                              │
│                              [Cancel]                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                 │
                                 │ Generation complete
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          RESULT STATE                                        │
│                                                                              │
│                    ┌─────────────────────────┐                               │
│                    │                         │                               │
│                    │    Generated Image      │                               │
│                    │    (Visualization)      │                               │
│                    │                         │                               │
│                    └─────────────────────────┘                               │
│                                                                              │
│                          [Start over]                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                 │
                                 │ Tap "Start over"
                                 ▼
                    ┌─────────────────────────┐
                    │  Return to Cloud #0     │
                    │  All state cleared      │
                    └─────────────────────────┘
```

---

## 2. State Transitions

### 2.1 Initial → Input Mode

**Trigger**: Tap on Cloud #0

**Animation Sequence** (duration: 0.6s total):
1. Cloud #0 scales down slightly (0.95) with fade out (0.3s)
2. Cloud #0 morphs/transitions into Cloud #1 position
3. Cloud #1 fades in and scales up from 0.9 to 1.0 (0.3s)
4. Cloud #2 slides in from right, slightly behind Cloud #1 (0.3s, starts at 0.2s)
5. "Draw my feelings" button fades in from bottom (0.3s, starts at 0.3s)
6. "Start over" button fades in (0.2s, starts at 0.4s)

**Easing**: `easeOut` for exits, `easeOut` for entrances

---

### 2.2 Cloud Carousel Swiping

**Trigger**: Horizontal swipe gesture on cloud area

**Swipe Left (Cloud #1 → Cloud #2)**:
1. Cloud #1 slides left and scales to 0.95 (0.4s spring)
2. Cloud #2 slides left into front position, scales to 1.0 (0.4s spring)
3. Page indicator updates

**Swipe Right (Cloud #2 → Cloud #1)**:
1. Cloud #2 slides right and scales to 0.95 (0.4s spring)
2. Cloud #1 slides right into front position, scales to 1.0 (0.4s spring)
3. Page indicator updates

**State Preservation**: Both clouds retain their input state during swipes

---

### 2.3 Enter Questionnaire

**Trigger**: Tap "Tap your moods" button on Cloud #2

**Animation Sequence** (duration: 0.5s):
1. Cloud carousel fades out and slides down slightly (0.3s)
2. Level 1 questionnaire fades in and slides up (0.3s, starts at 0.2s)
3. "Start over" button remains visible, repositions if needed

---

### 2.4 Questionnaire Level 1 → Level 2

**Trigger**: Tap any option (Good / Bad / Not Sure)

**Animation Sequence** (duration: 0.4s):
1. Selected option scales up briefly (1.1) with highlight
2. All Level 1 content slides left and fades (0.3s)
3. Level 2 content slides in from right (0.3s)
4. Emotion icons animate in with stagger (0.05s delay each)

---

### 2.5 Return from Questionnaire (Done)

**Trigger**: Tap "Done" on Level 2

**Animation Sequence** (duration: 0.4s):
1. Level 2 content slides down and fades out (0.3s)
2. Cloud carousel fades in and slides up (0.3s)
3. Cloud #2 now displays the selection summary text on the cloud
4. "Draw my feelings" button enables

**Cloud #2 After Selection**:
- The "Tap your moods" button is replaced with the summary sentence
- Summary displayed directly on Cloud #2: "I feel cozy, content and fuming."
- Checkmark badge remains visible on Cloud #2

---

### 2.6 Return from Questionnaire (via Back)

**Trigger**: Tap "Back" from Level 1

**Animation** (duration: 0.4s):
1. Level 1 slides down and fades out
2. Cloud carousel fades in and slides up
3. Previous selections (if any) are preserved on Cloud #2

---

### 2.7 Input Mode → Generating

**Trigger**: Tap "Draw my feelings" button (main action)

**Animation Sequence** (duration: 0.5s):
1. Button press animation (scale 0.97)
2. Clouds animate out - float upward and fade (0.4s)
3. Loading view fades in with cloud floating animation
4. Loading text appears with typing animation

---

### 2.8 Generating → Result (Option C)

**Trigger**: Visualization generation complete

**Animation Sequence** (duration: 0.8s):
1. Loading cloud floats up and fades out (0.3s)
2. Brief pause (0.1s)
3. Generated image fades in from center, subtle scale from 0.95 to 1.0 (0.5s)
4. "Start over" button fades in below image (0.3s, starts at 0.5s)

**Note**: Clouds do NOT return; they've been "transformed" into the visualization

---

### 2.9 Any State → Initial (Start Over)

**Trigger**: Tap "Start over" button (available in input mode and result view)

**Animation Sequence** (duration: 0.5s):
1. Current view fades out (0.3s)
2. All state is cleared:
   - Free text input → empty
   - Questionnaire selections → cleared
   - Generated image → discarded
3. Cloud #0 fades in with gentle float-down animation (0.3s)

---

## 3. Input Combination Logic

### 3.1 Valid Input States

The "Draw my feelings" button enables when ANY of these conditions are met:

| Free Text | Questionnaire | Button State |
|-----------|---------------|--------------|
| Empty | No selections | **Disabled** |
| Has text | No selections | **Enabled** |
| Empty | Has selections | **Enabled** |
| Has text | Has selections | **Enabled** |

### 3.2 Combined Input Handling

When both inputs are provided, they are combined for visualization:

```swift
struct CombinedInput {
    let freeText: String?           // From Cloud #1
    let category: FeelingCategory?  // From Level 1
    let emotions: [Emotion]         // From Level 2

    var hasValidInput: Bool {
        let hasText = !(freeText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasEmotions = !emotions.isEmpty
        return hasText || hasEmotions
    }
}
```

---

## 4. Error States

### 4.1 Generation Failure

**When**: Backend returns error or timeout during generation

**Display**:
- Error message overlay (same position as loading)
- Cloud icon with sad expression or X mark
- Text: "Oops! We couldn't create your visualization."
- Secondary text: "Please try again."
- Buttons: "Try again" (primary), "Start over" (secondary)

**"Try again"**: Re-attempts generation with same input
**"Start over"**: Returns to Cloud #0

### 4.2 Network Unavailable

**When**: No network connection detected

**Display**:
- Shown when tapping "Draw my feelings"
- Alert or inline message: "No internet connection. Please check your connection and try again."
- Button remains enabled for retry

---

## 5. Gesture Summary

| Gesture | Location | Action |
|---------|----------|--------|
| Tap | Cloud #0 | Enter input mode |
| Tap | Cloud #1 text area | Focus text input |
| Tap | Cloud #2 "Tap your moods" button | Start questionnaire |
| Tap | Cloud #2 summary text | Re-enter questionnaire to modify |
| Swipe left | Cloud carousel | Show Cloud #2 |
| Swipe right | Cloud carousel | Show Cloud #1 |
| Tap | Questionnaire option | Select option |
| Tap | Back button | Navigate back |
| Tap | "Done" (Level 2) | Return to cloud carousel with summary |
| Tap | "Draw my feelings" | Generate visualization |
| Tap | "Start over" | Reset to initial state |
| Tap | Outside keyboard | Dismiss keyboard |
