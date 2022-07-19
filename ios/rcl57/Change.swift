import SwiftUI

enum CurrentView {
    case calc
    case log
    case state
    case settings
    case library
}

class Change: ObservableObject {
    static let shared = Change()

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
    @Published var showHelpInSettings = false
    @Published var showPageInHelp = false
    @Published var transitionEdge: Edge = .trailing

    @Published var program: Prog57? = nil
    @Published var createProgram = false

    @Published var showLibrary = false
    @Published var showPreview = false

    @Published var pageTitle = ""
    @Published var pageURL = ""

    @Published var examplesLibExpanded = false
    @Published var userLibExpanded = false

    @Published var loadedProgram: Prog57?

    let PROGRAM_KEY = "program"

    init() {
        self.pc = Rcl57.shared.getProgramPc()
        self.isAlpha = Rcl57.shared.getOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG)
        self.isHpLrnMode = Rcl57.shared.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        self.isOpEditInLrn = Rcl57.shared.isOpEditInLrn()
        self.displayString = Rcl57.shared.display()
        self.logTimestamp = Rcl57.shared.getLogTimestamp()
        let programName = UserDefaults.standard.string(forKey: PROGRAM_KEY)
        if let program = Lib57.examplesLib.programs.first(where: {$0.getName() == programName}) {
            self.loadedProgram = program
        } else {
            self.loadedProgram = nil
        }
    }

    func setLoadedProgram(program: Prog57?) {
        loadedProgram = program
        UserDefaults.standard.set(program?.getName(), forKey: PROGRAM_KEY)
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
