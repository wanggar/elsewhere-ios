import SwiftUI

@main
struct elsewhereApp: App {
    @State private var authViewModel = AuthViewModel()
    @State private var appearanceManager = AppearanceManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(appearanceManager)
                .preferredColorScheme(appearanceManager.preference.preferredColorScheme)
        }
    }
}
