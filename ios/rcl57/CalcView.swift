/**
 * The main view. It holds the calculator with its keyboard and display.
 */

import SwiftUI

struct CalcView: View {
    private let rcl57: RCL57

    @State private var isTurboMode: Bool
    @State private var showingOptions = false

    @EnvironmentObject private var change: Change

    init(rcl57: RCL57) {
        self.rcl57 = rcl57

        isTurboMode = rcl57.getCalcMode() == .turbo
    }

    private func getMenuView(_ scaleFactor: Double, _ calcWidth: Double) -> some View {
        Button(action: {
             showingOptions = true
        }) {
            Text("\u{25ef}")
                .frame(width: calcWidth / 6, height: Style.headerHeight)
                .contentShape(Rectangle())
        }
        .confirmationDialog("Select", isPresented: $showingOptions, titleVisibility: .visible) {
            Button("Reset") {
                rcl57.clearAll()
                change.updateDisplayString()
            }
            Button(action: {
                isTurboMode.toggle()
                rcl57.setCalcMode(mode: isTurboMode ? .turbo : .classic)
                change.updateDisplayString()
            }) {
                HStack {
                    Text(isTurboMode ? "Turbo Mode" : "Classic Mode")
                    Image(systemName: "checkmark")
                }
            }
        }
    }

    private func getDisplayHeight(displayHeight: Double) -> Double {
        if !change.isMiniViewExpanded { return displayHeight }

        return displayHeight / 2
    }

    private func getView(_ geometry: GeometryProxy) -> some View {
        let calcWidth = geometry.size.width
        let displayHeight = 6 * Style.lineHeight
        let logBackgroundColor = Style.blackish

        return ZStack {
            Style.blackish.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Menu bar.
                HStack(spacing: 0) {
                    // Left button.
                    Button(action: {
                        change.leftTransition = true
                        withAnimation {
                            change.isFullProgram.toggle()
                        }
                    }) {
                        Text("\u{25c1}")
                            .frame(width: calcWidth / 6, height: Style.headerHeight)
                            .contentShape(Rectangle())
                    }

                    Spacer()

                    Button(action: {
                        withAnimation {
                            change.showBack.toggle()
                        }
                    }) {
                        Text("\u{25ef}")
                            .frame(width: calcWidth / 6, height: Style.headerHeight)
                            .contentShape(Rectangle())
                    }

                    Spacer()

                    // Mini view button.
                    Button(action: {
                        withAnimation {
                            change.isMiniViewExpanded.toggle()
                        }
                    }) {
                        Text(change.isMiniViewExpanded ? "\u{25b3}" : "\u{25bd}")
                            .frame(width: calcWidth / 6, height: Style.headerHeight)
                            .contentShape(Rectangle())
                    }

                    Spacer()

                    // Right button.
                    Button(action: {
                        change.leftTransition = false
                        withAnimation {
                            change.isFullLog.toggle()
                        }
                    }) {
                        Text("\u{25b7}")
                            .frame(width: calcWidth / 6, height: Style.headerHeight)
                            .contentShape(Rectangle())
                    }
                }
                .font(Style.directionsFont)
                .background(Style.blackish)
                .foregroundColor(Style.ivory)

                ZStack {
                    // Mini view.
                    if rcl57.isLrnMode() {
                        ProgramView(rcl57: rcl57, showPc: true)
                            .frame(width: CGFloat(calcWidth),
                                   height: displayHeight / 2)
                            .offset(x: 0, y: -(displayHeight / 4))
                            .background(logBackgroundColor)
                            .environmentObject(change)
                    } else if rcl57.getLoggedCount() == 0 {
                        ZStack {
                            Text("Log is empty")
                        }
                        .frame(width: CGFloat(calcWidth),
                               height: displayHeight / 2)
                        .background(Style.ivory)
                        .foregroundColor(Style.blackish)
                        .offset(x: 0, y: -(displayHeight / 4))
                    } else {
                        LogView(rcl57: rcl57)
                            .frame(width: CGFloat(calcWidth),
                                   height: displayHeight / 2)
                            .background(Style.ivory)
                            .offset(x: 0, y: -(displayHeight / 4))
                            .environmentObject(change)
                    }

                    // Display.
                    DisplayView(change.displayString)
                        .frame(width: CGFloat(calcWidth * 0.85),
                               height: CGFloat(displayHeight / 2))
                    .frame(width: calcWidth, height: getDisplayHeight(displayHeight: displayHeight))
                    .background(.black)
                    .offset(x: 0, y: (displayHeight / 2 - getDisplayHeight(displayHeight: displayHeight)/2))
                }
                .frame(width: calcWidth, height: displayHeight)

                // Keyboard.
                KeyboardView(rcl57: rcl57)
                    .environmentObject(change)
            }
        }
        .onAppear {
            change.updateDisplayString()
        }
    }

    var body: some View {
        print(Self._printChanges())
        return GeometryReader { geometry in
            self.getView(geometry)
        }
    }
}

struct CalcView_Previews: PreviewProvider {
    static var previews: some View {
        CalcView(rcl57: RCL57())
    }
}
