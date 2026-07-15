import SwiftUI

struct PostConvoIntroView: View {
    var onBegin: () -> Void

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                LoadingPulseIcon()
                    .padding(.bottom, 40)

                Text("FROM WHAT YOU SHARED")
                    .font(AppTheme.labelCaps(11))
                    .tracking(1.2)
                    .foregroundStyle(AppTheme.textMuted)
                    .padding(.bottom, 16)

                Text("I made three things that sound like your winter.")
                    .font(AppTheme.serifTitle(30))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()

                Text("headphones, if you can")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textMuted)
                    .padding(.bottom, 20)

                Button(action: onBegin) {
                    Text("begin")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.creamButton)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    PostConvoIntroView(onBegin: {})
}
