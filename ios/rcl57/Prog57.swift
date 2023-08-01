import Foundation

/**
 * An RCL-57 program.
 *
 * A program has steps, registers, a name, and help.
 */
class Prog57 : Hashable, CustomStringConvertible {
    static let programFileExtension = ".r57"

    /// The backing C struct for the program.
    private var prog57 = prog57_t()

    /// The location where the program is stored.
    var url: URL? = nil

    var isReadOnly: Bool

    var name: String {
        get {
            String(cString: prog57_get_name(&prog57))
        }
        set {
            prog57_set_name(&prog57, (newValue as NSString).utf8String)
        }
    }

    var help: String {
        get {
            let help = prog57_get_help(&prog57)
            if let help {
                return String(cString: help)
            } else {
                return "No description available"
            }
        }
        set {
            prog57_set_help(&prog57, (newValue as NSString).utf8String)
        }
    }

    /// The set of steps and user registers are held in 16 special registers.
    typealias RCL57RawState = (ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t,
                               ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t,
                               ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t,
                               ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t)

    var rawState: RCL57RawState {
        get {
            prog57.state
        }
        set {
            prog57.state = newValue
        }
    }

    /// For existing Library programs.
    init?(url: URL, readOnly: Bool) {
        var text: String
        do {
            text = try String(contentsOf: url)
        } catch {
            return nil
        }
        prog57_from_text(&prog57, text)
        self.isReadOnly = readOnly
        self.url = url
    }

    /// For imported programs.
    init?(text: String) {
        let found_name = prog57_from_text(&prog57, text)
        if !found_name {
            return nil
        }
        self.isReadOnly = false
    }

    /// For new programs ("create").
    init(name: String, description: String) {
        prog57_set_name(&prog57, (name as NSString).utf8String)
        prog57_set_help(&prog57, (description as NSString).utf8String)
        prog57_set_steps_from_memory(&prog57, &Rcl57.shared.rcl57)
        prog57_set_registers_from_memory(&prog57, &Rcl57.shared.rcl57)
        self.isReadOnly = false
    }

    func asString() -> String {
        String(cString: prog57_to_text(&prog57))
    }

    // MARK: Loading of steps and registers into memory.

    func loadStepsIntoMemory() {
        prog57_load_steps_into_memory(&prog57, &Rcl57.shared.rcl57)
    }

    func loadRegistersIntoMemory() {
        prog57_load_registers_into_memory(&prog57, &Rcl57.shared.rcl57)
    }

    // MARK: Saving of steps and registers from memory.

    func stepsNeedSaving() -> Bool {
        if isReadOnly { return false }
        return !prog57_has_same_steps_as_state(&prog57, &Rcl57.shared.rcl57)
    }

    func setStepsFromMemory() {
        prog57_set_steps_from_memory(&prog57, &Rcl57.shared.rcl57)
    }

    func registersNeedSaving() -> Bool {
        return !prog57_has_same_registers_as_state(&prog57, &Rcl57.shared.rcl57)
    }

    func setRegistersFromMemory() {
        prog57_set_registers_from_memory(&prog57, &Rcl57.shared.rcl57)
    }

    /// Saves a new or modified program into the filesystem.
    func save(filename: String) -> Bool {
        if isReadOnly { return false }

        do {
            let asString = asString()
            let userLibFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = userLibFolderURL.appendingPathComponent(filename + Prog57.programFileExtension)

            try asString.write(to: fileURL, atomically: true, encoding: .utf8)

            self.url = fileURL
        } catch {
            return false
        }

        return true
    }

    // MARK: CustomStringConvertible Conformance

    var description: String {
        return "Program \(name)"
    }

    // MARK: Hashable Conformance

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }

    static func ==(lhs: Prog57, rhs: Prog57) -> Bool {
        return lhs.name == rhs.name
    }
}
