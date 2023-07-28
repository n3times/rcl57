import SwiftUI

@main
struct Rcl57App: App {
    @Environment(\.scenePhase) var scenePhase

    @StateObject var change = Change()
    @StateObject var settings = Settings()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(change)
                .environmentObject(settings)
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .background {
                _ = Rcl57.shared.save()
            }
        }
    }
}
