import Foundation

struct SoundGenerationResult: Sendable {
    let headerTitle: String
    let checklist: GenerationChecklist
    let candidates: [SoundCandidate]
}

struct GenerationChecklist: Sendable {
    struct Item: Identifiable, Sendable {
        let id: UUID
        let text: String
        let state: GenerationItemState

        init(id: UUID = UUID(), text: String, state: GenerationItemState) {
            self.id = id
            self.text = text
            self.state = state
        }
    }

    let items: [Item]

    static func from(labels: [String], completedCount: Int = 0) -> GenerationChecklist {
        let items = labels.enumerated().map { index, text in
            let state: GenerationItemState
            if index < completedCount {
                state = .complete
            } else if index == completedCount {
                state = .inProgress
            } else {
                state = .pending
            }
            return Item(text: text, state: state)
        }
        return GenerationChecklist(items: items)
    }

    static var placeholder: GenerationChecklist {
        from(labels: [
            "listening to what you shared",
            "finding the right atmosphere",
            "layering the soundscape...",
            "finishing the mix",
        ], completedCount: 0)
    }
}

enum GenerationItemState: Sendable {
    case complete
    case inProgress
    case pending
}

protocol SoundGenerationService: Sendable {
    func generate(
        mode: CuratorMode,
        messages: [TranscriptMessage]
    ) async throws -> SoundGenerationResult
}

enum SoundGenerationError: LocalizedError {
    case invalidResponse
    case server(String)
    case decoding
    case audioWrite

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Unexpected response from the sound service."
        case .server(let message):
            return message
        case .decoding:
            return "Could not read sound candidates."
        case .audioWrite:
            return "Could not save generated audio."
        }
    }
}

struct APISoundGenerationService: SoundGenerationService {
    private struct RequestBody: Encodable {
        let mode: String
        let messages: [TranscriptMessage]
    }

    private struct ResponseBody: Decodable {
        let headerTitle: String
        let checklist: [String]
        let candidates: [CandidateDTO]
    }

    private struct CandidateDTO: Decodable {
        let id: String
        let title: String
        let subtitle: String
        let prompt: String?
        let durationSeconds: Double?
        let audioBase64: String
        let mimeType: String?
    }

    private struct ErrorBody: Decodable {
        let error: String
    }

    func generate(
        mode: CuratorMode,
        messages: [TranscriptMessage]
    ) async throws -> SoundGenerationResult {
        var request = URLRequest(url: APIConfig.soundCandidatesURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        request.httpBody = try JSONEncoder().encode(
            RequestBody(mode: mode.rawValue, messages: messages)
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SoundGenerationError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            if let errorBody = try? JSONDecoder().decode(ErrorBody.self, from: data) {
                throw SoundGenerationError.server(errorBody.error)
            }
            throw SoundGenerationError.server("Request failed (\(http.statusCode))")
        }

        let decoded: ResponseBody
        do {
            decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        } catch {
            throw SoundGenerationError.decoding
        }

        let candidates = try decoded.candidates.map { dto -> SoundCandidate in
            guard let audioData = Data(base64Encoded: dto.audioBase64) else {
                throw SoundGenerationError.decoding
            }
            let url = try Self.writeTempMP3(id: dto.id, data: audioData)
            return SoundCandidate(
                id: UUID(uuidString: dto.id) ?? UUID(),
                title: dto.title,
                subtitle: dto.subtitle,
                audioURL: url
            )
        }

        return SoundGenerationResult(
            headerTitle: decoded.headerTitle,
            checklist: .from(labels: decoded.checklist, completedCount: decoded.checklist.count),
            candidates: candidates
        )
    }

    private static func writeTempMP3(id: String, data: Data) throws -> URL {
        let safeName = id.replacingOccurrences(of: "/", with: "_")
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("elsewhere-\(safeName).mp3")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            throw SoundGenerationError.audioWrite
        }
    }
}

struct MockSoundGenerationService: SoundGenerationService {
    func generate(
        mode: CuratorMode,
        messages: [TranscriptMessage]
    ) async throws -> SoundGenerationResult {
        try await Task.sleep(for: .milliseconds(800))
        _ = mode
        _ = messages
        let candidates = [
            SoundCandidate(title: "the living room", subtitle: "heater settling, the page turning"),
            SoundCandidate(title: "the window, snowing", subtitle: "muffled street, faint wind"),
            SoundCandidate(title: "just the heater", subtitle: "stripped down, just clicks and hum"),
        ]
        return SoundGenerationResult(
            headerTitle: "YOUR WINTER, THREE WAYS",
            checklist: .from(labels: [
                "a living room, winter",
                "heater settling",
                "layering the page turning...",
                "snow muffling the street",
            ], completedCount: 4),
            candidates: candidates
        )
    }
}
