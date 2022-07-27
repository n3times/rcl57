/**
 * The main view. It holds the calculator,  log, state, settings and library views.
 */

import SwiftUI

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

    private func getMainView(_ geometry: GeometryProxy) -> some View {
        ZStack {
            if change.currentView == .calc || change.currentView == .settings || change.currentView == .library || change.currentView == .manual {
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

            if change.currentView == .log {
                LogView()
                    .environmentObject(change)
                    .transition(.move(edge: .trailing))
            } else if change.currentView == .state {
                StateView()
                    .environmentObject(change)
                    .transition(.move(edge: .leading))
            }
        }
    }

    var body: some View {
        return GeometryReader { geometry in
            self.getMainView(geometry)
        }
        .onReceive(timerPublisher) { _ in
            burst(ms: 20)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
