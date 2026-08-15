import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            AppTheme.loadingBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                LoadingPulseIcon(logoSize: 140)
                    .padding(.bottom, 36)

                Text("A sound from your life, for\nthe moments you need it.")
                    .font(AppTheme.serifTitle(26))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)

                Spacer()

                pageIndicator
                    .padding(.bottom, 48)
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppTheme.textSecondary)
                .frame(width: 6, height: 6)

            Circle()
                .fill(AppTheme.textMuted.opacity(0.45))
                .frame(width: 6, height: 6)

            Circle()
                .fill(AppTheme.textMuted.opacity(0.45))
                .frame(width: 6, height: 6)
        }
    }
}

#Preview {
    LoadingView()
}
