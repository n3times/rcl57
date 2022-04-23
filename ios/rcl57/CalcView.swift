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

    @State private var isMiniViewFull: Bool
    @State private var isMiniViewExpanded: Bool

    @State private var leftTransition: Bool

    init(rcl57: RCL57) {
        self.rcl57 = rcl57

        isTurboMode = rcl57.getSpeedup() == 1000
        isHpLRN = rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        isAlpha = rcl57.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)

        isFullLog = false
        isFullProgram = false

        isMiniViewFull = false
        isMiniViewExpanded = false

        leftTransition = false

        _change = StateObject(wrappedValue: Change(rcl57: rcl57))
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
        Menu("\u{25c7}") {  // Rounded square.
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
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .foregroundColor(Color.white)
    }

    private func getMiniViewHeight(displayHeight: Int, calcHeight: Int) -> Double {
        if !isMiniViewExpanded { return 0 }
        if isMiniViewFull {
            return Double(calcHeight - 45)
        } else {
            return Double(displayHeight) * 0.85
        }
    }

    private func getDisplayHeight(displayHeight: Int) -> Double {
        if !isMiniViewExpanded { return Double(displayHeight) * 1.7 }
        if isMiniViewFull {
            return 0
        } else {
            return Double(displayHeight) * 0.85
        }
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
            ZStack {
                if !isFullLog && !isFullProgram {
                VStack {
                    // Menu bar.
                    HStack(spacing: 0) {
                        // Left button.
                        Button("\u{25c1}") {
                            leftTransition = true
                            withAnimation {
                                isFullProgram.toggle()
                            }
                        }
                        .frame(width: calcWidth / 6, height: 45)
                        // Menu button.
                        getMenuView(scaleFactor, calcWidth)
                            .frame(width: calcWidth * 1 / 3 , height: 45)
                        // Mini view button.
                        Button(isMiniViewExpanded ? "\u{25cf}" : "\u{25ef}") {
                            withAnimation {
                                isMiniViewExpanded.toggle()
                            }
                        }
                        .frame(width: calcWidth * 1 / 3 , height: 45)


                        // Right button.
                        Button("\u{25b7}") {
                            leftTransition = false
                            withAnimation {
                                isFullLog.toggle()
                            }
                        }
                        .frame(width: calcWidth / 6, height: 45)
                    }
                    .font(Font.system(size: 32, weight: .regular, design: .monospaced))
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
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    isMiniViewFull.toggle()
                                }
                            }
                    } else {
                        LogView(rcl57: rcl57)
                            .frame(width: CGFloat(calcWidth),
                                   height: getMiniViewHeight(displayHeight: Int(displayHeight),
                                                             calcHeight: Int(calcHeight)))
                            .background(logBackgroundColor)
                            .environmentObject(change)
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    isMiniViewFull.toggle()
                                }
                            }
                    }

                    // Display.
                    HStack {
                        DisplayView(self.displayString)
                            .frame(width: CGFloat(calcWidth * 0.85),
                                   height: CGFloat(isMiniViewFull && isMiniViewExpanded ? 0
                                                   : displayHeight))
                    }
                    .frame(width: CGFloat(calcWidth),
                           height: getDisplayHeight(displayHeight: Int(displayHeight)))
                    .background(.black)

                    // Keyboard.
                    KeyboardView(rcl57: rcl57)
                        .environmentObject(change)
                }
                .transition(.move(edge: leftTransition ? .trailing : .leading))
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
                        LogView(rcl57: rcl57)
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
