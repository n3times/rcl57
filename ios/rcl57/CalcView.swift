import SwiftUI

/// A specialized bar to navigate to the different views of the app.
private struct CalcNavigationBar: View {

    /// A button of the calc navigation bar.
    struct CalcNavigationButton: View {
        @EnvironmentObject private var change: Change

        let text: String
        let destination: ViewType
        let edge: Edge

        var body: some View {
            Button(action: {
                change.transitionEdge = edge
                withAnimation {
                    change.currentViewType = destination
                }
            }) {
                Text(text)
                    .font(Style.directionsFontLarge)
                    .frame(maxWidth: .infinity, maxHeight: Style.headerHeight)
                    .offset(y: -5)
                    .contentShape(Rectangle())
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            CalcNavigationButton(text: Style.leftArrow, destination: .state, edge: .trailing)
                .foregroundColor(.lightGray)
            CalcNavigationButton(text: Style.square, destination: .manual, edge: .top)
                .foregroundColor(.deepishGreen)
            CalcNavigationButton(text: Style.square, destination: .settings, edge: .top)
                .foregroundColor(.lightGray)
            CalcNavigationButton(text: Style.square, destination: .library, edge: .top)
                .foregroundColor(.deepishBlue)
            CalcNavigationButton(text: Style.rightArrow, destination: .log, edge: .leading)
                .foregroundColor(.lightGray)
        }
        .font(Style.directionsFont)
        .background(Color.blackish)
        .foregroundColor(.ivory)
    }
}

/// Displays the program name and the current operation.
private struct CalcInfoView: View {
    @EnvironmentObject private var change: Change

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            HStack(spacing: 0) {
                Text(change.loadedProgram?.name ?? "")
                    .font(Style.programFont)
                    .offset(x: 15, y: -3)
                    .frame(width: width / 2, height: 20, alignment: .leading)

                Spacer()
                    .frame(width: width / 6, height: 20, alignment: .leading)

                Text(Rcl57.shared.currentOp)
                    .font(Style.operationFont)
                    .offset(x: -25, y: -3)
                    .frame(width: width / 3, height: 20, alignment: .trailing)
            }
            .foregroundColor(.lightGray)
            .background(Color.blackish)
        }
        .frame(height: 20)
    }
}

/// The calculator view with the navigation bar, info, display, and keyboard.
struct CalcView: View {
    @EnvironmentObject private var change: Change

    var body: some View {
        let displayHeight = 4 * Style.listLineHeight

        return GeometryReader { proxy in
            let width = proxy.size.width

            ZStack {
                Color.blackish.edgesIgnoringSafeArea(.top)
                Color.black.edgesIgnoringSafeArea(.bottom)
                VStack(spacing: 0) {
                    CalcNavigationBar()
                    CalcInfoView()
                    DisplayView(displayString: change.displayString)
                        .frame(width: CGFloat(width * 0.85), height: displayHeight)
                        .frame(width: width, height: displayHeight)
                        .background(.black)
                    KeyboardView()
                    Spacer(minLength: 20)
                }
            }
            .onAppear {
                change.updateDisplayString()
            }
        }
    }
}

struct CalcView_Previews: PreviewProvider {
    static var previews: some View {
        CalcView()
    }
}
