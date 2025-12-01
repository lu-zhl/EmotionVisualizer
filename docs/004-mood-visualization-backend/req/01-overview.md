# Overview - Mood Visualization Backend

## Document Information
- **Milestone**: 004-mood-visualization-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-26
- **Version**: 1.0

---

## 1. Purpose

This milestone implements the backend API for generating mood visualization images. The system accepts user mood input (free text and/or selected emotions from the "Draw My Feelings" frontend) and generates an abstract artistic visualization using Google Gemini's image generation capabilities.

## 2. Scope

### 2.1 In Scope

- REST API endpoint for visualization generation
- Google Gemini API integration for image generation
- Prompt engineering to translate mood input into artistic prompts
- MVP storage solution (base64 response)
- Error handling and graceful degradation
- Anonymous access (no authentication required)

### 2.2 Out of Scope (Future Milestones)

- User authentication integration
- Visualization history storage
- Rate limiting per user
- Cloud storage (S3/GCS)
- Mood intensity levels
- WebSocket real-time progress updates

## 3. User Stories

### US-001: Generate Visualization from Text
**As a** user who typed their feelings in free text,
**I want to** receive an abstract visualization of my mood,
**So that** I can see my emotions represented visually.

### US-002: Generate Visualization from Emotions
**As a** user who selected emotions from the questionnaire,
**I want to** receive an abstract visualization based on my selections,
**So that** I can see my chosen moods as an artistic image.

### US-003: Generate Visualization from Combined Input
**As a** user who provided both text and selected emotions,
**I want to** receive a visualization that considers both inputs,
**So that** I get the most accurate representation of my emotional state.

## 4. System Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   iOS App       │     │  FastAPI        │     │  Google Gemini  │
│   (Frontend)    │────▶│  Backend        │────▶│  API (Imagen)   │
│                 │     │                 │     │                 │
│  Draw My        │     │  /api/v1/       │     │  Image          │
│  Feelings UI    │◀────│  visualizations │◀────│  Generation     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌─────────────────┐
                        │  Prompt         │
                        │  Engineering    │
                        │  Module         │
                        └─────────────────┘
```

## 5. Data Flow

```
1. User Input (iOS App)
   ├── free_text: "I feel overwhelmed but excited"
   ├── feeling_category: "not_sure"
   └── selected_emotions: ["cozy", "content", "fuming"]
                │
                ▼
2. Backend Processing
   ├── Validate input (at least one field required)
   ├── Build visualization prompt
   │   └── Combine mood data + style constraints
   └── Call Gemini API
                │
                ▼
3. Gemini API
   ├── Generate abstract image
   └── Return image data
                │
                ▼
4. Response to iOS App
   ├── image_data: base64 encoded PNG
   └── prompt_used: generated prompt (for debugging)
```

## 6. Image Style Requirements

All generated images must adhere to these style constraints:

| Requirement | Description |
|-------------|-------------|
| **Style** | Abstract art - no realistic objects or scenes |
| **Colors** | Low saturation, muted/pastel tones |
| **Composition** | Symmetrical or balanced layout |
| **Text** | No text, letters, or words in the image |
| **Format** | PNG, suitable for mobile display |
| **Resolution** | 512x512 or 1024x1024 pixels |

## 7. Integration Points

### 7.1 Frontend Integration (iOS App)

The iOS app's `DrawMyFeelingsViewModel` will call this API when the user taps "Draw my feelings" button. The frontend provides:

- `free_text`: Content from Cloud #1 text input (0-5000 chars)
- `feeling_category`: Selected category from Level 1 questionnaire
- `selected_emotions`: Array of emotion IDs from Level 2 questionnaire

### 7.2 Gemini API Integration

- **API**: Google Gemini API with Imagen capabilities
- **Authentication**: API key stored in environment variables
- **Model**: `gemini-2.0-flash-exp` or appropriate image generation model

## 8. Success Criteria

1. API endpoint returns a valid image within 30 seconds
2. Generated images match the abstract, low-saturation style
3. Endpoint handles missing/invalid input gracefully
4. Gemini API failures return user-friendly error messages
5. Base64 image response works correctly with iOS app

## 9. Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| FastAPI | 0.104+ | REST API framework |
| google-generativeai | 0.3+ | Gemini API client |
| Pillow | 10.0+ | Image processing |
| python-dotenv | 1.0+ | Environment configuration |

## 10. Security Considerations

- Gemini API key must be stored securely (environment variable, not in code)
- Input validation to prevent prompt injection
- Rate limiting at infrastructure level (future enhancement)
- No PII stored in this milestone (anonymous access)

## 11. Related Documents

- [02-api-specification.md](./02-api-specification.md) - Detailed API specification
- [03-gemini-integration.md](./03-gemini-integration.md) - Gemini API integration guide
- [04-prompt-engineering.md](./04-prompt-engineering.md) - Prompt construction logic
- [05-error-handling.md](./05-error-handling.md) - Error handling strategies
