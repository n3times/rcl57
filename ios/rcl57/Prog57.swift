import SwiftUI

class Prog57 : Hashable, Equatable {
    /* Backing struct: name, help and state. */
    private var prog57 = prog57_t()

    /* Non-nil for programs that belong to a library. */
    var url: URL? = nil

    var readOnly: Bool

    /** Library Programs. */
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

    /** Imported programs. */
    init(text: String, readOnly: Bool) {
        prog57_from_text(&prog57, text)
        self.readOnly = readOnly
    }

    /** New programs. */
    init(name: String, help: String, readOnly: Bool) {
        prog57_set_name(&prog57, (name as NSString).utf8String)
        prog57_set_help(&prog57, (help as NSString).utf8String)
        prog57_set_steps_from_memory(&prog57, &Rcl57.shared.rcl57)
        prog57_set_registers_from_memory(&prog57, &Rcl57.shared.rcl57)
        self.readOnly = readOnly
    }

    func toText() -> String {
        return String(cString: prog57_to_text(&prog57))
    }

    func getName() -> String {
        return String(cString: prog57_get_name(&prog57))
    }

    func setName(name: String) {
        prog57_set_name(&prog57, (name as NSString).utf8String)
    }

    func getHelp() -> String {
        let help = prog57_get_help(&prog57)
        return String(cString: help!)
    }

    func setHelp(help: String) {
        prog57_set_help(&prog57, (help as NSString).utf8String)
    }

    func getState() -> (ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t) {
        return prog57.state
    }

    func setState(state: (ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t, ti57_reg_t)) {
        prog57.state = state
    }

    func setStepsFromMemory() {
        prog57_set_steps_from_memory(&prog57, &Rcl57.shared.rcl57)
    }

    func setRegistersFromMemory() {
        prog57_set_registers_from_memory(&prog57, &Rcl57.shared.rcl57)
    }

    func loadStepsIntoMemory() {
        prog57_load_steps_into_memory(&prog57, &Rcl57.shared.rcl57)
    }

    func loadRegistersIntoMemory() {
        prog57_load_registers_into_memory(&prog57, &Rcl57.shared.rcl57)
    }

    func hasSameStepsAsState() -> Bool {
        return prog57_has_same_steps_as_state(&prog57, &Rcl57.shared.rcl57)
    }

    func hasSameRegistersAsState() -> Bool {
        return prog57_has_same_registers_as_state(&prog57, &Rcl57.shared.rcl57)
    }

    func save(filename: String) -> Bool {
        let text = toText()

        let folderURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        let fileURL = folderURLs[0].appendingPathComponent(filename + ".p57")

        do {
            try text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file.
            return false
        }

        self.url = fileURL

        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.getName())
    }

    static func ==(lhs: Prog57, rhs: Prog57) -> Bool {
        return lhs.getName() == rhs.getName()
    }
}
