import SwiftUI

enum CreateProgramContext {
    case create
    case edit
    case imported
}

struct ProgramEditorView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false
    @State var name: String
    @State var help: String

    var originalProgram: Prog57? = nil

    var context: CreateProgramContext = .create

    @FocusState private var nameIsFocused: Bool

    init(program: Prog57) {
        self.context = .edit
        self.name = program.getName()
        self.help = program.getHelp()
        self.originalProgram = program
    }

    init() {
        name = ""
        help = ""
    }

    func getProgram() -> Prog57 {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHelp = help.trimmingCharacters(in: .whitespacesAndNewlines)
        if context == .create {
            return Prog57(name: trimmedName, help: trimmedHelp, readOnly: false)
        } else {
            let program = Prog57(name: trimmedName, help: trimmedHelp, readOnly: false)
            program.setState(state: originalProgram!.getState())
            return program
        }
    }

    var body: some View {
        UITextView.appearance().backgroundColor = .clear

        return ZStack {
            if change.showPreview {
                ProgramSaverView(originalProgram: originalProgram, program: getProgram(), context: context)
                    .transition(.move(edge: .trailing))
            }
            if !change.showPreview {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Button(action: {
                                isPresentingConfirm = true
                            }) {
                                Text(Style.downArrow)
                                    .frame(width: width / 5, height: Style.headerHeight)
                                    .font(Style.smallFont)
                                    .contentShape(Rectangle())
                            }
                            .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                                Button("Exit", role: .destructive) {
                                    nameIsFocused = false
                                    withAnimation {
                                        if context == .create {
                                            change.createProgram = false
                                        } else {
                                            change.editProgram = false
                                        }
                                    }
                                }
                            }
                            Text(context == .edit ? "Edit Program" : "Create Program")
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

struct ProgramEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramEditorView()
    }
}
