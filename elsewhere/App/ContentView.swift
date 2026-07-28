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

    var body: some View {
        Group {
            switch route {
            case .loading:
                LoadingView()
                    .transition(.opacity)

            case .intro:
                FirstPageView {
                    route = .signIn
                }
                .transition(.opacity)

            case .signIn:
                SignInView()
                    .transition(.opacity)
                    .onChange(of: authViewModel.state) { _, newState in
                        if case .signedIn = newState {
                            Task { await loadLibraryAndNavigate() }
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
        .task {
            guard route == .loading else { return }
            try? await Task.sleep(for: .seconds(2))
            await resolveInitialRoute()
        }
    }

    // MARK: - Route resolution

    private func resolveInitialRoute() async {
        authViewModel.checkExistingSession()

        if case .signedIn = authViewModel.state {
            await loadLibraryAndNavigate()
        } else {
            route = .intro
        }
    }

    private func loadLibraryAndNavigate() async {
        await libraryViewModel.fetchLibrary()
        route = libraryViewModel.library.sounds.isEmpty ? .home : .library
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
}
