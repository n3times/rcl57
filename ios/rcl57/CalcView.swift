/**
 * The main view. It holds the calculator with its keyboard and display.
 */

import SwiftUI

struct CalcView: View {
    static var isAnimating = false

    private let rcl57: RCL57

    @State private var displayString = ""
    @State private var currentOp = ""

    @State private var isTurboMode: Bool
    @State private var isHpLRN: Bool
    @State private var isAlpha: Bool

    @State private var isFullLog: Bool
    @State private var isFullProgram: Bool

    init(rcl57: RCL57) {
        self.rcl57 = rcl57

        isTurboMode = rcl57.getSpeedup() == 1000
        isHpLRN = rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        isAlpha = rcl57.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)

        isFullLog = false
        isFullProgram = false
    }

    private func burst(ms: Int32) {
        _ = self.rcl57.advance(ms: ms)
        self.displayString = self.rcl57.display()
        self.currentOp = self.rcl57.currentOp()
    }

    private func runDisplayAnimationLoop() {
        burst(ms: 20)
        if CalcView.isAnimating { return }
        CalcView.isAnimating = true
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            burst(ms: 20)
        }
    }

    private func setOption(option: Int32, value: Bool) {
        self.rcl57.setOptionFlag(option: option, value: value)
        self.displayString = self.rcl57.display()
    }

    private func getMenuView(_ scaleFactor: Double, _ calcWidth: Double) -> some View {
        Menu("Menu") {
            Button("Clear All") {
                rcl57.clearAll()
                runDisplayAnimationLoop()
                self.displayString = self.rcl57.display()
            }
            Button("Clear Log") {
                rcl57.clearLog()
            }
            Toggle("Turbo Speed", isOn: $isTurboMode)
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
                }
            Toggle("HP LRN", isOn: $isHpLRN)
                .onChange(of: isHpLRN) { _ in
                    setOption(option: RCL57_HP_LRN_MODE_FLAG, value: isHpLRN)
                }
            Toggle("Alpha Display", isOn: $isAlpha)
                .onChange(of: isAlpha) { _ in
                    setOption(option: RCL57_ALPHA_LRN_MODE_FLAG, value: isAlpha)
                }
        }
        .frame(width: calcWidth * 2 / 3 , height: 45)
        .background(Color.gray)
        .foregroundColor(Color.white)
        .font(.title2)
    }

    private func getView(_ geometry: GeometryProxy) -> some View {
        let standardCalcWidth = 375.0
        let standardDisplayHeight = 96.0

        let calcWidth = geometry.size.width

        let scaleFactor = calcWidth / standardCalcWidth

        let displayHeight = standardDisplayHeight * scaleFactor

        let logBackgroundColor = Color(red: 32.0/255, green: 32.0/255, blue: 36.0/255)

        return ZStack {
            Color(red: 16.0/255, green: 16.0/255, blue: 16.0/255).edgesIgnoringSafeArea(.all)
            ZStack {
                VStack {
                    // Menu bar.
                    HStack(spacing: 0) {
                        Button("\u{25c1}") {
                            withAnimation {
                                isFullProgram.toggle()
                            }
                        }
                        .frame(width: calcWidth / 6, height: 45)
                        getMenuView(scaleFactor, calcWidth)
                        Button("\u{25b7}") {
                            withAnimation {
                                isFullLog.toggle()
                            }
                        }
                        .frame(width: calcWidth / 6, height: 45)
                    }
                    .background(Color.gray)
                    .foregroundColor(Color.white)
                    .font(.title2)

                    // Mini view.
                    if rcl57.isLrnMode() {
                        MiniProgramView(rcl57: rcl57)
                            .frame(width: CGFloat(calcWidth),
                                   height: CGFloat(displayHeight * 0.7))
                            .background(logBackgroundColor)
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    isFullProgram.toggle()
                                }
                            }
                    } else {
                        LogView(rcl57: rcl57, isFull: false)
                            .frame(width: CGFloat(calcWidth),
                                   height: CGFloat(displayHeight * 0.7))
                            .background(logBackgroundColor)
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    isFullLog.toggle()
                                }
                            }
                    }

                    // Display.
                    HStack {
                        DisplayView(self.displayString)
                            .frame(width: CGFloat(calcWidth * 0.85),
                                   height: CGFloat(displayHeight))
                    }
                    .frame(width: CGFloat(calcWidth), height: CGFloat(displayHeight))
                    .background(.black)

                    // Keyboard.
                    KeyboardView(rcl57: rcl57)
                }

                if isFullLog {
                    VStack {
                        // Menu.
                        HStack(spacing: 0) {
                            Button("\u{25c1}") {  // Left arrow.
                                withAnimation {
                                    isFullLog.toggle()
                                }
                            }
                            .frame(width: calcWidth / 6, height: 45)
                            Text("Log")
                                .frame(width: calcWidth * 2 / 3, height: 45)
                            Spacer()
                                .frame(width: calcWidth / 6, height: 45)
                        }
                        .background(Color.gray)
                        .foregroundColor(Color.white)
                        .font(.title2)

                        // Full log.
                        LogView(rcl57: rcl57, isFull: true)
                            .background(logBackgroundColor)
                    }
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                }

                if isFullProgram {
                    VStack {
                        // Menu.
                        HStack {
                            Spacer()
                                .frame(width: calcWidth / 6, height: 45)
                            Text("Program")
                                .frame(width: calcWidth * 2 / 3, height: 45)
                            Button("\u{25b7}") {  // Right arrow.
                                withAnimation {
                                    isFullProgram.toggle()
                                }
                            }
                            .frame(width: calcWidth / 6, height: 45)
                        }
                        .background(Color.gray)
                        .foregroundColor(Color.white)
                        .font(.title2)

                        // Program.
                        ProgramView(rcl57: rcl57, maxLines: 500)
                            .background(logBackgroundColor)
                    }
                    .transition(.move(edge: .leading))
                    .zIndex(1)
                }
            }
        }
        .onAppear {
            self.displayString = self.rcl57.display()
            self.runDisplayAnimationLoop()
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
