# Emotions and Questionnaire Specification

## 1. Questionnaire Structure

### 1.1 Level 1: Feel Good?

**Purpose**: Initial categorization of emotional state

**Title**: "Feel good?"

**Layout**:
```
         ┌─────────────┐    ┌─────────────┐
         │    Good     │    │     Bad     │
         └─────────────┘    └─────────────┘

              ┌──────────────────┐
              │    Not Sure      │
              └──────────────────┘
```

**Options**:

| Option | Category | Icon Suggestion |
|--------|----------|-----------------|
| Good | `.good` | Smiling sun or upward curve |
| Bad | `.bad` | Rain cloud or downward curve |
| Not Sure | `.notSure` | Question mark cloud or wavy line |

**Selection Behavior**:
- Single selection only
- Tapping an option immediately proceeds to Level 2
- Selected state: Scale up (1.05), background highlight, checkmark overlay

---

### 1.2 Level 2: Specific Emotions

**Purpose**: Detailed emotion selection based on Level 1 choice

**Title**: "I feel like:"

**Selection Mode**: Multi-select (user can select multiple emotions)

**Layout**: Grid layout, 3 columns
- Icon size: 60pt × 60pt
- Grid spacing: 16pt horizontal, 20pt vertical
- Each cell includes icon + label below

---

## 2. Emotion Definitions

### 2.1 Positive Emotions (shown when "Good" selected)

| Emotion | Display Name | Icon Description | Suggested Color |
|---------|--------------|------------------|-----------------|
| `superHappy` | Super happy | Beaming face with sparkles | Warm yellow `#FFE4A0` |
| `pumped` | Pumped | Flexing arm or energy burst | Energetic coral `#FFB5A0` |
| `cozy` | Cozy | Wrapped in blanket or warm mug | Soft brown `#D4B896` |
| `chill` | Chill | Relaxed face with sunglasses | Cool mint `#A8E6CF` |
| `content` | Content | Peaceful smile, closed eyes | Soft lavender `#D4C4E8` |

### 2.2 Negative Emotions (shown when "Bad" selected)

| Emotion | Display Name | Icon Description | Suggested Color |
|---------|--------------|------------------|-----------------|
| `fuming` | Fuming | Steam coming from head | Deep red `#E8A0A0` |
| `freakedOut` | Freaked out | Wide eyes, hair standing | Electric purple `#C8A0E8` |
| `madAsHell` | Mad as hell | Angry face with furrowed brows | Hot red `#E8B0A0` |
| `blah` | Blah | Flat expression, horizontal mouth | Gray blue `#B0C4D4` |
| `down` | Down | Sad face, tear drop | Muted blue `#A0B8D4` |
| `boredStiff` | Bored stiff | Heavy-lidded eyes, yawning | Dull beige `#D4D0C4` |

### 2.3 All Emotions (shown when "Not Sure" selected)

When "Not Sure" is selected, display ALL emotions from both positive and negative categories.

**Layout Adjustment**:
- Use 2 sections with subtle headers
- "Positive vibes" section header (optional)
- "Negative vibes" section header (optional)
- Or display all in a single grid without sections

---

## 3. Data Model

### 3.1 Emotion Model

```swift
enum FeelingCategory: String, CaseIterable, Codable {
    case good
    case bad
    case notSure
}

struct Emotion: Identifiable, Equatable, Codable {
    let id: String
    let displayName: String
    let category: FeelingCategory
    let iconName: String        // Asset catalog name
    let accentColor: String     // Hex color for the emotion

    static let allEmotions: [Emotion] = [
        // Positive
        Emotion(id: "superHappy", displayName: "Super happy", category: .good,
                iconName: "emotion_super_happy", accentColor: "FFE4A0"),
        Emotion(id: "pumped", displayName: "Pumped", category: .good,
                iconName: "emotion_pumped", accentColor: "FFB5A0"),
        Emotion(id: "cozy", displayName: "Cozy", category: .good,
                iconName: "emotion_cozy", accentColor: "D4B896"),
        Emotion(id: "chill", displayName: "Chill", category: .good,
                iconName: "emotion_chill", accentColor: "A8E6CF"),
        Emotion(id: "content", displayName: "Content", category: .good,
                iconName: "emotion_content", accentColor: "D4C4E8"),

        // Negative
        Emotion(id: "fuming", displayName: "Fuming", category: .bad,
                iconName: "emotion_fuming", accentColor: "E8A0A0"),
        Emotion(id: "freakedOut", displayName: "Freaked out", category: .bad,
                iconName: "emotion_freaked_out", accentColor: "C8A0E8"),
        Emotion(id: "madAsHell", displayName: "Mad as hell", category: .bad,
                iconName: "emotion_mad_as_hell", accentColor: "E8B0A0"),
        Emotion(id: "blah", displayName: "Blah", category: .bad,
                iconName: "emotion_blah", accentColor: "B0C4D4"),
        Emotion(id: "down", displayName: "Down", category: .bad,
                iconName: "emotion_down", accentColor: "A0B8D4"),
        Emotion(id: "boredStiff", displayName: "Bored stiff", category: .bad,
                iconName: "emotion_bored_stiff", accentColor: "D4D0C4"),
    ]

    static func emotions(for category: FeelingCategory) -> [Emotion] {
        switch category {
        case .good:
            return allEmotions.filter { $0.category == .good }
        case .bad:
            return allEmotions.filter { $0.category == .bad }
        case .notSure:
            return allEmotions
        }
    }
}
```

