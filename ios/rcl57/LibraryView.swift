import SwiftUI
import UniformTypeIdentifiers

private struct ProgramNode: Identifiable {
    let id = UUID()
    let name: String
    var program: Prog57

    init(program: Prog57) {
        self.name = program.name
        self.program = program
    }
}

private struct LibraryNode: Identifiable {
    let id = UUID()
    let name: String
    var children: [ProgramNode] = []

    init(library: Lib57) {
        self.name = library.name
        for program in library.programs {
            children.append(ProgramNode(program: program))
        }
    }
}

private struct FooterView: View {
    @EnvironmentObject private var change: Change

    @State private var isPresentingImport = false

    private let exportedType = UTType(exportedAs: "com.n3times.rcl57", conformingTo: .text)

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: width / 5, height: Style.footerHeight)

                Button(action: {
                    isPresentingImport = true
                }) {
                    Text("IMPORT")
                        .font(Style.footerFont)
                        .frame(width: width * 3 / 5, height: Style.footerHeight, alignment: .center)
                        .buttonStyle(.plain)
                }
                .fileImporter(
                    isPresented: $isPresentingImport,
                    allowedContentTypes: [exportedType],
                    allowsMultipleSelection: false,
                    onCompletion: { result in
                        withAnimation {
                            do {
                                if let url = try? result.get().first {
                                    if url.startAccessingSecurityScopedResource() {
                                        LibraryView.importText = try String(contentsOf: url)
                                        change.isImportProgramInLibrary = true
                                        do { url.stopAccessingSecurityScopedResource() }
                                    } else {
                                        // TODO: Handle denied access
                                    }
                                }
                            } catch {
                                print (error.localizedDescription)
                            }
                        }
                    })

                Spacer()
                    .frame(width: width / 5, height: Style.footerHeight)
            }
            .background(Color.deepBlue)
            .foregroundColor(.ivory)
        }
    }
}

/// Displays a list of sample and user programs.
struct LibraryView: View {
    @EnvironmentObject private var change: Change

    private let samplesLibNode = LibraryNode(library: Lib57.samplesLib)
    private let userLibNode = LibraryNode(library: Lib57.userLib)

    static var importText = ""

    var body: some View {
        ZStack {
            if change.lastProgramViewed == nil {
                GeometryReader { proxy in
                    let width = proxy.size.width
                    VStack(spacing: 0) {
                        NavigationBar(left: nil,
                                      title: "Library",
                                      right: Style.downArrow,
                                      leftAction: nil,
                                      rightAction: { withAnimation {change.currentViewType = .calc} })
                        .background(Color.deepBlue)
                        .frame(width: width)

                        List {
                            DisclosureGroup(isExpanded: $change.isSamplesLibExpanded) {
                                ForEach(samplesLibNode.children) { item in
                                    Button(item.name) {
                                        withAnimation {
                                            change.lastProgramViewed = item.program
                                        }
                                    }
                                    .offset(x: 15)
                                }
                            } label: {
                                Text(samplesLibNode.name)
                                    .font(Style.listLineFontBold)
                                    .foregroundColor(.blackish)
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
                                            change.lastProgramViewed = item.program
                                        }
                                    }
                                    .offset(x: 15)
                                }
                            } label: {
                                Text(userLibNode.name)
                                    .font(Style.listLineFontBold)
                                    .foregroundColor(.blackish)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            change.isUserLibExpanded.toggle()
                                        }
                                    }
                            }
                        }
                        .listStyle(PlainListStyle())

                        FooterView()
                            .frame(height: Style.footerHeight)
                    }
                }
                .background(Color.white)
                .transition(.move(edge: .leading))
            }

            if let programViewed = change.lastProgramViewed {
                ProgramView(program: programViewed)
                    .transition(.move(edge: .trailing))
            }

            if change.isImportProgramInLibrary {
                ProgramEditView(rawText: LibraryView.importText)
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
