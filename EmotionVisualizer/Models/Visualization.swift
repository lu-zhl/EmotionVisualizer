import Foundation

struct Visualization: Identifiable, Codable {
    let id: UUID
    let entryId: UUID
    let imageURL: String
    let summary: String
    let insights: [String]
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        entryId: UUID,
        imageURL: String,
        summary: String,
        insights: [String],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.entryId = entryId
        self.imageURL = imageURL
        self.summary = summary
        self.insights = insights
        self.createdAt = createdAt
    }
}

extension Visualization {
    static var sampleVisualization: Visualization {
        Visualization(
            entryId: UUID(),
            imageURL: "placeholder",
            summary: "Your emotional state reflects a complex mix of anticipation and concern.",
            insights: [
                "High energy emotions present",
                "Multiple conflicting feelings",
                "Stress related to performance"
            ]
        )
    }
}
