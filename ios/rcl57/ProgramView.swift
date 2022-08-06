import SwiftUI

/** Shows the name and description of a program and let's the user take different actions on the program. */
struct ProgramView: View {
    @EnvironmentObject var change: Change

    @State private var isPresentingDelete: Bool = false
    @State private var isPresentingCopy: Bool = false

    let program: Prog57

    var body: some View {
        let loaded = program == change.loadedProgram
        let loadButtonText = loaded ? "RELOAD" : "LOAD"

        GeometryReader { geometry in
            let width = geometry.size.width

            VStack(spacing: 0) {
                MenuBarView(change: change,
                            left: Style.leftArrow,
                            title: program.getName(),
                            right: Style.downArrow,
                            width: width,
                            leftAction: { withAnimation {change.programView = nil} },
                            rightAction: { withAnimation {change.currentView = .calc} })
                .background(Style.deepBlue)

                if program.getDescription() == "" {
                    GeometryReader { geometry in
                        Text("No description available")
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height,
                                   alignment: .center)
                            .background(Style.ivory)
                            .foregroundColor(Style.blackish)
                    }
                } else {
                    HelpView(helpString: program.getDescription())
                }

                // Footer
                HStack(spacing: 0) {
                    Spacer(minLength: 15)

                    Menu {
                        Button(action: {
                            isPresentingCopy = true
                        }) {
                            Text("Copy to Clipboard")
                        }
                        if !program.readOnly {
                            Button(action: {
                                isPresentingDelete = true
                            }) {
                                Text("Delete")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .frame(maxWidth: width / 6, maxHeight: Style.footerHeight, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .confirmationDialog("Delete?", isPresented: $isPresentingDelete) {
                        Button("Delete " + program.getName(), role: .destructive) {
                            _ = Lib57.userLib.deleteProgram(program)
                            if program == change.loadedProgram {
                                change.loadedProgram = nil
                            }
                            change.isUserLibExpanded = true
                            withAnimation {
                                change.programView = nil
                            }
                        }
                    }
                    .confirmationDialog("Copy?", isPresented: $isPresentingCopy) {
                        Button("Copy " + program.getName(), role: .none) {
                            UIPasteboard.general.string = program.toString()
                        }
                    }
                    .frame(width: width / 6, height: Style.footerHeight, alignment: .leading)


                    Button(loadButtonText) {
                        program.loadStepsIntoMemory()
                        program.loadRegistersIntoMemory()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            change.setLoadedProgram(program: program)
                        }
                        withAnimation {
                            change.currentView = .calc
                        }
                    }
                    .font(Style.footerFont)
                    .frame(maxWidth: width * 2 / 3, maxHeight: Style.footerHeight, alignment: .center)
                    .buttonStyle(.plain)

                    if program.readOnly {
                        Spacer()
                            .frame(width: width / 6, height: Style.footerHeight)
                    } else {
                        Button("EDIT") {
                            change.isPreviewInEditProgram = false
                            withAnimation {
                                change.isEditInProgramView = true
                            }
                        }
                        .font(Style.footerFont)
                        .frame(maxWidth: width / 6, maxHeight: Style.footerHeight, alignment: .trailing)
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 15)
                }
            }
            .background(Style.deepBlue)
            .foregroundColor(Style.ivory)

            if change.isEditInProgramView {
                ProgramEditView(program: program)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
}

struct ProgramView_Previews: PreviewProvider {
    @EnvironmentObject var change: Change

    static var previews: some View {
        ProgramView(program: Prog57(name: "", description: ""))
    }
}
