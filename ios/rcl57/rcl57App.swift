import SwiftUI

@main
struct rcl57App: App {
    @Environment(\.scenePhase) var scenePhase

    let stateFilename = "penta7.dat"
    var penta7:Penta7?

    init() {
        penta7 = Penta7(filename: stateFilename)
        if penta7 == nil {
            penta7 = Penta7()
        }
    }

    var body: some Scene {
        WindowGroup {
            CalcView(penta7: penta7!)
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            if newScenePhase == .inactive {
                _ = self.penta7?.save(filename: stateFilename)
            }
        }
    }
}
