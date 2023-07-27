import SwiftUI

private struct CalcMenuButton: View {
    @EnvironmentObject private var change: Change

    let text: String
    let destination: CurrentView
    let edge: Edge

    var body: some View {
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
}

private struct CalcMenuBar: View {
    var body: some View {
        HStack(spacing: 0) {
            CalcMenuButton(text: Style.leftArrow, destination: .state, edge: .trailing)
                .foregroundColor(.lightGray)
            CalcMenuButton(text: Style.square, destination: .manual, edge: .top)
                .foregroundColor(.deepishGreen)
            CalcMenuButton(text: Style.square, destination: .settings, edge: .top)
                .foregroundColor(.lightGray)
            CalcMenuButton(text: Style.square, destination: .library, edge: .top)
                .foregroundColor(.deepishBlue)
            CalcMenuButton(text: Style.rightArrow, destination: .log, edge: .leading)
                .foregroundColor(.lightGray)
        }
        .font(Style.directionsFont)
        .background(Color.blackish)
        .foregroundColor(.ivory)
    }
}

private struct CalcInfoView: View {
    @EnvironmentObject private var change: Change

    let width: Double

    var body: some View {
        // Program Name and Current Operation.
        HStack(spacing: 0) {
            Text(change.loadedProgram != nil ? change.loadedProgram!.name : "")
                .font(Style.programFont)
                .offset(x: 15, y: -3)
                .frame(maxWidth: width / 2, maxHeight: 20, alignment: .leading)

            Spacer()
                .frame(maxWidth: width / 6, maxHeight: 20, alignment: .leading)

            Text(Rcl57.shared.currentOp)
                .font(Style.operationFont)
                .offset(x: -25, y: -3)
                .frame(maxWidth: width / 3, maxHeight: 20, alignment: .trailing)
        }
        .foregroundColor(.lightGray)
        .background(Color.blackish)
    }
}

/**
 * The calculator view with its keyboard, display, and a menu on top.
 */
struct CalcView: View {
    @EnvironmentObject private var change: Change

    var body: some View {
        let displayHeight = 4 * Style.listLineHeight

        return GeometryReader { geometry in
            let width = geometry.size.width

            ZStack {
                Color.blackish.edgesIgnoringSafeArea(.top)
                Color.black.edgesIgnoringSafeArea(.bottom)
                VStack(spacing: 0) {
                    CalcMenuBar()
                    CalcInfoView(width: width)
                    CalcDisplayView(displayString: change.displayString)
                        .frame(width: CGFloat(width * 0.85), height: displayHeight)
                        .frame(width: width, height: displayHeight)
                        .background(.black)
                    CalcKeyboardView()
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
