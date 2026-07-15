import Foundation
import Observation

enum PostConvoStep: Equatable {
    case generating
    case intro
    case candidates
    case saving
    case retry
}

@MainActor
@Observable
final class SoundCreationViewModel {
    let mode: CuratorMode
    let messages: [TranscriptMessage]

    private(set) var step: PostConvoStep = .generating
    private(set) var selectedCandidate: SoundCandidate
    private(set) var candidates: [SoundCandidate] = []
    private(set) var checklist: GenerationChecklist = .placeholder
    private(set) var headerTitle: String = "THREE WAYS"
    private(set) var generationError: String?
    private(set) var hasGeneratedSuccessfully = false

    private var skipIntroAfterGeneration = false
    private let service: SoundGenerationService
    private var generationTask: Task<Void, Never>?

    init(
        mode: CuratorMode,
        messages: [TranscriptMessage],
        service: SoundGenerationService = APISoundGenerationService()
    ) {
        self.mode = mode
        self.messages = messages.isEmpty ? TranscriptMessage.fallback(for: mode) : messages
        self.service = service
        self.selectedCandidate = SoundCandidate(
            title: "composing…",
            subtitle: "one moment"
        )
        startGeneration()
    }

    var isGenerating: Bool { step == .generating }
    var isShowingIntro: Bool { step == .intro }
    var isShowingCandidates: Bool { step == .candidates }
    var isShowingSaving: Bool { step == .saving }
    var isShowingRetry: Bool { step == .retry }

    func startGeneration() {
        generationTask?.cancel()
        generationError = nil
        step = .generating
        checklist = .placeholder
        CandidateAudioPlayer.shared.stop()

        generationTask = Task {
            await runGeneration()
        }
    }

    private func runGeneration() async {
        do {
            let result = try await service.generate(mode: mode, messages: messages)
            guard !Task.isCancelled else { return }

            checklist = result.checklist
            candidates = result.candidates
            headerTitle = result.headerTitle
            if let first = result.candidates.first {
                selectedCandidate = first
            }
            hasGeneratedSuccessfully = true

            // Brief beat so the completed checklist is visible.
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled else { return }

            step = skipIntroAfterGeneration ? .candidates : .intro
            skipIntroAfterGeneration = false
        } catch {
            guard !Task.isCancelled else { return }
            generationError = error.localizedDescription
            skipIntroAfterGeneration = false
            step = .retry
        }
    }

    func beginListening() {
        step = .candidates
        if let first = candidates.first {
            CandidateAudioPlayer.shared.play(url: first.audioURL)
        }
    }

    func select(_ candidate: SoundCandidate) {
        selectedCandidate = candidate
        CandidateAudioPlayer.shared.play(url: candidate.audioURL)
        step = .saving
    }

    func preview(_ candidate: SoundCandidate) {
        selectedCandidate = candidate
        CandidateAudioPlayer.shared.play(url: candidate.audioURL)
    }

    func requestRetry() {
        CandidateAudioPlayer.shared.stop()
        step = .retry
    }

    func backToCandidates() {
        if hasGeneratedSuccessfully, !candidates.isEmpty {
            step = .candidates
        } else {
            startGeneration()
        }
    }

    func retryGeneration() {
        skipIntroAfterGeneration = hasGeneratedSuccessfully
        startGeneration()
    }

    func stopAudio() {
        CandidateAudioPlayer.shared.stop()
    }
}
