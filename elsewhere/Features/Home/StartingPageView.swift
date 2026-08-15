import SwiftUI

struct StartingModeOption: Identifiable {
    let id = UUID()
    let mode: CuratorMode
    let title: String
    let subtitle: String
    let background: Color
    let titleColor: Color
    let subtitleColor: Color
}

struct StartingPageView: View {
    var onSavedToLibrary: (SavedSound) -> Void = { _ in }

    @Environment(AuthViewModel.self) private var authViewModel
    @State private var activeConvoSession: ConvoSession?
    @State private var showSettings = false

    private let gridOptions: [StartingModeOption] = [
        StartingModeOption(
            mode: .focus,
            title: "to focus",
            subtitle: "deep work",
            background: AppTheme.focusCardBackground,
            titleColor: AppTheme.focusText,
            subtitleColor: AppTheme.focusText.opacity(0.75)
        ),
        StartingModeOption(
            mode: .relax,
            title: "to relax",
            subtitle: "unwind",
            background: AppTheme.relaxCardBackground,
            titleColor: AppTheme.relaxText,
            subtitleColor: AppTheme.relaxText.opacity(0.75)
        ),
        StartingModeOption(
            mode: .uplift,
            title: "to uplift",
            subtitle: "gentle start",
            background: AppTheme.upliftCardBackground,
            titleColor: AppTheme.upliftText,
            subtitleColor: AppTheme.upliftText.opacity(0.75)
        ),
        StartingModeOption(
            mode: .move,
            title: "to move",
            subtitle: "walking",
            background: AppTheme.moveCardBackground,
            titleColor: AppTheme.moveCardText,
            subtitleColor: AppTheme.moveCardSecondaryText
        ),
    ]

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    greetingHeader
                        .padding(.top, 8)

                    headline
                        .padding(.top, 28)

                    suggestedCard
                        .padding(.top, 28)

                    alternativesSection
                        .padding(.top, 28)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
        }
        .fullScreenCover(item: $activeConvoSession, onDismiss: {
            activeConvoSession = nil
        }) { session in
            NavigationStack {
                AIConvoView(
                    mode: session.mode,
                    onSavedToLibrary: { sound in
                        onSavedToLibrary(sound)
                        activeConvoSession = nil
                    },
                    onCancel: {
                        activeConvoSession = nil
                    }
                )
                .id(session.id)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var firstName: String {
        authViewModel.displayName.components(separatedBy: " ").first ?? authViewModel.displayName
    }

    private var profileInitial: String {
        String(firstName.prefix(1)).uppercased()
    }

    private var greetingHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            Button { showSettings = true } label: {
                Circle()
                    .fill(AppTheme.profileBackground)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text(profileInitial)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")

            VStack(alignment: .leading, spacing: 2) {
                Text("Hi \(firstName)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("a quiet Tuesday night")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textMuted)
            }
        }
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Let's start with something for tonight.")
                .font(AppTheme.serifTitle(28))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("You can add the others whenever you're ready.")
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var suggestedCard: some View {
        Button {
            activeConvoSession = ConvoSession(mode: .sleep)
        } label: {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SUGGESTED FOR NOW")
                        .font(AppTheme.labelCaps(10))
                        .tracking(1.2)
                        .foregroundStyle(AppTheme.accentPurple)

                    Text("to sleep")
                        .font(AppTheme.serifTitle(26))
                        .foregroundStyle(AppTheme.accentPurple)

                    Text("when your mind won't slow down")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.accentPurple.opacity(0.8))
                }

                Spacer(minLength: 12)

                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.accentPurple)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 22)
            .background(AppTheme.sleepCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var alternativesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("or start somewhere else")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textMuted)

            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(gridOptions) { option in
                    ModeOptionCard(option: option) {
                        activeConvoSession = ConvoSession(mode: option.mode)
                    }
                }
            }
        }
    }
}

struct ModeOptionCard: View {
    let option: StartingModeOption
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Text(option.title)
                    .font(AppTheme.serifTitle(22))
                    .foregroundStyle(option.titleColor)

                Text(option.subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(option.subtitleColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .background(option.background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StartingPageView()
        .environment(AuthViewModel())
        .environment(AppearanceManager())
}
