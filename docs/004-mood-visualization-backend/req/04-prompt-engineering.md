# Prompt Engineering Guide

## Document Information
- **Milestone**: 004-mood-visualization-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-26
- **Version**: 1.0

---

## 1. Overview

This document defines how to construct effective prompts for Gemini image generation based on user mood input. The goal is to translate emotional data into prompts that produce consistent, aesthetically pleasing abstract visualizations.

## 2. Prompt Structure

### 2.1 Base Template

```
Create an abstract art visualization with the following characteristics:

STYLE:
- Abstract art style, no recognizable objects or realistic elements
- Soft, muted color palette with low saturation (pastel tones)
- Symmetrical or balanced composition
- Smooth gradients and flowing shapes
- NO text, letters, words, or numbers in the image

MOOD TO VISUALIZE:
{mood_description}

COLOR GUIDANCE:
{color_guidance}

OUTPUT:
- Square format (1:1 aspect ratio)
- Suitable for mobile display
- Calming and aesthetically pleasing
```

### 2.2 Prompt Components

| Component | Source | Description |
|-----------|--------|-------------|
| Style constraints | Fixed | Always included, defines visual style |
| Mood description | User input | Derived from emotions/text |
| Color guidance | Emotion mapping | Colors associated with emotions |

## 3. Emotion to Visual Mapping

### 3.1 Positive Emotions

| Emotion | Visual Elements | Color Palette | Shapes |
|---------|-----------------|---------------|--------|
| **Super happy** | Bright, uplifting, expansive | Warm yellows, soft oranges, light pink | Rising curves, radiating patterns |
| **Pumped** | Dynamic, energetic, vibrant | Coral, peach, warm gold | Bold curves, expanding circles |
| **Cozy** | Warm, enveloping, soft | Warm beige, soft terracotta, cream | Rounded, nested shapes |
| **Chill** | Calm, smooth, flowing | Cool mint, soft sage, pale blue | Gentle waves, horizontal flow |
| **Content** | Balanced, serene, complete | Soft lavender, dusty rose, warm gray | Centered, symmetrical, complete circles |

### 3.2 Negative Emotions

| Emotion | Visual Elements | Color Palette | Shapes |
|---------|-----------------|---------------|--------|
| **Fuming** | Intense (but muted), contained energy | Muted coral, dusty red, warm gray | Contained spirals, inward pressure |
| **Freaked out** | Scattered, fragmented, chaotic (softly) | Pale violet, soft gray, muted blue | Dispersed elements, irregular patterns |
| **Mad as hell** | Heavy, dense, pressured | Deep mauve, muted burgundy, charcoal | Dense centers, heavy forms |
| **Blah** | Flat, still, neutral | Gray tones, muted beige, pale taupe | Horizontal layers, static forms |
| **Down** | Low, weighted, subdued | Cool gray-blue, pale indigo, soft navy | Downward curves, sinking shapes |
| **Bored stiff** | Empty, repetitive, monotonous | Neutral grays, pale olive, muted tan | Regular, repetitive, sparse patterns |

### 3.3 Mixed/Uncertain States

When `feeling_category` is "not_sure" or emotions are mixed:

| State | Visual Elements | Color Palette |
|-------|-----------------|---------------|
| Mixed positive/negative | Contrasting but harmonious, transitional | Blend of warm and cool pastels |
| Uncertain | Soft, ambiguous, transitional | Neutral with hints of both warm and cool |

## 4. Prompt Generation Logic

### 4.1 Python Implementation

