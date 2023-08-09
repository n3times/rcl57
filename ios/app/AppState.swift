import SwiftUI;
import Combine

/// The different parts of the app the user can navigate to.
enum AppLocation {
    case calc, log, state, settings, library, manual
}

/// The different types of data the `StateView` can display.
enum StateViewMode {
    case steps, registers
}

/// The main properties that determine the state of the different views. They are monitored by
/// SwiftUI and changes result in the views being updated as needed.
class AppState: ObservableObject {
    // MARK: Emulator timer

    /// We run the emulator by short bursts. Each burst emulates running the actual TI-57 for a
    /// short period of time. In practice the emulator takes much less time to execute the burst.
    private static let burstMilliseconds = 20

    /// Timer that runs the emulator.
    private let timer = Timer.publish(
        every: Double(burstMilliseconds) / 1000,
        on: .main,
        in: .default
    ).autoconnect()

    /// Used to cancel the timer.
    private var timerCancellable: AnyCancellable?


    // MARK: Emulator state

    // Note that SwiftUI can't observe directly changes to the C emulator state. The relevant
    // state gets updated after every burst.

    /// The display, updated once per burst.
    @Published private(set) var displayString = Rcl57.shared.display

    /// The log timestamp, updated once per burst.
    @Published private(set) var logTimestamp = Log57.shared.logTimestamp


    // MARK: Loaded program

    // Persisted across launches.

    /// The loaded program key into `UserDefaults`.
    private let loadedProgramKey = "LOADED_PROGRAM_KEY"

    /// The loaded library key into `UserDefaults`.
    private let loadedLibraryKey = "LOADED_LIBRARY_KEY"

    /// The program currently in memory.
    @Published var loadedProgram: Prog57? {
        didSet {
            UserDefaults.standard.set(loadedProgram?.name, forKey: loadedProgramKey)
            UserDefaults.standard.set(loadedProgram?.library.name, forKey: loadedLibraryKey)
        }
    }


    // MARK: General Navigation

    /// The current app location.
    @Published var appLocation: AppLocation = .calc

    /// Used to handle animations: state <-> calc <-> log.
    @Published var destinationAppLocation: AppLocation = .calc

    /// Used to access the manual page that was last viewed.
    @Published var manualBookmark: ManualView.PageData? = nil

    /// Used to access the program that was last viewed.
    @Published var libraryBookmark: Prog57? = nil


    // MARK: State View

    /// Whether the `StateView` should show the steps or the registers.
    @Published var stateViewMode: StateViewMode = .steps


    // MARK: Library View

    /// Whether the list of sample programs is expanded.
    @Published var isSamplesLibExpanded = false

    /// Whether the list of user programs is expanded.
    @Published var isUserLibExpanded = false


    // MARK: Program View

    /// Whether the user is in the Program Editing screen.
    @Published var isProgramEditing = false

    /// Whether the user is in the Program Saving screen.
    @Published var isProgramSaving = false

    init() {
        let loadedProgramName = UserDefaults.standard.string(forKey: loadedProgramKey)
        let loadedLibraryName = UserDefaults.standard.string(forKey: loadedLibraryKey)

        let loadedLibrary =
            [Lib57.samplesLib, Lib57.userLib].first(where: { $0.name == loadedLibraryName })
        self.loadedProgram =
            loadedLibrary?.programs.first(where: { $0.name == loadedProgramName })

        self.timerCancellable = timer
            .sink { _ in
                _ = Rcl57.shared.advance(milliseconds: Int32(AppState.burstMilliseconds))
                if self.displayString != Rcl57.shared.display {
                    self.displayString = Rcl57.shared.display
                }
                if self.logTimestamp != Log57.shared.logTimestamp {
                    self.logTimestamp = Log57.shared.logTimestamp
                }
            }
    }

    deinit {
        self.timerCancellable?.cancel()
    }
}
