import SwiftUI

struct ProgramView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false
    @State private var isPresentingCopy: Bool = false
    let program: Prog57

    var body: some View {
        let loaded = program == change.loadedProgram
        let loadButtonText = loaded ? "RELOAD" : "LOAD"

        GeometryReader { geometry in
            let width = geometry.size.width

            VStack(spacing: 0) {
                // Menu.
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            change.program = nil
                        }
                    }) {
                        Text(Style.leftArrow)
                            .frame(width: width / 6, height: Style.headerHeight)
                            .font(Style.directionsFont)
                            .contentShape(Rectangle())
                    }
                    Text(program.getName())
                        .frame(maxWidth: width * 2 / 3, maxHeight: Style.headerHeight)
                        .font(Style.titleFont)
                    Button(action: {
                        withAnimation {
                            change.currentView = .calc
                        }
                    }) {
                        Text(Style.downArrow)
                            .frame(width: width / 6, height: Style.headerHeight)
                            .font(Style.directionsFont)
                            .contentShape(Rectangle())
                    }
                }
                .background(Style.deepBlue)
                .foregroundColor(Style.ivory)

                if program.getHelp() == "" {
                    GeometryReader { geometry in
                        Text("No description available")
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height,
                                   alignment: .center)
                            .background(Style.ivory)
                            .foregroundColor(Style.blackish)
                    }
                } else {
                    HelpView(helpString: program.getHelp())
                }

                // Footer
                HStack(spacing: 0) {
                    Spacer(minLength: 15)

                    if program.readOnly {
                        Spacer()
                            .frame(width: width / 6, height: Style.footerHeight)
                    } else {
                        Menu {
                            Button(action: {
                                isPresentingCopy = true
                            }) {
                                Text("Copy to Clipboard")
                            }
                            Button(action: {
                                isPresentingConfirm = true
                            }) {
                                Text("Delete")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .frame(maxWidth: width / 6, maxHeight: Style.footerHeight, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                            Button("Delete " + program.getName(), role: .destructive) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    Lib57.userLib.delete(program: program)
                                    if program == change.loadedProgram {
                                        change.loadedProgram = nil
                                    }
                                    change.program = nil
                                }
                                withAnimation {
                                    change.currentView = .calc
                                }
                            }
                        }
                        .confirmationDialog("Are you sure?", isPresented: $isPresentingCopy) {
                            Button("Copy " + program.getName(), role: .none) {
                                UIPasteboard.general.string = program.toText()
                            }
                        }
                        .frame(width: width / 6, height: Style.footerHeight, alignment: .leading)
                    }

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
                            change.showPreview = false
                            withAnimation {
                                change.editProgram = true
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

            if change.editProgram {
                ProgramEditorView(program: program)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
}

struct ProgramView_Previews: PreviewProvider {
    @EnvironmentObject var change: Change

    static var previews: some View {
        ProgramView(program: Prog57(name: "", help: "", readOnly: false))
    }
}