```python
from typing import List, Optional
from dataclasses import dataclass

@dataclass
class EmotionProfile:
    """Visual profile for an emotion."""
    description: str
    colors: List[str]
    shapes: str
    energy: str  # calm, moderate, intense

EMOTION_PROFILES = {
    "super_happy": EmotionProfile(
        description="joyful, bright, and uplifting energy",
        colors=["warm yellow", "soft orange", "light pink"],
        shapes="rising curves and radiating patterns",
        energy="moderate"
    ),
    "pumped": EmotionProfile(
        description="dynamic, energetic, and vibrant spirit",
        colors=["coral", "peach", "warm gold"],
        shapes="bold curves and expanding circles",
        energy="intense"
    ),
    "cozy": EmotionProfile(
        description="warm, comfortable, and enveloping feeling",
        colors=["warm beige", "soft terracotta", "cream"],
        shapes="rounded and nested shapes",
        energy="calm"
    ),
    "chill": EmotionProfile(
        description="calm, relaxed, and flowing state",
        colors=["cool mint", "soft sage", "pale blue"],
        shapes="gentle waves and horizontal flow",
        energy="calm"
    ),
    "content": EmotionProfile(
        description="peaceful, balanced, and satisfied feeling",
        colors=["soft lavender", "dusty rose", "warm gray"],
        shapes="centered, symmetrical, complete circles",
        energy="calm"
    ),
    "fuming": EmotionProfile(
        description="contained intensity and simmering energy",
        colors=["muted coral", "dusty red", "warm gray"],
        shapes="contained spirals with inward pressure",
        energy="intense"
    ),
    "freaked_out": EmotionProfile(
        description="scattered, anxious, and unsettled feeling",
        colors=["pale violet", "soft gray", "muted blue"],
        shapes="dispersed elements and irregular patterns",
        energy="intense"
    ),
    "mad_as_hell": EmotionProfile(
        description="heavy, dense, and pressured energy",
        colors=["deep mauve", "muted burgundy", "charcoal"],
        shapes="dense centers and heavy forms",
        energy="intense"
    ),
    "blah": EmotionProfile(
        description="flat, neutral, and unmotivated state",
        colors=["gray tones", "muted beige", "pale taupe"],
        shapes="horizontal layers and static forms",
        energy="calm"
    ),
    "down": EmotionProfile(
        description="low, weighted, and subdued feeling",
        colors=["cool gray-blue", "pale indigo", "soft navy"],
        shapes="downward curves and sinking shapes",
        energy="calm"
    ),
    "bored_stiff": EmotionProfile(
        description="empty, monotonous, and unstimulated feeling",
        colors=["neutral grays", "pale olive", "muted tan"],
        shapes="regular, repetitive, sparse patterns",
        energy="calm"
    )
}


class PromptBuilder:
    """Build image generation prompts from mood input."""

    BASE_STYLE = """
Abstract art visualization with these characteristics:
- Abstract style with no recognizable objects
- Soft, muted colors with low saturation (pastel tones)
- Symmetrical or balanced composition
- Smooth gradients and flowing shapes
- Absolutely NO text, letters, words, or numbers
"""

    def build_prompt(
        self,
        free_text: Optional[str] = None,
        feeling_category: Optional[str] = None,
        selected_emotions: Optional[List[str]] = None
    ) -> str:
        """
        Build a complete image generation prompt.

        Args:
            free_text: User's free-form text description
            feeling_category: "good", "bad", or "not_sure"
            selected_emotions: List of emotion IDs

        Returns:
            Complete prompt string for image generation
        """
        parts = [self.BASE_STYLE]

        # Add mood description
        mood_desc = self._build_mood_description(
            free_text, feeling_category, selected_emotions
        )
        parts.append(f"\nMOOD TO VISUALIZE:\n{mood_desc}")

        # Add color guidance
        colors = self._get_color_palette(selected_emotions, feeling_category)
        parts.append(f"\nCOLOR PALETTE:\n{colors}")

        # Add shape guidance
        shapes = self._get_shape_guidance(selected_emotions)
        if shapes:
            parts.append(f"\nSHAPE GUIDANCE:\n{shapes}")

        # Final instruction
        parts.append("\nCreate a calming, aesthetically pleasing square image.")

        return "\n".join(parts)

    def _build_mood_description(
        self,
        free_text: Optional[str],
        feeling_category: Optional[str],
        selected_emotions: Optional[List[str]]
    ) -> str:
        """Build the mood description section."""
        descriptions = []

        # Add emotion descriptions
        if selected_emotions:
            for emotion_id in selected_emotions:
                profile = EMOTION_PROFILES.get(emotion_id)
                if profile:
                    descriptions.append(profile.description)

        # Add free text summary
        if free_text:
            # Summarize long text
            text_summary = self._summarize_text(free_text)
            descriptions.append(f"User describes: {text_summary}")

        # Add category context
        if feeling_category:
            category_desc = {
                "good": "overall positive emotional state",
                "bad": "challenging emotional state",
                "not_sure": "mixed or uncertain emotional state"
            }
            descriptions.append(category_desc.get(feeling_category, ""))

        return " ".join(descriptions) if descriptions else "general emotional state"

    def _get_color_palette(
        self,
        selected_emotions: Optional[List[str]],
        feeling_category: Optional[str]
    ) -> str:
        """Determine color palette based on emotions."""
        colors = set()

        if selected_emotions:
            for emotion_id in selected_emotions:
                profile = EMOTION_PROFILES.get(emotion_id)
                if profile:
                    colors.update(profile.colors)

        if not colors:
            # Default based on category
            if feeling_category == "good":
                colors = {"soft warm tones", "light pastels", "gentle yellows"}
            elif feeling_category == "bad":
                colors = {"muted cool tones", "soft grays", "pale blues"}
            else:
                colors = {"neutral pastels", "soft balanced tones"}

        return "Use " + ", ".join(list(colors)[:5])

    def _get_shape_guidance(
        self,
        selected_emotions: Optional[List[str]]
    ) -> str:
        """Determine shape guidance based on emotions."""
        if not selected_emotions:
            return ""

        shapes = []
        for emotion_id in selected_emotions:
            profile = EMOTION_PROFILES.get(emotion_id)
            if profile:
                shapes.append(profile.shapes)

        return "Incorporate " + " and ".join(shapes[:3]) if shapes else ""

    def _summarize_text(self, text: str, max_length: int = 200) -> str:
        """Summarize long text for prompt inclusion."""
        if len(text) <= max_length:
            return text

        # Simple truncation with ellipsis
        # Future: Use AI summarization
        return text[:max_length-3] + "..."
```

