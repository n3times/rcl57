import SwiftUI

struct ProgramView: View {
    @Binding var showBack: Bool

    let program: Prog57

    var body: some View {
        return VStack(spacing: 0) {
            HelpView(hlpString: program.getHelp())
            HStack(spacing: 0) {
                Spacer()
                Button("Load") {
                    program.loadState()
                    withAnimation {
                        showBack.toggle()
                    }
                }
                .font(Style.titleFont)
                .frame(width: 100, height: Style.footerHeight)
                .buttonStyle(.plain)
                Spacer()
            }
            .background(Color.gray)
            .foregroundColor(Style.ivory)
        }
        .navigationBarItems(
            trailing:
                Button(action: {
                    withAnimation {
                        showBack.toggle()
                    }
                }) {
                    Text(Style.circle)
                        .frame(width: 70, height: Style.headerHeight, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .font(Style.directionsFont)
        )
    }
}
