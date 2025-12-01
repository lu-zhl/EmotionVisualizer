# API Specification - Mood Visualization

## Document Information
- **Milestone**: 004-mood-visualization-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-26
- **Version**: 1.0

---

## 1. Endpoint Overview

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/visualizations/feeling` | Generate feeling visualization (from emotions) |
| POST | `/api/v1/visualizations/story` | Generate story visualization (from text + emotions) |
| GET | `/api/v1/visualizations/health` | Health check for visualization service |

**Note (Version 2.0)**: The original `/generate` endpoint has been split into two specialized endpoints:
- `/feeling` - Visualizes selected emotions as abstract art
- `/story` - Analyzes and visualizes the reasons behind feelings

---

## 2. Generate Feeling Visualization

### POST /api/v1/visualizations/feeling

Generate an abstract mood visualization image based on selected emotions. This is the first visualization in the user journey - it draws the user's feelings as abstract art.

#### 2.1 Request

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
  "feeling_category": "string (required, enum: good|bad|not_sure)",
  "selected_emotions": ["string"] (required, array of emotion IDs)
}
```

**Validation Rules**:
- `feeling_category` is required, must be one of: `good`, `bad`, `not_sure`
- `selected_emotions` is required, must contain at least one valid emotion ID (see Section 5)

#### 2.2 Request Examples

**Example 1: Positive emotions**
```json
{
  "feeling_category": "good",
  "selected_emotions": ["cozy", "content"]
}
```

**Example 2: Mixed emotions**
```json
{
  "feeling_category": "not_sure",
  "selected_emotions": ["cozy", "content", "blah"]
}
```

**Example 3: Negative emotions**
```json
{
  "feeling_category": "bad",
  "selected_emotions": ["fuming", "down"]
}
```

#### 2.3 Success Response

**Status**: `200 OK`

```json
{
  "success": true,
  "data": {
    "image_data": "base64_encoded_png_string...",
    "image_format": "png",
    "image_size": {
      "width": 512,
      "height": 512
    },
    "prompt_used": "Abstract art visualization representing emotions of comfort and contentment...",
    "dominant_colors": ["#A8E6CF", "#D4C4E8", "#FFE4A0"],
    "generation_time_ms": 3500
  },
  "meta": {
    "timestamp": "2025-11-26T12:00:00Z",
    "api_version": "1.0"
  }
}
```

**Response Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `image_data` | string | Base64 encoded PNG image |
| `image_format` | string | Always "png" |
| `image_size.width` | integer | Image width in pixels |
| `image_size.height` | integer | Image height in pixels |
| `prompt_used` | string | The prompt sent to Gemini (for debugging) |
| `dominant_colors` | array | 3-4 hex color codes extracted from image (for firework animation) |
| `generation_time_ms` | integer | Time taken to generate image |

#### 2.4 Error Responses

**400 Bad Request - Validation Error**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "At least one of 'free_text' or 'selected_emotions' must be provided",
    "details": {
      "field": "request_body",
      "reason": "empty_input"
    }
  },
  "meta": {
    "timestamp": "2025-11-26T12:00:00Z"
  }
}
```

**400 Bad Request - Invalid Emotion**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid emotion ID: 'invalid_emotion'",
    "details": {
      "field": "selected_emotions",
      "invalid_values": ["invalid_emotion"],
      "valid_values": ["super_happy", "pumped", "cozy", "chill", "content", "fuming", "freaked_out", "mad_as_hell", "blah", "down", "bored_stiff"]
    }
  },
  "meta": {
    "timestamp": "2025-11-26T12:00:00Z"
  }
}
```

