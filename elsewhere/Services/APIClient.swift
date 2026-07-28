import Foundation

/// Centralised HTTP client that attaches the Bearer token to every request
/// and transparently refreshes on a 401.
enum APIClient {
    // MARK: - Core request

    static func request(
        url: URL,
        method: String = "GET",
        body: Data? = nil,
        contentType: String = "application/json"
    ) async throws -> Data {
        var req = buildRequest(url: url, method: method, body: body, contentType: contentType)

        // First attempt
        var (data, response) = try await URLSession.shared.data(for: req)

        // On 401, refresh the token and retry once
        if let http = response as? HTTPURLResponse, http.statusCode == 401 {
            try await AuthService.shared.refreshTokens()
            req = buildRequest(url: url, method: method, body: body, contentType: contentType)
            (data, response) = try await URLSession.shared.data(for: req)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            if let json = try? JSONDecoder().decode(ErrorBody.self, from: data) {
                throw APIClientError.server(json.error)
            }
            throw APIClientError.server("Request failed (\(http.statusCode))")
        }

        return data
    }

    // MARK: - Private

    private static func buildRequest(
        url: URL,
        method: String,
        body: Data?,
        contentType: String
    ) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue(contentType, forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 120

        if let token = KeychainService.get(.accessToken) {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body { req.httpBody = body }
        return req
    }

    private struct ErrorBody: Decodable { let error: String }
}

enum APIClientError: LocalizedError {
    case invalidResponse
    case server(String)
    case decoding

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Unexpected response from server."
        case .server(let m):   return m
        case .decoding:        return "Could not decode server response."
        }
    }
}
