import SwiftUI

private struct ProgramSaveViewToolbar: View {
    @EnvironmentObject private var appState: AppState

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
                    if existingProgram == appState.loadedProgram {
                        appState.loadedProgram = nil
                    }
                    if existingProgram == appState.libraryBookmark {
                        appState.libraryBookmark = nil
                    }
                    _ = Lib57.userLib.deleteProgram(existingProgram)
                }
                switch context {
                case .create:
                    _ = Lib57.userLib.addProgram(program)
                    appState.loadedProgram = program
                    appState.libraryBookmark = program
                case .edit:
                    if let originalProgram {
                        originalProgram.name = program.name
                        originalProgram.help = program.help
                    }
                    appState.libraryBookmark = program
                case .imported:
                    _ = Lib57.userLib.addProgram(program)
                    appState.isUserLibExpanded = true
                }
                withAnimation {
                    appState.isProgramEditing = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        appState.isProgramSaving = false
                    }
                }
                _ = program.save(filename: program.name)
            }
            .font(Style.toolbarFont)
            .frame(width: 200, height: Style.toolbarHeight)
            .buttonStyle(.plain)
            Spacer()
        }
        .background(Color.deeperBlue)
        .foregroundColor(.ivory)
    }
}

/// Displays the name and description of a program and saves it upon confirmation by the user.
struct ProgramSaveView: View {
    @EnvironmentObject private var appState: AppState

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
                          leftAction: { withAnimation { appState.isProgramSaving = false } },
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

            ProgramSaveViewToolbar(originalProgram: originalProgram, program: program, context: context)
                .frame(height: Style.toolbarHeight)
        }
    }
}

struct ProgramSaveView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramSaveView(program: Prog57(name: "", description: ""), context: .create)
    }
}
