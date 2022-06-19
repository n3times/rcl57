import SwiftUI

struct LibraryView: View {
    @Binding var showBack: Bool
    let rcl57: RCL57

    let hlpPages = [
                    ["3n + 1", "3n+1", "3n + 1"],
                    ["Biorhythms", "biorhythms", "Biorhythms"],
                    ["Equation Solver", "solver", "Equation Solver"],
                    ["Factors", "factors", "Factors"],
                    ["Hello World", "world", "Hello World"],
                    ["Hi-Lo", "hilo", "Hi-Lo"],
                    ["Lunar Lander", "lander", "Lunar Lander"],
                   ]

    var body: some View {
        List {
            ForEach(hlpPages, id: \.self) {hlpPage in
                let programView =
                ProgramView(showBack: $showBack, rcl57: rcl57, title: hlpPage[0], resource: hlpPage[1])
                NavigationLink(destination: programView) {
                    Text(hlpPage[2])
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Library")
        .navigationBarItems(
            trailing:
                Button(action: {
                    withAnimation {
                        showBack.toggle()
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

struct ProgramView: View {
    @Binding var showBack: Bool

    let rcl57: RCL57
    let title: String
    let resource: String
    var hlpURL: URL {
        Bundle.main.url(forResource: resource, withExtension: "hlp")!
    }
    var programURL: URL {
        Bundle.main.url(forResource: resource, withExtension: "r57")!
    }

    var body: some View {
        VStack(spacing: 0) {
            HlpView(hlpString: Hlp57.getHlpAsString(url: hlpURL))
            HStack(spacing: 0) {
                Spacer()
                Button("Load") {
                    rcl57.loadProgram(programURL: programURL)
                    withAnimation {
                        showBack.toggle()
                    }
                }
                .font(Style.titleFont)
                .frame(width: 100, height: Style.footerHeight)
                .buttonStyle(.plain)
                Spacer()
            }
            .background(Color.gray)
            .foregroundColor(Style.ivory)
        }
        .navigationBarItems(
            trailing:
                Button(action: {
                    withAnimation {
                        showBack.toggle()
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
