import SwiftUI

private struct WindowRainIllustration: View {
    var body: some View {
        ZStack {
            ForEach(0..<18, id: \.self) { index in
                let xOffset = CGFloat(index % 6) * 14 - 35 + CGFloat(index / 6) * 3
                let yOffset = CGFloat(index / 6) * 28 - 20

                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 1, height: 18)
                    .offset(x: xOffset, y: yOffset)
            }

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(AppTheme.immersiveWindowGlow.opacity(0.15))
                .frame(width: 120, height: 90)
                .overlay {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
                .overlay {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 1)
                        Spacer()
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 1)
                    }
                    .overlay {
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 1)
                            Spacer()
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
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

                bottomUtilityBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            if isPlaying {
                CandidateAudioPlayer.shared.play(url: sound.audioURL)
            }
        }
        .onDisappear {
            CandidateAudioPlayer.shared.stop()
        }
    }

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

    private var playbackControls: some View {
        HStack {
            Button {
                isPlaying.toggle()
                if isPlaying {
                    CandidateAudioPlayer.shared.play(url: sound.audioURL)
                } else {
                    CandidateAudioPlayer.shared.stop()
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

            Text("looping ∞")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textMuted)
        }
    }

    private var bottomUtilityBar: some View {
        HStack {
            utilityItem(icon: "timer", label: sound.mode.timerLabel)
            Spacer()
            utilityItem(icon: "info.circle", label: "what's in this")
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
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
        }
    }

    private func utilityItem(icon: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.textSecondary)

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.textMuted)
        }
    }
}

#Preview {
    NavigationStack {
        SoundDemoView(sound: .default)
    }
}
