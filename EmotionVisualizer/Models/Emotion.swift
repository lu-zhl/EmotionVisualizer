import Foundation

enum Emotion: String, Codable, CaseIterable, Identifiable {
    case joy
    case sadness
    case anger
    case fear
    case disgust
    case surprise
    case anxiety
    case contentment
    case frustration
    case excitement
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: String {
        switch self {
        case .joy: return "yellow"
        case .sadness: return "blue"
        case .anger: return "red"
        case .fear: return "purple"
        case .disgust: return "green"
        case .surprise: return "orange"
        case .anxiety: return "gray"
        case .contentment: return "mint"
        case .frustration: return "brown"
        case .excitement: return "pink"
        }
    }
    
    var icon: String {
        switch self {
        case .joy: return "face.smiling"
        case .sadness: return "cloud.rain"
        case .anger: return "flame"
        case .fear: return "exclamationmark.triangle"
        case .disgust: return "hand.raised"
        case .surprise: return "sparkles"
        case .anxiety: return "wind"
        case .contentment: return "heart"
        case .frustration: return "exclamationmark.circle"
        case .excitement: return "star"
        }
    }
}
