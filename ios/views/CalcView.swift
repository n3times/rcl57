import SwiftUI

/// A specialized bar to navigate to the different views of the app.
private struct CalcNavigationBar: View {
    /// A button of the calc navigation bar.
    struct CalcNavigationButton: View {
        @EnvironmentObject private var appState: AppState

        /// The title of the button.
        let title: String

        /// The app location to transition to when the button is pressed.
        let destination: AppLocation

        var body: some View {
            Button(action: {
                appState.destinationAppLocation = destination
                withAnimation {
                    appState.appLocation = destination
                }
            }) {
                Text(title)
                    .font(Style.directionsFontLarge)
                    .frame(maxWidth: .infinity, maxHeight: Style.headerHeight)
                    .offset(y: -5)
                    .contentShape(Rectangle())
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            CalcNavigationButton(title: Style.leftArrow, destination: .state)
                .foregroundColor(.lightGray)
            CalcNavigationButton(title: Style.square, destination: .manual)
                .foregroundColor(.deepishGreen)
            CalcNavigationButton(title: Style.square, destination: .settings)
                .foregroundColor(.lightGray)
            CalcNavigationButton(title: Style.square, destination: .library)
                .foregroundColor(.deepishBlue)
            CalcNavigationButton(title: Style.rightArrow, destination: .log)
                .foregroundColor(.lightGray)
        }
        .font(Style.directionsFont)
        .background(Color.blackish)
        .foregroundColor(.ivory)
    }
}

/// Displays the program name and the current operation.
private struct CalcInfoView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var emulatorState: EmulatorState

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            HStack(spacing: 0) {
                Text(appState.loadedProgram?.name ?? "")
                    .font(Style.programNameFont)
                    .offset(x: 15, y: -3)
                    .frame(width: width / 2, alignment: .leading)

                Spacer()
                    .frame(width: width / 6, alignment: .leading)

                Text(emulatorState.currentOp)
                    .font(Style.operationNameFont)
                    .offset(x: -25, y: -3)
                    .frame(width: width / 3, alignment: .trailing)
            }
        }
        .frame(height: Style.calcInfoHeight)
        .foregroundColor(.lightGray)
        .background(Color.blackish)
    }
}

/// The calculator view with the navigation bar, info, display, and keyboard.
struct CalcView: View {
    @EnvironmentObject private var emulatorState: EmulatorState

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack {
                Color.blackish.edgesIgnoringSafeArea(.top)
                Color.black.edgesIgnoringSafeArea(.bottom)
                VStack(spacing: 0) {
                    CalcNavigationBar()
                    CalcInfoView()
                    DisplayView(displayString: emulatorState.displayString)
                        .frame(width: CGFloat(width * 0.85), height: Style.calcDisplayHeight)
                        .background(.black)
                    KeyboardView()
                    Spacer(minLength: 20)
                }
            }
        }
    }
}

struct CalcView_Previews: PreviewProvider {
    static var previews: some View {
        CalcView()
    }
}
