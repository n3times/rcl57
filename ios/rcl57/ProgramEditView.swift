import SwiftUI

enum CreateProgramContext {
    case create
    case edit
    case imported
}

/** Gives tto the user a chance to edit the name and description of a program. */
struct ProgramEditView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingExit: Bool = false
    @State var name: String
    @State var help: String

    var originalProgram: Prog57? = nil

    var context: CreateProgramContext = .create

    @FocusState private var nameIsFocused: Bool

    init(program: Prog57) {
        self.context = .edit
        self.name = program.getName()
        self.help = program.getDescription()
        self.originalProgram = program
    }

    init() {
        name = ""
        help = ""
    }

    init(context: CreateProgramContext) {
        let paste = UIPasteboard.general.string ?? ""
        var program = Prog57(text: paste)
        if program == nil {
            program = Prog57(name: "",
                             description: "Clipboard does not appear to contain a legal program.")
        }
        self.context = .imported
        self.name = program!.getName()
        self.help = program!.getDescription()
        self.originalProgram = program
    }

    func getProgram() -> Prog57 {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHelp = help.trimmingCharacters(in: .whitespacesAndNewlines)
        if context == .create {
            return Prog57(name: trimmedName, description: trimmedHelp)
        } else {
            let program = Prog57(name: trimmedName, description: trimmedHelp)
            program.setState(state: originalProgram!.getState())
            return program
        }
    }

    var body: some View {
        UITextView.appearance().backgroundColor = .clear

        return ZStack {
            if change.showPreview {
                ProgramSaveView(originalProgram: originalProgram, program: getProgram(), context: context)
                    .transition(.move(edge: .trailing))
            }

            if !change.showPreview {
                GeometryReader { geometry in
                    let width = geometry.size.width

                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Button(action: {
                                isPresentingExit = true
                            }) {
                                Text(Style.downArrow)
                                    .frame(width: width / 5, height: Style.headerHeight)
                                    .font(Style.smallFont)
                                    .contentShape(Rectangle())
                            }
                            .confirmationDialog("Are you sure?", isPresented: $isPresentingExit) {
                                Button("Exit", role: .destructive) {
                                    nameIsFocused = false
                                    withAnimation {
                                        if context == .create {
                                            change.isCreateProgramInState = false
                                        } else if context == .imported {
                                            change.isImportProgramInLibrary = false
                                        } else {
                                            change.isEditInProgramView = false
                                        }
                                    }
                                }
                            }
                            Text(context == .edit ? "Edit Program" : context == .imported ? "Import Program" : "Create Program")
                                .frame(maxWidth: width * 3 / 5, maxHeight: Style.headerHeight)
                                .font(Style.titleFont)
                            Button(action: {
                                nameIsFocused = false
                                withAnimation {
                                    change.showPreview = true
                                }
                            }) {
                                Text(name.trimmingCharacters(in: CharacterSet.whitespaces) == ""
                                     ? Style.rightArrow : Style.rightArrowFull)
                                .frame(width: width / 5, height: Style.headerHeight)
                                .font(Style.smallFont)
                                .contentShape(Rectangle())
                            }
                            .disabled(name.trimmingCharacters(in: CharacterSet.whitespaces) == "")
                            .buttonStyle(.plain)
                        }
                        .background(Style.deepBlue)
                        .foregroundColor(Style.ivory)

                        TextField("Name", text: $name)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(height: 52)
                            .offset(x: 10)
                            .focused($nameIsFocused)

                        Style.blackish
                            .frame(height: 2)

                        TextEditor(text: $help)
                            .textFieldStyle(PlainTextFieldStyle())
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
                            .offset(x: 5, y: 5)
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct ProgramEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramEditView()
    }
}
