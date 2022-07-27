import SwiftUI

struct ManualMainView: View {
    @EnvironmentObject private var change: Change

    let emulatorPages = [["About RCL-57", "about"],
                         ["Emulator Options", "options"],
                         ["Help Files", "help"]]

    let calculatorPages = [["Basics", "basics"],
                           ["Math", "math"],
                           ["Registers", "registers"],
                           ["Hello World", "hello"],
                           ["Flow Control", "flow"]]

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
                                    left: nil,
                                    title: "Manual",
                                    right: Style.downArrow,
                                    width: width,
                                    background: Style.deepGreen,
                                    leftAction: { },
                                    rightAction: { withAnimation {change.currentView = .calc} })
                        List {
                            Section("The Emulator") {
                                ForEach(emulatorPages, id: \.self) { page in
                                    Button(page[0]) {
                                        change.pageTitle = page[0]
                                        change.pageURL = page[1]
                                        withAnimation {
                                            change.showPageInManual = true
                                        }
                                    }
                                }
                            }
                            Section("The Calculator") {
                                ForEach(calculatorPages, id: \.self) { page in
                                    Button(page[0]) {
                                        change.pageTitle = page[0]
                                        change.pageURL = page[1]
                                        withAnimation {
                                            change.showPageInManual = true
                                        }
                                    }
                                }
                            }
                        }
                        .background(Color(UIColor.systemBackground))
                        .foregroundColor(Color.black)
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
    }
}
