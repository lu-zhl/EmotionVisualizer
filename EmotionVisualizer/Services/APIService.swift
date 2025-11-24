import Foundation

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
}
