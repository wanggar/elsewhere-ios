import SwiftUI

struct LibraryView: View {
    var viewModel: LibraryViewModel

    @Environment(AuthViewModel.self) private var authViewModel
    @State private var selectedSound: SavedSound?
    @State private var activeConvoSession: ConvoSession?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        activeModeStack
                        otherSavedStacks
                        modesSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .offset(y: -4)
            }
            .navigationDestination(item: $selectedSound) { sound in
                SoundDemoView(sound: sound) {
                    CandidateAudioPlayer.shared.stop()
                    selectedSound = nil
                    activeConvoSession = ConvoSession(mode: sound.mode)
                }
            }
        }
        .fullScreenCover(item: $activeConvoSession, onDismiss: {
            activeConvoSession = nil
        }) { session in
            NavigationStack {
                AIConvoView(
                    mode: session.mode,
                    onSavedToLibrary: { sound in
                        viewModel.add(sound)
                        activeConvoSession = nil
                    },
                    onCancel: {
                        activeConvoSession = nil
                    }
                )
                .id(session.id)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        let firstName = authViewModel.displayName.components(separatedBy: " ").first ?? authViewModel.displayName
        let initial = String(firstName.prefix(1)).uppercased()
        return HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(firstName)'s space")
                    .font(AppTheme.serifTitle(34))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(viewModel.library.statusText)
                    .font(AppTheme.labelCaps(13))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Circle()
                .fill(AppTheme.profileBackground)
                .frame(width: 36, height: 36)
                .overlay {
                    Text(initial)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                }
        }
    }

    private var activeModeStack: some View {
        let sounds = viewModel.library.activeModeSounds

        return VStack(alignment: .leading, spacing: 10) {
            if sounds.isEmpty {
                placeholderCard(for: viewModel.library.activeMode)
            } else {
                ForEach(Array(sounds.enumerated()), id: \.element.id) { index, sound in
                    soundCard(sound: sound, isNowPlaying: index == sounds.count - 1)
                }
            }

            cardActions(for: viewModel.library.activeMode)
        }
    }

    private var otherSavedStacks: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(viewModel.library.otherSavedModeGroups, id: \.mode) { group in
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(group.sounds.enumerated()), id: \.element.id) { index, sound in
                        soundCard(sound: sound, isNowPlaying: index == group.sounds.count - 1)
                    }
                    cardActions(for: group.mode)
                }
            }
        }
    }

    private func soundCard(sound: SavedSound, isNowPlaying: Bool) -> some View {
        VStack(spacing: 0) {
            SoundWaveIllustration(color: sound.mode.cardPrimaryColor)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 8) {
                Text(isNowPlaying ? "\(sound.categoryLabel) · NOW PLAYING" : sound.categoryLabel)
                    .font(AppTheme.labelCaps(11))
                    .tracking(1.2)
                    .foregroundStyle(sound.mode.cardPrimaryColor)

                Text(sound.title)
                    .font(AppTheme.serifTitle(30))
                    .foregroundStyle(sound.mode.cardPrimaryColor)

                Text(sound.subtitle)
                    .font(AppTheme.serifItalic(17))
                    .foregroundStyle(sound.mode.cardSecondaryColor)

                progressBar(for: sound.mode)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(sound.mode.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture { selectedSound = sound }
        .overlay(alignment: .topTrailing) {
            Button {
                viewModel.delete(sound)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(sound.mode.cardPrimaryColor.opacity(0.45))
                    .padding(18)
            }
            .buttonStyle(.plain)
        }
    }

    private func placeholderCard(for mode: CuratorMode) -> some View {
        VStack(spacing: 0) {
            SoundWaveIllustration(color: mode.cardPrimaryColor)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 8) {
                Text("\(mode.categoryLabel) · NOW PLAYING")
                    .font(AppTheme.labelCaps(11))
                    .tracking(1.2)
                    .foregroundStyle(mode.cardPrimaryColor)

                Text(mode.displayTitle)
                    .font(AppTheme.serifTitle(30))
                    .foregroundStyle(mode.cardPrimaryColor)

                Text(mode.modeDescription)
                    .font(AppTheme.serifItalic(17))
                    .foregroundStyle(mode.cardSecondaryColor)

                progressBar(for: mode)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(mode.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func cardActions(for mode: CuratorMode) -> some View {
        Button {
            CandidateAudioPlayer.shared.stop()
            activeConvoSession = ConvoSession(mode: mode)
        } label: {
            Text("add card")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func progressBar(for mode: CuratorMode) -> some View {
        HStack(spacing: 12) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(mode.progressTrackColor)
                        .frame(height: 2)

                    Capsule()
                        .fill(mode.cardPrimaryColor)
                        .frame(width: geometry.size.width * 0.32, height: 3)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 12)

            Text("∞")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(mode.cardPrimaryColor)
        }
    }

    @ViewBuilder
    private var modesSection: some View {
        let pending = viewModel.library.pendingModes
        if !pending.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("WHEN YOU'RE READY")
                    .font(AppTheme.labelCaps(11))
                    .tracking(1.2)
                    .foregroundStyle(AppTheme.textMuted)

                VStack(spacing: 8) {
                    ForEach(pending) { mode in
                        LibraryModeCard(mode: mode) {
                            CandidateAudioPlayer.shared.stop()
                            activeConvoSession = ConvoSession(mode: mode)
                        }
                    }
                }
            }
        }
    }
}

private struct LibraryModeCard: View {
    let mode: CuratorMode
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(mode.categoryLabel)
                        .font(AppTheme.labelCaps(11))
                        .tracking(1.2)
                        .foregroundStyle(AppTheme.textMuted)

                    Text(mode.modeDescription)
                        .font(AppTheme.serifItalic(17))
                        .foregroundStyle(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(AppTheme.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LibraryView(viewModel: LibraryViewModel(library: SoundLibrary(
        sounds: [
            SavedSound(title: "the living room", subtitle: "heater settling, the page turning", mode: .sleep),
            SavedSound(title: "winter at home", subtitle: "snow outside, quiet inside", mode: .sleep),
            SavedSound(title: "gentle morning", subtitle: "soft light, slow start", mode: .uplift),
        ],
        activeMode: .sleep
    )))
}
