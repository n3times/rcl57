import SwiftUI

/** Shows the name and description of a program and saves it upon confirmation by the user. */
struct ProgramSaveView: View {
    @EnvironmentObject var change: Change

    let originalProgram: Prog57?
    let program: Prog57
    let context: ProgramEditContext

    init(originalProgram: Prog57? = nil, program: Prog57, context: ProgramEditContext) {
        self.originalProgram = originalProgram
        self.program = program
        self.context = context
    }

    func overrides() -> Bool {
        var existingProgram = Lib57.userLib.programByName(program.name)
        if existingProgram != nil {
            if context == .edit && originalProgram?.name == existingProgram?.name {
                existingProgram = nil
            }
        }
        return existingProgram != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(left: Style.leftArrow,
                          title: program.name + (overrides() ? "'" : ""),
                          right: nil,
                          leftAction: { withAnimation { change.isPreviewInEditProgram = false } },
                          rightAction: nil)
            .background(Color.deeperBlue)

            if program.description == "" {
                Text("No description available")
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .center)
                    .background(Color.ivory)
                    .foregroundColor(.blackish)
            } else {
                HelpView(helpString: program.description)
            }

            // Footer
            HStack(spacing: 0) {
                Spacer()
                Button(context == .edit ? "CONFIRM EDIT" : context == .imported ? "CONFIRM IMPORT" : "CONFIRM CREATE") {
                    var existingProgram = Lib57.userLib.programByName(program.name)
                    if existingProgram != nil {
                        if context == .edit && originalProgram?.name == existingProgram?.name {
                            existingProgram = nil
                        }
                    }
                    if let existingProgram {
                        if existingProgram == change.loadedProgram {
                            change.loadedProgram = nil
                        }
                        if existingProgram == change.programView?.program {
                            change.programView = nil
                        }
                        _ = Lib57.userLib.deleteProgram(existingProgram)
                    }
                    if context == .create || context == .imported {
                        _ = Lib57.userLib.addProgram(program)
                    } else {
                        originalProgram!.name = program.name
                        originalProgram!.description = program.description
                    }
                    _ = program.save(filename: program.name)
                    withAnimation {
                        if context == .create {
                            change.loadedProgram = program
                            change.isCreateProgramInState = false
                            change.programView = ProgramView(program: program)
                        } else if context == .imported {
                            change.isImportProgramInLibrary = false
                            change.isPreviewInEditProgram = false
                            change.isUserLibExpanded = true
                        } else {
                            change.isEditInProgramView = false
                            change.programView = ProgramView(program: program)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                change.isPreviewInEditProgram = false
                            }
                        }
                    }
                }
                .font(Style.footerFont)
                .frame(width: 200, height: Style.footerHeight)
                .buttonStyle(.plain)
                Spacer()
            }
            .background(Color.deeperBlue)
            .foregroundColor(.ivory)
        }
    }
}

struct ProgramSaveView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramSaveView(program: Prog57(name: "", description: ""), context: .create)
    }
}
