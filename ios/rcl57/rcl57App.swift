import SwiftUI

@main
struct rcl57App: App {
    @Environment(\.scenePhase) var scenePhase

    let stateFilename = "rcl57.dat"

    init() {
        Settings.setTurboSpeed(turbo: Settings.getTurboSpeed())
        Settings.setAlphaDisplay(alpha: Settings.getAlphaDisplay())
        Settings.setHPLrnMode(hpLrn: Settings.getHPLrnMode())
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            if newScenePhase == .inactive {
                _ = Rcl57.shared.save(filename: stateFilename)
            }
        }
    }
}
