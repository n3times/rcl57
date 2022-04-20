/**
 * The main view. It holds the calculator with its keyboard and display.
 */

import SwiftUI

final class Change: ObservableObject {
    var rcl57: RCL57?
    var pc: Int
    var isAlpha: Bool
    var isHpLrnMode: Bool
    var isOpEditInLrn: Bool

    @Published var changeCount = 0

    init(rcl57: RCL57) {
        self.rcl57 = rcl57
        self.pc = rcl57.getProgramPc()
        self.isAlpha = rcl57.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)
        self.isHpLrnMode = rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        self.isOpEditInLrn = rcl57.isOpEditInLrn()
    }

    func update() {
        let newPc = rcl57!.getProgramPc()
        if self.pc != newPc {
            self.pc = newPc
            changeCount += 1
        }

        let isAlpha = rcl57!.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)
        if self.isAlpha != isAlpha {
            self.isAlpha = isAlpha
            changeCount += 1
        }

        let isHpLrnMode = rcl57!.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        if self.isHpLrnMode != isHpLrnMode {
            self.isHpLrnMode = isHpLrnMode
            changeCount += 1
        }

        let isOpEditInLrn = rcl57!.isOpEditInLrn()
        if self.isOpEditInLrn != isOpEditInLrn {
            self.isOpEditInLrn = isOpEditInLrn
            changeCount += 1
        }

        if rcl57!.isLrnMode() {
            changeCount += 1
        }
    }
}

struct CalcView: View {
    static var isAnimating = false
    @StateObject var change: Change
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

        _change = StateObject(wrappedValue: Change(rcl57: rcl57))
    }

    private func burst(ms: Int32) {
        _ = self.rcl57.advance(ms: ms)
        self.displayString = self.rcl57.display()
        self.currentOp = self.rcl57.currentOp()
        ///.change.update()
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
                    change.update()
                }
        }
        .frame(width: calcWidth * 2 / 3 , height: 45)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
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
                    .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .foregroundColor(Color.white)
                    .font(.title2)

                    // Mini view.
                    if rcl57.isLrnMode() {
                        ProgramView(rcl57: rcl57, showPc: true)
                            .frame(width: CGFloat(calcWidth),
                                   height: CGFloat(displayHeight * 0.85))
                            .background(logBackgroundColor)
                            .environmentObject(change)
                    } else {
                        LogView(rcl57: rcl57, isFull: false)
                            .frame(width: CGFloat(calcWidth),
                                   height: CGFloat(displayHeight * 0.85))
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
                    .frame(width: CGFloat(calcWidth), height: CGFloat(displayHeight * 0.85))
                    .background(.black)

                    // Keyboard.
                    KeyboardView(rcl57: rcl57)
                        .environmentObject(change)
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
                        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
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
                        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                        .foregroundColor(Color.white)
                        .font(.title2)

                        // Program.
                        ProgramView(rcl57: rcl57, showPc: false)
                            .background(logBackgroundColor)
                            .environmentObject(change)
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
