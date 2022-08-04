import SwiftUI

enum CurrentView {
    case calc
    case log
    case state
    case settings
    case library
    case manual
}

class Change: ObservableObject {
    private let LOADED_PROGRAM_KEY = "LOADED_PROGRAM_KEY"

    @Published var changeCount = 0
    @Published var transitionEdge: Edge = .trailing

    @Published var displayString: String
    @Published var logTimestamp: Int
    @Published var loadedProgram: Prog57?

    @Published var currentView = CurrentView.calc

    // State View
    @Published var isStepsInState = true
    @Published var isCreateProgramInState = false

    // Manual View
    @Published var manualPageView: ManualPageView? = nil

    // Library View
    @Published var isSamplesLibExpanded = false
    @Published var isUserLibExpanded = false
    @Published var isImportProgramInLibrary = false

    // Program View
    @Published var programView: ProgramView? = nil
    @Published var isEditInProgramView = false

    // Program Editing
    @Published var isPreviewInEditProgram = false

    init() {
        self.displayString = Rcl57.shared.display()
        self.logTimestamp = Rcl57.shared.getLogTimestamp()

        let loadedProgramName = UserDefaults.standard.string(forKey: LOADED_PROGRAM_KEY)
        self.loadedProgram =
            Lib57.samplesLib.programs.first(where: {$0.getName() == loadedProgramName})
    }

    func setLoadedProgram(program: Prog57?) {
        loadedProgram = program
        UserDefaults.standard.set(program?.getName(), forKey: LOADED_PROGRAM_KEY)
    }

    func updateDisplayString() {
        let display = Rcl57.shared.display()
        if display != self.displayString {
            self.displayString = display
        }
    }

    func updateLogTimestamp() {
        let logTimestamp = Rcl57.shared.getLogTimestamp()
        if self.logTimestamp != logTimestamp {
            self.logTimestamp = logTimestamp
        }
    }

    func forceUpdate() {
        changeCount += 1
    }
}
