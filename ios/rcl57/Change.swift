import SwiftUI;
import Combine

enum ViewType {
    case calc, log, state, settings, library, manual
}

/// Properties that determine the state of the different Views. They are monitored by SwiftUI and
/// result in the Views being updated as needed.
class Change: ObservableObject {

    /// We run the emulator by short bursts. Each burst emulates running the actual TI-57 for a
    /// short period of time. In practice the emulator takes much less time to execute the burst.
    private static let burstMilliseconds = 20

    private let timerPublisher = Timer.TimerPublisher(
        interval: Double(burstMilliseconds) / 1000,
        runLoop: .main,
        mode: .default
    ).autoconnect()

    private var timerCancellable: AnyCancellable?

    private let LOADED_PROGRAM_KEY = "LOADED_PROGRAM_KEY"

    @Published var changeCount = 0

    /// The display as a String. Gets updated once per burst.
    @Published var displayString = Rcl57.shared.display

    /// The log timestamp, incremented when a new log line is added. Gets updated once per burst.
    @Published var logTimestamp = Rcl57.shared.logTimestamp

    @Published var loadedProgram: Prog57? {
        didSet {
            UserDefaults.standard.set(loadedProgram?.name, forKey: LOADED_PROGRAM_KEY)
        }
    }


    // MARK: Navigation


    @Published var currentViewType: ViewType = .calc
    @Published var transitionEdge: Edge = .trailing


    // MARK: State View

    @Published var isStepsInState = true
    @Published var isCreateProgramInState = false


    // MARK: Manual View


    /// Bookmark the last page in the manual viewed, for quick access.
    @Published var lastManualPageViewedData: ManualContentView.PageData? = nil


    // MARK: Library View


    @Published var isSamplesLibExpanded = false
    @Published var isUserLibExpanded = false


    // MARK: Program View

    @Published var isPreviewInEditProgram = false

    /// Bookmark the last program viewed in the library, for quick access.
    @Published var lastProgramViewed: Prog57? = nil

    @Published var isEditInProgramView = false

    @Published var isImportProgramInLibrary = false

    init() {
        let loadedProgramName = UserDefaults.standard.string(forKey: LOADED_PROGRAM_KEY)
        self.loadedProgram =
            Lib57.samplesLib.programs.first(where: {$0.name == loadedProgramName})

        self.timerCancellable = timerPublisher
            .sink { _ in
                _ = Rcl57.shared.advance(milliseconds: Int32(Change.burstMilliseconds))
                self.displayString = Rcl57.shared.display
                self.logTimestamp = Rcl57.shared.logTimestamp
            }
    }

    deinit {
        self.timerCancellable?.cancel()
    }

    func forceUpdate() {
        changeCount += 1
    }
}
