# EmotionVisualizer

An iOS application for visualizing and tracking emotions.

## Project Overview

This is an iOS application built with Swift and SwiftUI for emotion visualization and tracking. The project follows a documentation-first development methodology where comprehensive requirements and implementation plans guide the development process.

## Technology Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Platform**: iOS
- **Minimum iOS Version**: iOS 17.0+
- **Architecture**: MVVM (Model-View-ViewModel)

## Development Workflow

This project follows a **Documentation-First Methodology**:

### Directory Structure

```
EmotionVisualizer/
├── EmotionVisualizer/              # Main app source code
│   ├── App/                        # App entry point and configuration
│   ├── Views/                      # SwiftUI views
│   ├── Models/                     # Data models
│   ├── ViewModels/                 # View models
│   └── Resources/                  # Assets, colors, etc.
├── EmotionVisualizerTests/         # Unit tests
├── EmotionVisualizerUITests/       # UI tests
└── docs/                           # Documentation hub
    ├── organic/                    # Human-written organic requirements
    ├── <milestone-name>/
    │   ├── req/                    # Comprehensive requirements (by Documentation Writer)
    │   ├── impl/                   # Implementation documentation (by Coder)
    │   └── manual/                 # User manuals (for end-users and maintainers)
```

**Note**: Milestone names follow the pattern `<req-number>-<milestone-name>` where the req number comes from the organic requirement document (e.g., req002.md → `002-backend`)

### Development Roles

1. **Human**:
   - Writes organic requirements
   - Performs manual testing
   - Provides feedback to all agent-based roles

2. **Documentation Writer**:
   - Expands organic requirements into comprehensive documentation
   - Creates detailed specifications for the Coder
   - Must be a separate AI agent instance from Coder

3. **Coder**:
   - Reviews requirements and current codebase
   - Creates development plans
   - Implements features
   - Tests generated code
   - Delivers to Human for testing
   - Must be a separate AI agent instance from Documentation Writer

### Workflow Steps

1. **Human** writes organic requirement in markdown (`docs/organic/`)
2. **Documentation Writer** expands organic requirement into comprehensive markdown chapters (`docs/<milestone-name>/req/`)
3. **Coder** reviews knowledge and codebase, then:
   - Creates development plan
   - Executes plan and generates code
   - Tests the new code
   - Delivers to Human for testing
4. **Human** tests the updated features:
   - If requirement understanding issues: prompts Documentation Writer to revise
   - If technical issues: provides feedback to Coder (via vibecoding or organic docs)
5. **Iterate** through steps 1-4 until satisfactory result
6. **Commit** the code

## Development Setup

1. Open the project in Xcode 15+
2. Select your target device or simulator
3. Build and run (Cmd+R)

## Current Status

- Initial project structure implemented with MVVM architecture
- Core SwiftUI views created (Home, Intake, Journal, Visualization)
- Sample data and basic emotion tracking functionality
- Documentation workflow established (see docs/organic/req001.md)
