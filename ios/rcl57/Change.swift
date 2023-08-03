import SwiftUI;
import Combine

enum AppLocation {
    case calc, log, state, settings, library, manual
}

enum StateLocation {
    case viewState, createProgram
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

    // Note that SwiftUI can't observe directly changes to the C emulator state. The relevant
    // state gets updated after every burst.

    // Updated once per burst.
    @Published var displayString = Rcl57.shared.display

    // Updated once per burst.
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


    // MARK: General Navigation

    /// The current app location.
    @Published var appLocation: AppLocation = .calc

    /// Used to handle animations: state <-> calc <-> log.
    @Published var destinationAppLocation: AppLocation = .calc

    /// Used to access the manual page that was last viewed.
    @Published var manualBookmark: ManualContentView.PageData? = nil

    /// Used to access the program that was last viewed.
    @Published var libraryBookmark: Prog57? = nil


    // MARK: State View

    /// Whether the `StateView` should show the steps or the registers.
    @Published var stateViewMode: StateViewMode = .steps

    /// Whether the `StateView` should show the steps/registers or the create Program overlay.
    @Published var stateLocation: StateLocation = .viewState


    // MARK: Library View

    @Published var isSamplesLibExpanded = false
    @Published var isUserLibExpanded = false


    // MARK: Program View

    @Published var isSavingProgram = false
    @Published var isEditingProgram = false
    @Published var isImportingProgram = false


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
