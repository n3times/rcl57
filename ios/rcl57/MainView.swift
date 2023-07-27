import SwiftUI

/**
 * The main view. It holds the calculator, log, state, settings, library and manual views.
 *
 * This view is the root view of the view hierarchy of the app.
 */
struct MainView: View {
    @StateObject private var change = Change()

    private let timerPublisher = Timer.TimerPublisher(interval: 0.02, runLoop: .main, mode: .default)
        .autoconnect()

    @State var showBack = false

    private func burst(ms: Int32) {
        _ = Rcl57.shared.advance(ms: ms)
        change.updateLogTimestamp()
        change.updateDisplayString()
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if change.currentView != .state && change.currentView != .log {
                    CalcView()
                        .transition(.move(edge: change.transitionEdge))
                    if change.currentView == .library {
                        LibraryView()
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    }
                    if change.currentView == .settings {
                        SettingsView()
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    }
                    if change.currentView == .manual {
                        ManualMainView()
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    }
                }

                if change.currentView == .state {
                    StateView()
                        .transition(.move(edge: .leading))
                } else if change.currentView == .log {
                    LogView()
                        .transition(.move(edge: .trailing))
                }
            }
            .onReceive(timerPublisher) { _ in
                burst(ms: 20)
            }
        }
        .environmentObject(change)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
