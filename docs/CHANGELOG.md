# Changelog

All notable changes to the EmotionVisualizer documentation and features are recorded in this file.

---

## [004-mood-visualization-backend] - 2025-12-01

### Version 2.4.0

**Changes - Fixed 4-Corner Layout:**

1. **Explicit 4-Corner Composition**
   - Updated image style from generic "symmetrical" to **fixed 4-corner layout**
   - Factors positioned at exact corner coordinates:
     - Top-left: (22%, 22%)
     - Top-right: (78%, 22%)
     - Bottom-left: (22%, 78%)
     - Bottom-right: (78%, 78%)
   - Central stressor icon at exact center (50%, 50%)
   - Added fixed layout template diagram

2. **Factor-to-Corner Mapping**
   - `factors[0]` → Top-left corner (22%, 22%)
   - `factors[1]` → Top-right corner (78%, 22%)
   - `factors[2]` → Bottom-left corner (22%, 78%)
   - `factors[3]` → Bottom-right corner (78%, 78%)
   - If 3 factors: bottom-right left empty
   - If 5 factors: group related factors in one corner

**Files Modified:**
- `docs/004-mood-visualization-backend/req/02-api-specification.md` - v2.4 with fixed 4-corner layout

---

## [003-draw-feelings-frontend] - 2025-12-01

### Version 2.4.0

**Changes - Tappable Image Infographic:**

1. **Removed Text List Below Image**
   - Factor list NO longer displayed as text below the image
   - All factors shown IN the image only
   - Users tap icons in the image to see insights

2. **Circular Tappable Factor Icons**
   - **Shape**: Circular tap targets (not rectangular zones)
   - **Diameter**: 18% of image size
   - **Center positions** (matching icon locations):
     - Zone 1 (top-left): x: 22%, y: 22%
     - Zone 2 (top-right): x: 78%, y: 22%
     - Zone 3 (bottom-left): x: 22%, y: 78%
     - Zone 4 (bottom-right): x: 78%, y: 78%
   - Tap shows insight popout, NOT inline expansion

3. **Hint Text Added**
   - Text: "Tap icons to explore insights"
   - Displayed below image, centered

4. **Insight Popout (Replaces Inline Expansion)**
   - Centered card on screen (**85% width** - updated from 80%)
   - White background `#FFFFFF`, 16pt corner radius
   - Factor name as title header
   - Close button (✕) on right side
   - Dimmed background (`#000000` 50% opacity)
   - Tap dimmed area or ✕ to close

5. **Button Text Change**
   - Changed "Draw my story" → **"Understand my mood"**
   - Changed loading text "Understanding your story..." → **"Analyzing your mood..."**
   - Reflects focus on psychological analysis/insight

**Files Modified:**
- `docs/003-draw-feelings-frontend/req/02-ui-components.md` - v2.4 with circular tap targets and popout
- `docs/003-draw-feelings-frontend/req/03-user-flow.md` - v2.4 with "Understand my mood" terminology

---

## [004-mood-visualization-backend] - 2025-12-01

### Version 2.3.0 - IMPLEMENTED

**Changes - Deep Psychological Insights:**

1. **Deep Psychological Analysis** ✅
   - AI now provides **psychological insights**, not just surface descriptions
   - Each factor includes:
     - **Psychological root causes** (e.g., evolutionary need for acceptance)
     - **Cognitive bias explanations** (explained WITHOUT naming the bias)
     - **Light sociological context** (e.g., workplace dynamics)
   - Central stressor now uses **general category** (e.g., "Public Performance Anxiety" not specific event)
   - Insights are brief and concise (AI decides length)

2. **Text Labels IN Image** ✅
   - Changed from "no text labels" to **text labels included in image**
   - Text uses **Title Case** (e.g., "Fear of Judgment")
   - Text language **matches user's input language**
   - Factor labels: 2-4 words max
   - Central stressor label: up to 5 words

3. **Updated Response Structure** ✅
   - Changed `factors[].description` to `factors[].insight`
   - Renamed `EmotionalFactor` to `PsychologicalFactor` in Swift models
   - Added comparison table showing surface vs. deep insight examples

4. **Reserved for Future**
   - Reframing perspectives saved for future "strategies/suggestions" feature

**Files Modified:**
- `backend/app/services/story_analyzer.py` - v2.3 with deep psychological insights
- `backend/app/services/prompt_builder.py` - v2.3 with text labels in image
- `backend/app/api/v1/visualizations.py` - v2.3 with PsychologicalFactor model

