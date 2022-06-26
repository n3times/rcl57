import SwiftUI

@main
struct rcl57App: App {
    @Environment(\.scenePhase) var scenePhase

    let stateFilename = "rcl57.dat"

    init() {
        Settings.setFlavor(flavor: Settings.getFlavor())
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
