"""
Prompt Builder for Mood Visualization (Version 2.0)

Constructs image generation prompts:
- Feeling visualization: Abstract art from emotions
- Story visualization: 2D cartoon from text + emotions
"""

from typing import List, Optional
from dataclasses import dataclass


@dataclass
class EmotionProfile:
    """Visual profile for an emotion."""
    description: str
    colors: List[str]
    hex_colors: List[str]  # For dominant_colors in response
    shapes: str
    energy: str  # calm, moderate, intense


# Emotion profiles with visual characteristics
EMOTION_PROFILES = {
    "super_happy": EmotionProfile(
        description="joyful, bright, and uplifting energy",
        colors=["warm yellow", "soft orange", "light pink"],
        hex_colors=["#FFE4A0", "#FFB899", "#FFD4E5"],
        shapes="rising curves and radiating patterns",
        energy="moderate"
    ),
    "pumped": EmotionProfile(
        description="dynamic, energetic, and vibrant spirit",
        colors=["coral", "peach", "warm gold"],
        hex_colors=["#FFB5A0", "#FFDAB9", "#FFD700"],
        shapes="bold curves and expanding circles",
        energy="intense"
    ),
    "cozy": EmotionProfile(
        description="warm, comfortable, and enveloping feeling",
        colors=["warm beige", "soft terracotta", "cream"],
        hex_colors=["#D4B896", "#E2A68F", "#FFFDD0"],
        shapes="rounded and nested shapes",
        energy="calm"
    ),
    "chill": EmotionProfile(
        description="calm, relaxed, and flowing state",
        colors=["cool mint", "soft sage", "pale blue"],
        hex_colors=["#A8E6CF", "#9DC183", "#ADD8E6"],
        shapes="gentle waves and horizontal flow",
        energy="calm"
    ),
    "content": EmotionProfile(
        description="peaceful, balanced, and satisfied feeling",
        colors=["soft lavender", "dusty rose", "warm gray"],
        hex_colors=["#D4C4E8", "#D4A5A5", "#C4C4BC"],
        shapes="centered, symmetrical, complete circles",
        energy="calm"
    ),
    "fuming": EmotionProfile(
        description="contained intensity and simmering energy",
        colors=["muted coral", "dusty red", "warm gray"],
        hex_colors=["#E8A0A0", "#C25A5A", "#A89F9F"],
        shapes="contained spirals with inward pressure",
        energy="intense"
    ),
    "freaked_out": EmotionProfile(
        description="scattered, anxious, and unsettled feeling",
        colors=["pale violet", "soft gray", "muted blue"],
        hex_colors=["#C8A0E8", "#B0B0B0", "#8FA8C8"],
        shapes="dispersed elements and irregular patterns",
        energy="intense"
    ),
    "mad_as_hell": EmotionProfile(
        description="heavy, dense, and pressured energy",
        colors=["deep mauve", "muted burgundy", "charcoal"],
        hex_colors=["#8B4570", "#722F37", "#36454F"],
        shapes="dense centers and heavy forms",
        energy="intense"
    ),
    "blah": EmotionProfile(
        description="flat, neutral, and unmotivated state",
        colors=["gray tones", "muted beige", "pale taupe"],
        hex_colors=["#B0C4D4", "#C4B8A8", "#B8AFA0"],
        shapes="horizontal layers and static forms",
        energy="calm"
    ),
    "down": EmotionProfile(
        description="low, weighted, and subdued feeling",
        colors=["cool gray-blue", "pale indigo", "soft navy"],
        hex_colors=["#A0B8D4", "#9FA8DA", "#6B7B8C"],
        shapes="downward curves and sinking shapes",
        energy="calm"
    ),
    "bored_stiff": EmotionProfile(
        description="empty, monotonous, and unstimulated feeling",
        colors=["neutral grays", "pale olive", "muted tan"],
        hex_colors=["#D4D0C4", "#C5C99B", "#C2B280"],
        shapes="regular, repetitive, sparse patterns",
        energy="calm"
    )
}

