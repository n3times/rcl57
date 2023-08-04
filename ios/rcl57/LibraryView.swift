import SwiftUI
import UniformTypeIdentifiers

/// Allows the user to import a program into the user library.
private struct LibraryViewToolbar: View {
    @EnvironmentObject private var appState: AppState

    @State private var isPresentingImport = false

    private let exportedType = UTType(exportedAs: "com.n3times.rcl57", conformingTo: .text)

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: width / 5, height: Style.toolbarHeight)

                Button(action: {
                    isPresentingImport = true
                }) {
                    Text("IMPORT")
                        .font(Style.toolbarFont)
                        .frame(width: width * 3 / 5, height: Style.toolbarHeight, alignment: .center)
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
                                        appState.isProgramEditing = true
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
                    .frame(width: width / 5, height: Style.toolbarHeight)
            }
            .background(Color.deepBlue)
            .foregroundColor(.ivory)
        }
    }
}

/// Displays a list of sample and user programs.
struct LibraryView: View {
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

    @EnvironmentObject private var appState: AppState

    private let samplesLibNode = LibraryNode(library: Lib57.samplesLib)
    private let userLibNode = LibraryNode(library: Lib57.userLib)

    static var importText = ""

    var body: some View {
        ZStack {
            if let program = appState.libraryBookmark {
                // Go directly to the Program View, if that was the last page visited.
                ProgramView(program: program)
                    .transition(.move(edge: .trailing))
            } else {
                VStack(spacing: 0) {
                    NavigationBar(left: nil,
                                  title: "Library",
                                  right: Style.downArrow,
                                  leftAction: nil,
                                  rightAction: { withAnimation {appState.appLocation = .calc} })
                    .background(Color.deepBlue)

                    List {
                        DisclosureGroup(isExpanded: $appState.isSamplesLibExpanded) {
                            ForEach(samplesLibNode.children) { item in
                                Button(item.name) {
                                    withAnimation {
                                        appState.libraryBookmark = item.program
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
                                        appState.isSamplesLibExpanded.toggle()
                                    }
                                }
                        }
                        DisclosureGroup(isExpanded: $appState.isUserLibExpanded) {
                            ForEach(userLibNode.children) { item in
                                Button(item.name) {
                                    withAnimation {
                                        appState.libraryBookmark = item.program
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
                                        appState.isUserLibExpanded.toggle()
                                    }
                                }
                        }
                    }
                    .listStyle(PlainListStyle())

                    LibraryViewToolbar()
                        .frame(height: Style.toolbarHeight)
                }
                .background(Color.white)
                .transition(.move(edge: .leading))

                if appState.isProgramEditing {
                    ProgramEditView(rawText: LibraryView.importText)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
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
