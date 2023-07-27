import SwiftUI

@main
struct Rcl57App: App {
    @Environment(\.scenePhase) var scenePhase

    init() {
        // Technically this is only necessary if the state is not loaded from a file.
        Settings.hasTurboSpeed = Settings.hasTurboSpeed
        Settings.hasAlphaDisplay = Settings.hasAlphaDisplay
        Settings.hasHpLrnMode = Settings.hasHpLrnMode
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .background {
                _ = Rcl57.shared.save()
            }
        }
    }
}