# Valid emotion IDs
VALID_EMOTIONS = set(EMOTION_PROFILES.keys())

# Valid feeling categories
VALID_CATEGORIES = {"good", "bad", "not_sure"}

# Fallback colors for firework animation
FALLBACK_COLORS = ["#FFD700", "#FF6B6B", "#4ECDC4", "#A78BFA"]


class PromptBuilder:
    """Build image generation prompts from mood input."""

    FEELING_BASE_STYLE = """
Abstract art visualization with these characteristics:
- Abstract style with no recognizable objects or people
- Soft, muted colors with low saturation (pastel tones)
- Symmetrical or balanced composition
- Smooth gradients and flowing shapes
- Absolutely NO text, letters, words, or numbers
"""

    STORY_BASE_STYLE = """
Create a minimalist 2D cartoon illustration with these characteristics:
- Minimalist, flat 2D cartoon style (clean, simple, not detailed)
- SYMMETRICAL composition - balanced layout with central focus
- White or light neutral background
- Gentle pastel colors
- No text, letters, words, or numbers in the image
- Clean lines, minimal detail
- Friendly and non-threatening visual style
"""

    def build_feeling_prompt(
        self,
        feeling_category: str,
        selected_emotions: List[str]
    ) -> str:
        """
        Build a prompt for feeling visualization (abstract art from emotions).

        Args:
            feeling_category: "good", "bad", or "not_sure"
            selected_emotions: List of emotion IDs

        Returns:
            Complete prompt string for abstract art generation
        """
        parts = [self.FEELING_BASE_STYLE]

        # Add mood description
        mood_desc = self._build_emotion_description(selected_emotions, feeling_category)
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

    def build_story_prompt(
        self,
        story_text: str,
        feeling_category: str,
        selected_emotions: List[str],
        central_stressor: Optional[str] = None,
        factors: Optional[List[dict]] = None
    ) -> str:
        """
        Build a prompt for story visualization (2D cartoon/infographic from text + emotions).

        Args:
            story_text: User's story text (min 50 chars)
            feeling_category: "good", "bad", or "not_sure"
            selected_emotions: List of emotion IDs
            central_stressor: The main situation identified (from story analysis)
            factors: List of emotional factors (from story analysis)

        Returns:
            Complete prompt string for story infographic generation
        """
        parts = [self.STORY_BASE_STYLE]

        # Use analyzed stressor if available, otherwise summarize story
        if central_stressor:
            parts.append(f"\nCENTRAL SITUATION:\n{central_stressor}")
        else:
            story_summary = self._summarize_story(story_text)
            parts.append(f"\nSTORY TO ILLUSTRATE:\n{story_summary}")

        # Add emotional factors as visual elements
        if factors:
            factor_names = [f.get("factor", "") for f in factors if f.get("factor")]
            if factor_names:
                parts.append(f"\nEMOTIONAL FACTORS TO SHOW AS ICONS:\n" +
                           "\n".join(f"- {name}" for name in factor_names))

        # Add emotional context
        emotion_context = self._build_emotion_context(selected_emotions, feeling_category)
        parts.append(f"\nEMOTIONAL CONTEXT:\n{emotion_context}")

        # Add color guidance based on emotions
        colors = self._get_color_palette(selected_emotions, feeling_category)
        parts.append(f"\nCOLOR MOOD:\n{colors}")

        # Updated final instruction for minimalist 2D cartoon with symmetrical composition
        parts.append("""
Create a minimalist 2D cartoon infographic:
- SYMMETRICAL composition with balanced layout
- Central icon in the middle representing the main situation
- Surrounding icons arranged symmetrically around the center (like a mind-map)
- Clean lines, flat design, minimal detail
- NO text labels in the image
- White or light neutral background
- Connected with simple lines from center to surrounding icons
- Soft pastel colors based on emotional tone
- Child-friendly, non-threatening visual style

Example composition:
        [Factor]          [Factor]
              \\              /
               \\            /
                [ Central  ]
               /            \\
              /              \\
        [Factor]          [Factor]""")

        return "\n".join(parts)

    def get_dominant_colors(self, selected_emotions: List[str]) -> List[str]:
        """
        Get dominant hex colors from selected emotions for firework animation.

        Args:
            selected_emotions: List of emotion IDs

        Returns:
            List of 3-4 hex color codes
        """
        colors = []
        for emotion_id in selected_emotions:
            profile = EMOTION_PROFILES.get(emotion_id)
            if profile:
                # Take the first hex color from each emotion
                if profile.hex_colors:
                    colors.append(profile.hex_colors[0])

        # Ensure we have 3-4 colors
        if len(colors) < 3:
            # Add fallback colors
            for fallback in FALLBACK_COLORS:
                if fallback not in colors:
                    colors.append(fallback)
                if len(colors) >= 4:
                    break

        return colors[:4]

    def _build_emotion_description(
        self,
        selected_emotions: List[str],
        feeling_category: str
    ) -> str:
        """Build mood description from emotions."""
        descriptions = []

        for emotion_id in selected_emotions:
            profile = EMOTION_PROFILES.get(emotion_id)
            if profile:
                descriptions.append(profile.description)

        # Add category context
        category_desc = {
            "good": "overall positive emotional state",
            "bad": "challenging emotional state",
            "not_sure": "mixed or uncertain emotional state"
        }
        descriptions.append(category_desc.get(feeling_category, ""))

        return " ".join(descriptions) if descriptions else "general emotional state"

    def _build_emotion_context(
        self,
        selected_emotions: List[str],
        feeling_category: str
    ) -> str:
        """Build emotional context for story visualization."""
        emotion_names = []
        energy_levels = []

        for emotion_id in selected_emotions:
            profile = EMOTION_PROFILES.get(emotion_id)
            if profile:
                # Convert emotion_id to readable name
                name = emotion_id.replace("_", " ")
                emotion_names.append(name)
                energy_levels.append(profile.energy)

        context_parts = []
        if emotion_names:
            context_parts.append(f"The person feels: {', '.join(emotion_names)}")

        # Determine overall energy
        if "intense" in energy_levels:
            context_parts.append("The emotional intensity is high.")
        elif all(e == "calm" for e in energy_levels):
            context_parts.append("The emotional state is calm and subdued.")
        else:
            context_parts.append("The emotional state is moderate.")

        return " ".join(context_parts)

    def _get_color_palette(
        self,
        selected_emotions: List[str],
        feeling_category: str
    ) -> str:
        """Determine color palette based on emotions."""
        colors = set()

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

    def _get_shape_guidance(self, selected_emotions: List[str]) -> str:
        """Determine shape guidance based on emotions."""
        shapes = []
        for emotion_id in selected_emotions:
            profile = EMOTION_PROFILES.get(emotion_id)
            if profile:
                shapes.append(profile.shapes)

        return "Incorporate " + " and ".join(shapes[:3]) if shapes else ""

    def _summarize_story(self, text: str, max_length: int = 300) -> str:
        """Summarize story text for prompt inclusion."""
        text = text.strip()
        if len(text) <= max_length:
            return text

        # Simple truncation with ellipsis
        return text[:max_length - 3] + "..."

    # Legacy method for backwards compatibility
    def build_prompt(
        self,
        free_text: Optional[str] = None,
        feeling_category: Optional[str] = None,
        selected_emotions: Optional[List[str]] = None
    ) -> str:
        """Legacy method - use build_feeling_prompt or build_story_prompt instead."""
        if selected_emotions:
            return self.build_feeling_prompt(
                feeling_category=feeling_category or "not_sure",
                selected_emotions=selected_emotions
            )
        return self.FEELING_BASE_STYLE


# Global instance
prompt_builder = PromptBuilder()
