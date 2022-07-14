import SwiftUI

struct PreviewProgramView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false
    let program: Prog57

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
                            Text("Back")
                                .frame(width: width / 5, height: Style.headerHeight)
                                .font(Style.smallFont)
                                .contentShape(Rectangle())
                        }
                        Text(program.getName())
                            .frame(width: width * 3 / 5, height: Style.headerHeight)
                            .font(Style.titleFont)
                        Button(action: {
                            withAnimation {
                                Lib57.userLib.add(program: program)
                                _ = program.save(filename: program.getName())
                                change.createProgram = false
                                change.loadedProgram = program
                            }
                        }) {
                            Text("Confirm")
                                .frame(width: width / 5, height: Style.headerHeight)
                                .font(Style.smallFont)
                                .contentShape(Rectangle())
                        }
                    }
                    .background(Style.deepBlue)
                    .foregroundColor(Style.ivory)

                    HelpView(hlpString: program.getHelp())
                }
            }
            .transition(.move(edge: .leading))
        }
    }
}

struct CreateProgramView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProgramView()
    }
}
