import AVFoundation
import ElevenLabs

/// Serializes ElevenLabs / LiveKit room lifecycle app-wide so a second session
/// cannot start before the previous room has fully disconnected.
@MainActor
final class ConversationSessionCoordinator {
    static let shared = ConversationSessionCoordinator()

    private var activeConversation: Conversation?
    private var currentWork: Task<Void, Never>?

    private init() {}

    func endActiveSession() async {
        await run {
            let conversation = self.activeConversation
            self.activeConversation = nil
            guard let conversation else { return }
            await conversation.endConversation()
            try? await Task.sleep(for: .milliseconds(600))
        }
    }

    func startSession(
        agentId: String,
        config: ConversationConfig
    ) async throws -> Conversation {
        try await run {
            let existing = self.activeConversation
            self.activeConversation = nil
            if let existing {
                await existing.endConversation()
                try? await Task.sleep(for: .milliseconds(600))
            }

            self.prepareAudioSessionForVoice()

            let conversation = try await ElevenLabs.startConversation(
                agentId: agentId,
                config: config
            )
            self.activeConversation = conversation
            return conversation
        }
    }

    func endSession(_ conversation: Conversation) async {
        await run {
            self.activeConversation = nil
            await conversation.endConversation()
            try? await Task.sleep(for: .milliseconds(600))
        }
    }

    private func prepareAudioSessionForVoice() {
        CandidateAudioPlayer.shared.stop()

        let session = AVAudioSession.sharedInstance()
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
        try? session.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .allowBluetooth]
        )
        try? session.setActive(true)
    }

    private func run(
        _ work: @escaping @MainActor () async -> Void
    ) async {
        let previous = currentWork
        let task = Task { @MainActor in
            await previous?.value
            await work()
        }
        currentWork = task
        await task.value
    }

    private func run<T>(
        _ work: @escaping @MainActor () async throws -> T
    ) async throws -> T {
        let previous = currentWork
        var outcome: Result<T, Error>?
        let task = Task { @MainActor in
            await previous?.value
            do {
                outcome = .success(try await work())
            } catch {
                outcome = .failure(error)
            }
        }
        currentWork = task
        await task.value
        switch outcome {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        case .none:
            throw CancellationError()
        }
    }
}
