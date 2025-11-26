import Foundation
import SwiftUI
import UIKit

@MainActor
class DrawMyFeelingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var state: DrawMyFeelingsState = .initial
    @Published var input: EmotionInput = EmotionInput()
    @Published var currentCloudIndex: Int = 0  // 0 = Cloud #1, 1 = Cloud #2
    @Published var generatedVisualization: GeneratedVisualization?
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // MARK: - Constants
    let maxCharacterCount = 5000
    let warningCharacterThreshold = 4500

    // MARK: - Computed Properties
    var canGenerateVisualization: Bool {
        input.hasValidInput
    }

    var characterCount: Int {
        input.freeText.count
    }

    var isNearCharacterLimit: Bool {
        characterCount > warningCharacterThreshold
    }

    var hasQuestionnaireSelections: Bool {
        !input.selectedEmotions.isEmpty
    }

    var hasFreeText: Bool {
        !input.freeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var availableEmotions: [DMFEmotion] {
        guard let category = input.feelingCategory else { return [] }
        return DMFEmotion.emotions(for: category)
    }

    // MARK: - State Transitions

    func enterInputMode() {
        withAnimation(.dmfEmphasis) {
            state = .inputMode
        }
        triggerHaptic(.light)
    }

    func startQuestionnaire() {
        withAnimation(.dmfStandard) {
            state = .questionnaire(level: 1)
        }
        triggerHaptic(.light)
    }

    func selectCategory(_ category: FeelingCategory) {
        input.feelingCategory = category
        withAnimation(.dmfStandard) {
            state = .questionnaire(level: 2)
        }
        triggerHaptic(.light)
    }

    func toggleEmotion(_ emotion: DMFEmotion) {
        if input.selectedEmotions.contains(emotion.id) {
            input.selectedEmotions.remove(emotion.id)
        } else {
            input.selectedEmotions.insert(emotion.id)
        }
        triggerHaptic(.light)
    }

    func isEmotionSelected(_ emotion: DMFEmotion) -> Bool {
        input.selectedEmotions.contains(emotion.id)
    }

    func finishQuestionnaire() {
        // Go back to input mode with summary displayed on Cloud #2
        withAnimation(.dmfStandard) {
            state = .inputMode
            currentCloudIndex = 1  // Show questionnaire cloud with summary
        }
        triggerHaptic(.success)
    }

    func modifySelections() {
        // Re-enter questionnaire at Level 2 to modify selections
        withAnimation(.dmfStandard) {
            state = .questionnaire(level: 2)
        }
        triggerHaptic(.light)
    }

    func goBackInQuestionnaire() {
        switch state {
        case .questionnaire(level: 2):
            // Go back to level 1, clear level 2 selections
            input.selectedEmotions = []
            withAnimation(.dmfStandard) {
                state = .questionnaire(level: 1)
            }
        case .questionnaire(level: 1):
            // Exit questionnaire back to input mode
            withAnimation(.dmfStandard) {
                state = .inputMode
            }
        default:
            break
        }
        triggerHaptic(.light)
    }

    func startOver() {
        withAnimation(.dmfEmphasis) {
            input.reset()
            generatedVisualization = nil
            errorMessage = nil
            currentCloudIndex = 0
            state = .initial
        }
        triggerHaptic(.light)
    }

    func swipeToCloud(at index: Int) {
        withAnimation(.dmfSpringy) {
            currentCloudIndex = max(0, min(1, index))
        }
    }

    // MARK: - Visualization Generation

    func generateVisualization() async {
        guard canGenerateVisualization else { return }

        withAnimation(.dmfStandard) {
            state = .generating
        }
        triggerHaptic(.light)

        // Build prompt from inputs
        let prompt = buildPrompt()

        do {
            // Simulate API call (in future, this will call actual backend)
            try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds

            // Create mock visualization result
            let visualization = GeneratedVisualization(
                imageURL: "placeholder_visualization",
                prompt: prompt
            )

            withAnimation(.dmfGentle) {
                generatedVisualization = visualization
                state = .result
            }
            triggerHaptic(.success)
        } catch {
            withAnimation(.dmfStandard) {
                errorMessage = "Oops! We couldn't create your visualization."
                showError = true
                state = .inputMode
            }
            triggerHaptic(.error)
        }
    }

    func cancelGeneration() {
        withAnimation(.dmfStandard) {
            state = .inputMode
        }
    }

    func retryGeneration() async {
        showError = false
        errorMessage = nil
        await generateVisualization()
    }

    // MARK: - Private Helpers

    private func buildPrompt() -> String {
        var promptParts: [String] = []

        if hasFreeText {
            promptParts.append("User describes feeling: \"\(input.freeText)\"")
        }

        if let category = input.feelingCategory {
            promptParts.append("General mood: \(category.displayName)")
        }

        if !input.selectedEmotions.isEmpty {
            let emotionNames = input.selectedEmotionsList.map { $0.displayName }.joined(separator: ", ")
            promptParts.append("Specific emotions: \(emotionNames)")
        }

        return promptParts.joined(separator: ". ")
    }

    private func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
