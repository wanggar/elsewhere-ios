import Foundation
import Observation
import ElevenLabs
import Combine

@MainActor
@Observable
final class ConversationViewModel {
    let mode: CuratorMode

    // Connection
    private(set) var connectionStatus: String = "Disconnected"
    private(set) var isConnected = false
    private(set) var isConnecting = false
    private(set) var connectionError: String?

    // Conversation
    private(set) var messages: [Message] = []
    private(set) var agentState: ElevenLabs.AgentState = .listening
    private(set) var isMuted = false

    // Post-convo flow
    private(set) var showPostConvoFlow = false
    private(set) var compositionTranscript: [TranscriptMessage] = []

    private var conversation: Conversation?
    private var cancellables = Set<AnyCancellable>()

    private let agentId = "agent_6201kwtgrnwge91s0q7729cpj9fn"

    init(mode: CuratorMode) {
        self.mode = mode
    }

    // MARK: - Session lifecycle

    func startConversation() async {
        guard !Task.isCancelled else { return }
        guard !isConnecting else { return }

        isConnecting = true
        connectionError = nil
        connectionStatus = "Connecting..."

        guard await MicrophonePermission.requestIfNeeded() else {
            isConnecting = false
            connectionStatus = "Mic blocked"
            connectionError = "Microphone access is required to talk with your curator. Enable it in Settings → Elsewhere → Microphone."
            return
        }

        do {
            conversation = try await connectWithFallback()
            guard !Task.isCancelled else {
                await tearDownConversation(clearMessages: true)
                return
            }
            setupObservers()
            await ensureMicrophoneActive()
        } catch is CancellationError {
            await tearDownConversation(clearMessages: true)
        } catch {
            connectionStatus = "Failed to connect"
            connectionError = friendlyError(from: error)
            isConnecting = false
            isConnected = false
        }
    }

    func endConversation() async {
        await tearDownConversation(clearMessages: true)
    }

    /// Ends the live session, snapshots the transcript, and opens sound composition.
    func finishAndCompose() async {
        let snapshot = messages.map(TranscriptMessage.from)
        compositionTranscript = snapshot.isEmpty
            ? TranscriptMessage.fallback(for: mode)
            : snapshot
        await tearDownConversation(clearMessages: false)
        showPostConvoFlow = true
    }

    private func tearDownConversation(clearMessages: Bool) async {
        if let conversation {
            await ConversationSessionCoordinator.shared.endSession(conversation)
            self.conversation = nil
        } else {
            await ConversationSessionCoordinator.shared.endActiveSession()
        }
        cancellables.removeAll()
        isConnected = false
        isConnecting = false
        connectionStatus = "Disconnected"
        if clearMessages {
            messages = []
        }
    }

    // MARK: - Controls

    func handleMicTap() {
        Task {
            if isConnected {
                try? await conversation?.toggleMute()
            } else if !isConnecting {
                await startConversation()
            }
        }
    }

    func dismissPostConvoFlow() {
        showPostConvoFlow = false
        messages = []
        compositionTranscript = []
    }

    func prepareForExit() async {
        showPostConvoFlow = false
        await endConversation()
    }

    // MARK: - Connection

    /// Prefer a plain voice session so talking always works.
    /// Then optionally retry once with curator prompt overrides if the dashboard allows them.
    private func connectWithFallback() async throws -> Conversation {
        let voiceConfig = ConversationConfig(
            conversationOverrides: ConversationOverrides(textOnly: false),
            dynamicVariables: [
                "curator_mode": mode.rawValue,
                "curator_mode_label": mode.displayTitle,
            ]
        )

        let curatedConfig = ConversationConfig(
            agentOverrides: AgentOverrides(
                prompt: CuratorAgentInstructions.systemPrompt(for: mode),
                firstMessage: CuratorAgentInstructions.firstMessage(for: mode)
            ),
            conversationOverrides: ConversationOverrides(textOnly: false),
            dynamicVariables: [
                "curator_mode": mode.rawValue,
                "curator_mode_label": mode.displayTitle,
            ]
        )

        // Try curated prompt first; if ElevenLabs rejects overrides, fall back to plain voice.
        do {
            return try await ConversationSessionCoordinator.shared.startSession(
                agentId: agentId,
                config: curatedConfig
            )
        } catch {
            await ConversationSessionCoordinator.shared.endActiveSession()
            return try await ConversationSessionCoordinator.shared.startSession(
                agentId: agentId,
                config: voiceConfig
            )
        }
    }

    private func ensureMicrophoneActive() async {
        guard let conversation, isMuted else { return }
        try? await conversation.toggleMute()
    }

    private func friendlyError(from error: Error) -> String {
        let text = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        if text.localizedCaseInsensitiveContains("override") {
            return "Curator prompt overrides aren’t enabled for this agent yet. Tap the mic to retry."
        }
        if text.localizedCaseInsensitiveContains("network") || text.localizedCaseInsensitiveContains("offline") {
            return "Network issue connecting to your curator. Check Wi‑Fi and try again."
        }
        return text.isEmpty ? "Couldn’t connect to your curator. Tap the mic to try again." : text
    }

    // MARK: - Combine observers

    private func setupObservers() {
        guard let conversation else { return }

        conversation.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msgs in
                Task { @MainActor [weak self] in self?.messages = msgs }
            }
            .store(in: &cancellables)

        conversation.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    switch state {
                    case .idle:
                        self.connectionStatus = "Disconnected"
                        self.isConnected = false
                        self.isConnecting = false
                    case .connecting:
                        self.connectionStatus = "Connecting..."
                        self.isConnected = false
                    case .active:
                        self.connectionStatus = "Connected"
                        self.isConnected = true
                        self.isConnecting = false
                        self.connectionError = nil
                    case .ended:
                        self.connectionStatus = "Ended"
                        self.isConnected = false
                        self.isConnecting = false
                    case .error:
                        self.connectionStatus = "Error"
                        self.isConnected = false
                        self.isConnecting = false
                        self.connectionError = "The curator session hit an error. Tap the mic to try again."
                    }
                }
            }
            .store(in: &cancellables)

        conversation.$isMuted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] muted in
                Task { @MainActor [weak self] in self?.isMuted = muted }
            }
            .store(in: &cancellables)

        conversation.$agentState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] agentState in
                Task { @MainActor [weak self] in self?.agentState = agentState }
            }
            .store(in: &cancellables)
    }
}
