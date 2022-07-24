import SwiftUI

struct ManualPageView: View {
    @EnvironmentObject private var change: Change

    let title: String
    let hlpResource: String
    var hlpURL: URL {
        Bundle.main.url(forResource: hlpResource, withExtension: "hlp")!
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            VStack(spacing: 0) {
                MenuBarView(change: change,
                            left: Style.leftArrow,
                            title: title,
                            right: Style.downArrow,
                            width: width,
                            background: Style.deepGreen,
                            leftAction: { withAnimation {change.showPageInHelp = false} },
                            rightAction: { withAnimation {change.currentView = .calc} })
                HelpView(hlpURL: hlpURL)
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.bottom))
    }
}

struct ManualMainView: View {
    @EnvironmentObject private var change: Change

    let hlpPages = [["About RCL-57", "about"],
                    ["Emulator Options", "options"],
                    ["Calculator Basics", "basics"],
                    ["Math Functions", "math"],
                    ["Registers", "registers"],
                    ["Hello World", "hello"],
                    ["Flow Control", "flow"],
                    ["Help Files", "help"]]

    var body: some View {
        ZStack {
            if change.showPageInHelp {
                ManualPageView(title: change.pageTitle, hlpResource: change.pageURL)
                    .transition(.move(edge: .trailing))
            }

            if !change.showPageInHelp {
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
                            ForEach(hlpPages, id: \.self) { hlpPage in
                                Button(hlpPage[0]) {
                                    change.pageTitle = hlpPage[0]
                                    change.pageURL = hlpPage[1]
                                    withAnimation {
                                        change.showPageInHelp = true
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
