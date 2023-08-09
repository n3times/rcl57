import SwiftUI

/// The list of manual pages.
struct ManualView: View {
    @EnvironmentObject private var appState: AppState

    struct PageData: Hashable {
        let title: String
        let resource: String
    }

    private let aboutPageData = PageData(title: "About", resource: "about")

    private let emulatorPagesData = [PageData(title: "Options", resource: "options"),
                                     PageData(title: "Using the Library", resource: "library"),
                                     PageData(title: "Writing Help Files", resource: "help")]

    private let calculatorPagesData = [PageData(title: "Basics", resource: "basics"),
                                       PageData(title: "Math Functions", resource: "math"),
                                       PageData(title: "Registers", resource: "registers"),
                                       PageData(title: "Hello World", resource: "hello"),
                                       PageData(title: "Flow Control", resource: "flow")]

    var body: some View {
        ZStack {
            if let pageData = appState.manualBookmark {
                ManualPageView(title: pageData.title, resource: pageData.resource)
                    .transition(.move(edge: .trailing))
            } else {
                VStack(spacing: 0) {
                    NavigationBar(left: nil,
                                  title: "User Manual",
                                  right: Style.downArrow,
                                  leftAction: nil,
                                  rightAction: { withAnimation { appState.appLocation = .calc } })
                    .background(Color.deepGreen)
                    List {
                        Button("About") {
                            withAnimation {
                                appState.manualBookmark = aboutPageData
                            }
                        }
                        Section("The Emulator") {
                            ForEach(emulatorPagesData, id: \.self) { pageData in
                                Button(pageData.title) {
                                    withAnimation {
                                        appState.manualBookmark = pageData
                                    }
                                }
                            }
                        }
                        Section("The Calculator") {
                            ForEach(calculatorPagesData, id: \.self) { pageData in
                                Button(pageData.title) {
                                    withAnimation {
                                        appState.manualBookmark = pageData
                                    }
                                }
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .foregroundColor(Color.black)
                }
                .transition(.move(edge: .leading))
            }
        }
    }
}
