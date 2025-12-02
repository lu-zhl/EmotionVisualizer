import SwiftUI

struct DrawMyFeelingsView: View {
    @StateObject private var viewModel = DrawMyFeelingsViewModel()
    @State private var showFireworks = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient.screenBackground
                .ignoresSafeArea()

            // Main content based on state
            contentView
                .animation(.dmfEmphasis, value: viewModel.state)

            // Generating overlays
            if viewModel.state == .generatingFeeling {
                GeneratingView(
                    message: "Drawing your feelings...",
                    onCancel: viewModel.cancelGeneration
                )
                .transition(.opacity)
            }

            if viewModel.state == .generatingStory {
                GeneratingView(
                    message: "Analyzing your mood...",
                    onCancel: viewModel.cancelGeneration
                )
                .transition(.opacity)
            }

            // Firework overlay
            if showFireworks {
                FireworkView(colors: viewModel.currentVisualizationColors)
                    .allowsHitTesting(false)
            }

            // Error overlay
            if viewModel.showError, let errorMessage = viewModel.errorMessage {
                ErrorView(
                    message: errorMessage,
                    onRetry: {
                        Task { await viewModel.retryGeneration() }
                    },
                    onStartOver: viewModel.startOver
                )
                .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .initial:
            initialView

        case .questionnaireLevel1:
            level1QuestionnaireView

        case .questionnaireLevel2:
            level2QuestionnaireView

        case .generatingFeeling, .generatingStory:
            // Handled by overlay
            Color.clear

        case .feelingResult:
            feelingResultView

        case .freeTextInput:
            freeTextInputView

        case .storyResult:
            storyResultView
        }
    }

    // MARK: - Initial View (Cloud #0)

    private var initialView: some View {
        VStack {
            Spacer()

            InitialCloudView(onTap: viewModel.tapCloud0)
                .transition(.scale.combined(with: .opacity))

            Spacer()
        }
    }

    // MARK: - Questionnaire Views

    private var level1QuestionnaireView: some View {
        Level1QuestionnaireView(
            onSelectCategory: viewModel.selectCategory,
            onBack: viewModel.goBack,
            onStartOver: viewModel.startOver
        )
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    private var level2QuestionnaireView: some View {
        Level2EmotionsView(
            emotions: viewModel.availableEmotions,
            selectedEmotions: viewModel.journeyData.selectedEmotions,
            onToggleEmotion: viewModel.toggleEmotion,
            onDone: {
                Task { await viewModel.generateFeelingVisualization() }
            },
            onBack: viewModel.goBack,
            onStartOver: viewModel.startOver
        )
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: - Feeling Result View

    private var feelingResultView: some View {
        FeelingResultView(
            visualization: viewModel.feelingVisualization,
            summaryText: viewModel.journeyData.summaryText,
            onCelebrate: triggerFirework,
            onKnowMore: viewModel.goToFreeTextInput,
            onStartOver: viewModel.startOver
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - Free Text Input View

    private var freeTextInputView: some View {
        FreeTextInputView(
            text: $viewModel.journeyData.storyText,
            characterCount: viewModel.journeyData.storyCharacterCount,
            minCharacters: UserJourneyData.minStoryLength,
            maxCharacters: UserJourneyData.maxStoryLength,
            canSubmit: viewModel.journeyData.canDrawStory,
            onDrawStory: {
                Task { await viewModel.generateStoryVisualization() }
            },
            onStartOver: viewModel.startOver
        )
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: - Story Result View

    private var storyResultView: some View {
        StoryResultView(
            visualization: viewModel.storyVisualization,
            onCelebrate: triggerFirework,
            onStartOver: viewModel.startOver
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - Firework Animation

    private func triggerFirework() {
        viewModel.celebrateFeelings()
        showFireworks = true

        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showFireworks = false
        }
    }
}

#Preview {
    DrawMyFeelingsView()
}
