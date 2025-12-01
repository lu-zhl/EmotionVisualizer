import Foundation
import SwiftUI

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int, String)
    case unauthorized
}

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T
}

struct TokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let user: UserInfo

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case user
    }
}

struct UserInfo: Decodable {
    let id: String
    let email: String
    let name: String
}

struct EntryResponse: Decodable {
    let entry: EmotionEntryData
}

struct EmotionEntryData: Decodable {
    let id: String
    let situation: String
    let emotions: [String]
    let intensity: Double
    let notes: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, situation, emotions, intensity, notes
        case createdAt = "created_at"
    }
}

class APIService {
    static let shared = APIService()

    // Use localhost for iOS simulator, or your machine's IP for physical device
    private let baseURL = "http://localhost:8000/api/v1"
    private var accessToken: String?

    private init() {}

    // MARK: - Authentication

    func register(email: String, password: String, name: String) async throws -> TokenResponse {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "email": email,
            "password": password,
            "name": name
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "", code: 0))
        }

        guard httpResponse.statusCode == 201 else {
            throw APIError.serverError(httpResponse.statusCode, "Registration failed")
        }

        let apiResponse = try JSONDecoder().decode(APIResponse<TokenResponse>.self, from: data)
        self.accessToken = apiResponse.data.accessToken
        return apiResponse.data
    }

    func login(email: String, password: String) async throws -> TokenResponse {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "", code: 0))
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode, "Login failed")
        }

        let apiResponse = try JSONDecoder().decode(APIResponse<TokenResponse>.self, from: data)
        self.accessToken = apiResponse.data.accessToken
        return apiResponse.data
    }

    // MARK: - Emotion Entries

    func createEntry(situation: String, emotions: [String], intensity: Double, notes: String) async throws -> EmotionEntryData {
        guard let token = accessToken else {
            throw APIError.unauthorized
        }

        let url = URL(string: "\(baseURL)/entries")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "situation": situation,
            "emotions": emotions,
            "intensity": intensity,
            "notes": notes
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "", code: 0))
        }

        guard httpResponse.statusCode == 201 else {
            throw APIError.serverError(httpResponse.statusCode, "Failed to create entry")
        }

        let apiResponse = try JSONDecoder().decode(APIResponse<EntryResponse>.self, from: data)
        return apiResponse.data.entry
    }

    // For testing
    func testConnection() async throws -> Bool {
        let url = URL(string: "http://localhost:8000/health")!
        let (_, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }

        return httpResponse.statusCode == 200
    }

    // MARK: - Visualization (Version 2.1)

    func generateFeelingVisualization(feelingCategory: String, selectedEmotions: [String]) async throws -> FeelingVisualizationResponse {
        let url = URL(string: "\(baseURL)/visualizations/feeling")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        let body: [String: Any] = [
            "feeling_category": feelingCategory,
            "selected_emotions": selectedEmotions
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        }

        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(FeelingVisualizationAPIResponse.self, from: data)

        guard apiResponse.success, let responseData = apiResponse.data else {
            throw APIError.serverError(500, apiResponse.error?.message ?? "Failed to generate visualization")
        }

        return responseData
    }

    func generateStoryVisualization(storyText: String, feelingCategory: String, selectedEmotions: [String]) async throws -> StoryVisualizationResponse {
        let url = URL(string: "\(baseURL)/visualizations/story")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 90  // Longer timeout for story analysis

        let body: [String: Any] = [
            "story_text": storyText,
            "feeling_category": feelingCategory,
            "selected_emotions": selectedEmotions
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        }

        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(StoryVisualizationAPIResponse.self, from: data)

        guard apiResponse.success, let responseData = apiResponse.data else {
            throw APIError.serverError(500, apiResponse.error?.message ?? "Failed to generate visualization")
        }

        return responseData
    }

    // Legacy method for backwards compatibility
    func generateVisualization(freeText: String?, feelingCategory: String?, selectedEmotions: [String]?) async throws -> FeelingVisualizationResponse {
        // Use the new feeling endpoint
        return try await generateFeelingVisualization(
            feelingCategory: feelingCategory ?? "not_sure",
            selectedEmotions: selectedEmotions ?? []
        )
    }
}

// MARK: - Visualization Response Models (Version 2.1)

// Shared types
struct ImageSize: Decodable {
    let width: Int
    let height: Int
}

struct VisualizationError: Decodable {
    let code: String
    let message: String
    let details: [String: String]?
}

struct VisualizationMeta: Decodable {
    let timestamp: String
    let apiVersion: String?

    enum CodingKeys: String, CodingKey {
        case timestamp
        case apiVersion = "api_version"
    }
}

// MARK: - Feeling Visualization Response (from /feeling endpoint)

struct FeelingVisualizationAPIResponse: Decodable {
    let success: Bool
    let data: FeelingVisualizationResponse?
    let error: VisualizationError?
    let meta: VisualizationMeta
}

struct FeelingVisualizationResponse: Decodable {
    let imageData: String
    let imageFormat: String
    let imageSize: ImageSize
    let promptUsed: String
    let dominantColors: [String]
    let generationTimeMs: Int

    enum CodingKeys: String, CodingKey {
        case imageData = "image_data"
        case imageFormat = "image_format"
        case imageSize = "image_size"
        case promptUsed = "prompt_used"
        case dominantColors = "dominant_colors"
        case generationTimeMs = "generation_time_ms"
    }
}

// MARK: - Story Visualization Response (from /story endpoint)

struct StoryVisualizationAPIResponse: Decodable {
    let success: Bool
    let data: StoryVisualizationResponse?
    let error: VisualizationError?
    let meta: VisualizationMeta
}

struct StoryVisualizationResponse: Decodable {
    let imageData: String
    let imageFormat: String
    let imageSize: ImageSize
    let promptUsed: String
    let dominantColors: [String]
    let storyAnalysis: StoryAnalysis
    let generationTimeMs: Int

    enum CodingKeys: String, CodingKey {
        case imageData = "image_data"
        case imageFormat = "image_format"
        case imageSize = "image_size"
        case promptUsed = "prompt_used"
        case dominantColors = "dominant_colors"
        case storyAnalysis = "story_analysis"
        case generationTimeMs = "generation_time_ms"
    }
}

struct StoryAnalysis: Decodable {
    let centralStressor: String
    let factors: [EmotionalFactor]
    let language: String

    enum CodingKeys: String, CodingKey {
        case centralStressor = "central_stressor"
        case factors
        case language
    }
}

struct EmotionalFactor: Decodable {
    let factor: String
    let description: String
}

// Legacy alias for backwards compatibility
typealias VisualizationResponse = FeelingVisualizationResponse

// MARK: - Color Conversion Extension

extension String {
    func toColor() -> Color? {
        var hex = self.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")

        guard hex.count == 6,
              let rgbValue = UInt64(hex, radix: 16) else { return nil }

        return Color(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}
