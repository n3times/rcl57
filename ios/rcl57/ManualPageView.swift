import SwiftUI

/** A spectific page of the User Manual. */
struct ManualPageView: View, Hashable {
    @EnvironmentObject private var change: Change

    let title: String
    let helpResource: String

    var body: some View {
        let helpURL = Bundle.main.url(forResource: helpResource, withExtension: "hlp")!

        GeometryReader { geometry in
            let width = geometry.size.width
            VStack(spacing: 0) {
                MenuBarView(left: Style.leftArrow,
                            title: title,
                            right: Style.downArrow,
                            width: width,
                            leftAction: { withAnimation {change.manualPageView = nil} },
                            rightAction: { withAnimation {change.currentView = .calc} })
                .background(Color.deepGreen)

                HelpView(helpURL: helpURL)
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.bottom))
    }

    // MARK: Hashable Conformance

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.helpResource)
    }

    static func ==(lhs: ManualPageView, rhs: ManualPageView) -> Bool {
        return lhs.helpResource == rhs.helpResource
    }
}