### 4.2 Usage Example

```python
builder = PromptBuilder()

# Example 1: Emotions only
prompt = builder.build_prompt(
    selected_emotions=["cozy", "content"]
)

# Example 2: Free text only
prompt = builder.build_prompt(
    free_text="I feel peaceful watching the sunset"
)

# Example 3: Combined
prompt = builder.build_prompt(
    free_text="Mixed day at work",
    feeling_category="not_sure",
    selected_emotions=["chill", "blah"]
)
```

## 5. Prompt Examples

### 5.1 Single Positive Emotion

**Input**: `selected_emotions: ["content"]`

**Generated Prompt**:
```
Abstract art visualization with these characteristics:
- Abstract style with no recognizable objects
- Soft, muted colors with low saturation (pastel tones)
- Symmetrical or balanced composition
- Smooth gradients and flowing shapes
- Absolutely NO text, letters, words, or numbers

MOOD TO VISUALIZE:
peaceful, balanced, and satisfied feeling

COLOR PALETTE:
Use soft lavender, dusty rose, warm gray

SHAPE GUIDANCE:
Incorporate centered, symmetrical, complete circles

Create a calming, aesthetically pleasing square image.
```

### 5.2 Multiple Mixed Emotions

**Input**:
```json
{
  "feeling_category": "not_sure",
  "selected_emotions": ["pumped", "freaked_out"]
}
```