### 3.2 Questionnaire State

```swift
class QuestionnaireState: ObservableObject {
    @Published var selectedCategory: FeelingCategory?
    @Published var selectedEmotions: Set<String> = []

    var availableEmotions: [Emotion] {
        guard let category = selectedCategory else { return [] }
        return Emotion.emotions(for: category)
    }

    var hasSelections: Bool {
        !selectedEmotions.isEmpty
    }

    func toggleEmotion(_ emotion: Emotion) {
        if selectedEmotions.contains(emotion.id) {
            selectedEmotions.remove(emotion.id)
        } else {
            selectedEmotions.insert(emotion.id)
        }
    }

    func reset() {
        selectedCategory = nil
        selectedEmotions = []
    }
}
```

---

## 4. UI Components

### 4.1 Level 1 Option Button

**Size**: 120pt × 100pt

**States**:

| State | Background | Border | Scale | Icon |
|-------|------------|--------|-------|------|
| Default | `#F5FAFD` | 1pt `#D0E4EF` | 1.0 | Normal |
| Pressed | `#E8F4FC` | 2pt `#87CEEB` | 0.98 | Normal |
| Selected | `#E0F4FF` | 2pt `#87CEEB` | 1.0 | + Checkmark |

**Layout**:
```
┌─────────────────────┐
│                     │
│      [Icon]         │  ← 40pt × 40pt icon
│                     │
│      Label          │  ← 15pt, Medium
│                     │
└─────────────────────┘
```

### 4.2 Level 2 Emotion Button

**Size**: (Screen width - 48pt - 32pt) / 3 × same (square)
- Approximately 100pt × 100pt on iPhone 14

**States**:

| State | Background | Border | Icon Style |
|-------|------------|--------|------------|
| Default | `#FFFFFF` | 1pt `#E8E8E8` | Outline |
| Pressed | `#F5FAFD` | 1pt `#ADD8E6` | Outline |
| Selected | Emotion accent color (20% opacity) | 2pt emotion accent | Filled |

**Layout**:
```
┌─────────────────────┐
│                     │
│      [Icon]         │  ← 60pt × 60pt icon
│                     │
│   Emotion Name      │  ← 13pt, Regular
│                     │
└─────────────────────┘
```

**Selection indicator**: Small filled circle or checkmark in top-right corner when selected

### 4.3 "Done" Button (Level 2)

**Location**: Bottom of Level 2 view, above "Start over"

**Visual**:
- Same style as main "Draw my feelings" button but smaller
- Size: 160pt × 48pt
- Text: "Done"
- Only enabled when at least one emotion is selected

---

## 5. Icon Design Guidelines

### 5.1 Style Requirements

All emotion icons must follow these guidelines:

