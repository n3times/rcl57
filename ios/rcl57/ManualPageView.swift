import SwiftUI

/** A spectific page of the User Manual. */
struct ManualPageView: View {
    @EnvironmentObject private var change: Change

    let title: String
    let helpResource: String

    var body: some View {
        let helpURL = Bundle.main.url(forResource: helpResource, withExtension: "hlp")!

        GeometryReader { geometry in
            let width = geometry.size.width
            VStack(spacing: 0) {
                MenuBarView(change: change,
                            left: Style.leftArrow,
                            title: title,
                            right: Style.downArrow,
                            width: width,
                            leftAction: { withAnimation {change.showPageInManual = false} },
                            rightAction: { withAnimation {change.currentView = .calc} })
                .background(Style.deepGreen)

                HelpView(helpURL: helpURL)
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.bottom))
    }
}
