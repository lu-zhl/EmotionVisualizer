import Foundation
import SwiftUI

// MARK: - App State
enum DrawMyFeelingsState: Equatable {
    case initial                    // Showing Cloud #0
    case inputMode                  // Showing Cloud #1 and Cloud #2 (Cloud #2 shows summary if selections exist)
    case questionnaire(level: Int)  // In questionnaire flow (level 1 or 2)
    case generating                 // Creating visualization
    case result                     // Showing generated image
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

// MARK: - Combined Input
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

// MARK: - Generated Visualization Result
struct GeneratedVisualization: Identifiable, Equatable {
    let id: UUID
    let imageData: Data?
    let imageURL: String?
    let prompt: String
    let createdAt: Date

    init(id: UUID = UUID(), imageData: Data? = nil, imageURL: String? = nil, prompt: String, createdAt: Date = Date()) {
        self.id = id
        self.imageData = imageData
        self.imageURL = imageURL
        self.prompt = prompt
        self.createdAt = createdAt
    }
}
