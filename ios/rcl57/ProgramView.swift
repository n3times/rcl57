import SwiftUI

/// Used for exporting RCL-57 programs.
private struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityViewController>
    ) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityViewController>
    ) {
        // Nothing to update.
    }
}

/// Lets the user delete, edit and share the program.
private struct ProgramViewToolbar: View {
    @EnvironmentObject private var appState: AppState

    @State private var isPresentingDelete = false
    @State private var isPresentingShare = false

    let program: Prog57
    let width: Double

    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                isPresentingShare = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(Style.directionsFont)
                    .offset(x: 15)
                    .frame(width: width / 5, height: Style.toolbarHeight, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .sheet(isPresented: $isPresentingShare) {
                if let programUrl = program.url {
                    ActivityViewController(activityItems: [programUrl])
                }
            }

            Button(action: {
                program.loadStepsIntoMemory()
                program.loadRegistersIntoMemory()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    appState.loadedProgram = program
                }
                withAnimation {
                    appState.appLocation = .calc
                }
            }) {
                let loadButtonText = program == appState.loadedProgram ? "RELOAD" : "LOAD"
                Text(loadButtonText)
                    .font(Style.toolbarFont)
                    .frame(width: width * 3 / 5, height: Style.toolbarHeight, alignment: .center)
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
            }

            if program.isReadOnly {
                Spacer()
                    .frame(width: width / 5, height: Style.toolbarHeight)
            } else {
                Menu {
                    Button(action: {
                        isPresentingDelete = true
                    }) {
                        Text("Delete")
                    }
                    Button(action: {
                        withAnimation {
                            appState.isProgramEditing = true
                        }
                    }) {
                        Text("Edit")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(Style.directionsFont)
                        .frame(width: width / 5, height: Style.toolbarHeight, alignment: .trailing)
                        .offset(x: -15)
                        .contentShape(Rectangle())
                }
                .frame(width: width / 5, height: Style.toolbarHeight, alignment: .trailing)
                .offset(x: -15)
                .contentShape(Rectangle())
                .confirmationDialog("Delete?", isPresented: $isPresentingDelete) {
                    Button("Delete \(program.name)", role: .destructive) {
                        _ = Lib57.userLib.deleteProgram(program)
                        if program == appState.loadedProgram {
                            appState.loadedProgram = nil
                        }
                        appState.isUserLibExpanded = true
                        withAnimation {
                            appState.libraryBookmark = nil
                        }
                    }
                }
            }
        }
    }
}

/// Displays the name and description of a program. Lets the user take different actions on the
/// program.
struct ProgramView: View {
    @EnvironmentObject private var appState: AppState

    let program: Prog57

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            VStack(spacing: 0) {
                NavigationBar(left: Style.leftArrow,
                              title: program.name,
                              right: Style.downArrow,
                              leftAction: { withAnimation { appState.libraryBookmark = nil } },
                              rightAction: { withAnimation { appState.appLocation = .calc } })
                .background(Color.deepBlue)

                if program.help.isEmpty {
                    Text("No description available")
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .center)
                        .background(Color.ivory)
                        .foregroundColor(.blackish)
                } else {
                    HelpView(helpString: program.help)
                }

                ProgramViewToolbar(program: program, width: width)
                    .frame(maxHeight: Style.toolbarHeight)
            }
            .background(Color.deepBlue)
            .foregroundColor(.ivory)

            if appState.isProgramEditing {
                ProgramEditView(program: program)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
}

struct ProgramView_Previews: PreviewProvider {
    @EnvironmentObject private var appState: AppState

    static var previews: some View {
        ProgramView(program: Prog57(name: "", description: ""))
    }
}
