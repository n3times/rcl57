/**
 * The main view. It holds the calculator, full log, and full program views.
 */

import SwiftUI

final class Change: ObservableObject {
    var rcl57: Rcl57?
    var pc: Int
    var isAlpha: Bool
    var isHpLrnMode: Bool
    var isOpEditInLrn: Bool

    @Published var changeCount = 0
    @Published var displayString: String
    @Published var isFullLog: Bool
    @Published var isFullProgram: Bool
    @Published var isMiniViewVisible: Bool
    @Published var leftTransition: Bool
    @Published var logTimestamp: Int

    init(rcl57: Rcl57) {
        self.rcl57 = rcl57
        self.pc = rcl57.getProgramPc()
        self.isAlpha = rcl57.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)
        self.isHpLrnMode = rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        self.isOpEditInLrn = rcl57.isOpEditInLrn()
        self.displayString = rcl57.display()
        self.isFullLog = false
        self.isFullProgram = false
        self.isMiniViewVisible = false
        self.leftTransition = false
        self.logTimestamp = rcl57.getLogTimestamp()
    }

    func updateDisplayString() {
        let display = rcl57!.display()
        if display != self.displayString {
            self.displayString = display
            forceUpdate()
        }
    }

    func updateLogTimestamp() {
        let logTimestamp = rcl57!.getLogTimestamp()
        if self.logTimestamp != logTimestamp {
            self.logTimestamp = logTimestamp
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
    }
}

private struct FlipView<FrontView: View, BackView: View>: View {

    let frontView: FrontView
    let backView: BackView

    @EnvironmentObject private var change: Change
    @Binding var showBack: Bool

    var body: some View {
        ZStack() {
            frontView
                .modifier(FlipOpacity(percentage: showBack ? 0 : 1))
                .rotation3DEffect(Angle.degrees(showBack ? 180 : 360), axis: (0,1,0))
            backView
                .modifier(FlipOpacity(percentage: showBack ? 1 : 0))
                .rotation3DEffect(Angle.degrees(showBack ? 0.00001 : 180), axis: (0,1,0))
        }
    }
}

private struct FlipOpacity: AnimatableModifier {
   var percentage: CGFloat = 0

   var animatableData: CGFloat {
      get { percentage }
      set { percentage = newValue }
   }

   func body(content: Content) -> some View {
      content
           .opacity(Double(percentage < 0.5 ? 0 : 0.99999))
   }
}

struct MainView: View {
    private let timerPublisher = Timer.TimerPublisher(interval: 0.02, runLoop: .main, mode: .default)
        .autoconnect()

    @StateObject private var change: Change
    @State var showBack = false

    init() {
        _change = StateObject(wrappedValue: Change(rcl57: Rcl57.shared))
    }

    private func burst(ms: Int32) {
        _ = Rcl57.shared.advance(ms: ms)
        change.updateLogTimestamp()
        change.updateDisplayString()
    }

    private func getMainView(_ geometry: GeometryProxy) -> some View {
        let front = CalcView(showBack: $showBack)
        let back2 = SettingsView(rcl57: Rcl57.shared, showBack: $showBack)

        return ZStack {
            ZStack {
                if !change.isFullLog && !change.isFullProgram {
                    FlipView(frontView: front, backView: back2, showBack: $showBack)
                        .environmentObject(change)
                        .transition(.move(edge: change.leftTransition ? .trailing : .leading))
                }

                if change.isFullLog {
                    FullLogView()
                        .environmentObject(change)
                        .transition(.move(edge: .trailing))
                } else if change.isFullProgram {
                    FullLrnView()
                        .environmentObject(change)
                        .transition(.move(edge: .leading))
                }
            }
        }
    }

    var body: some View {
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
        MainView()
    }
}
