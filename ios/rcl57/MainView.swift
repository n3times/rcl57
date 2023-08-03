import SwiftUI

/**
 * The root view: a navigation-like view from where the user can access the different views.
 *
 * The CalcView, at the center, is the initial view:
 * - StateView <-> CalcView <-> LogView
 * - Above the CalcView: ManualView, SettingsView, and LibraryView
 */
struct MainView: View {
    @EnvironmentObject private var change: Change

    var body: some View {
        ZStack {
            let viewType = change.appLocation
            if viewType == .calc || viewType == .library || viewType == .manual || viewType == .settings {
                CalcView()
                    .transition(.move(
                        edge: change.previousAppLocation == .state ? .trailing : .leading
                    ))
                    .zIndex(0)
            }
            switch viewType {
            case .calc:
                EmptyView()
            case .state:
                StateView()
                    .transition(.move(edge: .leading))
            case .log:
                LogView()
                    .transition(.move(edge: .trailing))
            case .library:
                LibraryView()
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            case .manual:
                ManualView()
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            case .settings:
                SettingsView()
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
