import SwiftUI

@main
struct rcl57App: App {
    @Environment(\.scenePhase) var scenePhase

    let stateFilename = "rcl57.dat"
    var rcl57: Rcl57

    init() {
        rcl57 = Rcl57(filename: stateFilename)
        Settings.setFlavor(flavor: Settings.getFlavor(), rcl57: rcl57)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            if newScenePhase == .inactive {
                _ = self.rcl57.save(filename: stateFilename)
            }
        }
    }
}
