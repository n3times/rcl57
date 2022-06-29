import SwiftUI

class Prog57 : Hashable, Equatable {
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
        return Help57.toHTML(hlpString: String(cString: help!))
    }

    func getHelp() -> String {
        let help = prog57_get_help(&prog57)
        return String(cString: help!)
    }

    func setHelp(help: String) {
        prog57_set_help(&prog57, (help as NSString).utf8String)
    }

    func loadState() {
        prog57_load_state(&prog57, &Rcl57.shared.rcl57)
    }

    func saveState() {
        prog57_save_state(&prog57, &Rcl57.shared.rcl57)
    }

    func save(filename: String) -> Bool {
        let text = toText()

        let folderURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        let fileURL = folderURLs[0].appendingPathComponent(filename)

        do {
            try text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            return false
        }

        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.getName())
    }

    static func ==(lhs: Prog57, rhs: Prog57) -> Bool {
        return lhs.getName() == rhs.getName()
    }
}
