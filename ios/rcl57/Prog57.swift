import SwiftUI

class Prog57 : Hashable, Equatable {
    private var prog57 = prog57_t()

    init?(url: URL) {
        var text: String
        do {
            text = try String(contentsOf: url)
        } catch {
            return nil
        }
        prog57_from_text(&prog57, text)
    }

    init(name: String, help: String) {
        prog57_set_name(&prog57, (name as NSString).utf8String)
        prog57_set_help(&prog57, (help as NSString).utf8String)
        prog57_save_state(&prog57, &Rcl57.shared.rcl57)
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
            // failed to write file.
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
