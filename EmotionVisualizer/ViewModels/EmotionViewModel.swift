import Foundation
import SwiftUI

@MainActor
class EmotionViewModel: ObservableObject {
    @Published var entries: [EmotionEntry] = []
    @Published var visualizations: [Visualization] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadSampleData()
    }
    
    func addEntry(_ entry: EmotionEntry) {
        entries.insert(entry, at: 0)
        entries.sort { $0.timestamp > $1.timestamp }
    }
    
    func deleteEntry(_ entry: EmotionEntry) {
        entries.removeAll { $0.id == entry.id }
    }
    
    func updateEntry(_ entry: EmotionEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            entries.sort { $0.timestamp > $1.timestamp }
        }
    }
    
    func generateVisualization(for entry: EmotionEntry) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            let visualization = Visualization(
                entryId: entry.id,
                imageURL: "placeholder_\(entry.id)",
                summary: generateSummary(for: entry),
                insights: generateInsights(for: entry)
            )
            
            visualizations.append(visualization)
            isLoading = false
        } catch {
            errorMessage = "Failed to generate visualization"
            isLoading = false
        }
    }
    
    private func generateSummary(for entry: EmotionEntry) -> String {
        let emotionNames = entry.emotions.map { $0.displayName }.joined(separator: ", ")
        let intensityDescription = entry.intensity > 0.7 ? "intense" : entry.intensity > 0.4 ? "moderate" : "mild"
        
        return "You're experiencing \(intensityDescription) feelings of \(emotionNames) related to '\(entry.situation)'."
    }
    
    private func generateInsights(for entry: EmotionEntry) -> [String] {
        var insights: [String] = []
        
        if entry.emotions.count > 3 {
            insights.append("You're experiencing multiple emotions simultaneously, which is normal in complex situations.")
        }
        
        if entry.intensity > 0.7 {
            insights.append("The intensity of your emotions is quite high. Consider taking some time for self-care.")
        }
        
        if entry.emotions.contains(.anxiety) && entry.emotions.contains(.excitement) {
            insights.append("Anxiety and excitement often go together as they share similar physiological responses.")
        }
        
        if entry.emotions.contains(.sadness) && entry.emotions.contains(.anger) {
            insights.append("Sadness and anger can be interrelated. Anger sometimes masks underlying sadness.")
        }
        
        insights.append("Remember, all emotions are valid and provide valuable information about your needs.")
        
        return insights
    }
    
    func getVisualization(for entryId: UUID) -> Visualization? {
        visualizations.first { $0.entryId == entryId }
    }
    
    private func loadSampleData() {
        entries = EmotionEntry.sampleEntries
    }
    
    func clearAllData() {
        entries.removeAll()
        visualizations.removeAll()
    }
}
