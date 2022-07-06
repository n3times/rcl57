import SwiftUI

struct ProgramView: View {
    @EnvironmentObject private var change: Change

    let program: Prog57

    var body: some View {
        return VStack(spacing: 0) {
            HelpView(hlpString: program.getHelp())
            HStack(spacing: 0) {
                Spacer()
                Button("Load") {
                    program.loadState()
                    withAnimation {
                        change.currentView = .calc
                    }
                }
                .font(Style.titleFont)
                .frame(width: 100, height: Style.footerHeight)
                .buttonStyle(.plain)
                Spacer()
            }
            .background(Style.blackish)
            .foregroundColor(Style.ivory)
        }
    }
}
