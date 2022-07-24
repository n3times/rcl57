import SwiftUI

struct ProgramSaverView: View {
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

    var body: some View {
        ZStack {
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

                        Text(program.getName())
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
                        HelpView(hlpString: program.getHelp())
                    }

                    // Footer
                    HStack(spacing: 0) {
                        Spacer()
                        Button(context == .edit ? "CONFIRM EDIT" : "CONFIRM CREATE") {
                            withAnimation {
                                if context == .edit {
                                    Lib57.userLib.delete(program: originalProgram!)
                                }
                                Lib57.userLib.add(program: program)
                                _ = program.save(filename: program.getName())
                                if context == .create {
                                    change.loadedProgram = program
                                    change.createProgram = false
                                } else {
                                    change.editProgram = false
                                    change.program = program
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
}

struct ProgramSaverView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramSaverView(originalProgram: nil, program: Prog57(name: "", help: "", readOnly: false), context: .create)
    }
}
