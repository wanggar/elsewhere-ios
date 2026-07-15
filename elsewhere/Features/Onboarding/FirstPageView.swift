import SwiftUI

struct FirstPageView: View {
    var onFindYours: () -> Void = {}

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 12)

                playerCard
                    .padding(.top, 36)

                Spacer()

                swipeHint

                findYoursButton
                    .padding(.top, 28)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SLEEP · MAYA, 24")
                .font(AppTheme.labelCaps(11))
                .tracking(1.2)
                .foregroundStyle(AppTheme.textMuted)

            Text("A-ma's kitchen, 9pm.")
                .font(AppTheme.serifTitle(34))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }

    private var playerCard: some View {
        VStack(spacing: 18) {
            HStack(spacing: 16) {
                Button(action: {}) {
                    Circle()
                        .fill(AppTheme.playBlue)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.textPrimary)
                                .offset(x: 1)
                        }
                }
                .buttonStyle(.plain)

                Text("tap to listen — no sign-in needed")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)

                Spacer(minLength: 0)
            }

            previewProgressBar
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(AppTheme.playerCardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var previewProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.progressTrack)
                    .frame(height: 3)

                Capsule()
                    .fill(AppTheme.playBlue)
                    .frame(width: geometry.size.width * 0.33, height: 3)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 8)
    }

    private var swipeHint: some View {
        Text("→ swipe for Jordan, Sam, Lin")
            .font(.system(size: 14))
            .foregroundStyle(AppTheme.textMuted)
            .frame(maxWidth: .infinity)
    }

    private var findYoursButton: some View {
        Button(action: onFindYours) {
            HStack(spacing: 6) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 16, weight: .medium))

                Text("find yours")
                    .font(.system(size: 17, weight: .medium))
            }
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
    FirstPageView()
}
