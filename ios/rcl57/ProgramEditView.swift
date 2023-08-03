import SwiftUI
import AudioToolbox

enum ProgramEditContext {
    case create
    case edit
    case imported
}

/// Allows the user to edit the name and description of a program.
struct ProgramEditView: View {
    @EnvironmentObject private var change: Change

    @State private var isPresentingExit = false

    @State private var name: String
    @State private var help: String

    var originalProgram: Prog57? = nil

    var context: ProgramEditContext = .create

    @FocusState private var nameIsFocused: Bool

    init(program: Prog57) {
        self.context = .edit
        self.name = program.name
        self.help = program.help
        self.originalProgram = program
    }

    init() {
        name = ""
        help = ""
    }

    init(rawText: String) {
        self.context = .imported
        if let program = Prog57(text: rawText) {
            self.name = program.name
            self.help = program.help
            self.originalProgram = program
        } else {
            let program = Prog57(name: "",
                                 description: "Clipboard does not contain a legal program.")
            self.name = program.name
            self.help = program.help
            self.originalProgram = program
        }
    }

    func getProgram() -> Prog57 {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHelp = help.trimmingCharacters(in: .whitespacesAndNewlines)
        if context == .create {
            return Prog57(name: trimmedName, description: trimmedHelp)
        } else {
            let program = Prog57(name: trimmedName, description: trimmedHelp)
            if let rawState = originalProgram?.rawState {
                program.rawState = rawState
            }
            return program
        }
    }

    var body: some View {
        UITextView.appearance().backgroundColor = .clear

        return ZStack {
            if change.isPreviewInEditProgram {
                ProgramSaveView(originalProgram: originalProgram, program: getProgram(), context: context)
                    .transition(.move(edge: .trailing))
            }

            if !change.isPreviewInEditProgram {
                GeometryReader { proxy in
                    let width = proxy.size.width

                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Button(action: {
                                if context == .create &&
                                    name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty &&
                                    help.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
                                    withAnimation {
                                        change.stateLocation = .view
                                    }
                                } else {
                                    isPresentingExit = true
                                }
                            }) {
                                Text(Style.downArrow)
                                    .frame(width: width / 5, height: Style.headerHeight)
                                    .font(Style.directionsFont)
                                    .contentShape(Rectangle())
                            }
                            .confirmationDialog("Exit?", isPresented: $isPresentingExit) {
                                Button("Exit", role: .destructive) {
                                    nameIsFocused = false
                                    withAnimation {
                                        if context == .create {
                                            change.stateLocation = .view
                                        } else if context == .imported {
                                            change.isImportProgramInLibrary = false
                                        } else {
                                            change.isEditInProgramView = false
                                        }
                                    }
                                }
                            }
                            Text(context == .edit ? "Edit Program" : context == .imported ? "Import Program" : "Create Program")
                                .frame(width: width * 3 / 5, height: Style.headerHeight)
                                .font(Style.titleFont)
                            Button(action: {
                                nameIsFocused = false
                                withAnimation {
                                    change.isPreviewInEditProgram = true
                                }
                            }) {
                                Text(name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                                     ? Style.rightArrow : Style.rightArrowFull)
                                .frame(width: width / 5, height: Style.headerHeight)
                                .font(Style.directionsFont)
                                .contentShape(Rectangle())
                            }
                            .disabled(name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
                            .buttonStyle(.plain)
                        }
                        .background(Color.deeperBlue)
                        .foregroundColor(.ivory)

                        TextField("Name", text: $name)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(height: 52)
                            .offset(x: 10)
                            .focused($nameIsFocused)

                        Color.blackish
                            .frame(height: 2)

                        TextEditor(text: $help)
                            .textFieldStyle(PlainTextFieldStyle())
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .offset(x: 5, y: 5)
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
        .background(Color(.systemBackground))
    }
}

struct ProgramEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramEditView()
    }
}
