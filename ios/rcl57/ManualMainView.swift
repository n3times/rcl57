import SwiftUI

/** The list of topics of the User Manual. */
struct ManualMainView: View {
    @EnvironmentObject private var change: Change

    let aboutPage = ManualPageView(title: "About", helpResource: "about")

    let emulatorPages = [ManualPageView(title: "Options", helpResource: "options"),
                         ManualPageView(title: "Using the Library", helpResource: "library"),
                         ManualPageView(title: "Writing Help Files", helpResource: "help")]

    let calculatorPages = [ManualPageView(title: "Basics", helpResource: "basics"),
                           ManualPageView(title: "Math Functions", helpResource: "math"),
                           ManualPageView(title: "Registers", helpResource: "registers"),
                           ManualPageView(title: "Hello World", helpResource: "hello"),
                           ManualPageView(title: "Flow Control", helpResource: "flow")]

    var body: some View {
        ZStack {
            if change.manualPageView == nil {
                GeometryReader { geometry in
                    let width = geometry.size.width

                    VStack(spacing: 0) {
                        MenuBarView(left: nil,
                                    title: "User Manual",
                                    right: Style.downArrow,
                                    width: width,
                                    leftAction: { },
                                    rightAction: { withAnimation {change.currentView = .calc} })
                        .background(Color.deepGreen)

                        List {
                            Button("About") {
                                withAnimation {
                                    change.manualPageView = aboutPage
                                }
                            }
                            Section("The Emulator") {
                                ForEach(emulatorPages, id: \.self) { page in
                                    Button(page.title) {
                                        withAnimation {
                                            change.manualPageView = page
                                        }
                                    }
                                }
                            }
                            Section("The Calculator") {
                                ForEach(calculatorPages, id: \.self) { page in
                                    Button(page.title) {
                                        withAnimation {
                                            change.manualPageView = page
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

            if change.manualPageView != nil {
                change.manualPageView
                    .transition(.move(edge: .trailing))
            }
        }
    }
}
