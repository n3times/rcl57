/**
 * The calculator view with its keyboard and display.
 */

import SwiftUI

struct CalcView: View {
    @EnvironmentObject private var change: Change

    private static let displayHeight = 4 * Style.listLineHeight

    private func getDisplayHeight() -> Double {
        return CalcView.displayHeight
    }

    private func getMiniView() -> some View {
        if Rcl57.shared.isLrnMode() {
            return AnyView(StateInnerView(isMiniView: true))
        } else if Rcl57.shared.getLoggedCount() == 0 {
            return AnyView(ZStack {
                Text("Log is empty")
            })
        } else {
            return AnyView(LogInnerView())
        }
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
                        .foregroundColor(Style.ivory)
                    getButtonView(text: Style.square, width: width / 6, destination: .manual, edge: .top)
                        .foregroundColor(Style.ivory)
                    getButtonView(text: Style.circle, width: width / 6, destination: .settings, edge: .top)
                        .foregroundColor(Style.ivory)
                    getButtonView(text: Style.square, width: width / 6, destination: .library, edge: .top)
                        .foregroundColor(Style.ivory)
                    getButtonView(text: Style.rightArrow, width: width / 6, destination: .log, edge: .leading)
                        .foregroundColor(Style.ivory)
                }
                .font(Style.directionsFont)
                .background(Style.blackish)
                .foregroundColor(Style.ivory)

                // Program Name.
                Text(change.loadedProgram != nil ? change.loadedProgram!.getName() : "")
                    .foregroundColor(Style.ivory)
                    .font(Style.programFont)
                    .frame(width: width, height: 20, alignment: .leading)
                    .offset(x: 15, y: -3)
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
