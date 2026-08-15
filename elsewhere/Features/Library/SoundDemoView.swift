import SwiftUI

private struct WindowRainIllustration: View {
    var body: some View {
        ZStack {
            ForEach(0..<18, id: \.self) { index in
                let xOffset = CGFloat(index % 6) * 14 - 35 + CGFloat(index / 6) * 3
                let yOffset = CGFloat(index / 6) * 28 - 20

                Capsule()
                    .fill(AppTheme.immersiveStroke)
                    .frame(width: 1, height: 18)
                    .offset(x: xOffset, y: yOffset)
            }

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(AppTheme.immersiveWindowGlow.opacity(0.15))
                .frame(width: 120, height: 90)
                .overlay {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(AppTheme.immersiveStroke, lineWidth: 1)
                }
                .overlay {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(AppTheme.immersiveStroke)
                            .frame(height: 1)
                        Spacer()
                        Rectangle()
                            .fill(AppTheme.immersiveStroke)
                            .frame(height: 1)
                    }
                    .overlay {
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(AppTheme.immersiveStroke)
                                .frame(width: 1)
                            Spacer()
                            Rectangle()
                                .fill(AppTheme.immersiveStroke)
                                .frame(width: 1)
                        }
                    }
                }
                .shadow(color: AppTheme.immersiveWindowGlow.opacity(0.35), radius: 24, y: 8)
        }
        .frame(height: 120)
    }
}

private struct ImmersiveGlowOrb: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.immersiveGlow.opacity(0.45),
                            AppTheme.immersiveGlow.opacity(0.08),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)

            CompactSoundIcon(color: AppTheme.immersiveGlow.opacity(0.9))
        }
    }
}

struct SoundDemoView: View {
    let sound: SavedSound
    var onAddCard: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = true

    // Timer
    @State private var showTimerPanel = false
    @State private var selectedPresetSeconds: Int? // nil = loop forever
    @State private var remainingSeconds: Int?
    @State private var countdownTask: Task<Void, Never>?

    // What's in this
    @State private var showInsight = false
    @State private var insight: SoundInsight?
    @State private var isLoadingInsight = false

    private let timerPresets: [(label: String, seconds: Int?)] = [
        ("∞", nil),
        ("5m", 5 * 60),
        ("15m", 15 * 60),
        ("30m", 30 * 60),
        ("45m", 45 * 60),
        ("1h", 60 * 60),
        ("2h", 120 * 60),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.immersiveBackgroundTop, AppTheme.immersiveBackgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                backButton
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                Spacer()

                WindowRainIllustration()
                    .padding(.bottom, 40)

                ImmersiveGlowOrb()
                    .padding(.bottom, 48)

                soundInfo
                    .padding(.horizontal, 24)

                playbackControls
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                Spacer()

                if showTimerPanel {
                    timerPanel
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                bottomUtilityBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
            }
        }
        .navigationBarBackButtonHidden(true)
        .animation(.easeInOut(duration: 0.25), value: showTimerPanel)
        .sheet(isPresented: $showInsight) {
            SoundInsightSheet(
                sound: sound,
                insight: insight,
                isLoading: isLoadingInsight
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if isPlaying {
                CandidateAudioPlayer.shared.play(url: sound.audioURL)
            }
        }
        .onDisappear {
            countdownTask?.cancel()
            CandidateAudioPlayer.shared.stop()
        }
    }

