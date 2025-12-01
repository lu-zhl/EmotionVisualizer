import Foundation
import SwiftUI
import UIKit

@MainActor
class DrawMyFeelingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var state: DrawMyFeelingsState = .initial
    @Published var journeyData: UserJourneyData = UserJourneyData()
    @Published var feelingVisualization: GeneratedVisualization?
    @Published var storyVisualization: GeneratedVisualization?
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // MARK: - Computed Properties
    var availableEmotions: [DMFEmotion] {
        guard let category = journeyData.feelingCategory else { return [] }
        return DMFEmotion.emotions(for: category)
    }

    var hasSelectedEmotions: Bool {
        !journeyData.selectedEmotions.isEmpty
    }

    var currentVisualizationColors: [Color] {
        switch state {
        case .feelingResult:
            return feelingVisualization?.dominantColors ?? []
        case .storyResult:
            return storyVisualization?.dominantColors ?? []
        default:
            return []
        }
    }

    // MARK: - State Transitions

    func tapCloud0() {
        withAnimation(.dmfEmphasis) {
            state = .questionnaireLevel1
        }
        triggerHaptic(.light)
    }

    func selectCategory(_ category: FeelingCategory) {
        journeyData.feelingCategory = category
        withAnimation(.dmfStandard) {
            state = .questionnaireLevel2
        }
        triggerHaptic(.light)
    }

    func toggleEmotion(_ emotion: DMFEmotion) {
        if journeyData.selectedEmotions.contains(emotion.id) {
            journeyData.selectedEmotions.remove(emotion.id)
        } else {
            journeyData.selectedEmotions.insert(emotion.id)
        }
        triggerHaptic(.light)
    }

    func isEmotionSelected(_ emotion: DMFEmotion) -> Bool {
        journeyData.selectedEmotions.contains(emotion.id)
    }

    func goBack() {
        switch state {
        case .questionnaireLevel2:
            journeyData.selectedEmotions = []
            withAnimation(.dmfStandard) {
                state = .questionnaireLevel1
            }
        case .questionnaireLevel1:
            withAnimation(.dmfStandard) {
                state = .initial
            }
        case .freeTextInput:
            withAnimation(.dmfStandard) {
                state = .feelingResult
            }
        default:
            break
        }
        triggerHaptic(.light)
    }

    func startOver() {
        withAnimation(.dmfEmphasis) {
            journeyData.reset()
            feelingVisualization = nil
            storyVisualization = nil
            errorMessage = nil
            state = .initial
        }
        triggerHaptic(.light)
    }

    // MARK: - Feeling Visualization

    func generateFeelingVisualization() async {
        guard journeyData.hasValidEmotions,
              let category = journeyData.feelingCategory else { return }

        withAnimation(.dmfStandard) {
            state = .generatingFeeling
        }
        triggerHaptic(.light)

        do {
            let response = try await APIService.shared.generateFeelingVisualization(
                feelingCategory: category.backendValue,
                selectedEmotions: journeyData.backendEmotions
            )

            guard let imageData = Data(base64Encoded: response.imageData) else {
                throw NSError(domain: "DrawMyFeelings", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode image"])
            }

            let colors = response.dominantColors.compactMap { $0.toColor() }

            let visualization = GeneratedVisualization(
                imageData: imageData,
                prompt: response.promptUsed,
                dominantColors: colors
            )

            withAnimation(.dmfGentle) {
                feelingVisualization = visualization
                state = .feelingResult
            }
            triggerHaptic(.success)
        } catch {
            print("Feeling visualization error: \(error)")
            withAnimation(.dmfStandard) {
                errorMessage = "Oops! We couldn't draw your feelings. Please try again."
                showError = true
                state = .questionnaireLevel2
            }
            triggerHaptic(.error)
        }
    }

    // MARK: - Story Visualization

    func goToFreeTextInput() {
        withAnimation(.dmfStandard) {
            state = .freeTextInput
        }
        triggerHaptic(.light)
    }

    func generateStoryVisualization() async {
        guard journeyData.canDrawStory,
              let category = journeyData.feelingCategory else { return }

        withAnimation(.dmfStandard) {
            state = .generatingStory
        }
        triggerHaptic(.light)

        do {
            let response = try await APIService.shared.generateStoryVisualization(
                storyText: journeyData.storyText,
                feelingCategory: category.backendValue,
                selectedEmotions: journeyData.backendEmotions
            )

            guard let imageData = Data(base64Encoded: response.imageData) else {
                throw NSError(domain: "DrawMyFeelings", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode image"])
            }

            let colors = response.dominantColors.compactMap { $0.toColor() }

            // Convert story analysis from API response
            let storyAnalysis = GeneratedStoryAnalysis(from: response.storyAnalysis)

            let visualization = GeneratedVisualization(
                imageData: imageData,
                prompt: response.promptUsed,
                dominantColors: colors,
                storyAnalysis: storyAnalysis
            )

            withAnimation(.dmfGentle) {
                storyVisualization = visualization
                state = .storyResult
            }
            triggerHaptic(.success)
        } catch {
            print("Story visualization error: \(error)")
            withAnimation(.dmfStandard) {
                errorMessage = "Oops! We couldn't understand your story. Please try again."
                showError = true
                state = .freeTextInput
            }
            triggerHaptic(.error)
        }
    }

    // MARK: - Celebrate Animation
    func celebrateFeelings() {
        triggerHaptic(.medium)
        // The actual firework animation is handled by the view
    }

    // MARK: - Cancel Generation
    func cancelGeneration() {
        withAnimation(.dmfStandard) {
            switch state {
            case .generatingFeeling:
                state = .questionnaireLevel2
            case .generatingStory:
                state = .freeTextInput
            default:
                break
            }
        }
    }

    // MARK: - Retry
    func retryGeneration() async {
        showError = false
        errorMessage = nil
        switch state {
        case .questionnaireLevel2:
            await generateFeelingVisualization()
        case .freeTextInput:
            await generateStoryVisualization()
        default:
            break
        }
    }

    // MARK: - Private Helpers

    private func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Legacy compatibility
extension DrawMyFeelingsViewModel {
    var input: EmotionInput {
        get {
            var emotionInput = EmotionInput()
            emotionInput.feelingCategory = journeyData.feelingCategory
            emotionInput.selectedEmotions = journeyData.selectedEmotions
            emotionInput.freeText = journeyData.storyText
            return emotionInput
        }
        set {
            journeyData.feelingCategory = newValue.feelingCategory
            journeyData.selectedEmotions = newValue.selectedEmotions
            journeyData.storyText = newValue.freeText
        }
    }

    var generatedVisualization: GeneratedVisualization? {
        feelingVisualization ?? storyVisualization
    }
}
