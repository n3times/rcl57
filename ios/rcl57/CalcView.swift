/**
 * The calculator view with its keyboard and display.
 */

import SwiftUI

struct CalcView: View {
    private let fullDisplayHeight = (3 + Double(Style.miniViewLineCount)) * Style.listLineHeight
    private let miniViewHeight = Double(Style.miniViewLineCount) * Style.listLineHeight

    @EnvironmentObject private var change: Change

    private func getDisplayHeight() -> Double {
        return fullDisplayHeight - (change.showMiniView ? miniViewHeight : 0)
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
                .frame(maxWidth: .infinity, maxHeight: Style.headerHeight)
                .contentShape(Rectangle())
        }
    }

    private func getView(_ geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let miniViewIcon = change.showMiniView ? Style.upArrow : Style.downArrow
        let displayHeight = getDisplayHeight()

        return ZStack {
            Style.blackish.edgesIgnoringSafeArea(.top)
            Color.black.edgesIgnoringSafeArea(.bottom)
            VStack(spacing: 0) {
                // Menu bar.
                HStack(spacing: 0) {
                    getButtonView(text: Style.leftArrow, width: width / 6,
                                  destination: .state, edge: .trailing)
                    getButtonView(text: Style.circle, width: width / 6, destination: .settings, edge: .trailing)
                    Button(action: {
                        withAnimation {
                            change.showMiniView.toggle()
                        }
                    }) {
                        Text(miniViewIcon)
                            .frame(maxWidth: .infinity, maxHeight: Style.headerHeight)
                            .contentShape(Rectangle())
                    }
                    getButtonView(text: Style.square, width: width / 6, destination: .library, edge: .top)
                    getButtonView(text: Style.rightArrow, width: width / 6, destination: .log, edge: .leading)
                }
                .font(Style.directionsFont)
                .background(Style.blackish)
                .foregroundColor(Style.ivory)

                // Program
                Text(change.loadedProgram != nil ? change.loadedProgram!.getName() : "")
                    .foregroundColor(Style.ivory)
                    .font(Style.programFont)
                    .frame(width: width, height: 20, alignment: .leading)
                    .offset(x: 15, y: -3)
                    .background(Style.blackish)

                // Display + Mini View.
                ZStack {
                    getMiniView()
                        .frame(width: CGFloat(width),
                               height: miniViewHeight)
                        .offset(x: 0, y: -(fullDisplayHeight - miniViewHeight) / 2)
                        .background(Style.ivory)
                        .foregroundColor(Style.blackish)

                    CalcDisplayView(displayString: change.displayString)
                        .frame(width: CGFloat(width * 0.85), height: displayHeight)
                        .frame(width: width, height: displayHeight)
                        .background(.black)
                        .offset(x: 0, y: (fullDisplayHeight - displayHeight) / 2)
                }
                .frame(width: width, height: fullDisplayHeight)
                .background(Style.ivory)

                // Keyboard View.
                CalcKeyboardView()
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
