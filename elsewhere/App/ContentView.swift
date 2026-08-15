import SwiftUI

private enum AppRoute {
    case loading
    case intro
    case home
    case library
}

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var route: AppRoute = .loading
    @State private var libraryViewModel = LibraryViewModel()

    var body: some View {
        Group {
            switch route {
            case .loading:
                LoadingView()
                    .transition(.opacity)

            case .intro:
                FirstPageView()
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
                route = .intro
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
            route = .library
        } else {
            route = .intro
        }
    }

    private func routeAfterSignIn() async {
        await libraryViewModel.fetchLibrary()
        route = libraryViewModel.library.sounds.isEmpty ? .home : .library
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
        .environment(AppearanceManager())
}
