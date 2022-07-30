import SwiftUI

struct ProgramSaveView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false
    let originalProgram: Prog57?
    let program: Prog57
    let context: CreateProgramContext

    init(originalProgram: Prog57?, program: Prog57, context: CreateProgramContext) {
        self.originalProgram = originalProgram
        self.program = program
        self.context = context
    }

    func overrides() -> Bool {
        var existingProgram = Lib57.userLib.findProgram(name: program.getName())
        if existingProgram != nil {
            if context == .edit && originalProgram?.getName() == existingProgram?.getName() {
                existingProgram = nil
            }
        }
        return existingProgram != nil
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            change.showPreview = false
                        }
                    }) {
                        Text(Style.leftArrow)
                            .frame(width: width / 6, height: Style.headerHeight)
                            .font(Style.smallFont)
                            .contentShape(Rectangle())
                    }

                    Text(program.getName() + (overrides() ? "'" : ""))
                        .frame(maxWidth: width * 2 / 3, maxHeight: Style.headerHeight)
                        .font(Style.titleFont)

                    Spacer()
                        .frame(width: width / 6, height: Style.headerHeight)
                }
                .background(Style.deepBlue)
                .foregroundColor(Style.ivory)

                if program.getHelp() == "" {
                    Text("No description available")
                        .frame(maxWidth: geometry.size.width,
                               maxHeight: geometry.size.height - Style.headerHeight - Style.footerHeight,
                               alignment: .center)
                        .background(Style.ivory)
                        .foregroundColor(Style.blackish)
                } else {
                    HelpView(helpString: program.getHelp())
                }

                // Footer
                HStack(spacing: 0) {
                    Spacer()
                    Button(context == .edit ? "CONFIRM EDIT" : context == .imported ? "CONFIRM IMPORT" : "CONFIRM CREATE") {
                        var existingProgram = Lib57.userLib.findProgram(name: program.getName())
                        if existingProgram != nil {
                            if context == .edit && originalProgram?.getName() == existingProgram?.getName() {
                                existingProgram = nil
                            }
                        }
                        if existingProgram != nil {
                            if existingProgram! == change.loadedProgram {
                                change.loadedProgram = nil
                            }
                            if existingProgram! == change.programShownInLibrary {
                                change.programShownInLibrary = nil
                            }
                            Lib57.userLib.delete(program: existingProgram!)
                        }
                        if context == .create || context == .imported {
                            Lib57.userLib.add(program: program)
                        } else {
                            originalProgram!.setName(name: program.getName())
                            originalProgram!.setHelp(help: program.getHelp())
                        }
                        _ = program.save(filename: program.getName())
                        withAnimation {
                            if context == .create {
                                change.loadedProgram = program
                                change.createProgram = false
                                change.programShownInLibrary = program
                            } else if context == .imported {
                                change.importProgram = false
                                change.showPreview = false
                                change.userLibExpanded = true
                            } else {
                                change.editProgram = false
                                change.programShownInLibrary = program
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    change.showPreview = false
                                }
                            }
                        }
                    }
                    .font(Style.footerFont)
                    .frame(width: 200, height: Style.footerHeight)
                    .buttonStyle(.plain)
                    Spacer()
                }
                .background(Style.deepBlue)
                .foregroundColor(Style.ivory)
            }
        }
    }
}

struct ProgramSaveView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramSaveView(originalProgram: nil, program: Prog57(name: "", help: "", readOnly: false), context: .create)
    }
}
