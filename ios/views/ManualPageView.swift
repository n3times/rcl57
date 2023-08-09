import SwiftUI

/// A page of the User Manual.
struct ManualPageView: View {
    @EnvironmentObject private var appState: AppState

    let title: String
    let resource: String

    var body: some View {
        let helpURL = Bundle.main.url(forResource: resource, withExtension: "hlp")
        VStack(spacing: 0) {
            NavigationBar(left: Style.leftArrow,
                          title: title,
                          right: Style.downArrow,
                          leftAction: { withAnimation { appState.manualBookmark = nil } },
                          rightAction: { withAnimation { appState.appLocation = .calc } })
            .background(Color.deepGreen)

            if let helpURL {
                HelpView(helpURL: helpURL)
            } else {
                Text("No help page")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.bottom))
    }
}
