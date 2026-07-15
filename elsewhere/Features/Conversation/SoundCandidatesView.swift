import SwiftUI

struct SoundCandidate: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let audioURL: URL?

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        audioURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.audioURL = audioURL
    }
}

struct SoundCandidatesView: View {
    let headerTitle: String
    let candidates: [SoundCandidate]
    var onSelect: (SoundCandidate) -> Void
    var onSave: (SoundCandidate) -> Void
    var onTryAgain: () -> Void

    @State private var selectedIndex = 0

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 12)

                candidateList
                    .padding(.top, 28)

                Spacer()

                actionButtons
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if candidates.indices.contains(selectedIndex) {
                onSelect(candidates[selectedIndex])
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(headerTitle.uppercased())
                .font(AppTheme.labelCaps(11))
                .tracking(1.2)
                .foregroundStyle(AppTheme.textMuted)

            Text("Try each one. Sit with the one that feels closest.")
                .font(AppTheme.serifTitle(28))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var candidateList: some View {
        VStack(spacing: 12) {
            ForEach(Array(candidates.enumerated()), id: \.element.id) { index, candidate in
                SoundCandidateCard(
                    candidate: candidate,
                    isSelected: selectedIndex == index
                ) {
                    selectedIndex = index
                    onSelect(candidate)
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {
            Button {
                guard candidates.indices.contains(selectedIndex) else { return }
                onSave(candidates[selectedIndex])
            } label: {
                Text("save this one")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.creamButton)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(candidates.isEmpty)

            Button(action: onTryAgain) {
                Text("try again")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(.plain)
        }
    }
}

struct SoundCandidateCard: View {
    let candidate: SoundCandidate
    let isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                if isSelected {
                    Circle()
                        .fill(AppTheme.accentPurple)
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.white.opacity(0.9))
                        }
                } else {
                    Circle()
                        .stroke(AppTheme.textMuted.opacity(0.5), lineWidth: 1)
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "play.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.textMuted)
                                .offset(x: 1)
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(candidate.title)
                        .font(AppTheme.serifTitle(20))
                        .foregroundStyle(isSelected ? AppTheme.accentPurple : AppTheme.textPrimary)

                    Text(candidate.subtitle)
                        .font(AppTheme.serifItalic(15))
                        .foregroundStyle(isSelected ? AppTheme.accentPurple.opacity(0.8) : AppTheme.textSecondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(isSelected ? AppTheme.nowPlayingBackground : AppTheme.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SoundCandidatesView(
        headerTitle: "YOUR WINTER, THREE WAYS",
        candidates: [
            SoundCandidate(title: "the living room", subtitle: "heater settling, the page turning"),
            SoundCandidate(title: "the window, snowing", subtitle: "muffled street, faint wind"),
            SoundCandidate(title: "just the heater", subtitle: "stripped down, just clicks and hum"),
        ],
        onSelect: { _ in },
        onSave: { _ in },
        onTryAgain: {}
    )
}
