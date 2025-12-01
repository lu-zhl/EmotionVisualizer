import Foundation
import SwiftUI

// MARK: - App State (Version 2.0)
enum DrawMyFeelingsState: Equatable {
    case initial                    // Showing Cloud #0
    case questionnaireLevel1        // Choosing Good/Bad/Not Sure
    case questionnaireLevel2        // Selecting specific emotions
    case generatingFeeling          // Creating feeling visualization
    case feelingResult              // Showing feeling visualization
    case freeTextInput              // Entering story text
    case generatingStory            // Creating story visualization
    case storyResult                // Showing story visualization
}

// MARK: - Feeling Category
enum FeelingCategory: String, CaseIterable, Codable, Identifiable {
    case good
    case bad
    case notSure

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .good: return "Good"
        case .bad: return "Bad"
        case .notSure: return "Not Sure"
        }
    }

    var iconName: String {
        switch self {
        case .good: return "sun.max.fill"
        case .bad: return "cloud.rain.fill"
        case .notSure: return "questionmark.circle.fill"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .good: return "Good. Feeling positive. Button."
        case .bad: return "Bad. Feeling negative. Button."
        case .notSure: return "Not Sure. Uncertain feelings. Button."
        }
    }

    var backendValue: String {
        switch self {
        case .good: return "good"
        case .bad: return "bad"
        case .notSure: return "not_sure"
        }
    }
}

// MARK: - Emotion
struct DMFEmotion: Identifiable, Equatable, Codable, Hashable {
    let id: String
    let displayName: String
    let category: FeelingCategory
    let iconName: String
    let accentColorHex: String

    var accentColor: Color {
        Color(hex: accentColorHex)
    }

    var backendId: String {
        // Convert camelCase to snake_case for backend
        switch id {
        case "superHappy": return "super_happy"
        case "freakedOut": return "freaked_out"
        case "madAsHell": return "mad_as_hell"
        case "boredStiff": return "bored_stiff"
        default: return id.lowercased()
        }
    }

    static let allEmotions: [DMFEmotion] = [
        // Positive emotions
        DMFEmotion(id: "superHappy", displayName: "Super happy", category: .good,
                   iconName: "face.smiling.fill", accentColorHex: "FFE4A0"),
        DMFEmotion(id: "pumped", displayName: "Pumped", category: .good,
                   iconName: "bolt.fill", accentColorHex: "FFB5A0"),
        DMFEmotion(id: "cozy", displayName: "Cozy", category: .good,
                   iconName: "cup.and.saucer.fill", accentColorHex: "D4B896"),
        DMFEmotion(id: "chill", displayName: "Chill", category: .good,
                   iconName: "leaf.fill", accentColorHex: "A8E6CF"),
        DMFEmotion(id: "content", displayName: "Content", category: .good,
                   iconName: "heart.fill", accentColorHex: "D4C4E8"),

        // Negative emotions
        DMFEmotion(id: "fuming", displayName: "Fuming", category: .bad,
                   iconName: "flame.fill", accentColorHex: "E8A0A0"),
        DMFEmotion(id: "freakedOut", displayName: "Freaked out", category: .bad,
                   iconName: "exclamationmark.triangle.fill", accentColorHex: "C8A0E8"),
        DMFEmotion(id: "madAsHell", displayName: "Mad as hell", category: .bad,
                   iconName: "cloud.bolt.fill", accentColorHex: "E8B0A0"),
        DMFEmotion(id: "blah", displayName: "Blah", category: .bad,
                   iconName: "minus.circle.fill", accentColorHex: "B0C4D4"),
        DMFEmotion(id: "down", displayName: "Down", category: .bad,
                   iconName: "cloud.rain.fill", accentColorHex: "A0B8D4"),
        DMFEmotion(id: "boredStiff", displayName: "Bored stiff", category: .bad,
                   iconName: "moon.zzz.fill", accentColorHex: "D4D0C4"),
    ]

    static func emotions(for category: FeelingCategory) -> [DMFEmotion] {
        switch category {
        case .good:
            return allEmotions.filter { $0.category == .good }
        case .bad:
            return allEmotions.filter { $0.category == .bad }
        case .notSure:
            return allEmotions
        }
    }
}

