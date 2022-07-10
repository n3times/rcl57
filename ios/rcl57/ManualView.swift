import SwiftUI

struct ManualView: View {
    @EnvironmentObject private var change: Change

    @State var pageTitle = ""
    @State var pageURL = ""

    let hlpPages = [["About", "about", "About RCL-57"],
                    ["Options", "options", "Emulator Options"],
                    ["Basics", "basics", "Calculator Basics"],
                    ["Math", "math", "Math Functions"],
                    ["Registers", "registers", "Registers"],
                    ["Hello World", "hello", "Hello World"],
                    ["Flow Control", "flow", "Flow Control"],
                    ["Help Files", "help", "Help Files"]]

    var body: some View {
        ZStack {
            if change.showPageInHelp {
                ManualPageView(title: pageTitle, hlpResource: pageURL)
                    .transition(.move(edge: .trailing))
            }

            if !change.showPageInHelp {
                GeometryReader { geometry in
                    let width = geometry.size.width

                    VStack(spacing: 0) {
                        MenuBarView(change: change,
                                    left: Style.leftArrow,
                                    title: "Help",
                                    right: Style.downArrow,
                                    width: width,
                                    leftAction: { withAnimation {change.showHelpInSettings = false} },
                                    rightAction: { withAnimation {change.currentView = .calc} })
                        List {
                            ForEach(hlpPages, id: \.self) { hlpPage in
                                Button(hlpPage[2]) {
                                    pageTitle = hlpPage[0]
                                    pageURL = hlpPage[1]
                                    withAnimation {
                                        change.showPageInHelp = true
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
    }

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
                                leftAction: { withAnimation {change.showPageInHelp = false} },
                                rightAction: { withAnimation {change.currentView = .calc} })
                    HelpView(hlpURL: hlpURL)
                }
            }
        }
    }
}