**400 Bad Request - Text Too Long**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "free_text exceeds maximum length of 5000 characters",
    "details": {
      "field": "free_text",
      "max_length": 5000,
      "actual_length": 5234
    }
  },
  "meta": {
    "timestamp": "2025-11-26T12:00:00Z"
  }
}
```

**503 Service Unavailable - Gemini API Error**
```json
{
  "success": false,
  "error": {
    "code": "GENERATION_SERVICE_ERROR",
    "message": "Image generation service is temporarily unavailable",
    "details": {
      "retry_after_seconds": 30,
      "service": "gemini"
    }
  },
  "meta": {
    "timestamp": "2025-11-26T12:00:00Z"
  }
}
```

**504 Gateway Timeout - Generation Timeout**
```json
{
  "success": false,
  "error": {
    "code": "GENERATION_TIMEOUT",
    "message": "Image generation timed out. Please try again.",
    "details": {
      "timeout_seconds": 30
    }
  },
  "meta": {
    "timestamp": "2025-11-26T12:00:00Z"
  }
}
```

---

## 3. Generate Story Visualization

### POST /api/v1/visualizations/story

Generate a visualization that illustrates the **reasons and psychological factors** behind the user's feelings. This is the second visualization in the user journey.

**Key Features**:
- AI **automatically analyzes** the user's story to identify the central stressor and underlying psychological factors
- Identifies **3-5 general psychological factors** (e.g., "Social Anxiety", "Fear of Judgment", not specific details)
- Generates a **minimalist 2D cartoon** image with **symmetrical composition**
- Image shows icons representing the situation and emotional factors WITHOUT text labels
- Returns a separate `story_analysis` JSON field with text labels for the iOS app to display
- Output language matches the dominant language of the user's input

**AI Analysis Process**:
The backend performs a two-step process:
1. **Step 1 - Text Analysis**: AI reads the user's story and identifies:
   - The central stressor/situation
   - 3-5 general psychological factors contributing to their emotional state
   - Examples of factors: Social Anxiety, Fear of Judgment, Perfectionism, Lack of Preparation, High Expectations, Uncertainty, Loss of Control, Imposter Syndrome, Fear of Failure, etc.
2. **Step 2 - Image Generation**: Based on the analysis, generate a minimalist infographic

**Why No Text in Image**:
AI image generators often struggle with accurate text rendering. Instead, we generate clean icon-based visuals and return the analysis as structured data for the iOS app to overlay or display alongside the image.

#### 3.1 Request

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
  "story_text": "string (required, min 50 chars, max 5000 chars)",
  "feeling_category": "string (required, enum: good|bad|not_sure)",
  "selected_emotions": ["string"] (required, array of emotion IDs)
}
```

**Validation Rules**:
- `story_text` is required, minimum 50 characters, maximum 5000 characters
- `feeling_category` is required, must be one of: `good`, `bad`, `not_sure`
- `selected_emotions` is required, must contain at least one valid emotion ID

#### 3.2 Request Examples

**Example 1: Work-related stress (Chinese)**
```json
{
  "story_text": "我现在的压力最大的是需要在公司年会上唱歌。我担心在同事面前表现不好，害怕被评判或嘲笑。而且我觉得练习不够，不熟悉歌曲。",
  "feeling_category": "bad",
  "selected_emotions": ["freaked_out", "down"]
}
```

**Example 2: Mixed feelings at work (English)**
```json
{
  "story_text": "I had a really tough day at work. My manager criticized my presentation in front of everyone, and I felt so embarrassed. But my colleague came to support me afterwards which made me feel a bit better.",
  "feeling_category": "not_sure",
  "selected_emotions": ["down", "content"]
}
```

**Example 3: Positive experience**
```json
{
  "story_text": "I finally finished the project I've been working on for months! The team celebrated together and my boss said it was excellent work. I feel like all the hard work paid off.",
  "feeling_category": "good",
  "selected_emotions": ["super_happy", "pumped", "content"]
}
```

#### 3.3 Success Response

**Status**: `200 OK`

```json
{
  "success": true,
  "data": {
    "image_data": "base64_encoded_png_string...",
    "image_format": "png",
    "image_size": {
      "width": 512,
      "height": 512
    },
    "prompt_used": "Simplified 2D infographic showing a person at microphone with surrounding icons representing anxiety, judgment, and preparation concerns...",
    "dominant_colors": ["#A8E6CF", "#FFE4A0", "#B0C4D4"],
    "story_analysis": {
      "central_stressor": "Company Annual Gala Performance",
      "factors": [
        {
          "factor": "Social Anxiety",
          "description": "Worry about performing in front of colleagues"
        },
        {
          "factor": "Fear of Judgment",
          "description": "Afraid of being mocked or criticized"
        },
        {
          "factor": "Perfectionism",
          "description": "Want to perform flawlessly"
        },
        {
          "factor": "Lack of Preparation",
          "description": "Feel under-practiced or unfamiliar with the song"
        }
      ],
      "language": "zh"
    },
    "generation_time_ms": 4200
  },
  "meta": {
    "timestamp": "2025-11-26T12:00:00Z",
    "api_version": "2.1"
  }
}
```

**Response Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `image_data` | string | Base64 encoded PNG image (cartoon/infographic style, no text labels) |
| `image_format` | string | Always "png" |
| `image_size.width` | integer | Image width in pixels |
| `image_size.height` | integer | Image height in pixels |
| `prompt_used` | string | The prompt sent to Gemini (for debugging) |
| `dominant_colors` | array | 3-4 hex color codes extracted from image (for firework animation) |
| `story_analysis` | object | AI-generated analysis of the user's story |
| `story_analysis.central_stressor` | string | The main situation/stressor identified |
| `story_analysis.factors` | array | List of emotional factors contributing to feelings |
| `story_analysis.factors[].factor` | string | Name of the emotional factor |
| `story_analysis.factors[].description` | string | Brief explanation of how this factor relates to the story |
| `story_analysis.language` | string | Detected dominant language code (e.g., "en", "zh") |
| `generation_time_ms` | integer | Time taken to generate image |

