import SwiftUI

/** The list of topics of the User Manual. */
struct ManualMainView: View {
    @EnvironmentObject private var change: Change

    let emulatorPages = [["Options", "options"],
                         ["Using the Library", "library"],
                         ["Writing Help Files", "help"]]

    let calculatorPages = [["Basics", "basics"],
                           ["Math Functions", "math"],
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
                                    title: "User Manual",
                                    right: Style.downArrow,
                                    width: width,
                                    leftAction: { },
                                    rightAction: { withAnimation {change.currentView = .calc} })
                        .background(Style.deepGreen)

                        List {
                            Button("About") {
                                change.pageTitle = "About"
                                change.pageURL = "about"
                                withAnimation {
                                    change.showPageInManual = true
                                }
                            }
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
