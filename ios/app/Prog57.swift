import Foundation

/**
 * An RCL-57 program.
 *
 * A program has steps, registers, a name, and a description.
 */
class Prog57 : Hashable {
    /// The type used by the emulator to represent the set of steps and user registers.
    typealias ProgramRawData = (ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t,
                                ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t,
                                ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t,
                                ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t)

    /// The file extension for RCL-57 programs.
    static let programFileExtension = ".r57"

    /// The struct used by the emulator for a program.
    private var prog57 = prog57_t()

    /// The library the program belongs to.
    let library: Lib57

    /// The location where the program is stored.
    private(set) var url: URL?

    /// Whether the program can be modified.
    let isReadOnly: Bool

    /// The name of the program.
    var name: String {
        get {
            String(cString: prog57_get_name(&prog57))
        }
        set {
            prog57_set_name(&prog57, (newValue as NSString).utf8String)
        }
    }

    /// The text that describes the program and how to use it.
    var description: String {
        get {
            let description = prog57_get_help(&prog57)
            if let description {
                return String(cString: description)
            } else {
                return "No description available"
            }
        }
        set {
            prog57_set_help(&prog57, (newValue as NSString).utf8String)
        }
    }

    /// A String representing the steps, registers, name, and description.
    var rawText: String {
        String(cString: prog57_to_text(&prog57))
    }

    /// The steps and registers in machine readable format.
    var rawData: ProgramRawData {
        get {
            prog57.state
        }
        set {
            prog57.state = newValue
        }
    }

    /// Initializes a program from a URL.
    init?(fromURL url: URL, readOnly: Bool, library: Lib57) {
        var text: String
        do {
            text = try String(contentsOf: url)
        } catch {
            return nil
        }
        prog57_from_text(&prog57, text)
        self.isReadOnly = readOnly
        self.url = url
        self.library = library
    }

    /// Initializes a program from a text representation.
    init?(fromRawText rawText: String) {
        let found_name = prog57_from_text(&prog57, rawText)
        if !found_name {
            return nil
        }
        self.isReadOnly = false
        self.library = Lib57.userLib
    }

    /// Initializes a program from a name and a description.
    init(name: String, description: String) {
        prog57_set_name(&prog57, (name as NSString).utf8String)
        prog57_set_help(&prog57, (description as NSString).utf8String)
        prog57_set_steps_from_memory(&prog57, &Rcl57.shared.rcl57)
        prog57_set_registers_from_memory(&prog57, &Rcl57.shared.rcl57)
        self.isReadOnly = false
        self.library = Lib57.userLib
    }


    // MARK: Loading and saving.

    /// Loads steps and registers into memory.
    func load() {
        prog57_load_steps_into_memory(&prog57, &Rcl57.shared.rcl57)
        prog57_load_registers_into_memory(&prog57, &Rcl57.shared.rcl57)
    }

    /// Returns `true` if the steps in memory do not match the steps of the program.
    func stepsNeedSaving() -> Bool {
        if isReadOnly { return false }
        return !prog57_has_same_steps_as_state(&prog57, &Rcl57.shared.rcl57)
    }

    /// Saves the steps currently in memory into the program and filesystem.
    func saveSteps() -> Bool {
        prog57_set_steps_from_memory(&prog57, &Rcl57.shared.rcl57)
        return save()
    }

    /// Returns `true` if the registers in memory do not match the registers of the program.
    func registersNeedSaving() -> Bool {
        return !prog57_has_same_registers_as_state(&prog57, &Rcl57.shared.rcl57)
    }

    /// Saves the registers currently in memory into the program and filesystem.
    func saveRegisters() -> Bool {
        prog57_set_registers_from_memory(&prog57, &Rcl57.shared.rcl57)
        return save()
    }

    /// Saves the program into the filesystem.
    func save() -> Bool {
        if isReadOnly { return false }

        do {
            if let directoryURL = FileManager.default.urls(for: .documentDirectory,
                                                           in: .userDomainMask).first {
                let fileURL = directoryURL.appendingPathComponent(
                    self.name + Prog57.programFileExtension)
                try rawText.write(to: fileURL, atomically: true, encoding: .utf8)
                self.url = fileURL
            } else {
                return false
            }
        } catch {
            return false
        }

        return true
    }


    // MARK: Hashable Conformance

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }

    static func ==(lhs: Prog57, rhs: Prog57) -> Bool {
        return lhs.name == rhs.name
    }
}
