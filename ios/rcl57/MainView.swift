/**
 * The main view. It holds the calculator, full log, and full program views.
 */

import SwiftUI

final class BoolObject: ObservableObject {
    @Published var value = false
}

final class BoolProgram: ObservableObject {
    @Published var value = false
}

final class BoolLog: ObservableObject {
    @Published var value = false
}

final class BoolLeft: ObservableObject {
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

struct MainView: View {
    private let rcl57: RCL57

    @StateObject private var change: Change
    @StateObject private var isFullLog: BoolLog
    @StateObject private var isFullProgram: BoolProgram
    @StateObject private var isMiniViewExpanded: BoolObject
    @StateObject private var leftTransition: BoolLeft

    init(rcl57: RCL57) {
        self.rcl57 = rcl57

        _change = StateObject(wrappedValue: Change(rcl57: rcl57))
        _isFullLog = StateObject(wrappedValue: BoolLog())
        _isFullProgram = StateObject(wrappedValue: BoolProgram())
        _isMiniViewExpanded = StateObject(wrappedValue: BoolObject())
        _leftTransition = StateObject(wrappedValue: BoolLeft())
    }

    private func getMainView(_ geometry: GeometryProxy) -> some View {
        return ZStack {
            ZStack {
                if !isFullLog.value && !isFullProgram.value {
                    CalcView(rcl57: rcl57)
                        .environmentObject(change)
                        .environmentObject(isFullLog)
                        .environmentObject(isFullProgram)
                        .environmentObject(isMiniViewExpanded)
                        .environmentObject(leftTransition)
                        .transition(.move(edge: leftTransition.value ? .trailing : .leading))
                }

                if isFullProgram.value {
                    FullProgramView(rcl57: rcl57)
                        .environmentObject(isFullProgram)
                        .environmentObject(change)
                        .environmentObject(isMiniViewExpanded)
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                }

                if isFullLog.value {
                    FullLogView(rcl57: rcl57)
                        .environmentObject(isFullLog)
                        .environmentObject(isMiniViewExpanded)
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(rcl57: RCL57())
    }
}
