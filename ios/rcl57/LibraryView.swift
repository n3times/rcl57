import SwiftUI

private struct LibraryNode: Identifiable {
    let id = UUID()
    let name: String
    var children: [LibraryNode] = []
    var program: Prog57?

    init(program: Prog57) {
        self.name = program.getName()
        self.program = program
    }

    init(library: Lib57) {
        self.name = library.name
        let programs = library.programs
        if programs.count > 0 {
            children = []
            for program in programs {
                children.append(LibraryNode(program: program))
            }
        }
    }

    static let samplesLib = LibraryNode(library: Lib57.samplesLib)
    var userLib: LibraryNode {
        LibraryNode(library: Lib57.samplesLib)
    }
}

/**
 * Shows a list of sample and user programs.
 */
struct LibraryView: View {
    @EnvironmentObject var change: Change

    @State private var isPresentingImport: Bool = false

    var body: some View {
        ZStack {
            if change.programShownInLibrary == nil {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    VStack(spacing: 0) {
                        MenuBarView(change: change,
                                    left: nil,
                                    title: "Library",
                                    right: Style.downArrow,
                                    width: width,
                                    leftAction: {},
                                    rightAction: { withAnimation {change.currentView = .calc} })
                        .background(Style.deepBlue)
                        .frame(width: width)

                        let userLib = LibraryNode(library: Lib57.userLib)
                        let items: [LibraryNode] = [.samplesLib, userLib]

                        List {
                            DisclosureGroup(isExpanded: $change.samplesLibExpanded) {
                                ForEach(items[0].children) { item in
                                    Button(item.name) {
                                        withAnimation {
                                            change.programShownInLibrary = item.program
                                        }
                                    }
                                    .offset(x: 15)
                                }
                            } label: {
                                Text(items[0].name)
                                    .font(Style.listLineFontBold)
                                    .foregroundColor(Style.blackish)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            change.samplesLibExpanded.toggle()
                                        }
                                    }
                            }

                            DisclosureGroup(isExpanded: $change.userLibExpanded) {
                                if items[1].children.count == 0 {

                                } else {
                                    ForEach(items[1].children) { item in
                                        Button(item.name) {
                                            withAnimation {
                                                change.programShownInLibrary = item.program
                                            }
                                        }
                                        .offset(x: 15)
                                    }
                                }
                            } label: {
                                Text(items[1].name)
                                    .font(Style.listLineFontBold)
                                    .foregroundColor(Style.blackish)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            change.userLibExpanded.toggle()
                                        }
                                    }
                            }
                        }
                        .listStyle(PlainListStyle())

                        // Footer
                        HStack(spacing: 0) {
                            Spacer()
                                .frame(width: width / 6, height: Style.footerHeight)

                            Button("IMPORT") {
                                isPresentingImport = true
                            }
                            .font(Style.footerFont)
                            .frame(maxWidth: width * 2 / 3, maxHeight: Style.footerHeight, alignment: .center)
                            .buttonStyle(.plain)

                            Spacer()
                                .frame(width: width / 6, height: Style.footerHeight)
                        }
                        .confirmationDialog("Are you sure?", isPresented: $isPresentingImport) {
                            Button("Import from Clipboad", role: .none) {
                                withAnimation {
                                    change.importProgram = true
                                }
                            }
                        }
                        .background(Style.deepBlue)
                        .foregroundColor(Style.ivory)
                    }
                }
                .background(Color.white)
                .transition(.move(edge: .leading))
            }

            if change.programShownInLibrary != nil {
                ProgramView(program: change.programShownInLibrary!)
                    .environmentObject(change)
                    .transition(.move(edge: .trailing))
            }

            if change.importProgram {
                ProgramEditView(context: .imported)
                    .transition(.move(edge: .bottom))
            }
        }
        .foregroundColor(Color.black)
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