- **Style**: Minimalist line art with optional subtle fill
- **Stroke width**: 2pt consistent
- **Color**: Single accent color per icon (from emotion's accentColor)
- **Canvas**: 60pt × 60pt with 4pt padding (52pt visible area)
- **Format**: PDF vector (for scalability) or SVG converted to asset catalog

### 5.2 Icon States

Each emotion needs two icon variants:

1. **Outline** (default state):
   - Stroke only, no fill
   - Color: `#666666` (gray)

2. **Filled** (selected state):
   - Filled with emotion's accent color
   - Stroke in darker shade of accent color

### 5.3 Placeholder Icons

Until custom icons are designed, use SF Symbols as placeholders:

| Emotion | SF Symbol Placeholder |
|---------|----------------------|
| Super happy | `face.smiling.fill` |
| Pumped | `bolt.fill` |
| Cozy | `cup.and.saucer.fill` |
| Chill | `leaf.fill` |
| Content | `heart.fill` |
| Fuming | `flame.fill` |
| Freaked out | `exclamationmark.triangle.fill` |
| Mad as hell | `cloud.bolt.fill` |
| Blah | `minus.circle.fill` |
| Down | `cloud.rain.fill` |
| Bored stiff | `moon.zzz.fill` |

---

## 6. Questionnaire Navigation

### 6.1 Navigation Flow

```
Cloud #2 "Tap your moods" button
         │
         ▼
    ┌─────────┐
    │ Level 1 │ ←──────────────────┐
    └────┬────┘                    │
         │ Select option           │ Back
         ▼                         │
    ┌─────────┐                    │
    │ Level 2 │ ───────────────────┘
    └────┬────┘
         │ Tap "Done"
         ▼
  Return to Cloud Carousel
  (Cloud #2 displays summary: "I feel cozy, content and fuming.")
         │
         │ Tap Cloud #2 summary
         ▼
  Re-enter questionnaire (Level 2 with selections preserved)
```

### 6.2 Selection Summary on Cloud #2

**Purpose**: After completing emotion selection, the summary is displayed directly on Cloud #2 instead of a separate page.

**Display Location**: Cloud #2 in the cloud carousel

**Summary Sentence**:
- Text: "I feel [emotions]."
- Font: System, 18pt, Medium
- Color: `#333333`
- Alignment: Centered on cloud
- Multi-line wrapping for long text

**Sentence Formatting Rules**:

| Selected Emotions | Output Format |
|-------------------|---------------|
| 1 emotion | "I feel content." |
| 2 emotions | "I feel content and chill." |
| 3+ emotions | "I feel cozy, content and fuming." |

- Emotion names are displayed in **lowercase**
- Use "and" (not "&") before the last emotion
- Use Oxford comma style: commas between all items except before "and"

**Code Implementation**:

```swift
extension QuestionnaireState {
    var summaryText: String {
        let emotions = selectedEmotionObjects.map { $0.displayName.lowercased() }

        switch emotions.count {
        case 0:
            return ""
        case 1:
            return "I feel \(emotions[0])."
        case 2:
            return "I feel \(emotions[0]) and \(emotions[1])."
        default:
            let allButLast = emotions.dropLast().joined(separator: ", ")
            let last = emotions.last!
            return "I feel \(allButLast) and \(last)."
        }
    }

    var selectedEmotionObjects: [Emotion] {
        Emotion.allEmotions.filter { selectedEmotions.contains($0.id) }
    }
}
```

**Cloud #2 States**:

| State | Content | Interaction |
|-------|---------|-------------|
| Before selection | "Tap your moods" button | Tap to start questionnaire |
| After selection | Summary text (e.g., "I feel cozy, content and fuming.") | Tap to re-enter questionnaire |

### 6.3 Back Button Behavior

| From | To | State Handling |
|------|----|----|
| Level 1 | Cloud #2 | Exit questionnaire, no changes |
| Level 2 | Level 1 | Preserve Level 1 selection, clear Level 2 selections |

### 6.4 Modifying Selections

After returning to the cloud carousel with a summary:
- Tap on Cloud #2 (or the summary text) to re-enter the questionnaire
- Questionnaire opens at Level 2 with previous selections preserved
- User can modify selections and tap "Done" again

### 6.5 "Start Over" from Questionnaire

When "Start over" is tapped during questionnaire:
1. Clear all questionnaire state
2. Clear free text input
3. Return directly to Cloud #0 (initial state)
4. Skip the input mode entirely

---

## 7. Accessibility

### 7.1 VoiceOver Labels

**Level 1 Options**:
- "Good. Feeling positive. Button."
- "Bad. Feeling negative. Button."
- "Not Sure. Uncertain feelings. Button."

**Level 2 Emotions**:
- "[Emotion name]. [Selected/Not selected]. Button. Double tap to [select/deselect]."

**Navigation**:
- "Back. Return to previous question."
- "Done. Confirm emotion selections and return to input."

**Cloud #2 Summary**:
- When summary is displayed: "Your mood selection: [emotion1], [emotion2], and [emotion3]. Tap to modify."

### 7.2 Haptic Feedback

| Action | Haptic Type |
|--------|-------------|
| Select Level 1 option | Light impact |
| Select/deselect emotion | Light impact |
| Complete questionnaire | Success notification |
| Error state | Error notification |
