import Foundation

enum APIConfig {
    /// Production Vercel backend. Override via Info.plist `ELSEWHERE_API_BASE_URL` for local dev.
    static var baseURL: URL {
        if let override = Bundle.main.object(forInfoDictionaryKey: "ELSEWHERE_API_BASE_URL") as? String,
           let url = URL(string: override.trimmingCharacters(in: CharacterSet(charactersIn: "/"))),
           !override.isEmpty {
            return url
        }
        return URL(string: "https://elsewhere-backend.vercel.app")!
    }

    // MARK: - Endpoint URLs

    static var soundCandidatesURL: URL {
        baseURL.appendingPathComponent("api/sound-candidates")
    }

    static var libraryURL: URL {
        baseURL.appendingPathComponent("api/library")
    }

    static func libraryItemURL(id: String) -> URL {
        baseURL.appendingPathComponent("api/library/\(id)")
    }

    static var appleSignInURL: URL {
        baseURL.appendingPathComponent("api/auth/apple")
    }

    static var refreshTokenURL: URL {
        baseURL.appendingPathComponent("api/auth/refresh")
    }

    // MARK: - Auth helpers (used by AuthService before APIClient exists)

    struct AuthResponse: Decodable {
        let accessToken: String
        let refreshToken: String
        let user: UserResponse
    }

    struct UserResponse: Decodable {
        let id: String
        let displayName: String?
    }

    struct RefreshResponse: Decodable {
        let accessToken: String
        let refreshToken: String
    }

    static func performAppleSignIn(
        identityToken: String,
        givenName: String?,
        familyName: String?
    ) async throws -> AuthUser {
        var request = URLRequest(url: appleSignInURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = ["identityToken": identityToken]
        var fullName: [String: String] = [:]
        if let g = givenName  { fullName["givenName"]  = g }
        if let f = familyName { fullName["familyName"] = f }
        if !fullName.isEmpty  { body["fullName"] = fullName }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
               let errorMsg = json["error"] {
                throw AuthError.serverError(errorMsg)
            }
            throw AuthError.serverError("Sign-in request failed")
        }

        let decoded = try JSONDecoder().decode(AuthResponse.self, from: data)
        KeychainService.set(decoded.accessToken,  for: .accessToken)
        KeychainService.set(decoded.refreshToken, for: .refreshToken)
        KeychainService.set(decoded.user.id,      for: .userId)
        if let name = decoded.user.displayName {
            KeychainService.set(name, for: .displayName)
        }

        return AuthUser(id: decoded.user.id, displayName: decoded.user.displayName)
    }

    static func performRefresh(refreshToken: String) async throws -> RefreshResponse {
        var request = URLRequest(url: refreshTokenURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["refreshToken": refreshToken])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw AuthError.serverError("Token refresh failed")
        }
        return try JSONDecoder().decode(RefreshResponse.self, from: data)
    }
}
