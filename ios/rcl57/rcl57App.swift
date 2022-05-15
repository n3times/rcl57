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
        Settings.setOriginalDisplay(has_original_display: Settings.hasOriginalDisplay(), rcl57: rcl57!)
        Settings.setOriginalLrn(has_original_lrn: Settings.hasOriginalLrn(), rcl57: rcl57!)
        Settings.setOriginalSpeed(has_original_speed: Settings.hasOriginalSpeed(), rcl57: rcl57!)
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
