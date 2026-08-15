import Foundation

/// Stores curator-conversation excerpts keyed by saved sound id,
/// so "what's in this" can stay personal even after a library refresh.
enum ConversationMemoryStore {
    private static let keyPrefix = "elsewhere.conversationMemory."

    struct Memory: Codable, Equatable, Sendable {
        let userLines: [String]
        let agentLines: [String]
        let rawUserText: String
    }

    static func save(messages: [TranscriptMessage], for soundID: UUID) {
        let userLines = messages
            .filter { $0.role == "user" }
            .map { $0.content.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !isGenericFallback($0) }

        let agentLines = messages
            .filter { $0.role == "agent" }
            .map { $0.content.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let memory = Memory(
            userLines: Array(userLines.prefix(12)),
            agentLines: Array(agentLines.suffix(6)),
            rawUserText: userLines.joined(separator: " ")
        )

        guard let data = try? JSONEncoder().encode(memory) else { return }
        UserDefaults.standard.set(data, forKey: keyPrefix + soundID.uuidString)
    }

    static func load(for soundID: UUID) -> Memory? {
        guard let data = UserDefaults.standard.data(forKey: keyPrefix + soundID.uuidString) else {
            return nil
        }
        return try? JSONDecoder().decode(Memory.self, from: data)
    }

    static func delete(for soundID: UUID) {
        UserDefaults.standard.removeObject(forKey: keyPrefix + soundID.uuidString)
    }

    private static func isGenericFallback(_ text: String) -> Bool {
        let lower = text.lowercased()
        return lower.contains("keep it personal and calming")
            || lower.hasPrefix("i want a soundscape")
    }
}
