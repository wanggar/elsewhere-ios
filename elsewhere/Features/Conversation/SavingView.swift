import SwiftUI

struct SavingView: View {
    let candidate: SoundCandidate
    var onBack: () -> Void
    var onSave: (String) -> Void

    @State private var soundName: String

    private let suggestions = [
        "the living room",
        "winter at home",
        "mom reading nearby",
        "the heater settling",
    ]

    init(candidate: SoundCandidate, onBack: @escaping () -> Void, onSave: @escaping (String) -> Void = { _ in }) {
        self.candidate = candidate
        self.onBack = onBack
        self.onSave = onSave
        _soundName = State(initialValue: candidate.title)
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                backButton
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        soundSummaryCard
                            .padding(.top, 20)

                        namingSection
                            .padding(.top, 32)

                        suggestionsSection
                            .padding(.top, 28)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                }

                saveButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var backButton: some View {
        Button(action: onBack) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 14, weight: .medium))
                Text("back")
                    .font(.system(size: 16))
            }
            .foregroundStyle(AppTheme.textSecondary)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var soundSummaryCard: some View {
        VStack(spacing: 12) {
            CompactSoundIcon()
                .padding(.top, 8)

            Text("SLEEP")
                .font(AppTheme.labelCaps(10))
                .tracking(1.2)
                .foregroundStyle(AppTheme.accentPurple)

            Text("the sound you chose")
                .font(AppTheme.serifTitle(22))
                .foregroundStyle(AppTheme.accentPurple)

            Text(candidate.subtitle)
                .font(AppTheme.serifItalic(16))
                .foregroundStyle(AppTheme.accentPurple.opacity(0.85))
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppTheme.nowPlayingBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var namingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What do you want to call this?")
                .font(AppTheme.serifTitle(28))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Something only you would recognize. A name for the memory, not the sound.")
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            TextField("", text: $soundName, prompt: Text("name your sound").foregroundStyle(AppTheme.textMuted))
                .font(AppTheme.serifTitle(20))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(AppTheme.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppTheme.inputBorder.opacity(0.6), lineWidth: 1)
                }
                .padding(.top, 8)
        }
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("OR TRY ONE OF THESE")
                .font(AppTheme.labelCaps(10))
                .tracking(1.2)
                .foregroundStyle(AppTheme.textMuted)

            FlowLayout(spacing: 10) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        soundName = suggestion
                    } label: {
                        Text(suggestion)
                            .font(AppTheme.serifTitle(15))
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .overlay {
                                Capsule()
                                    .stroke(AppTheme.textMuted.opacity(0.4), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            onSave(soundName)
        } label: {
            Text("save to your space")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AppTheme.creamButton)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SavingView(
        candidate: SoundCandidate(title: "the living room", subtitle: "heater settling, the page turning"),
        onBack: {}
    )
}
