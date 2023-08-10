import SwiftUI

@main
struct Rcl57App: App {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var appState = AppState()
    @StateObject private var emulatorState = EmulatorState()
    @StateObject private var settingsState = SettingsState()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .environmentObject(emulatorState)
                .environmentObject(settingsState)
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .background {
                _ = Rcl57.shared.saveState()
            }
        }
    }
}
