/**
 * The main view. It holds the calculator with its keyboard and display.
 */

import SwiftUI

struct CalcView: View {
    private let rcl57: RCL57
    @State private var timer: Timer?

    @State private var displayString = ""

    @State private var isTurboMode: Bool
    @State private var isHpLRN: Bool
    @State private var isAlpha: Bool

    @EnvironmentObject private var change: Change
    @EnvironmentObject private var isFullLog: BoolLog
    @EnvironmentObject private var isFullProgram: BoolProgram
    @EnvironmentObject private var isMiniViewExpanded: BoolObject
    @EnvironmentObject private var leftTransition: BoolLeft

    init(rcl57: RCL57) {
        self.rcl57 = rcl57

        isTurboMode = rcl57.getSpeedup() == 1000
        isHpLRN = rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        isAlpha = rcl57.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)
    }

    private func burst(ms: Int32) {
        _ = self.rcl57.advance(ms: ms)
        self.displayString = self.rcl57.display()
    }

    private func runDisplayAnimationLoop() {
        burst(ms: 20)
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                burst(ms: 20)
            }
        }
    }

    private func setOption(option: Int32, value: Bool) {
        self.rcl57.setOptionFlag(option: option, value: value)
        self.displayString = self.rcl57.display()
    }

    private func getMenuView(_ scaleFactor: Double, _ calcWidth: Double) -> some View {
        Menu("\u{25ef}") {
            Button("Reset") {
                rcl57.clearAll()
                runDisplayAnimationLoop()
                self.displayString = self.rcl57.display()
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

    private func getMiniViewHeight(displayHeight: Int, calcHeight: Int) -> Double {
        if !isMiniViewExpanded.value { return 0 }

        return Double(displayHeight) * 0.85
    }

    private func getDisplayHeight(displayHeight: Int) -> Double {
        if !isMiniViewExpanded.value { return Double(displayHeight) * 1.7 }

        return Double(displayHeight) * 0.85
    }

    private func getView(_ geometry: GeometryProxy) -> some View {
        let standardCalcWidth = 375.0
        let standardDisplayHeight = 96.0

        let calcWidth = geometry.size.width
        let calcHeight = geometry.size.height

        let scaleFactor = calcWidth / standardCalcWidth

        let displayHeight = standardDisplayHeight * scaleFactor

        let logBackgroundColor = Color(red: 32.0/255, green: 32.0/255, blue: 36.0/255)

        return ZStack {
            Color(red: 16.0/255, green: 16.0/255, blue: 16.0/255).edgesIgnoringSafeArea(.all)
            VStack {
                // Menu bar.
                HStack(spacing: 0) {
                    // Left button.
                    Button("\u{25c1}") {
                        leftTransition.value = true
                        withAnimation {
                            isFullProgram.value.toggle()
                        }
                    }
                    .frame(width: calcWidth / 6, height: 45)

                    Spacer()

                    // Menu button.
                    getMenuView(scaleFactor, calcWidth)
                        .frame(width: calcWidth * 1 / 6 , height: 45)

                    Spacer()

                    // Mini view button.
                    Button(isMiniViewExpanded.value ? "\u{25b3}" : "\u{25bd}") {
                        withAnimation {
                            isMiniViewExpanded.value.toggle()
                        }
                    }
                    .frame(width: calcWidth * 1 / 6 , height: 45)

                    Spacer()

                    // Right button.
                    Button("\u{25b7}") {
                        leftTransition.value = false
                        withAnimation {
                            isFullLog.value.toggle()
                        }
                    }
                    .frame(width: calcWidth / 6, height: 45)
                }
                .font(Font.system(size: 25, weight: .regular, design: .monospaced))
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                .foregroundColor(Color.white)

                // Mini view.
                if rcl57.isLrnMode() {
                    ProgramView(rcl57: rcl57, showPc: true)
                        .frame(width: CGFloat(calcWidth),
                                height: getMiniViewHeight(displayHeight: Int(displayHeight),
                                                             calcHeight: Int(calcHeight)))
                        .background(logBackgroundColor)
                        .environmentObject(change)
                        .environmentObject(isMiniViewExpanded)
                } else {
                    LogView(rcl57: rcl57)
                        .frame(width: CGFloat(calcWidth),
                                height: getMiniViewHeight(displayHeight: Int(displayHeight),
                                                            calcHeight: Int(calcHeight)))
                        .background(logBackgroundColor)
                        .environmentObject(isMiniViewExpanded)
                }

                // Display.
                HStack {
                    DisplayView(self.displayString)
                        .frame(width: CGFloat(calcWidth * 0.85),
                                height: CGFloat(displayHeight * 0.85))
                }
                .frame(width: CGFloat(calcWidth),
                        height: getDisplayHeight(displayHeight: Int(displayHeight)))
                .background(.black)

                // Keyboard.
                KeyboardView(rcl57: rcl57)
                    .environmentObject(change)
            }
        }
        .onAppear {
            self.displayString = self.rcl57.display()
            self.runDisplayAnimationLoop()
        }
        .onDisappear() {
            if timer != nil {
              timer!.invalidate()
              timer = nil
            }
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
