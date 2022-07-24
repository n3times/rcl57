import SwiftUI

struct ManualMainView: View {
    @EnvironmentObject private var change: Change

    let manualPages = [["About RCL-57", "about"],
                       ["Emulator Options", "options"],
                       ["Calculator Basics", "basics"],
                       ["Math Functions", "math"],
                       ["Registers", "registers"],
                       ["Hello World", "hello"],
                       ["Flow Control", "flow"],
                       ["Help Files", "help"]]

    var body: some View {
        ZStack {
            if change.showPageInManual {
                ManualPageView(title: change.pageTitle, helpResource: change.pageURL)
                    .transition(.move(edge: .trailing))
            }

            if !change.showPageInManual {
                GeometryReader { geometry in
                    let width = geometry.size.width

                    VStack(spacing: 0) {
                        MenuBarView(change: change,
                                    left: Style.leftArrow,
                                    title: "RCL-57 Manual",
                                    right: Style.downArrow,
                                    width: width,
                                    background: Style.deepGreen,
                                    leftAction: { withAnimation {change.showHelpInSettings = false} },
                                    rightAction: { withAnimation {change.currentView = .calc} })
                        List {
                            ForEach(manualPages, id: \.self) { manualPage in
                                Button(manualPage[0]) {
                                    change.pageTitle = manualPage[0]
                                    change.pageURL = manualPage[1]
                                    withAnimation {
                                        change.showPageInManual = true
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .background(Color(UIColor.systemBackground))
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
    }
}
