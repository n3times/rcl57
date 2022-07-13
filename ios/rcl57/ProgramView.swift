import SwiftUI

struct ProgramView: View {
    @EnvironmentObject private var change: Change

    let program: Prog57

    var body: some View {
        let loaded = program == change.loadedProgram
        let loadButtonText = loaded ? "RELOAD" : "LOAD"

        return VStack(spacing: 0) {
            HelpView(hlpString: program.getHelp())
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
}
