import SwiftUI

struct CreateProgramView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false
    @State private var name = ""
    @State private var help = ""

    var body: some View {
        ZStack {
            if change.showPreview {
                let program = Prog57(name: name, help: help, readOnly: false)
                PreviewProgramView(change: _change, program: program)
            }
            if !change.showPreview {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Button(action: {
                                if name.isEmpty && help.isEmpty {
                                    withAnimation {
                                        change.createProgram = false
                                    }
                                } else {
                                    isPresentingConfirm = true
                                }
                            }) {
                                Text("Cancel")
                                    .frame(width: width / 5, height: Style.headerHeight)
                                    .font(Style.smallFont)
                                    .contentShape(Rectangle())
                            }
                            .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                                Button("Exit", role: .destructive) {
                                    withAnimation {
                                        change.createProgram = false
                                    }
                                }
                            }
                            Text("Create Program")
                                .frame(width: width * 3 / 5, height: Style.headerHeight)
                                .font(Style.titleFont)
                            Button(action: {
                                withAnimation {
                                    change.showPreview = true
                                }
                            }) {
                                Text("Preview")
                                    .frame(width: width / 5, height: Style.headerHeight)
                                    .font(Style.smallFont)
                                    .contentShape(Rectangle())
                            }
                            .disabled(name.trimmingCharacters(in: CharacterSet.whitespaces) == "")
                        }
                        .background(Style.deepBlue)
                        .foregroundColor(Style.ivory)

                        TextField("Name", text: $name)
                            .background(Color.white)
                            .frame(height: 44)
                            .offset(x: 10, y: 0)

                        TextEditor(text: $help)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                            .background(Color.white)
                            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
    }
}

struct PreviewProgramView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProgramView()
    }
}
