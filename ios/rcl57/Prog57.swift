import Foundation

/**
 * An RCL-57 program.
 *
 * It is characterized by its name, description, steps and registers.
 *
 * Registers and steps are combined into a 'state' structure.
 */
class Prog57 : Hashable {
    static let programFileExtension = ".r57"

    /* Backing struct: name, description and state. */
    private var prog57 = prog57_t()

    var url: URL? = nil

    var readOnly: Bool

    /** For existing Library programs. */
    init?(url: URL, readOnly: Bool) {
        var text: String
        do {
            text = try String(contentsOf: url)
        } catch {
            return nil
        }
        prog57_from_text(&prog57, text)
        self.readOnly = readOnly
        self.url = url
    }

    /** For imported programs. */
    init?(text: String) {
        let found_name = prog57_from_text(&prog57, text)
        if !found_name {
            return nil
        }
        self.readOnly = false
    }

    /** For new programs ("create"). */
    init(name: String, description: String) {
        prog57_set_name(&prog57, (name as NSString).utf8String)
        prog57_set_help(&prog57, (description as NSString).utf8String)
        prog57_set_steps_from_memory(&prog57, &Rcl57.shared.rcl57)
        prog57_set_registers_from_memory(&prog57, &Rcl57.shared.rcl57)
        self.readOnly = false
    }

    func toString() -> String {
        return String(cString: prog57_to_text(&prog57))
    }

    var name: String {
        get {
            String(cString: prog57_get_name(&prog57))
        }
        set {
            prog57_set_name(&prog57, (newValue as NSString).utf8String)
        }
    }

    var description: String {
        get {
            let help = prog57_get_help(&prog57)
            return String(cString: help!)
        }
        set {
            prog57_set_help(&prog57, (newValue as NSString).utf8String)
        }
    }

    typealias State = (ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t,
                       ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t,
                       ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t)

    var state: State {
        get {
            prog57.state
        }
        set {
            prog57.state = newValue
        }
    }

    /**
     * Loading of steps and registers into memory.
     */

    func loadStepsIntoMemory() {
        prog57_load_steps_into_memory(&prog57, &Rcl57.shared.rcl57)
    }

    func loadRegistersIntoMemory() {
        prog57_load_registers_into_memory(&prog57, &Rcl57.shared.rcl57)
    }

    /**
     * Saving of steps and registers from memory.
     */

    func stepsNeedSaving() -> Bool {
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

    /** Saving program into file system . */
    func save(filename: String) -> Bool {
        if readOnly { return false }

        do {
            let asString = toString()
            let userLibFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = userLibFolderURL.appendingPathComponent(filename + Prog57.programFileExtension)

            try asString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)

            self.url = fileURL
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
