import SwiftUI

struct PostConvoFlowView: View {
    var onSaved: (SavedSound) -> Void

    @State private var viewModel: SoundCreationViewModel

    init(
        mode: CuratorMode,
        messages: [TranscriptMessage],
        onSaved: @escaping (SavedSound) -> Void
    ) {
        self.onSaved = onSaved
        _viewModel = State(
            initialValue: SoundCreationViewModel(mode: mode, messages: messages)
        )
    }

    var body: some View {
        Group {
            if viewModel.isGenerating {
                SoundGenerationView(checklist: viewModel.checklist)
                    .transition(.opacity)
            } else if viewModel.isShowingIntro {
                PostConvoIntroView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewModel.beginListening()
                    }
                }
                .transition(.opacity)
            } else if viewModel.isShowingCandidates {
                SoundCandidatesView(
                    headerTitle: viewModel.headerTitle,
                    candidates: viewModel.candidates,
                    onSelect: { candidate in
                        viewModel.preview(candidate)
                    },
                    onSave: { candidate in
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewModel.select(candidate)
                        }
                    },
                    onTryAgain: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewModel.requestRetry()
                        }
                    }
                )
                .transition(.opacity)
            } else if viewModel.isShowingSaving {
                SavingView(
                    candidate: viewModel.selectedCandidate,
                    isSaving: viewModel.isSavingToCloud,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewModel.backToCandidates()
                        }
                    },
                    onSave: { name in
                        viewModel.stopAudio()
                        Task {
                            do {
                                let sound = try await viewModel.saveToCloud(name: name)
                                onSaved(sound)
                            } catch {
                                // Surface the error back to retry view
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    viewModel.requestRetry()
                                }
                            }
                        }
                    }
                )
                .transition(.opacity)
            } else if viewModel.isShowingRetry {
                RetryView(
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewModel.backToCandidates()
                        }
                    },
                    onAnotherTry: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewModel.retryGeneration()
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.step)
        .onDisappear {
            viewModel.stopAudio()
        }
    }
}

#Preview("Mock generation") {
    PostConvoFlowView(
        mode: .sleep,
        messages: TranscriptMessage.fallback(for: .sleep),
        service: MockSoundGenerationService(),
        onSaved: { _ in }
    )
}

extension PostConvoFlowView {
    init(
        mode: CuratorMode,
        messages: [TranscriptMessage],
        service: SoundGenerationService,
        onSaved: @escaping (SavedSound) -> Void
    ) {
        self.onSaved = onSaved
        _viewModel = State(
            initialValue: SoundCreationViewModel(
                mode: mode,
                messages: messages,
                service: service
            )
        )
    }
}
