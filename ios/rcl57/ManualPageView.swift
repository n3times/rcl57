import SwiftUI

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
                            background: Style.deepGreen,
                            leftAction: { withAnimation {change.showPageInManual = false} },
                            rightAction: { withAnimation {change.currentView = .calc} })
                HelpView(helpURL: helpURL)
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.bottom))
    }
}
