import Foundation
import ElevenLabs

struct TranscriptMessage: Codable, Equatable, Sendable {
    let role: String
    let content: String

    static func from(_ message: Message) -> TranscriptMessage {
        let role: String
        switch message.role {
        case .user:
            role = "user"
        case .agent:
            role = "agent"
        @unknown default:
            role = "agent"
        }
        return TranscriptMessage(role: role, content: message.content)
    }

    static func fallback(for mode: CuratorMode) -> [TranscriptMessage] {
        [
            TranscriptMessage(
                role: "user",
                content: "I want a soundscape \(mode.displayTitle). Keep it personal and calming."
            )
        ]
    }
}