---

## [003-draw-feelings-frontend] - 2025-12-01

### Version 2.3.0 - IMPLEMENTED

**Changes - Insight Display:**

1. **Story Visualization Image Update** ✅
   - Image now includes text labels (rendered by AI)
   - Minimalist 2D cartoon with symmetrical composition
   - Labels in Title Case, matching user's language

2. **Tappable Factor List** ✅
   - Factors displayed as tappable list items below image
   - Tap to expand and reveal psychological insight
   - Smooth expand/collapse animation (0.3s ease)
   - Chevron icon indicates expand/collapse state

3. **Insight Display Card** ✅
   - Background: `#F5F9FC` (light blue-gray)
   - Corner radius: 12pt, Padding: 12pt
   - Font: 14pt Regular, Color: `#555555`
   - Shows: root cause, cognitive bias explanation, sociological context

**Files Modified:**
- `EmotionVisualizer/Services/APIService.swift` - v2.3 with PsychologicalFactor
- `EmotionVisualizer/Views/DrawMyFeelings/Models/DMFModels.swift` - v2.3 with GeneratedPsychologicalFactor
- `EmotionVisualizer/Views/DrawMyFeelings/Components/StoryResultView.swift` - v2.3 with tappable factors

---

## [004-mood-visualization-backend] - 2025-11-30

### Version 2.2.0

**Changes - AI Analysis & Image Style:**

1. **Automatic Psychological Factor Analysis**
   - AI now automatically analyzes user's story to identify root causes
   - Identifies 3-5 general psychological factors (variable based on story)
   - Examples: Social Anxiety, Fear of Judgment, Perfectionism, Lack of Preparation, High Expectations, Uncertainty, Loss of Control, Imposter Syndrome, Fear of Failure
   - Documented two-step AI process: Text Analysis → Image Generation

2. **Updated Image Style: Minimalist 2D Cartoon**
   - Changed from "simplified 2D cartoon/infographic" to **"minimalist 2D cartoon"**
   - Added **symmetrical composition** requirement
   - Central icon for stressor, surrounding icons arranged symmetrically
   - Added example composition diagram in `02-api-specification.md`
   - White or light neutral background

---

## [003-draw-feelings-frontend] - 2025-11-30

### Version 2.2.0

**Changes:**

1. **Story Result Screen Enhanced**
   - Added story analysis display section (central stressor + factors list)
   - Specified font sizes: 16pt for stressor header, 14pt for factors
   - Analysis displayed below/alongside visualization image

2. **Future Expansion: "Understand More" Feature (Placeholder)**
   - Added section 3.3 documenting planned future feature
   - Will allow users to explore psychological factors in depth
   - Planned: tap factor for explanation, pattern recognition, educational content
   - Placeholder UI included in `02-ui-components.md`

---

## [004-mood-visualization-backend] - 2025-11-30

### Version 2.1.0

**Changes - Story Visualization Enhancements:**

1. **Cartoon/Infographic Style for `/story` Endpoint**
   - Changed from abstract art to simplified 2D cartoon/infographic style
   - Image shows icons representing the situation and emotional factors
   - NO text labels in the image (AI text rendering is unreliable)
   - Added image style guidelines in `02-api-specification.md`

2. **New `story_analysis` Response Field**
   - AI analyzes user's story text to identify emotional factors
   - Returns structured JSON with:
     - `central_stressor`: The main situation/stressor identified
     - `factors[]`: Array of emotional factors with name and description
     - `language`: Detected dominant language code (e.g., "en", "zh")
   - iOS app can display this alongside the image

3. **Multi-language Support**
   - Detects dominant language of user's input text
   - Returns `story_analysis` labels in the detected language
   - For mixed-language input, uses the language that appears most frequently

4. **Updated iOS Swift Models**
   - Split response into `FeelingVisualizationResponse` and `StoryVisualizationResponse`
   - Added `StoryAnalysis` and `EmotionalFactor` structs
   - Added shared types: `ImageSize`, `ResponseMeta`, `APIError`

---

## [003-draw-feelings-frontend] - 2025-11-30

### Version 2.1.0

**Changes:**

1. **Button Text Change: "Celebrate my feelings" → "Let it out!"**
   - Works better for both positive and negative emotions
   - "Celebrate" implied only positive feelings
   - "Let it out!" suggests emotional release for any feeling
   - Updated in `02-ui-components.md` and `03-user-flow.md`

---

## [004-mood-visualization-backend] - 2025-11-30

