import SwiftUI;

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
    // MARK: Loaded program

    // Persisted across launches.

    /// The loaded program key in `UserDefaults`.
    private let loadedProgramKey = "LOADED_PROGRAM_KEY"

    /// The loaded library key in `UserDefaults`.
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
    }
}
