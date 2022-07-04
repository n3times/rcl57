import SwiftUI

struct ManualView: View {
    @EnvironmentObject private var change: Change

    let hlpPages = [["About", "about", "About RCL-57"],
                    ["Options", "options", "Emulator Options"],
                    ["Basics", "basics", "Calculator Basics"],
                    ["Math", "math", "Math Functions"],
                    ["Registers", "registers", "Registers"],
                    ["Hello World", "hello", "Hello World"],
                    ["Flow Control", "flow", "Flow Control"]]

    var body: some View {
        List {
            ForEach(hlpPages, id: \.self) { hlpPage in
                NavigationLink(destination: ManualPageView(title: hlpPage[0], hlpResource: hlpPage[1])) {
                    Text(hlpPage[2])
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Help")
        .navigationBarItems(
            trailing:
                Button(action: {
                    withAnimation {
                        change.currentView = .calc
                    }
                }) {
                    Text(Style.circle)
                        .frame(width: 70, height: Style.headerHeight, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .font(Style.directionsFont)
        )
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

        HStack {
            HelpView(hlpURL: hlpURL)
        }
        .navigationBarItems(
            trailing:
                Button(action: {
                    withAnimation {
                        change.currentView = .calc
                    }
                }) {
                    Text(Style.circle)
                        .frame(width: 70, height: Style.headerHeight, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .font(Style.directionsFont)
        )
    }
}
