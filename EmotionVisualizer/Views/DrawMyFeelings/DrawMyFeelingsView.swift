import SwiftUI

struct DrawMyFeelingsView: View {
    @StateObject private var viewModel = DrawMyFeelingsViewModel()

    var body: some View {
        ZStack {
            // Background
            LinearGradient.screenBackground
                .ignoresSafeArea()

            // Main content based on state
            contentView
                .animation(.dmfEmphasis, value: viewModel.state)

            // Generating overlay
            if viewModel.state == .generating {
                GeneratingView(onCancel: viewModel.cancelGeneration)
                    .transition(.opacity)
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

        case .inputMode:
            inputModeView

        case .questionnaire(let level):
            if level == 1 {
                level1QuestionnaireView
            } else {
                level2QuestionnaireView
            }

        case .generating:
            // Handled by overlay
            Color.clear

        case .result:
            resultView
        }
    }

    // MARK: - Initial View (Cloud #0)

    private var initialView: some View {
        VStack {
            Spacer()

            InitialCloudView(onTap: viewModel.enterInputMode)
                .transition(.scale.combined(with: .opacity))

            Spacer()
        }
    }

    // MARK: - Input Mode View

    private var inputModeView: some View {
        VStack(spacing: 0) {
            // Navigation bar with Start Over
            HStack {
                Button(action: viewModel.startOver) {
                    HStack(spacing: DMFSpacing.xxs) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16))
                        Text("Start over")
                            .font(.dmfButtonSmall)
                    }
                    .foregroundColor(.textSecondary)
                }

                Spacer()
            }
            .padding(.horizontal, DMFSpacing.lg)
            .padding(.top, DMFSpacing.md)

            Spacer()

            // Cloud carousel
            CloudCarousel(
                freeText: $viewModel.input.freeText,
                currentIndex: $viewModel.currentCloudIndex,
                maxCharacters: viewModel.maxCharacterCount,
                warningThreshold: viewModel.warningCharacterThreshold,
                hasFreeTextContent: viewModel.hasFreeText,
                hasQuestionnaireSelections: viewModel.hasQuestionnaireSelections,
                selectedEmotions: viewModel.input.selectedEmotionsList,
                onStartQuestionnaire: viewModel.startQuestionnaire,
                onModifySelections: viewModel.modifySelections
            )

            Spacer()

            // Draw my feelings button
            PrimaryActionButton(
                title: "Draw my feelings",
                isEnabled: viewModel.canGenerateVisualization,
                action: {
                    Task { await viewModel.generateVisualization() }
                }
            )
            .padding(.horizontal, DMFSpacing.lg)
            .padding(.bottom, DMFSpacing.lg)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Questionnaire Views

    private var level1QuestionnaireView: some View {
        Level1QuestionnaireView(
            onSelectCategory: viewModel.selectCategory,
            onBack: viewModel.goBackInQuestionnaire,
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
            selectedEmotions: viewModel.input.selectedEmotions,
            onToggleEmotion: viewModel.toggleEmotion,
            onDone: viewModel.finishQuestionnaire,
            onBack: viewModel.goBackInQuestionnaire,
            onStartOver: viewModel.startOver
        )
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: - Result View

    private var resultView: some View {
        VisualizationResultView(
            visualization: viewModel.generatedVisualization,
            onStartOver: viewModel.startOver
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

#Preview {
    DrawMyFeelingsView()
}
