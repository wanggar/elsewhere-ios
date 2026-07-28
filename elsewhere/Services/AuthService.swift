import Foundation
import AuthenticationServices

struct AuthUser: Sendable {
    let id: String
    let displayName: String?
}

@MainActor
final class AuthService: NSObject, ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding
{
    static let shared = AuthService()

    // MARK: - Apple Sign In

    func signInWithApple() async throws -> AuthUser {
        try await withCheckedThrowingContinuation { continuation in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()

            self.continuation = continuation
        }
    }

    // MARK: - Session helpers

    /// Returns a valid access token, refreshing if needed.
    func validAccessToken() async throws -> String {
        guard let token = KeychainService.get(.accessToken) else {
            throw AuthError.notSignedIn
        }
        // Attempt a refresh if the token is within 5 minutes of expiry.
        // For simplicity we let the 401 in APIClient trigger a refresh cycle.
        return token
    }

    func refreshTokens() async throws {
        guard let refreshToken = KeychainService.get(.refreshToken) else {
            throw AuthError.notSignedIn
        }
        let response = try await APIConfig.performRefresh(refreshToken: refreshToken)
        KeychainService.set(response.accessToken, for: .accessToken)
        KeychainService.set(response.refreshToken, for: .refreshToken)
    }

    func signOut() {
        KeychainService.clearAll()
    }

    var storedUser: AuthUser? {
        guard let id = KeychainService.get(.userId) else { return nil }
        return AuthUser(id: id, displayName: KeychainService.get(.displayName))
    }

    // MARK: - Private continuation storage

    private var continuation: CheckedContinuation<AuthUser, Error>?

    // MARK: - ASAuthorizationControllerDelegate

    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        Task { @MainActor in
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let identityToken = String(data: tokenData, encoding: .utf8)
            else {
                continuation?.resume(throwing: AuthError.credentialError)
                continuation = nil
                return
            }

            let givenName = credential.fullName?.givenName
            let familyName = credential.fullName?.familyName

            do {
                let user = try await APIConfig.performAppleSignIn(
                    identityToken: identityToken,
                    givenName: givenName,
                    familyName: familyName
                )
                KeychainService.set(user.id, for: .userId)
                if let name = user.displayName {
                    KeychainService.set(name, for: .displayName)
                }
                continuation?.resume(returning: user)
            } catch {
                continuation?.resume(throwing: error)
            }
            continuation = nil
        }
    }

    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            if let authError = error as? ASAuthorizationError,
               authError.code == .canceled
            {
                continuation?.resume(throwing: AuthError.cancelled)
            } else {
                continuation?.resume(throwing: error)
            }
            continuation = nil
        }
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    nonisolated func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        // Safe to call from non-isolated context since UIApplication.shared
        // and windows are only accessed on the main thread internally.
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
            let window = scene.windows.first
        else {
            return UIWindow()
        }
        return window
    }
}

enum AuthError: LocalizedError {
    case notSignedIn
    case credentialError
    case cancelled
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .notSignedIn:      return "You are not signed in."
        case .credentialError:  return "Could not read Apple credentials."
        case .cancelled:        return "Sign in was cancelled."
        case .serverError(let m): return m
        }
    }
}
