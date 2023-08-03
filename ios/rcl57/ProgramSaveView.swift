import SwiftUI

private struct FooterView: View {
    @EnvironmentObject private var change: Change

    let originalProgram: Prog57?
    let program: Prog57
    let context: ProgramEditContext

    var body: some View {
        let confirmChangeString: String = {
            switch context {
            case .create:
                return "CONFIRM CREATE"
            case .edit:
                return "CONFIRM EDIT"
            case .imported:
                return "CONFIRM IMPORT"
            }
        }()

        HStack(spacing: 0) {
            Spacer()
            Button(confirmChangeString) {
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
                    if existingProgram == change.libraryBookmark {
                        change.libraryBookmark = nil
                    }
                    _ = Lib57.userLib.deleteProgram(existingProgram)
                }
                switch context {
                case .create:
                    _ = Lib57.userLib.addProgram(program)
                    withAnimation {
                        change.loadedProgram = program
                        change.stateLocation = .viewState
                        change.libraryBookmark = program
                    }
                case .edit:
                    if let originalProgram {
                        originalProgram.name = program.name
                        originalProgram.help = program.help
                    }
                    withAnimation {
                        change.isEditingProgram = false
                        change.libraryBookmark = program
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            change.isSavingProgram = false
                        }
                    }
                case .imported:
                    _ = Lib57.userLib.addProgram(program)
                    withAnimation {
                        change.isImportingProgram = false
                        change.isSavingProgram = false
                        change.isUserLibExpanded = true
                    }
                }
                _ = program.save(filename: program.name)
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

/// Displays the name and description of a program and saves it upon confirmation by the user.
struct ProgramSaveView: View {
    @EnvironmentObject private var change: Change

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
                          leftAction: { withAnimation { change.isSavingProgram = false } },
                          rightAction: nil)
            .background(Color.deeperBlue)

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

            FooterView(originalProgram: originalProgram, program: program, context: context)
                .frame(height: Style.footerHeight)
        }
    }
}

struct ProgramSaveView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramSaveView(program: Prog57(name: "", description: ""), context: .create)
    }
}