**Image Style Guidelines**:
- **Minimalist 2D cartoon** style (clean, simple, not detailed)
- **Symmetrical composition** - balanced layout with central focus
- Central icon representing the main stressor/situation (positioned in center)
- Surrounding icons representing psychological factors (arranged symmetrically around center)
- Clean lines, minimal detail, flat design
- Connected with simple lines (mind-map style)
- NO text labels in the image itself
- Soft, appropriate colors based on emotional tone
- White or light neutral background

**Example Composition**:
```
        [Factor 1]          [Factor 2]
              \                /
               \              /
                [  Central   ]
                [ Stressor   ]
               /              \
              /                \
        [Factor 3]          [Factor 4]
```

#### 3.4 Error Responses

**400 Bad Request - Text Too Short**
```json
{
  "success": false,
  "error": {
    "code": "TEXT_TOO_SHORT",
    "message": "Please share more about your feelings",
    "details": {
      "field": "story_text",
      "min_length": 50,
      "actual_length": 32
    }
  },
  "meta": {
    "timestamp": "2025-11-26T12:00:00Z"
  }
}
```

**400 Bad Request - Missing Emotions**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Selected emotions are required to understand your story",
    "details": {
      "field": "selected_emotions",
      "reason": "missing_required_field"
    }
  },
  "meta": {
    "timestamp": "2025-11-26T12:00:00Z"
  }
}
```

(Other error responses same as /feeling endpoint: 503 Service Unavailable, 504 Gateway Timeout)

---

## 4. Health Check

### GET /api/v1/visualizations/health

Check the health status of the visualization service and its dependencies.

#### 3.1 Success Response

**Status**: `200 OK`

```json
{
  "status": "healthy",
  "checks": {
    "gemini_api": {
      "status": "healthy",
      "latency_ms": 150
    }
  },
  "timestamp": "2025-11-26T12:00:00Z"
}
```

#### 3.2 Degraded Response

**Status**: `200 OK`

```json
{
  "status": "degraded",
  "checks": {
    "gemini_api": {
      "status": "unhealthy",
      "error": "Connection timeout"
    }
  },
  "timestamp": "2025-11-26T12:00:00Z"
}
```

---

## 5. Valid Emotion IDs

The following emotion IDs are accepted in the `selected_emotions` array:

### Positive Emotions (feeling_category: "good")

| ID | Display Name | Description |
|----|--------------|-------------|
| `super_happy` | Super happy | Extremely joyful, elated |
| `pumped` | Pumped | Excited, energized |
| `cozy` | Cozy | Comfortable, warm feeling |
| `chill` | Chill | Relaxed, at ease |
| `content` | Content | Satisfied, peaceful |

### Negative Emotions (feeling_category: "bad")

| ID | Display Name | Description |
|----|--------------|-------------|
| `fuming` | Fuming | Very angry, seething |
| `freaked_out` | Freaked out | Anxious, panicked |
| `mad_as_hell` | Mad as hell | Extremely angry |
| `blah` | Blah | Unmotivated, flat |
| `down` | Down | Sad, low mood |
| `bored_stiff` | Bored stiff | Extremely bored |

---

## 6. iOS Integration

### 6.1 Swift Request Models

**Feeling Visualization Request**:
```swift
struct FeelingVisualizationRequest: Codable {
    let feelingCategory: String
    let selectedEmotions: [String]

    enum CodingKeys: String, CodingKey {
        case feelingCategory = "feeling_category"
        case selectedEmotions = "selected_emotions"
    }
}
```

**Story Visualization Request**:
```swift
struct StoryVisualizationRequest: Codable {
    let storyText: String
    let feelingCategory: String
    let selectedEmotions: [String]

    enum CodingKeys: String, CodingKey {
        case storyText = "story_text"
        case feelingCategory = "feeling_category"
        case selectedEmotions = "selected_emotions"
    }
}
```

### 6.2 Swift Response Models

**Feeling Visualization Response** (from `/feeling` endpoint):
```swift
struct FeelingVisualizationResponse: Codable {
    let success: Bool
    let data: FeelingVisualizationData?
    let error: APIError?
    let meta: ResponseMeta?

    struct FeelingVisualizationData: Codable {
        let imageData: String
        let imageFormat: String
        let imageSize: ImageSize
        let promptUsed: String
        let dominantColors: [String]
        let generationTimeMs: Int

