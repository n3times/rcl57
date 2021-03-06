import SwiftUI

/**
 * The calculator view with its keyboard, display, and a menu on top.
 */
struct CalcView: View {
    @EnvironmentObject private var change: Change

    private static let displayHeight = 4 * Style.listLineHeight

    private func getDisplayHeight() -> Double {
        return CalcView.displayHeight
    }

    private func getButtonView(text: String, width: Double, destination: CurrentView, edge: Edge) -> some View {
        Button(action: {
            change.transitionEdge = edge
            withAnimation {
                change.currentView = destination
            }
        }) {
            Text(text)
                .font(Style.directionsFontLarge)
                .frame(maxWidth: .infinity, maxHeight: Style.headerHeight)
                .offset(y: -5)
                .contentShape(Rectangle())
        }
    }

    private func getView(_ geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let displayHeight = getDisplayHeight()

        return ZStack {
            Style.blackish.edgesIgnoringSafeArea(.top)
            Color.black.edgesIgnoringSafeArea(.bottom)
            VStack(spacing: 0) {
                // Menu bar.
                HStack(spacing: 0) {
                    getButtonView(text: Style.leftArrow, width: width / 6, destination: .state, edge: .trailing)
                        .foregroundColor(Style.lightGray)
                    getButtonView(text: Style.square, width: width / 6, destination: .manual, edge: .top)
                        .foregroundColor(Style.deepishGreen)
                    getButtonView(text: Style.square, width: width / 6, destination: .settings, edge: .top)
                        .foregroundColor(Style.lightGray)
                    getButtonView(text: Style.square, width: width / 6, destination: .library, edge: .top)
                        .foregroundColor(Style.deepishBlue)
                    getButtonView(text: Style.rightArrow, width: width / 6, destination: .log, edge: .leading)
                        .foregroundColor(Style.lightGray)
                }
                .font(Style.directionsFont)
                .background(Style.blackish)
                .foregroundColor(Style.ivory)

                // Program Name.
                HStack(spacing: 0) {
                    Text(change.loadedProgram != nil ? change.loadedProgram!.getName() : "")
                        .font(Style.programFont)
                        .offset(x: 15, y: -3)
                        .frame(maxWidth: width / 2, maxHeight: 20, alignment: .leading)

                    Spacer()
                        .frame(maxWidth: width / 6, maxHeight: 20, alignment: .leading)

                    Text(Rcl57.shared.currentOp())
                        .font(Style.operationFont)
                        .offset(x: -25, y: -3)
                        .frame(maxWidth: width / 3, maxHeight: 20, alignment: .trailing)
                }
                .foregroundColor(Style.lightGray)
                .background(Style.blackish)

                // Display.
                CalcDisplayView(displayString: change.displayString)
                    .frame(width: CGFloat(width * 0.85), height: displayHeight)
                    .frame(width: width, height: displayHeight)
                    .background(.black)

                // Keyboard View.
                CalcKeyboardView()

                Spacer(minLength: 20)
            }
        }
        .onAppear {
            change.updateDisplayString()
        }
    }

    var body: some View {
        return GeometryReader { geometry in
            self.getView(geometry)
        }
    }
}

struct CalcView_Previews: PreviewProvider {
    static var previews: some View {
        CalcView()
    }
}
