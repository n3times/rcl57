import SwiftUI

struct LibraryView: View {
    @Binding var showBack: Bool
    let rcl57: Rcl57
    let url: URL

    func getPrograms(_ folderURL: URL) -> [Prog57] {
        var programs: [Prog57] = []
        let enumerator = FileManager.default.enumerator(at: folderURL, includingPropertiesForKeys: [])
        while let urlObject = enumerator!.nextObject() {
            let url = urlObject as! URL
            if url.path.hasSuffix(".p57") {
                programs.append(Prog57(url: url)!)
            }
        }
        return programs
    }

    var body: some View {
        List {
            ForEach(getPrograms(url), id: \.self) { program in
                let programView = ProgramView(showBack: $showBack, rcl57: rcl57, program: program)
                NavigationLink(destination: programView) {
                    Text(program.getName())
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

    let rcl57: Rcl57
    let program: Prog57

    var body: some View {
        VStack(spacing: 0) {
            HelpView(hlpString: program.getHelp())
            HStack(spacing: 0) {
                Spacer()
                Button("Load") {
                    program.loadState(rcl57: rcl57)
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
