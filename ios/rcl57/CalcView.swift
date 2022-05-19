/**
 * The calculator view with its keyboard and display.
 */

import SwiftUI

struct CalcView: View {
    let rcl57: RCL57

    private let fullDisplayHeight = (3 + Style.lineCount) * Style.lineHeight
    private let miniViewHeight = Style.lineCount * Style.lineHeight

    @EnvironmentObject private var change: Change

    @Binding var showBack: Bool

    private func getDisplayHeight() -> Double {
        return fullDisplayHeight - (change.isMiniViewVisible ? miniViewHeight : 0)
    }

    private func getMiniView() -> some View {
        if rcl57.isLrnMode() {
            return AnyView(ProgramView(rcl57: rcl57, isMiniView: true))
        } else if rcl57.getLoggedCount() == 0 {
            return AnyView(ZStack {
                Text("Log is empty")
            })
        } else {
            return AnyView(LogView(rcl57: rcl57))
        }
    }

    private func getButtonView(text: String, width: Double, prop: Binding<Bool>) -> some View {
        Button(action: {
            change.leftTransition = text == Style.leftArrow
            withAnimation {
                prop.wrappedValue.toggle()
            }
        }) {
            Text(text)
                .frame(width: width, height: Style.headerHeight)
                .contentShape(Rectangle())
        }
    }

    private func getView(_ geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let miniViewIcon = change.isMiniViewVisible ? Style.downArrow : Style.upArrow
        let displayHeight = getDisplayHeight()

        return ZStack {
            Style.blackish.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Menu bar.
                HStack(spacing: 0) {
                    getButtonView(text: Style.leftArrow, width: width / 6,
                                  prop: $change.isFullProgram)
                    Spacer()
                    getButtonView(text: Style.circle, width: width / 6, prop: $showBack)
                    Spacer()
                    getButtonView(text: miniViewIcon, width: width / 6,
                                  prop: $change.isMiniViewVisible)
                    Spacer()
                    getButtonView(text: Style.rightArrow, width: width / 6, prop: $change.isFullLog)
                }
                .font(Style.directionsFont)
                .background(Style.blackish)
                .foregroundColor(Style.ivory)

                // Display + Mini View.
                ZStack {
                    getMiniView()
                        .frame(width: CGFloat(width),
                               height: miniViewHeight)
                        .offset(x: 0, y: -(fullDisplayHeight - miniViewHeight) / 2)
                        .background(Style.ivory)
                        .foregroundColor(Style.blackish)


                    DisplayView(displayString: change.displayString)
                        .frame(width: CGFloat(width * 0.85), height: displayHeight)
                        .frame(width: width, height: displayHeight)
                        .background(.black)
                        .offset(x: 0, y: (fullDisplayHeight - displayHeight) / 2)
                }
                .frame(width: width, height: fullDisplayHeight)
                .background(Style.ivory)

                // Keyboard View.
                KeyboardView(rcl57: rcl57)
                    .environmentObject(change)
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
        CalcView(rcl57: RCL57(), showBack: .constant(false))
    }
}
