/**
 * The main view. It holds the calculator with its keyboard and display.
 */

import SwiftUI

final class BoolObject: ObservableObject {
    @Published var value = false
}

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

    @StateObject private var isFullLog: BoolObject
    @StateObject private var isFullProgram: BoolObject
    @StateObject private var isMiniViewExpanded: BoolObject

    @State private var leftTransition: Bool

    init(rcl57: RCL57) {
        self.rcl57 = rcl57

        isTurboMode = rcl57.getSpeedup() == 1000
        isHpLRN = rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        isAlpha = rcl57.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)

        leftTransition = false

        _change = StateObject(wrappedValue: Change(rcl57: rcl57))
        _isFullLog = StateObject(wrappedValue: BoolObject())
        _isFullProgram = StateObject(wrappedValue: BoolObject())
        _isMiniViewExpanded = StateObject(wrappedValue: BoolObject())
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
            ZStack {
                if !isFullLog.value && !isFullProgram.value {
                VStack {
                    // Menu bar.
                    HStack(spacing: 0) {
                        // Left button.
                        Button("\u{25c1}") {
                            leftTransition = true
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
                            leftTransition = false
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
                            .environmentObject(change)
                            .environmentObject(isMiniViewExpanded)
                    }

                    // Display.
                    HStack {
                        DisplayView(self.displayString)
                            .frame(width: CGFloat(calcWidth * 0.85),
                                   height: CGFloat(displayHeight))
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

                if isFullLog.value {
                    FullLogView(rcl57: rcl57)
                        .environmentObject(isFullLog)
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                }

                if isFullProgram.value {
                    FullProgramView(rcl57: rcl57)
                        .environmentObject(isFullProgram)
                        .environmentObject(change)
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
