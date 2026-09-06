import SwiftUI

struct SampleSound: Identifiable {
    let id = UUID()
    /// Bundle resource name without extension — .mp3 or .m4a both resolve.
    let fileName: String
    let kicker: String
    let title: String
    let identity: String
    let background: Color
    let textColor: Color

    var audioURL: URL? {
        Bundle.main.url(forResource: fileName, withExtension: "mp3")
            ?? Bundle.main.url(forResource: fileName, withExtension: "m4a")
    }
}

struct SampleSoundsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.scenePhase) private var scenePhase

    @State private var player = SampleAudioPlayer()
    @State private var selection = 0
    @State private var settleTask: Task<Void, Never>?
    @State private var userPaused = false

    private let samples: [SampleSound] = [
        SampleSound(
            fileName: "Morning_city_ambienc_#1-1788180047529",
            kicker: "CITY · DANY, 28",
            title: "Beijing balcony, 11pm.",
            identity: "“The city hums me to sleep.”",
            background: AppTheme.sleepCardBackground,
            textColor: AppTheme.accentPurple
        ),
        SampleSound(
            fileName: "Hip-hop_music_blasti_#2-1788180313947",
            kicker: "MOVE · JORDAN, 26",
            title: "Night drive, 1am.",
            identity: "“I think best at 140 BPM.”",
            background: AppTheme.moveCardBackground,
            textColor: AppTheme.moveCardText
        ),
        SampleSound(
            fileName: "Very_gentle_ocean_wa_#4-1788180401608",
            kicker: "REST · LIN, 31",
            title: "The tide, an hour before dawn.",
            identity: "“I need the horizon.”",
            background: AppTheme.focusCardBackground,
            textColor: AppTheme.focusText
        ),
    ]

    private var cardCount: Int { samples.count + 1 }
    private var onGhostCard: Bool { selection == samples.count }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 12)

                deck
                    .padding(.top, 24)

                footer
                    .padding(.top, 20)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            player.preload(samples.compactMap { sample in
                sample.audioURL.map { (id: sample.id, url: $0) }
            })
            scheduleAutoplay(for: 0, delay: .milliseconds(700))
        }
        .onDisappear {
            settleTask?.cancel()
            player.stop()
        }
        .onChange(of: selection) { _, newValue in
            userPaused = false
            scheduleAutoplay(for: newValue, delay: .milliseconds(300))
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                if !onGhostCard && !userPaused {
                    player.play(id: samples[selection].id)
                }
            default:
                player.pause()
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THREE PEOPLE, THREE ELSEWHERES")
                .font(AppTheme.labelCaps(11))
                .tracking(1.2)
                .foregroundStyle(AppTheme.textMuted)

            Text("One of them might\nsound like you.")
                .font(AppTheme.serifTitle(30))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Deck

    private var deck: some View {
        TabView(selection: $selection) {
            ForEach(Array(samples.enumerated()), id: \.element.id) { index, sample in
                SampleCard(
                    sample: sample,
                    isPlaying: player.playingID == sample.id,
                    onToggle: { toggle(sample) }
                )
                .padding(.horizontal, 24)
                .tag(index)
            }

            ghostCard
                .padding(.horizontal, 24)
                .tag(samples.count)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private var ghostCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("YOURS")
                .font(AppTheme.labelCaps(11))
                .tracking(1.2)
                .foregroundStyle(AppTheme.textMuted)

            Text("…and yours.")
                .font(AppTheme.serifTitle(32))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.top, 12)

            Text("Tell us about a moment from your life.\nWe’ll make the sound of it.")
                .font(AppTheme.serifItalic(17))
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)

            Spacer(minLength: 0)

            LiveWaveformBars(isPlaying: false, color: AppTheme.textMuted)
                .opacity(0.4)

            Spacer(minLength: 0)

            signInButton

            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.accentPurple)
                    .padding(.top, 12)
            }

            Text("Private and saved only to your account.")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.textMuted)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(24)
        .background(AppTheme.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppTheme.surfaceBorder, style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
        }
    }

    private var signInButton: some View {
        Button {
            Task { await authViewModel.signInWithApple() }
        } label: {
            HStack(spacing: 6) {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(AppTheme.ctaForeground)
                } else {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 16, weight: .medium))

                    Text("find yours")
                        .font(.system(size: 17, weight: .medium))
                }
            }
            .foregroundStyle(AppTheme.ctaForeground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AppTheme.creamButton)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(authViewModel.isLoading)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(0..<cardCount, id: \.self) { index in
                    if index == samples.count {
                        Circle()
                            .strokeBorder(AppTheme.textMuted, lineWidth: 1)
                            .frame(width: 7, height: 7)
                            .opacity(selection == index ? 1 : 0.45)
                    } else {
                        Circle()
                            .fill(selection == index ? AppTheme.textPrimary : AppTheme.progressTrack)
                            .frame(width: 7, height: 7)
                    }
                }
            }

            Text(onGhostCard ? "it takes a minute to make yours" : "swipe to sample another")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textMuted)
                .animation(.none, value: selection)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Playback

    private func toggle(_ sample: SampleSound) {
        if player.playingID == sample.id {
            userPaused = true
            player.pause()
        } else {
            userPaused = false
            player.play(id: sample.id)
        }
    }

    private func scheduleAutoplay(for index: Int, delay: Duration) {
        settleTask?.cancel()
        settleTask = Task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled, selection == index else { return }
            if index < samples.count {
                if !userPaused { player.play(id: samples[index].id) }
            } else {
                player.pause()
            }
        }
    }
}

