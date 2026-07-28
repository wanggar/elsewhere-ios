import Foundation
import Observation

enum AuthState: Equatable {
    case unknown
    case signedOut
    case signedIn(AuthUser)

    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown), (.signedOut, .signedOut): return true
        case (.signedIn(let a), .signedIn(let b)): return a.id == b.id
        default: return false
        }
    }
}

@MainActor
@Observable
final class AuthViewModel {
    private(set) var state: AuthState = .unknown
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    func checkExistingSession() {
        if let user = AuthService.shared.storedUser {
            state = .signedIn(user)
        } else {
            state = .signedOut
        }
    }

    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await AuthService.shared.signInWithApple()
            state = .signedIn(user)
        } catch AuthError.cancelled {
            // User cancelled — no error message needed
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() {
        AuthService.shared.signOut()
        state = .signedOut
    }

    var currentUser: AuthUser? {
        if case .signedIn(let user) = state { return user }
        return nil
    }

    var displayName: String {
        currentUser?.displayName ?? "you"
    }
}
