import SwiftUI
import ElevenLabs

struct AIConvoView: View {
    var onSavedToLibrary: ((SavedSound) -> Void)? = nil
    var onCancel: (() -> Void)? = nil

    @State private var viewModel: ConversationViewModel

    init(
        mode: CuratorMode,
        onSavedToLibrary: ((SavedSound) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self.onSavedToLibrary = onSavedToLibrary
        self.onCancel = onCancel
        _viewModel = State(initialValue: ConversationViewModel(mode: mode))
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                statusHeader
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                messagesFeed
                    .padding(.top, 8)

                micInputSection
                    .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .task {
            await viewModel.startConversation()
        }
        .onDisappear {
            Task { await viewModel.endConversation() }
        }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.showPostConvoFlow },
            set: { if !$0 { viewModel.dismissPostConvoFlow() } }
        )) {
            PostConvoFlowView(
                mode: viewModel.mode,
                messages: viewModel.compositionTranscript
            ) { sound in
                viewModel.dismissPostConvoFlow()
                onSavedToLibrary?(sound)
            }
        }
    }

    // MARK: - Status header

    private var statusHeader: some View {
        HStack {
            Button("Close") {
                Task {
                    await viewModel.prepareForExit()
                    onCancel?()
                }
            }
            .font(.system(size: 14))
            .foregroundStyle(AppTheme.textMuted)

            Spacer()

            HStack(spacing: 8) {
                Circle()
                    .fill(statusDotColor)
                    .frame(width: 7, height: 7)
                Text(viewModel.connectionStatus.uppercased())
                    .font(AppTheme.labelCaps(11))
                    .tracking(1.2)
                    .foregroundStyle(AppTheme.textMuted)
            }

            Spacer()

            if viewModel.isConnected || !viewModel.messages.isEmpty {
                Button("Compose") {
                    Task { await viewModel.finishAndCompose() }
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.pulsePurple)
            } else {
                Color.clear
                    .frame(width: 52, height: 1)
            }
        }
    }

    private var statusDotColor: Color {
        guard viewModel.isConnected else { return AppTheme.textMuted.opacity(0.4) }
        return viewModel.agentState == .speaking ? AppTheme.pulsePurple : AppTheme.textSecondary
    }

    // MARK: - Message feed

    private var messagesFeed: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    if viewModel.messages.isEmpty {
                        emptyState
                            .padding(.top, 60)
                    } else {
                        ForEach(viewModel.messages, id: \.id) { message in
                            messageBubble(message)
                                .id(message.id)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                guard let last = viewModel.messages.last else { return }
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.isConnecting ? "Starting your session..." : "Your curator is ready.")
                .font(AppTheme.serifTitle(28))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(
                viewModel.isConnecting
                    ? "Connecting to your \(viewModel.mode.displayTitle) curator."
                    : "Tap the mic below to begin."
            )
            .font(.system(size: 15))
            .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func messageBubble(_ message: Message) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 48) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.role == .user ? "YOU" : "CURATOR")
                    .font(AppTheme.labelCaps(10))
                    .tracking(1.2)
                    .foregroundStyle(AppTheme.textMuted)

                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.role == .user
                            ? AppTheme.pulsePurple.opacity(0.2)
                            : AppTheme.convoSummaryBackground
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if message.role == .agent { Spacer(minLength: 48) }
        }
    }

    // MARK: - Mic section

    private var micInputSection: some View {
        VStack(spacing: 16) {
            Button {
                viewModel.handleMicTap()
            } label: {
                ZStack {
                    Circle()
                        .stroke(AppTheme.textPrimary.opacity(0.9), lineWidth: 1.5)
                        .frame(width: 72, height: 72)

                    Circle()
                        .fill(micFillColor)
                        .frame(width: 56, height: 56)
                        .overlay {
                            Image(systemName: viewModel.isMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isConnecting)

            Text(micFooterLabel)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textMuted)
        }
    }

    private var micFillColor: Color {
        if viewModel.isConnecting || viewModel.isMuted {
            return AppTheme.textMuted.opacity(0.3)
        }
        return AppTheme.pulsePurple
    }

    private var micFooterLabel: String {
        if viewModel.isConnecting { return "connecting..." }
        if !viewModel.isConnected { return "tap to begin" }
        if viewModel.isMuted { return "muted — tap to unmute" }
        return viewModel.agentState == .speaking ? "curator speaking" : "listening — tap to mute"
    }
}

#Preview {
    NavigationStack {
        AIConvoView(mode: .sleep)
    }
}
