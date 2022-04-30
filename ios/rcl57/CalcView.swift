/**
 * The main view. It holds the calculator with its keyboard and display.
 */

import SwiftUI

struct CalcView: View {
    private let rcl57: RCL57

    @State private var isTurboMode: Bool
    @State private var isHpLRN: Bool
    @State private var isAlpha: Bool

    @EnvironmentObject private var change: Change

    init(rcl57: RCL57) {
        self.rcl57 = rcl57

        isTurboMode = rcl57.getSpeedup() == 1000
        isHpLRN = rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        isAlpha = rcl57.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)
    }

    private func setOption(option: Int32, value: Bool) {
        self.rcl57.setOptionFlag(option: option, value: value)
        change.updateDisplayString()
    }

    private func getMenuView(_ scaleFactor: Double, _ calcWidth: Double) -> some View {
        Menu("\u{25ef}") {
            Button("Reset") {
                rcl57.clearAll()
                change.updateDisplayString()
            }
            Toggle("Turbo", isOn: $isTurboMode)
                .onChange(of: isTurboMode) { _ in
                    if isTurboMode {
                        rcl57.setSpeedup(speedup: 1000)
                    } else {
                        rcl57.setSpeedup(speedup: 2)
                    }
                    setOption(option: RCL57_SHORT_PAUSE_FLAG, value: isTurboMode)
                    setOption(option: RCL57_FASTER_TRACE_FLAG, value: isTurboMode)
                    setOption(option: RCL57_QUICK_STOP_FLAG, value: isTurboMode)
                    setOption(option: RCL57_SHOW_RUN_INDICATOR_FLAG, value: isTurboMode)
                    setOption(option: RCL57_HP_LRN_MODE_FLAG, value: isTurboMode)
                    setOption(option: RCL57_ALPHA_LRN_MODE_FLAG, value: isTurboMode)
                }
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .foregroundColor(Color.white)
    }

    private func getDisplayHeight(displayHeight: Double) -> Double {
        if !change.isMiniViewExpanded { return displayHeight }

        return displayHeight / 2
    }

    private func getView(_ geometry: GeometryProxy) -> some View {
        let standardCalcWidth = 375.0
        let standardDisplayHeight = 160.0

        let calcWidth = geometry.size.width
        let scaleFactor = calcWidth / standardCalcWidth
        let displayHeight = standardDisplayHeight * scaleFactor
        let logBackgroundColor = Color(red: 32.0/255, green: 32.0/255, blue: 36.0/255)

        return ZStack {
            Color(red: 16.0/255, green: 16.0/255, blue: 16.0/255).edgesIgnoringSafeArea(.all)
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
                            .frame(width: calcWidth / 6, height: 55)
                            .contentShape(Rectangle())
                    }

                    Spacer()

                    // Menu button.
                    getMenuView(scaleFactor, calcWidth)
                        .frame(width: calcWidth * 1 / 6 , height: 55)

                    Spacer()

                    // Mini view button.
                    Button(action: {
                        withAnimation {
                            change.isMiniViewExpanded.toggle()
                        }
                    }) {
                        Text(change.isMiniViewExpanded ? "\u{25b3}" : "\u{25bd}")
                            .frame(width: calcWidth / 6, height: 55)
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
                            .frame(width: calcWidth / 6, height: 55)
                            .contentShape(Rectangle())
                    }
                }
                .font(Font.system(size: 20, weight: .regular, design: .monospaced))
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                .foregroundColor(Color.white)

                ZStack {
                    // Mini view.
                    if rcl57.isLrnMode() {
                        ProgramView(rcl57: rcl57, showPc: true)
                            .frame(width: CGFloat(calcWidth),
                                   height: displayHeight / 2)
                            .offset(x: 0, y: -(displayHeight / 4))
                            .background(logBackgroundColor)
                            .environmentObject(change)
                    } else {
                        LogView(rcl57: rcl57)
                            .background(Color(red: 1.0, green: 1.0, blue: 0.93))
                            .frame(width: CGFloat(calcWidth),
                                   height: displayHeight / 2)
                            .offset(x: 0, y: -(displayHeight / 4))
                            .background(Color(red: 1.0, green: 1.0, blue: 0.93))
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
                .zIndex(-1)

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
