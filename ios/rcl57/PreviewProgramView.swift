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
                            Text(Style.leftArrow)
                                .frame(width: width / 6, height: Style.headerHeight)
                                .font(Style.smallFont)
                                .contentShape(Rectangle())
                        }

                        Text(program.getName())
                            .frame(width: width * 2 / 3, height: Style.headerHeight)
                            .font(Style.titleFont)

                        Spacer()
                            .frame(width: width / 6, height: Style.headerHeight)
                    }
                    .background(Style.deepBlue)
                    .foregroundColor(Style.ivory)

                    if program.getHelp() == "" {
                        Text("No description available")
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height - Style.headerHeight - Style.footerHeight,
                                   alignment: .center)
                            .background(Style.ivory)
                            .foregroundColor(Style.blackish)
                    } else {
                        HelpView(hlpString: program.getHelp())
                    }

                    // Footer
                    HStack(spacing: 0) {
                        Spacer()
                        Button("CREATE") {
                            withAnimation {
                                Lib57.userLib.add(program: program)
                                _ = program.save(filename: program.getName())
                                change.createProgram = false
                                change.loadedProgram = program
                            }
                        }
                        .font(Style.footerFont)
                        .frame(width: 100, height: Style.footerHeight)
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

struct PreviewProgramView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewProgramView(program: Prog57(name: "", help: "", readOnly: false))
    }
}
