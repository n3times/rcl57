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
                        change.showStepsInState.toggle()
                    }) {
                        Text(!change.showStepsInState ? Style.ying : Style.yang)
                            .frame(width: width / 12, height: Style.headerHeight)
                            .font(Style.directionsFontLarge)
                            .contentShape(Rectangle())
                    }
                    Spacer()
                        .frame(width: width / 24, height: Style.headerHeight)
                    Text(change.showStepsInState ? "Program" : "Data")
                        .frame(width: width * 2 / 3, height: Style.headerHeight)
                        .font(Style.titleFont)
                    // Right button.
                    Button(action: {
                        withAnimation {
                            change.currentView = .calc
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

                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: width / 6, height: Style.footerHeight)
                    Button("Clear") {
                        isPresentingConfirm = true
                    }
                    .font(Style.footerFont)
                    .frame(width: width * 2 / 3, height: Style.footerHeight)
                    .disabled(change.showStepsInState ? Rcl57.shared.getProgramLastIndex() == -1
                                                 : Rcl57.shared.getRegistersLastIndex() == -1)
                    .buttonStyle(.plain)
                    .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        if change.showStepsInState {
                            Button("Clear Program", role: .destructive) {
                                change.setLoadedProgram(program: nil)
                                Rcl57.shared.clearProgram()
                                change.forceUpdate()
                            }
                        } else {
                            Button("Clear Registers", role: .destructive) {
                                Rcl57.shared.clearRegisters()
                                change.forceUpdate()
                            }
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