// MARK: - User Journey Data (Version 2.0)
struct UserJourneyData: Equatable {
    // Questionnaire data
    var feelingCategory: FeelingCategory?
    var selectedEmotions: Set<String> = []

    // Story text
    var storyText: String = ""

    // Constants
    static let minStoryLength = 50
    static let maxStoryLength = 5000
    static let warningThreshold = 4500

    // Computed properties
    var hasValidEmotions: Bool {
        !selectedEmotions.isEmpty && feelingCategory != nil
    }

    var selectedEmotionsList: [DMFEmotion] {
        DMFEmotion.allEmotions.filter { selectedEmotions.contains($0.id) }
    }

    var backendEmotions: [String] {
        selectedEmotionsList.map { $0.backendId }
    }

    var summaryText: String {
        guard !selectedEmotions.isEmpty else { return "" }
        let emotionNames = selectedEmotionsList.map { $0.displayName.lowercased() }
        if emotionNames.count == 1 {
            return "I feel \(emotionNames[0])."
        } else if emotionNames.count == 2 {
            return "I feel \(emotionNames[0]) and \(emotionNames[1])."
        } else {
            let allButLast = emotionNames.dropLast().joined(separator: ", ")
            return "I feel \(allButLast) and \(emotionNames.last!)."
        }
    }

    var storyCharacterCount: Int {
        storyText.trimmingCharacters(in: .whitespacesAndNewlines).count
    }

    var canDrawStory: Bool {
        storyCharacterCount >= Self.minStoryLength
    }

    var isNearCharacterLimit: Bool {
        storyCharacterCount > Self.warningThreshold
    }

    var charactersNeeded: Int {
        max(0, Self.minStoryLength - storyCharacterCount)
    }

    mutating func reset() {
        feelingCategory = nil
        selectedEmotions = []
        storyText = ""
    }
}

// MARK: - Generated Visualization Result (Version 2.1)
struct GeneratedVisualization: Identifiable, Equatable {
    let id: UUID
    let imageData: Data?
    let prompt: String
    let dominantColors: [Color]
    let storyAnalysis: GeneratedStoryAnalysis?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        imageData: Data? = nil,
        prompt: String,
        dominantColors: [Color] = [],
        storyAnalysis: GeneratedStoryAnalysis? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.imageData = imageData
        self.prompt = prompt
        self.dominantColors = dominantColors
        self.storyAnalysis = storyAnalysis
        self.createdAt = createdAt
    }
}

// MARK: - Story Analysis Result (Version 2.1)
struct GeneratedStoryAnalysis: Equatable {
    let centralStressor: String
    let factors: [GeneratedEmotionalFactor]
    let language: String

    init(centralStressor: String, factors: [GeneratedEmotionalFactor], language: String) {
        self.centralStressor = centralStressor
        self.factors = factors
        self.language = language
    }

    init(from apiResponse: StoryAnalysis) {
        self.centralStressor = apiResponse.centralStressor
        self.factors = apiResponse.factors.map { GeneratedEmotionalFactor(from: $0) }
        self.language = apiResponse.language
    }
}

struct GeneratedEmotionalFactor: Equatable {
    let factor: String
    let description: String

    init(factor: String, description: String) {
        self.factor = factor
        self.description = description
    }

    init(from apiResponse: EmotionalFactor) {
        self.factor = apiResponse.factor
        self.description = apiResponse.description
    }
}

// MARK: - Legacy Support
struct EmotionInput: Equatable {
    var freeText: String = ""
    var feelingCategory: FeelingCategory?
    var selectedEmotions: Set<String> = []

    var hasValidInput: Bool {
        let hasText = !freeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasEmotions = !selectedEmotions.isEmpty
        return hasText || hasEmotions
    }

    var selectedEmotionsList: [DMFEmotion] {
        DMFEmotion.allEmotions.filter { selectedEmotions.contains($0.id) }
    }

    mutating func reset() {
        freeText = ""
        feelingCategory = nil
        selectedEmotions = []
    }
}
