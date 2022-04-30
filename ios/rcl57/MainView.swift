/**
 * The main view. It holds the calculator, full log, and full program views.
 */

import SwiftUI

final class Change: ObservableObject {
    var rcl57: RCL57?
    var pc: Int
    var isAlpha: Bool
    var isHpLrnMode: Bool
    var isOpEditInLrn: Bool

    @Published var changeCount = 0
    @Published var displayString: String
    @Published var isFullLog: Bool
    @Published var isFullProgram: Bool
    @Published var isMiniViewExpanded: Bool
    @Published var leftTransition: Bool
    @Published var logTimestamp: Int

    init(rcl57: RCL57) {
        self.rcl57 = rcl57
        self.pc = rcl57.getProgramPc()
        self.isAlpha = rcl57.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)
        self.isHpLrnMode = rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        self.isOpEditInLrn = rcl57.isOpEditInLrn()
        self.displayString = rcl57.display()
        self.isFullLog = false
        self.isFullProgram = false
        self.isMiniViewExpanded = false
        self.leftTransition = false
        self.logTimestamp = rcl57.getLogTimestamp()
    }

    func updateDisplayString() {
        let display = rcl57!.display()
        if display != self.displayString {
            self.displayString = display
            changeCount += 1
        }
    }

    func forceUpdate() {
        changeCount += 1
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

        let logTimestamp = rcl57!.getLogTimestamp()
        if self.logTimestamp != logTimestamp {
            self.logTimestamp = logTimestamp
            changeCount += 1
        }

        if rcl57!.isLrnMode() {
            changeCount += 1
        }
    }
}

struct MainView: View {
    private let rcl57: RCL57
    private let timerPublisher = Timer.TimerPublisher(interval: 0.02, runLoop: .main, mode: .default)
        .autoconnect()

    @StateObject private var change: Change

    init(rcl57: RCL57) {
        self.rcl57 = rcl57

        _change = StateObject(wrappedValue: Change(rcl57: rcl57))
    }

    private func burst(ms: Int32) {
        _ = self.rcl57.advance(ms: ms)
        change.updateDisplayString()
        change.update()
    }

    private func getMainView(_ geometry: GeometryProxy) -> some View {
        return ZStack {
            ZStack {
                if !change.isFullLog && !change.isFullProgram {
                    CalcView(rcl57: rcl57)
                        .environmentObject(change)
                        .transition(.move(edge: change.leftTransition ? .trailing : .leading))
                }

                if change.isFullProgram {
                    FullProgramView(rcl57: rcl57)
                        .environmentObject(change)
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                }

                if change.isFullLog {
                    FullLogView(rcl57: rcl57)
                        .environmentObject(change)
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                }
            }
        }
    }

    var body: some View {
        print(Self._printChanges())
        return GeometryReader { geometry in
            self.getMainView(geometry)
        }
        .onReceive(timerPublisher) { _ in
            burst(ms: 20)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(rcl57: RCL57())
    }
}
