import SwiftUI

private enum AppRoute {
    case loading
    case intro
    case home
    case library
}

struct ContentView: View {
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
                    route = .home
                }
                .transition(.opacity)
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
            try? await Task.sleep(for: .seconds(3))
            route = .intro
        }
    }
}

#Preview {
    ContentView()
}
