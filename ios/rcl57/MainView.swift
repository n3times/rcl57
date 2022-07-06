/**
 * The main view. It holds the calculator, full log, and full program views.
 */

import SwiftUI

enum CurrentView {
    case calc
    case log
    case state
    case settings
    case library
}

final class Change: ObservableObject {
    var pc: Int
    var isAlpha: Bool
    var isHpLrnMode: Bool
    var isOpEditInLrn: Bool

    @Published var changeCount = 0
    @Published var displayString: String
    @Published var logTimestamp: Int

    @Published var currentView = CurrentView.calc

    @Published var showMiniView = false
    @Published var showStepsInState = true
    @Published var transitionEdge: Edge = .trailing

    @Published var program: Prog57? = nil

    @Published var showLibrary = false

    init() {
        self.pc = Rcl57.shared.getProgramPc()
        self.isAlpha = Rcl57.shared.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)
        self.isHpLrnMode = Rcl57.shared.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        self.isOpEditInLrn = Rcl57.shared.isOpEditInLrn()
        self.displayString = Rcl57.shared.display()
        self.logTimestamp = Rcl57.shared.getLogTimestamp()
    }

    func updateDisplayString() {
        let display = Rcl57.shared.display()
        if display != self.displayString {
            self.displayString = display
            forceUpdate()
        }
    }

    func updateLogTimestamp() {
        let logTimestamp = Rcl57.shared.getLogTimestamp()
        if self.logTimestamp != logTimestamp {
            self.logTimestamp = logTimestamp
            changeCount += 1
        }
    }

    func forceUpdate() {
        changeCount += 1
    }

    func update() {
        let newPc = Rcl57.shared.getProgramPc()
        if self.pc != newPc {
            self.pc = newPc
            changeCount += 1
        }

        let isAlpha = Rcl57.shared.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)
        if self.isAlpha != isAlpha {
            self.isAlpha = isAlpha
            changeCount += 1
        }

        let isHpLrnMode = Rcl57.shared.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        if self.isHpLrnMode != isHpLrnMode {
            self.isHpLrnMode = isHpLrnMode
            changeCount += 1
        }

        let isOpEditInLrn = Rcl57.shared.isOpEditInLrn()
        if self.isOpEditInLrn != isOpEditInLrn {
            self.isOpEditInLrn = isOpEditInLrn
            changeCount += 1
        }

        let logTimestamp = Rcl57.shared.getLogTimestamp()
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

    var body: some View {
        ZStack() {
            frontView
                .modifier(FlipOpacity(percentage: change.currentView == .settings ? 0 : 1))
                .rotation3DEffect(Angle.degrees(change.currentView == .settings ? 180 : 360), axis: (0,1,0))
            backView
                .modifier(FlipOpacity(percentage: change.currentView == .settings ? 1 : 0))
                .rotation3DEffect(Angle.degrees(change.currentView == .settings ? 0.00001 : 180), axis: (0,1,0))
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
        _change = StateObject(wrappedValue: Change())
    }

    private func burst(ms: Int32) {
        _ = Rcl57.shared.advance(ms: ms)
        change.updateLogTimestamp()
        change.updateDisplayString()
    }

    private func getMainView(_ geometry: GeometryProxy) -> some View {
        ZStack {
            if change.currentView == .calc || change.currentView == .settings || change.currentView == .library {
                FlipView(frontView: CalcView(), backView: SettingsView())
                    .environmentObject(change)
                    .transition(.move(edge: change.transitionEdge))
                if change.currentView == .library {
                    FullLibraryView()
                        .environmentObject(change)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
            }

            if change.currentView == .log {
                FullLogView()
                    .environmentObject(change)
                    .transition(.move(edge: .trailing))
            } else if change.currentView == .state {
                FullStateView()
                    .environmentObject(change)
                    .transition(.move(edge: .leading))
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