    // MARK: - Header / info

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                Text("back to your space")
                    .font(.system(size: 16))
            }
            .foregroundStyle(AppTheme.textSecondary)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var soundInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(sound.categoryLabel)
                .font(AppTheme.labelCaps(11))
                .tracking(1.2)
                .foregroundStyle(AppTheme.textSecondary)

            Text(sound.title)
                .font(AppTheme.serifTitle(34))
                .foregroundStyle(AppTheme.textPrimary)

            Text(sound.immersiveDescription)
                .font(AppTheme.serifItalic(17))
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Playback

    private var playbackControls: some View {
        HStack {
            Button {
                isPlaying.toggle()
                if isPlaying {
                    CandidateAudioPlayer.shared.play(url: sound.audioURL)
                    if let remaining = remainingSeconds, remaining > 0 {
                        startCountdown(from: remaining)
                    }
                } else {
                    CandidateAudioPlayer.shared.stop()
                    pauseCountdown()
                }
            } label: {
                Circle()
                    .fill(AppTheme.textPrimary)
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(AppTheme.immersiveBackgroundBottom)
                            .offset(x: isPlaying ? 0 : 1)
                    }
            }
            .buttonStyle(.plain)

            Spacer()

            Text(loopStatusLabel)
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(AppTheme.textMuted)
        }
    }

    private var loopStatusLabel: String {
        if let remaining = remainingSeconds {
            return "stops in \(formatTime(remaining))"
        }
        return "looping ∞"
    }

    // MARK: - Timer panel

    private var timerPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(sound.mode.timerLabel.uppercased())
                    .font(AppTheme.labelCaps(10))
                    .tracking(1.2)
                    .foregroundStyle(AppTheme.textMuted)

                Spacer()

                Text(remainingSeconds.map(formatTime) ?? "∞")
                    .font(.system(size: 28, weight: .light, design: .monospaced))
                    .foregroundStyle(AppTheme.textPrimary)
            }

            Text("Sounds loop by default. Set a timer and they’ll stop when time’s up.")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(timerPresets, id: \.label) { preset in
                        timerChip(label: preset.label, seconds: preset.seconds)
                    }
                }
            }

            if selectedPresetSeconds != nil {
                Button {
                    clearTimer()
                } label: {
                    Text("clear timer")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.pulsePurple)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background(AppTheme.cardSurface.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.immersiveStroke, lineWidth: 1)
        }
    }

    private func timerChip(label: String, seconds: Int?) -> some View {
        let selected = selectedPresetSeconds == seconds

        return Button {
            applyTimer(seconds: seconds)
        } label: {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(selected ? AppTheme.ctaForeground : AppTheme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(selected ? AppTheme.creamButton : AppTheme.convoSummaryBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom bar

    private var bottomUtilityBar: some View {
        HStack {
            Button {
                showTimerPanel.toggle()
            } label: {
                utilityItem(
                    icon: "timer",
                    label: remainingSeconds == nil ? sound.mode.timerLabel : formatTime(remainingSeconds!),
                    emphasized: showTimerPanel || remainingSeconds != nil
                )
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                openInsight()
            } label: {
                utilityItem(icon: "info.circle", label: "what's in this", emphasized: showInsight)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                onAddCard?()
            } label: {
                utilityItem(icon: "plus", label: "add card")
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 20)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.immersiveDivider)
                .frame(height: 1)
        }
    }

    private func utilityItem(icon: String, label: String, emphasized: Bool = false) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(emphasized ? AppTheme.pulsePurple : AppTheme.textSecondary)

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(emphasized ? AppTheme.pulsePurple : AppTheme.textMuted)
        }
    }

    // MARK: - Timer logic

    private func applyTimer(seconds: Int?) {
        countdownTask?.cancel()
        selectedPresetSeconds = seconds
        remainingSeconds = seconds

        guard let seconds else { return }

        if isPlaying {
            startCountdown(from: seconds)
        }
    }

    private func clearTimer() {
        countdownTask?.cancel()
        countdownTask = nil
        selectedPresetSeconds = nil
        remainingSeconds = nil
    }

    private func pauseCountdown() {
        countdownTask?.cancel()
        countdownTask = nil
    }

    private func startCountdown(from seconds: Int) {
        countdownTask?.cancel()
        remainingSeconds = seconds
        countdownTask = Task { @MainActor in
            var left = seconds
            while left > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                left -= 1
                remainingSeconds = left
            }
            CandidateAudioPlayer.shared.stop()
            isPlaying = false
            remainingSeconds = nil
            selectedPresetSeconds = nil
            showTimerPanel = false
        }
    }

    private func formatTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Insight

    private func openInsight() {
        showInsight = true
        guard insight == nil, !isLoadingInsight else { return }
        isLoadingInsight = true
        Task {
            let result = await SoundInsightService.insight(for: sound)
            insight = result
            isLoadingInsight = false
        }
    }
}

// MARK: - What's in this sheet

private struct SoundInsightSheet: View {
    let sound: SavedSound
    let insight: SoundInsight?
    let isLoading: Bool

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("WHAT'S IN THIS")
                        .font(AppTheme.labelCaps(11))
                        .tracking(1.2)
                        .foregroundStyle(AppTheme.textMuted)
                        .padding(.bottom, 10)

                    Text(sound.title)
                        .font(AppTheme.serifTitle(28))
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.bottom, 6)

                    Text(sound.mode.categoryLabel)
                        .font(AppTheme.labelCaps(11))
                        .tracking(1.2)
                        .foregroundStyle(sound.mode.cardPrimaryColor)
                        .padding(.bottom, 24)

                    if isLoading && insight == nil {
                        loadingState
                    } else if let insight {
                        insightCard(insight)
                    }
                }
                .padding(24)
            }
        }
    }

    private var loadingState: some View {
        VStack(alignment: .leading, spacing: 14) {
            ProgressView()
                .tint(AppTheme.pulsePurple)
            Text("Listening back through your conversation…")
                .font(AppTheme.serifItalic(16))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppTheme.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func insightCard(_ insight: SoundInsight) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(insight.headline)
                .font(AppTheme.serifItalic(18))
                .foregroundStyle(AppTheme.pulsePurple)

            insightSection(title: "FROM YOUR CHAT", body: insight.memory)
            insightSection(title: "WHAT WE BUILT", body: insight.layers)
            insightSection(title: "WHY IT FITS", body: insight.connection)
        }
        .padding(20)
        .background(AppTheme.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.surfaceBorder.opacity(0.7), lineWidth: 1)
        }
    }

    private func insightSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTheme.labelCaps(10))
                .tracking(1.2)
                .foregroundStyle(AppTheme.textMuted)

            Text(body)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        SoundDemoView(sound: .default)
    }
}
