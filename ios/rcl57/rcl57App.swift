import SwiftUI

@main
struct rcl57App: App {
    @Environment(\.scenePhase) var scenePhase

    init() {
        // Technically this is only necessary if the state is not loaded from a file.
        Settings.setTurboSpeed(Settings.getTurboSpeed())
        Settings.setAlphaDisplay(Settings.getAlphaDisplay())
        Settings.setHPLrnMode(Settings.getHPLrnMode())
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .inactive {
                _ = Rcl57.shared.save()
            }
        }
    }
}