**Generated Prompt**:
```
Abstract art visualization with these characteristics:
- Abstract style with no recognizable objects
- Soft, muted colors with low saturation (pastel tones)
- Symmetrical or balanced composition
- Smooth gradients and flowing shapes
- Absolutely NO text, letters, words, or numbers

MOOD TO VISUALIZE:
dynamic, energetic, and vibrant spirit scattered, anxious, and unsettled feeling mixed or uncertain emotional state

COLOR PALETTE:
Use coral, peach, warm gold, pale violet, soft gray

SHAPE GUIDANCE:
Incorporate bold curves and expanding circles and dispersed elements and irregular patterns

Create a calming, aesthetically pleasing square image.
```

### 5.3 Free Text with Emotions

**Input**:
```json
{
  "free_text": "Had a tough meeting but I'm feeling okay now",
  "feeling_category": "not_sure",
  "selected_emotions": ["chill"]
}
```

**Generated Prompt**:
```
Abstract art visualization with these characteristics:
- Abstract style with no recognizable objects
- Soft, muted colors with low saturation (pastel tones)
- Symmetrical or balanced composition
- Smooth gradients and flowing shapes
- Absolutely NO text, letters, words, or numbers

MOOD TO VISUALIZE:
calm, relaxed, and flowing state User describes: Had a tough meeting but I'm feeling okay now mixed or uncertain emotional state

COLOR PALETTE:
Use cool mint, soft sage, pale blue

SHAPE GUIDANCE:
Incorporate gentle waves and horizontal flow

Create a calming, aesthetically pleasing square image.
```

## 6. Prompt Safety

### 6.1 Input Sanitization

```python
import re

def sanitize_input(text: str) -> str:
    """
    Sanitize user input before including in prompt.

    - Remove potential prompt injection attempts
    - Remove special characters
    - Limit length
    """
    if not text:
        return ""

    # Remove potential instruction overrides
    dangerous_patterns = [
        r"ignore\s+(previous|above|all)",
        r"disregard",
        r"forget",
        r"new\s+instructions?",
        r"system\s*:",
        r"assistant\s*:",
    ]

    cleaned = text
    for pattern in dangerous_patterns:
        cleaned = re.sub(pattern, "", cleaned, flags=re.IGNORECASE)

    # Remove special characters that could affect prompts
    cleaned = re.sub(r'[<>\[\]{}|\\]', '', cleaned)

    # Limit length
    return cleaned[:2000]
```

### 6.2 Content Filtering

```python
BLOCKED_TERMS = [
    # Add terms that shouldn't appear in mood visualizations
    # This is a safety measure
]

def check_content_safety(text: str) -> bool:
    """Check if input text is safe for image generation."""
    text_lower = text.lower()
    return not any(term in text_lower for term in BLOCKED_TERMS)
```

## 7. Testing Prompts

### 7.1 Test Cases

| Test ID | Input | Expected Output Characteristics |
|---------|-------|--------------------------------|
| T1 | Single positive emotion | Warm, balanced, calm image |
| T2 | Single negative emotion | Muted, subdued image |
| T3 | Mixed emotions | Blend of characteristics |
| T4 | Long free text | Should truncate gracefully |
| T5 | Empty input | Should use defaults |

### 7.2 Validation

```python
def validate_prompt(prompt: str) -> bool:
    """Validate generated prompt meets requirements."""
    checks = [
        "no text" in prompt.lower() or "no letters" in prompt.lower(),
        "abstract" in prompt.lower(),
        "pastel" in prompt.lower() or "muted" in prompt.lower(),
        len(prompt) < 2000,  # Not too long
        len(prompt) > 100,   # Not too short
    ]
    return all(checks)
```

## 8. Future Enhancements

1. **Intensity Levels**: Add support for mood intensity (slightly, moderately, very)
2. **AI Summarization**: Use Gemini to summarize long free text before prompt building
3. **Prompt Caching**: Cache prompts for identical inputs
4. **A/B Testing**: Test different prompt structures for quality
5. **User Feedback Loop**: Allow users to rate visualizations to improve prompts
