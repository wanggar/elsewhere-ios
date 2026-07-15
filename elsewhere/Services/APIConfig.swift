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

    static var soundCandidatesURL: URL {
        baseURL.appendingPathComponent("api/sound-candidates")
    }
}
