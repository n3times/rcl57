import SwiftUI
import Combine

enum ViewType {
    case calc
    case log
    case state
    case settings
    case library
    case manual
}

class Change: ObservableObject {
    private let timerPublisher = Timer.TimerPublisher(interval: 0.02, runLoop: .main, mode: .default)
        .autoconnect()
    private var cancellable: AnyCancellable?

    private let LOADED_PROGRAM_KEY = "LOADED_PROGRAM_KEY"

    @Published var changeCount = 0
    @Published var transitionEdge: Edge = .trailing

    @Published var displayString: String
    @Published var logTimestamp: Int
    @Published var loadedProgram: Prog57?

    @Published var currentViewType = ViewType.calc

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
        self.displayString = Rcl57.shared.display
        self.logTimestamp = Rcl57.shared.logTimestamp

        let loadedProgramName = UserDefaults.standard.string(forKey: LOADED_PROGRAM_KEY)
        self.loadedProgram =
            Lib57.samplesLib.programs.first(where: {$0.name == loadedProgramName})

        self.cancellable = timerPublisher
            .sink { _ in
                self.burst(ms: 20)
            }
    }

    deinit {
        self.cancellable?.cancel()
    }

    func setLoadedProgram(program: Prog57?) {
        loadedProgram = program
        UserDefaults.standard.set(program?.name, forKey: LOADED_PROGRAM_KEY)
    }

    func burst(ms: Int32) {
        _ = Rcl57.shared.advance(ms: ms)
        updateLogTimestamp()
        updateDisplayString()
    }

    func updateDisplayString() {
        let display = Rcl57.shared.display
        if display != self.displayString {
            self.displayString = display
        }
    }

    func updateLogTimestamp() {
        let logTimestamp = Rcl57.shared.logTimestamp
        if self.logTimestamp != logTimestamp {
            self.logTimestamp = logTimestamp
        }
    }

    func forceUpdate() {
        changeCount += 1
    }
}
