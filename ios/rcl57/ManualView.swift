import SwiftUI

/// The list of topics in the User Manual.
struct ManualContentView: View {
    @EnvironmentObject private var change: Change

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
        List {
            Button("About") {
                withAnimation {
                    change.manualBookmark = aboutPageData
                }
            }
            Section("The Emulator") {
                ForEach(emulatorPagesData, id: \.self) { pageData in
                    Button(pageData.title) {
                        withAnimation {
                            change.manualBookmark = pageData
                        }
                    }
                }
            }
            Section("The Calculator") {
                ForEach(calculatorPagesData, id: \.self) { pageData in
                    Button(pageData.title) {
                        withAnimation {
                            change.manualBookmark = pageData
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .foregroundColor(Color.black)
    }
}

/// The list of manual pages and a navigation bar.
struct ManualView: View {
    @EnvironmentObject private var change: Change

    var body: some View {
        ZStack {
            if change.manualBookmark == nil {
                VStack(spacing: 0) {
                    NavigationBar(left: nil,
                                  title: "User Manual",
                                  right: Style.downArrow,
                                  leftAction: nil,
                                  rightAction: { withAnimation { change.appLocation = .calc } })
                    .background(Color.deepGreen)
                    ManualContentView()
                }
                .transition(.move(edge: .leading))
            }

            if let pageData = change.manualBookmark {
                ManualPageView(title: pageData.title, resource: pageData.resource)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}
