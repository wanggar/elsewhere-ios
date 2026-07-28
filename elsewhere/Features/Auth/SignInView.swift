import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 60)
                    .padding(.horizontal, 28)

                Spacer()

                bottomSection
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("elsewhere")
                .font(AppTheme.serifTitle(38))
                .foregroundStyle(AppTheme.textPrimary)

            Text("A sound from your life,\nfor the moments you need it.")
                .font(AppTheme.serifItalic(20))
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Bottom section

    private var bottomSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.accentPurple)
            }

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { _ in
                // Delegate-based — result handled in AuthService
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .disabled(authViewModel.isLoading)
            .onTapGesture {
                Task { await authViewModel.signInWithApple() }
            }

            Text("Your sounds are private and only stored on your account.")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.textMuted)
        }
    }
}

#Preview {
    SignInView()
        .environment(AuthViewModel())
}