### Version 2.0.0

**Major Changes - Dual Visualization Endpoints:**

1. **Split `/generate` into Two Specialized Endpoints**
   - `POST /api/v1/visualizations/feeling` - Abstract art from emotions only
   - `POST /api/v1/visualizations/story` - 2D cartoon from text + emotions
   - Updated `02-api-specification.md` with complete request/response specs for both

2. **New `/feeling` Endpoint**
   - Generates abstract mood visualization from selected emotions
   - Request: `feeling_category` (required), `selected_emotions` (required)
   - First visualization in user journey

3. **New `/story` Endpoint**
   - Generates simplified 2D cartoon illustrating reasons behind feelings
   - Request: `story_text` (required, min 50 chars), `feeling_category`, `selected_emotions`
   - AI analyzes text to create visual story

4. **Dominant Colors in Response**
   - Added `dominant_colors` field to response (array of 3-4 hex codes)
   - Used by iOS for firework animation colors

5. **Updated iOS Swift Models**
   - Split request model into `FeelingVisualizationRequest` and `StoryVisualizationRequest`
   - Added `dominantColors` to response model
   - Added color conversion extension for firework animation

6. **New Error Code**
   - Added `TEXT_TOO_SHORT` error for story endpoint (min 50 characters)

---

## [003-draw-feelings-frontend] - 2025-11-30

### Version 2.0.0

**Major Changes - New User Flow:**

1. **Restructured User Journey**
   - Old: Cloud #0 → Carousel (Cloud #1/Cloud #2) → Result
   - New: Cloud #0 → Questionnaire → Feeling Visualization → Free Text → Story Visualization
   - Free text input now comes AFTER initial feeling visualization
   - Completely rewrote `03-user-flow.md` with new flow diagram

2. **Removed Cloud Carousel**
   - Simplified to linear flow without swiping between clouds
   - Cloud #0 still serves as entry point ("How are you feeling?")
   - Cloud #1 (free text) now appears after feeling visualization
   - Removed carousel components from `02-ui-components.md`

3. **New "Celebrate My Feelings" Button**
   - Available on both Feeling Result and Story Result screens
   - Triggers particle-based firework animation
   - Colors extracted from current visualization's `dominant_colors`
   - Multiple taps allowed (fireworks can overlap)
   - No sound effects
   - Added to `02-ui-components.md` section 4.1

4. **Firework Animation Component**
   - 50-100 particles per burst
   - 2 second duration with gravity-affected fall
   - Uses visualization colors with fallback palette
   - Does not block UI interactions
   - Added to `02-ui-components.md` section 5

5. **New "Know More About My Feeling" Button**
   - Appears on Feeling Result screen
   - Navigates to free text input (Cloud #1)
   - Added to `02-ui-components.md` section 4.2

6. **New "Draw My Story" Button**
   - Appears on free text input screen
   - Disabled until 50+ characters entered
   - Submits to `/api/v1/visualizations/story` endpoint
   - Added to `02-ui-components.md` section 4.3

7. **Updated Application States**
   - Added: `feelingResult`, `freeTextInput`, `generatingStory`, `storyResult`
   - Updated state machine in `03-user-flow.md` section 3.1

8. **Text Input Validation**
   - Minimum 50 characters required for story text
   - Character counter shows "min 50" hint until reached
   - Updated `02-ui-components.md` section 7

---

## [004-mood-visualization-backend] - 2025-11-26

### Version 1.0.0

**Initial Release:**

- Created comprehensive backend documentation for mood visualization image generation
- Files created:
  - `01-overview.md` - Purpose, scope, architecture, dependencies
  - `02-api-specification.md` - REST API endpoint specifications with examples
  - `03-gemini-integration.md` - Google Gemini API integration guide
  - `04-prompt-engineering.md` - Prompt construction logic and emotion mappings
  - `05-error-handling.md` - Error codes, exception handling, iOS integration

**Features documented:**
- `POST /api/v1/visualizations/generate` endpoint
- Input: free_text, feeling_category, selected_emotions
- Output: Base64 encoded PNG image
- Google Gemini API integration for image generation
- Prompt engineering with emotion-to-visual mappings
- 11 emotion profiles with colors, shapes, and energy levels
- Comprehensive error handling with user-friendly messages
- MVP: Anonymous access, base64 response (no cloud storage)

**Future enhancements identified:**
- User authentication integration
- Cloud storage (S3/GCS) for images
- Visualization history
- Rate limiting
- Mood intensity levels

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
