import SwiftUI

/** A list of LineView's. */
struct FullStateView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false

    var body: some View {
        return GeometryReader { geometry in
            let width = geometry.size.width
            VStack(spacing: 0) {
                // Menu.
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: width / 24, height: Style.headerHeight)
                    Button(action: {
                        change.showProgram.toggle()
                    }) {
                        Text(!change.showProgram ? Style.ying : Style.yang)
                            .frame(width: width / 12, height: Style.headerHeight)
                            .font(Style.directionsFontLarge)
                            .contentShape(Rectangle())
                    }
                    Spacer()
                        .frame(width: width / 24, height: Style.headerHeight)
                    Text(change.showProgram ? "Program" : "Registers")
                        .frame(width: width * 2 / 3, height: Style.headerHeight)
                        .font(Style.titleFont)
                    // Right button.
                    Button(action: {
                        withAnimation {
                            change.isFullProgram.toggle()
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

                // Program.
                StateView(isMiniView: false)
                    .background(Style.ivory)
                    .environmentObject(change)

                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: width / 6, height: Style.footerHeight)
                    Button("Clear") {  // Left arrow.
                        isPresentingConfirm = true
                    }
                    .font(Style.titleFont)
                    .frame(width: width * 2 / 3, height: Style.footerHeight)
                    .disabled(change.showProgram ? Rcl57.shared.getProgramLastIndex() == -1
                                                 : Rcl57.shared.getRegistersLastIndex() == -1)
                    .buttonStyle(.plain)
                    .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        Button(change.showProgram ? "Clear Program" : "Clear Registers", role: .destructive) {
                            change.showProgram ? Rcl57.shared.clearProgram() : Rcl57.shared.clearRegisters()
                            change.forceUpdate()
                        }
                    }
                    Spacer()
                        .frame(width: width / 6, height: Style.footerHeight)
                }
                .background(Style.blackish)
                .foregroundColor(Style.ivory)
            }
        }
    }
}

struct FullStateView_Previews: PreviewProvider {
    static var previews: some View {
        FullStateView()
    }
}
