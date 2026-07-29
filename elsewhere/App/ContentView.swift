import SwiftUI

private enum AppRoute {
    case loading
    case intro
    case signIn
    case home
    case library
}

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var route: AppRoute = .loading
    @State private var libraryViewModel = LibraryViewModel()
    @State private var hasSeenIntro = false

    var body: some View {
        Group {
            switch route {
            case .loading:
                LoadingView()
                    .transition(.opacity)

            case .intro:
                FirstPageView {
                    hasSeenIntro = true
                    route = .signIn
                }
                .transition(.opacity)

            case .signIn:
                SignInView()
                    .transition(.opacity)
                    .onChange(of: authViewModel.state) { _, newState in
                        if case .signedIn = newState {
                            Task { await routeAfterSignIn() }
                        }
                    }

            case .home:
                StartingPageView { sound in
                    libraryViewModel.add(sound)
                    route = .library
                }
                .transition(.opacity)

            case .library:
                LibraryView(viewModel: libraryViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: route)
        .onChange(of: authViewModel.state) { _, newState in
            if case .signedOut = newState {
                libraryViewModel = LibraryViewModel()
                route = hasSeenIntro ? .signIn : .intro
            }
        }
        .task {
            guard route == .loading else { return }
            await resolveInitialRoute()
        }
    }

    // MARK: - Route resolution

    private func resolveInitialRoute() async {
        authViewModel.checkExistingSession()

        if case .signedIn = authViewModel.state {
            // Returning signed-in user — go straight to library.
            // LibraryView fetches content on appear; no need to block routing on a network call.
            route = .library
        } else {
            route = .intro
        }
    }

    /// Called only after a fresh Apple sign-in — checks whether the library
    /// already has sounds and routes accordingly.
    private func routeAfterSignIn() async {
        await libraryViewModel.fetchLibrary()
        route = libraryViewModel.library.sounds.isEmpty ? .home : .library
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
}
