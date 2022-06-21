import SwiftUI

class Prog57 {
    private var prog57 = prog57_t()

    init?(url: URL) {
        let text: String
        do {
            text = try String(contentsOf: url)
        } catch {
            text = "Error"
        }
        prog57_from_text(&prog57, UnsafeMutablePointer(mutating: text))
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

    func getHTMLHelp() -> String {
        let help = prog57_get_help(&prog57)
        return Hlp57.getHTML(hlp: String(cString: help!))
    }

    func setHelp(help: String) {
        prog57_set_help(&prog57, (help as NSString).utf8String)
    }

    func loadState(rcl57: Rcl57) {
        prog57_load_state(&prog57, &rcl57.rcl57)
    }

    func saveState(rcl57: Rcl57) {
        prog57_save_state(&prog57, &rcl57.rcl57)
    }

    func save(filename: String) -> Bool {
        let text = toText()

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        let url = paths[0].appendingPathComponent(filename)

        do {
            try text.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            return false
        }

        return true
    }
}