        enum CodingKeys: String, CodingKey {
            case imageData = "image_data"
            case imageFormat = "image_format"
            case imageSize = "image_size"
            case promptUsed = "prompt_used"
            case dominantColors = "dominant_colors"
            case generationTimeMs = "generation_time_ms"
        }
    }
}
```

**Story Visualization Response** (from `/story` endpoint):
```swift
struct StoryVisualizationResponse: Codable {
    let success: Bool
    let data: StoryVisualizationData?
    let error: APIError?
    let meta: ResponseMeta?

    struct StoryVisualizationData: Codable {
        let imageData: String
        let imageFormat: String
        let imageSize: ImageSize
        let promptUsed: String
        let dominantColors: [String]
        let storyAnalysis: StoryAnalysis
        let generationTimeMs: Int

        enum CodingKeys: String, CodingKey {
            case imageData = "image_data"
            case imageFormat = "image_format"
            case imageSize = "image_size"
            case promptUsed = "prompt_used"
            case dominantColors = "dominant_colors"
            case storyAnalysis = "story_analysis"
            case generationTimeMs = "generation_time_ms"
        }
    }

    struct StoryAnalysis: Codable {
        let centralStressor: String
        let factors: [EmotionalFactor]
        let language: String

        enum CodingKeys: String, CodingKey {
            case centralStressor = "central_stressor"
            case factors
            case language
        }
    }

    struct EmotionalFactor: Codable {
        let factor: String
        let description: String
    }
}
```

**Shared Types**:
```swift
struct ImageSize: Codable {
    let width: Int
    let height: Int
}

struct ResponseMeta: Codable {
    let timestamp: String
    let apiVersion: String

    enum CodingKeys: String, CodingKey {
        case timestamp
        case apiVersion = "api_version"
    }
}

struct APIError: Codable {
    let code: String
    let message: String
    let details: [String: AnyCodable]?
}
```

### 6.3 Converting Base64 to UIImage

```swift
extension String {
    func toUIImage() -> UIImage? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return UIImage(data: data)
    }
}

// Usage
if let imageData = response.data?.imageData,
   let image = imageData.toUIImage() {
    // Display image
}
```

### 6.4 Converting Dominant Colors for Firework Animation

```swift
extension String {
    func toColor() -> Color? {
        var hex = self.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")

        guard hex.count == 6,
              let rgbValue = UInt64(hex, radix: 16) else { return nil }

        return Color(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}

// Usage - extract colors for firework animation
let fireworkColors = response.data?.dominantColors.compactMap { $0.toColor() } ?? []
```

---

## 7. Rate Limiting (Future)

> **Note**: Rate limiting is not implemented in MVP but planned for future.

**Planned Limits**:
- Anonymous users: 10 requests per hour per IP
- Authenticated users: 50 requests per hour

**Response Headers** (future):
```
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 7
X-RateLimit-Reset: 1700000000
```

---

## 8. Testing with curl

```bash
# Generate feeling visualization (abstract art from emotions)
curl -X POST http://localhost:8000/api/v1/visualizations/feeling \
  -H "Content-Type: application/json" \
  -d '{
    "feeling_category": "good",
    "selected_emotions": ["cozy", "content"]
  }'

# Generate feeling visualization with negative emotions
curl -X POST http://localhost:8000/api/v1/visualizations/feeling \
  -H "Content-Type: application/json" \
  -d '{
    "feeling_category": "bad",
    "selected_emotions": ["fuming", "down"]
  }'

# Generate story visualization (cartoon from text + emotions)
curl -X POST http://localhost:8000/api/v1/visualizations/story \
  -H "Content-Type: application/json" \
  -d '{
    "story_text": "I had a really tough day at work. My manager criticized my presentation in front of everyone, and I felt so embarrassed. But my colleague came to support me afterwards which made me feel a bit better.",
    "feeling_category": "not_sure",
    "selected_emotions": ["down", "content"]
  }'

# Health check
curl http://localhost:8000/api/v1/visualizations/health
```

---

## 9. OpenAPI Schema

The endpoints will be documented in OpenAPI format at `/docs` when the backend is running.

```yaml
paths:
  /api/v1/visualizations/feeling:
    post:
      summary: Generate feeling visualization
      description: Generate abstract art based on selected emotions
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/FeelingVisualizationRequest'
      responses:
        '200':
          description: Successfully generated feeling visualization
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/VisualizationResponse'
        '400':
          description: Validation error
        '503':
          description: Generation service unavailable
        '504':
          description: Generation timeout

  /api/v1/visualizations/story:
    post:
      summary: Generate story visualization
      description: Generate 2D cartoon illustrating the story behind feelings
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/StoryVisualizationRequest'
      responses:
        '200':
          description: Successfully generated story visualization
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/VisualizationResponse'
        '400':
          description: Validation error
        '503':
          description: Generation service unavailable
        '504':
          description: Generation timeout
```
