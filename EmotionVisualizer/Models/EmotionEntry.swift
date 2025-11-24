import Foundation

struct EmotionEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let timestamp: Date
    let situation: String
    let emotions: [Emotion]
    let intensity: Double
    let notes: String
    var visualizationURL: String?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        situation: String,
        emotions: [Emotion],
        intensity: Double,
        notes: String = "",
        visualizationURL: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.situation = situation
        self.emotions = emotions
        self.intensity = intensity
        self.notes = notes
        self.visualizationURL = visualizationURL
    }
}

extension EmotionEntry {
    static var sampleEntries: [EmotionEntry] {
        [
            EmotionEntry(
                timestamp: Date().addingTimeInterval(-86400),
                situation: "Morning presentation at work",
                emotions: [.anxiety, .excitement],
                intensity: 0.7,
                notes: "Big presentation coming up"
            ),
            EmotionEntry(
                timestamp: Date().addingTimeInterval(-172800),
                situation: "Argument with friend",
                emotions: [.anger, .frustration, .sadness],
                intensity: 0.85,
                notes: "Disagreement about plans"
            ),
            EmotionEntry(
                timestamp: Date().addingTimeInterval(-259200),
                situation: "Completed project",
                emotions: [.joy, .contentment],
                intensity: 0.9,
                notes: "Finished ahead of schedule"
            )
        ]
    }
}
