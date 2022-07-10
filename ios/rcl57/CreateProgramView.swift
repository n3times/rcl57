import SwiftUI

struct CreateProgramView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false
    @State private var name = ""
    @State private var help = ""

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                VStack(spacing: 0) {
                    // Menu.
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
                            Text(Style.leftArrow)
                                .frame(width: width / 6, height: Style.headerHeight)
                                .font(Style.directionsFont)
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
                            .frame(width: width * 2 / 3, height: Style.headerHeight)
                            .font(Style.titleFont)
                        Button(action: {
                            withAnimation {
                                Lib57.userLib.add(program: Prog57(name: name, help: help))
                                change.createProgram = false
                            }
                        }) {
                            Text(Style.rightArrow)
                                .frame(width: width / 6, height: Style.headerHeight)
                                .font(Style.directionsFont)
                                .contentShape(Rectangle())
                        }
                    }
                    .background(Style.blackish)
                    .foregroundColor(Style.ivory)

                    TextField("Name", text: $name)
                    .background(Style.ivory)
                    .frame(height: 40)
                    TextEditor(text: $help)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                    .background(Style.ivory)
                    .frame(minWidth: 100, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .background(Style.ivory)
            .transition(.move(edge: .leading))
        }
    }
}

struct CreateProgramView_Previews: PreviewProvider {
    static var previews: some View {
        FullLibraryView()
    }
}
