import SwiftUI;
import Combine

enum AppLocation {
    case calc, log, state, settings, library, manual
}

enum StateLocation {
    case view, create
}

enum StateViewMode {
    case steps, registers
}

/// Properties that determine the state of the different views. They are monitored by SwiftUI and
/// result in the Views being updated as needed.
class Change: ObservableObject {

    // MARK: Timer

    // We run the emulator by short bursts. Each burst emulates running the actual TI-57 for a
    // short period of time. In practice the emulator takes much less time to execute the burst.

    private static let burstMilliseconds = 20
    private var timerCancellable: AnyCancellable?
    private let timer = Timer.publish(
        every: Double(burstMilliseconds) / 1000,
        on: .main,
        in: .default
    ).autoconnect()


    // MARK: Emulator state

    // The display and the log timestamp get updated once per burst, since SwiftUI can't observe
    // directly changes to the emulator state.

    @Published var displayString = Rcl57.shared.display
    @Published var logTimestamp = Rcl57.shared.logTimestamp


    // MARK: Loaded program

    // Persisted across launches.

    private let loadedProgramKey = "LOADED_PROGRAM_KEY"
    private let loadedLibraryKey = "LOADED_LIBRARY_KEY"

    @Published var loadedProgram: Prog57? {
        didSet {
            UserDefaults.standard.set(loadedProgram?.name, forKey: loadedProgramKey)
            UserDefaults.standard.set(loadedProgram?.library.name, forKey: loadedLibraryKey)
        }
    }


    // MARK: Navigation

    @Published var appLocation: AppLocation = .calc
    @Published var previousAppLocation: AppLocation = .calc


    // MARK: Bookmarks

    // Used for quick access to a page/view.

    @Published var manualBookmark: ManualContentView.PageData? = nil
    @Published var libraryBookmark: Prog57? = nil


    // MARK: State View

    @Published var stateViewMode: StateViewMode = .steps
    @Published var stateLocation: StateLocation = .view


    // MARK: Library View

    @Published var isSamplesLibExpanded = false
    @Published var isUserLibExpanded = false


    // MARK: Program View

    @Published var isPreviewInEditProgram = false
    @Published var isEditInProgramView = false
    @Published var isImportProgramInLibrary = false


    init() {
        let loadedProgramName = UserDefaults.standard.string(forKey: loadedProgramKey)
        let loadedLibraryName = UserDefaults.standard.string(forKey: loadedLibraryKey)

        let loadedLibrary =
            [Lib57.samplesLib, Lib57.userLib].first(where: { $0.name == loadedLibraryName })
        self.loadedProgram =
            loadedLibrary?.programs.first(where: { $0.name == loadedProgramName })

        self.timerCancellable = timer
            .sink { _ in
                _ = Rcl57.shared.advance(milliseconds: Int32(Change.burstMilliseconds))
                if self.displayString != Rcl57.shared.display {
                    self.displayString = Rcl57.shared.display
                }
                if self.logTimestamp != Rcl57.shared.logTimestamp {
                    self.logTimestamp = Rcl57.shared.logTimestamp
                }
            }
    }

    deinit {
        self.timerCancellable?.cancel()
    }
}
