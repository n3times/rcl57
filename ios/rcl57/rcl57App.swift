import SwiftUI

@main
struct rcl57App: App {
    @Environment(\.scenePhase) var scenePhase

    let stateFilename = "rcl57.dat"
    var rcl57:RCL57?

    init() {
        rcl57 = RCL57(filename: stateFilename)
        if rcl57 == nil {
            rcl57 = RCL57()
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView(rcl57: rcl57!)
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            if newScenePhase == .inactive {
                _ = self.rcl57?.save(filename: stateFilename)
            }
        }
    }
}