// MARK: - Sample card

private struct SampleCard: View {
    let sample: SampleSound
    let isPlaying: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(sample.kicker)
                .font(AppTheme.labelCaps(11))
                .tracking(1.2)
                .foregroundStyle(sample.textColor.opacity(0.75))

            Text(sample.title)
                .font(AppTheme.serifTitle(32))
                .foregroundStyle(sample.textColor)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)

            Text(sample.identity)
                .font(AppTheme.serifItalic(17))
                .foregroundStyle(sample.textColor.opacity(0.8))
                .padding(.top, 10)

            Spacer(minLength: 0)

            LiveWaveformBars(isPlaying: isPlaying, color: sample.textColor)

            HStack(spacing: 14) {
                Button(action: onToggle) {
                    Circle()
                        .fill(sample.textColor)
                        .frame(width: 52, height: 52)
                        .overlay {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(sample.background)
                                .offset(x: isPlaying ? 0 : 1)
                        }
                }
                .buttonStyle(.plain)
                .disabled(sample.audioURL == nil)
                .opacity(sample.audioURL == nil ? 0.4 : 1)
                .accessibilityLabel(isPlaying ? "Pause sample" : "Play sample")

                Text(caption)
                    .font(.system(size: 14))
                    .foregroundStyle(sample.textColor.opacity(0.75))

                Spacer(minLength: 0)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(24)
        .background(sample.background)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var caption: String {
        if sample.audioURL == nil {
            #if DEBUG
            return "add \(sample.fileName).mp3 to the bundle"
            #else
            return "sound coming soon"
            #endif
        }
        return isPlaying ? "now playing · loops" : "tap to listen — no sign-in needed"
    }
}

// MARK: - Waveform

private struct LiveWaveformBars: View {
    let isPlaying: Bool
    let color: Color

    private let barCount = 30

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: !isPlaying)) { context in
            HStack(spacing: 3) {
                ForEach(0..<barCount, id: \.self) { index in
                    Capsule()
                        .fill(color.opacity(isPlaying ? 0.9 : 0.3))
                        .frame(width: 3, height: barHeight(index: index, time: context.date.timeIntervalSinceReferenceDate))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
        }
        .frame(height: 40)
    }

    private func barHeight(index: Int, time: TimeInterval) -> CGFloat {
        guard isPlaying else { return 6 }
        let phase = Double(index) * 0.55
        let wave = sin(time * 2.6 + phase) * 0.5 + sin(time * 1.7 + phase * 1.3) * 0.5
        return 6 + abs(CGFloat(wave)) * 30
    }
}

#Preview {
    SampleSoundsView()
        .environment(AuthViewModel())
}
