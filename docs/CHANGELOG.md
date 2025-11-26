# Changelog

All notable changes to the EmotionVisualizer documentation and features are recorded in this file.

---

## [003-draw-feelings-frontend] - 2025-11-26

### Version 1.3.0

**Changes:**

1. **Selection Summary Displayed on Cloud #2**
   - Removed separate "Selection Summary Page" - summary now displays directly on Cloud #2
   - After completing questionnaire and tapping "Done", user returns to cloud carousel
   - Cloud #2 shows the summary text (e.g., "I feel cozy, content and fuming.") instead of "Tap your moods" button
   - Tapping Cloud #2 with summary re-enters questionnaire at Level 2 to modify selections
   - Updated flow diagrams in `03-user-flow.md`
   - Updated Cloud #2 states in `02-ui-components.md` section 1.4
   - Updated navigation flow in `05-emotions-questionnaire.md` section 6

---

## [003-draw-feelings-frontend] - 2025-11-26

### Version 1.2.0

**Changes:**

1. **Cloud Solid Fill Rendering**
   - Clarified that clouds must be rendered as **solid filled shapes**, not outlined circles
   - Internal construction circles must NOT be visible - only the outer cloud silhouette
   - Added cloud fill colors: `#FFFFFF` (white), `#F8FCFF` (light blue-white), `#E8F4FC` (light blue)
   - Border should only appear on the outer edge, not on internal circles
   - Updated `02-ui-components.md` section 1.1 with correct/incorrect implementation examples
   - Updated `04-visual-design.md` section 1.2 with cloud fill color specifications

---

## [003-draw-feelings-frontend] - 2025-11-26

### Version 1.1.0

**Changes:**

1. **Cloud Icon Transparency**
   - Set cloud icon transparency to 100% (fully opaque)
   - Updated `04-visual-design.md` with new section 1.2 Cloud Opacity

2. **Cloud #2 Button Text**
   - Changed button text from "Draw my feelings" to "Tap your moods"
   - Updated files: `02-ui-components.md`, `03-user-flow.md`, `05-emotions-questionnaire.md`

3. **Selection Summary Page**
   - Added new page displayed after completing questionnaire Level 2
   - Shows selection results as a sentence (e.g., "I feel content, chill and blah.")
   - Added "Back" button to return to Level 2 for modifications
   - Added "Continue" button to proceed to input mode
   - Updated navigation flow and state transitions in `03-user-flow.md`
   - Added detailed specifications in `05-emotions-questionnaire.md` section 6.2

---

## [003-draw-feelings-frontend] - 2025-11-26

### Version 1.0.0

**Initial Release:**

- Created comprehensive design documentation for "Draw My Feelings" frontend feature
- Files created:
  - `01-overview.md` - Purpose, scope, design principles, architecture overview
  - `02-ui-components.md` - Cloud components, buttons, carousel, loading states
  - `03-user-flow.md` - User journey, state transitions, animations
  - `04-visual-design.md` - Colors, typography, spacing, shadows, animations
  - `05-emotions-questionnaire.md` - Questionnaire structure, emotion definitions, icons

**Features documented:**
- Cloud #0 (Initial), Cloud #1 (Free Text), Cloud #2 (Questionnaire)
- Cloud carousel with swipe navigation
- Two-level questionnaire (Feel good? -> Specific emotions)
- 11 emotions: 5 positive, 6 negative
- Combined input support (text + questionnaire)
- Visualization result display (Option C - same screen transition)
- "Start over" navigation throughout flow
