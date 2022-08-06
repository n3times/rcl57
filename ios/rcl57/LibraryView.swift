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
}


/**
 * Shows a list of sample and user programs.
 */
struct LibraryView: View {
    @EnvironmentObject var change: Change

    @State private var isPresentingImport: Bool = false

    fileprivate let samplesLibNode = LibraryNode(library: Lib57.samplesLib)
    fileprivate let userLibNode = LibraryNode(library: Lib57.userLib)

    var body: some View {
        ZStack {
            if change.programView == nil {
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

                        List {
                            DisclosureGroup(isExpanded: $change.isSamplesLibExpanded) {
                                ForEach(samplesLibNode.children) { item in
                                    Button(item.name) {
                                        withAnimation {
                                            change.programView = ProgramView(program: item.program!)
                                        }
                                    }
                                    .offset(x: 15)
                                }
                            } label: {
                                Text(samplesLibNode.name)
                                    .font(Style.listLineFontBold)
                                    .foregroundColor(Style.blackish)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            change.isSamplesLibExpanded.toggle()
                                        }
                                    }
                            }
                            DisclosureGroup(isExpanded: $change.isUserLibExpanded) {
                                ForEach(userLibNode.children) { item in
                                    Button(item.name) {
                                        withAnimation {
                                            change.programView = ProgramView(program: item.program!)
                                        }
                                    }
                                    .offset(x: 15)
                                }
                            } label: {
                                Text(userLibNode.name)
                                    .font(Style.listLineFontBold)
                                    .foregroundColor(Style.blackish)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            change.isUserLibExpanded.toggle()
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
                        .confirmationDialog("Import?", isPresented: $isPresentingImport) {
                            Button("Import from Clipboad", role: .none) {
                                withAnimation {
                                    change.isImportProgramInLibrary = true
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

            if change.programView != nil {
                change.programView!
                    .environmentObject(change)
                    .transition(.move(edge: .trailing))
            }

            if change.isImportProgramInLibrary {
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
