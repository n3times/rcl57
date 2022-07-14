import SwiftUI

struct FullProgramView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false
    let program: Prog57

    var body: some View {
        let loaded = program == change.loadedProgram
        let loadButtonText = loaded ? "RELOAD" : "LOAD"

        ZStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                VStack(spacing: 0) {
                    // Menu.
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation {
                                change.program = nil
                            }
                        }) {
                            Text(Style.leftArrow)
                                .frame(width: width / 6, height: Style.headerHeight)
                                .font(Style.directionsFont)
                                .contentShape(Rectangle())
                        }
                        Text(program.getName())
                            .frame(width: width * 2 / 3, height: Style.headerHeight)
                            .font(Style.titleFont)
                        Button(action: {
                            withAnimation {
                                change.currentView = .calc
                            }
                        }) {
                            Text(Style.downArrow)
                                .frame(width: width / 6, height: Style.headerHeight)
                                .font(Style.directionsFont)
                                .contentShape(Rectangle())
                        }
                    }
                    .background(Style.deepBlue)
                    .foregroundColor(Style.ivory)

                    HelpView(hlpString: program.getHelp())
                        .background(Style.ivory)

                    // Footer
                    HStack(spacing: 0) {
                        Spacer()
                        Button(loadButtonText) {
                            program.loadState()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                change.setLoadedProgram(program: program)
                            }
                            withAnimation {
                                change.currentView = .calc
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
            .transition(.move(edge: .leading))
        }
    }
}

struct FullProgramView_Previews: PreviewProvider {
    static var previews: some View {
        FullLibraryView()
    }
}
