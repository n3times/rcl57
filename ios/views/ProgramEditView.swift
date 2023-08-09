import SwiftUI
import AudioToolbox

enum ProgramEditContext {
    case create
    case edit
    case imported
}

/// A custom navigation bar to access the `ProgramSaveView`, and to cancel editing.
private struct ProgramEditNavigationBar: View {
    @EnvironmentObject private var appState: AppState

    @State private var isPresentingExit = false

    @Binding var name: String
    @Binding var description: String

    let context: ProgramEditContext

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            HStack(spacing: 0) {
                Button(action: {
                    if context == .create && name.isEmpty && description.isEmpty {
                        withAnimation {
                            appState.isProgramEditing = false
                        }
                    } else {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
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
                        withAnimation {
                            appState.isProgramEditing = false
                        }
                    }
                }

                Text(context == .edit ? "Edit Program" : context == .imported ? "Import Program" : "Create Program")
                    .frame(width: width * 3 / 5, height: Style.headerHeight)
                    .font(Style.headerTitleFont)

                Button(action: {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            appState.isProgramSaving = true
                        }
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
        }
        .background(Color.deeperBlue)
        .foregroundColor(.ivory)
        .frame(height: Style.headerHeight)
    }
}

/// Allows the user to edit the name and description of a program.
struct ProgramEditView: View {
    @EnvironmentObject private var appState: AppState

    @State private var isPresentingExit = false

    @State private var name: String
    @State private var description: String

    private var originalProgram: Prog57? = nil

    private let context: ProgramEditContext

    private var program: Prog57 {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        if context == .create {
            return Prog57(name: trimmedName, description: trimmedDescription)
        } else {
            let program = Prog57(name: trimmedName, description: trimmedDescription)
            if let rawData = originalProgram?.rawData {
                program.rawData = rawData
            }
            return program
        }
    }

    init(program: Prog57) {
        self.context = .edit
        self.name = program.name
        self.description = program.description
        self.originalProgram = program
    }

    init() {
        self.context = .create
        name = ""
        description = ""
    }

    init(rawText: String) {
        self.context = .imported
        if let program = Prog57(fromRawText: rawText) {
            self.name = program.name
            self.description = program.description
            self.originalProgram = program
        } else {
            let program = Prog57(name: "",
                                 description: "Clipboard does not contain a valid program.")
            self.name = program.name
            self.description = program.description
            self.originalProgram = program
        }
    }

    var body: some View {
        UITextView.appearance().backgroundColor = .clear

        return ZStack {
            if appState.isProgramSaving {
                ProgramSaveView(originalProgram: originalProgram,
                                program: self.program,
                                context: context
                )
                .transition(.move(edge: .trailing))
            }

            if !appState.isProgramSaving {
                VStack(spacing: 0) {
                    ProgramEditNavigationBar(name: $name, description: $description, context: context)

                    TextField("Name", text: $name)
                        .textFieldStyle(PlainTextFieldStyle())
                        .frame(height: 52)
                        .offset(x: 10)

                    Color.blackish
                        .frame(height: 2)

                    TextEditor(text: $description)
                        .textFieldStyle(PlainTextFieldStyle())
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .offset(x: 5, y: 5)
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
