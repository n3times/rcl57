import SwiftUI

/**
 * The main view. It holds the calculator,  log, state, settings, library and manual views.
 */
struct MainView: View {
    private let timerPublisher = Timer.TimerPublisher(interval: 0.02, runLoop: .main, mode: .default)
        .autoconnect()

    @StateObject private var change: Change
    @State var showBack = false

    init() {
        _change = StateObject(wrappedValue: Change())
    }

    private func burst(ms: Int32) {
        _ = Rcl57.shared.advance(ms: ms)
        change.updateLogTimestamp()
        change.updateDisplayString()
    }

    var body: some View {
        return GeometryReader { geometry in
            ZStack {
                if change.currentView != .state && change.currentView != .log {
                    CalcView()
                        .environmentObject(change)
                        .transition(.move(edge: change.transitionEdge))
                    if change.currentView == .library {
                        LibraryView()
                            .environmentObject(change)
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    }
                    if change.currentView == .settings {
                        SettingsView()
                            .environmentObject(change)
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    }
                    if change.currentView == .manual {
                        ManualMainView()
                            .environmentObject(change)
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    }
                }

                if change.currentView == .state {
                    StateView()
                        .environmentObject(change)
                        .transition(.move(edge: .leading))
                } else if change.currentView == .log {
                    LogView()
                        .environmentObject(change)
                        .transition(.move(edge: .trailing))
                }
            }
            .onReceive(timerPublisher) { _ in
                burst(ms: 20)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
