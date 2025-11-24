# EmotionVisualizer (iOS)

> **Important Disclaimer:** EmotionVisualizer is a self-reflection and emotional awareness tool. It is **not** a medical device, nor does it offer diagnosis, treatment, or professional psychological advice. If you are in crisis or need mental health support, please consult a qualified professional immediately.

## 🧠 Project Overview

**EmotionVisualizer** is an iOS application designed to help users deconstruct complex emotional situations. By guiding users through a dynamic, AI-powered questionnaire, the app identifies root stressors. It then generates a concise summary of the situation and uses advanced visualization techniques to translate abstract psychological causes into tangible visual representations.

The goal is to provide users with a "mirror" for their mind, fostering self-awareness and offering a new perspective on things that bother them.

## ✨ Core Features

* **Dynamic Intake Flow:** Users start by briefly stating their bothering situation. The app uses the **Gemini API** to generate context-aware, multiple-choice follow-up scenarios, helping the user drill down to the specific reality of their problem without needing to type lengthy paragraphs.
* **AI-Powered Synthesis:** The backend utilizes Gemini to analyze the user's selections and generate a coherent summary of their current psychological landscape.
* **Causal Visualization:** The core of the app. The synthesized data is sent to the **Nano Banana Pro** visualization engine to generate unique visual metaphors or structured diagrams representing the "reasons" behind the user's stress.
* **Insight Journal:** Users can save past visualizations to track recurring patterns in their emotional responses over time.

## 🛠 Tech Stack

* **Client (iOS):** Swift, SwiftUI (targeting iOS 17.0+)
* **Architecture:** MVVM-C (Model-View-ViewModel-Coordinator)
* **Backend Orchestration:** (e.g., Python FastAPI / Node.js Express / Firebase Functions) - *To hold API keys securely.*
* **AI Logic:** Google Gemini API (assumed latest model, e.g., Gemini 1.5 Pro)
* **Visualization Engine:** Nano Banana Pro (External API/Service)

## 📐 High-Level Architecture Diagram

```mermaid
graph TD
    User[iOS Client] -->|1. Initial Input| Backend
    Backend -->|2. Prompt for Scenarios| GeminiAPI
    GeminiAPI -->|3. Return Choices| Backend
    Backend -->|4. Display Choices| User
    User -->|5. Selects Reality| Backend
    Backend -->|6. Request Summary & Analysis| GeminiAPI
    GeminiAPI -->|7. Return Structured Data| Backend
    Backend -->|8. Request Visualization| NanoBananaPro
    NanoBananaPro -->|9. Return Visual Assets| Backend
    Backend -->|10. Final View Result| User