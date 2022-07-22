import SwiftUI

struct CreateProgramView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false
    @State private var name = ""
    @State private var help = ""

    @FocusState private var nameIsFocused: Bool

    var body: some View {
        UITextView.appearance().backgroundColor = .clear

        return ZStack {
            if change.showPreview {
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedHelp = help.trimmingCharacters(in: .whitespacesAndNewlines)
                let program = Prog57(name: trimmedName, help: trimmedHelp, readOnly: false)
                PreviewProgramView(change: _change, program: program)
                    .transition(.move(edge: .trailing))
            }
            if !change.showPreview {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Button(action: {
                                if name.isEmpty && help.isEmpty {
                                    nameIsFocused = false
                                    withAnimation {
                                        change.createProgram = false
                                    }
                                } else {
                                    isPresentingConfirm = true
                                }
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
                                        change.createProgram = false
                                    }
                                }
                            }
                            Text("Create Program")
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

struct CreateProgramView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProgramView()
    }
}
