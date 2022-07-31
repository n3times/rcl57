import Foundation

/**
 * A library contains programs.
 *
 * Programs in a given library must have unique names.
 * A library can be 'readOnly' meaning that no programs can be added to or deleted from the library.
 */
class Lib57 {
    private static let samplesLibURL =
        Bundle.main.bundleURL.appendingPathComponent("samples_lib")
    private static let userLibURL =
        Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    let folderURL: URL
    let name: String
    let readonly: Bool

    var programs: [Prog57]

    static let samplesLib = Lib57(folderURL: samplesLibURL, name: "Sample Programs", readonly: true)
    static let userLib = Lib57(folderURL: userLibURL!, name: "User Programs", readonly: false)

    init(folderURL: URL, name: String, readonly: Bool) {
        self.folderURL = folderURL
        self.name = name
        self.readonly = readonly

        programs = []
        let enumerator = Foundation.FileManager.default.enumerator(at: folderURL, includingPropertiesForKeys: [])
        while let programURLObject = enumerator!.nextObject() {
            let programURL = programURLObject as! URL
            if programURL.path.hasSuffix(Prog57.programFileExtension) {
                programs.append(Prog57(url: programURL, readOnly: readonly)!)
            }
        }
        programs = programs.sorted { $0.getName() < $1.getName() }
    }

    func addProgram(_ program: Prog57) -> Bool {
        if readonly { return false }
        if getProgramByName(program.getName()) != nil { return false }

        do {
            let text = program.toText()
            let programURL = folderURL.appendingPathComponent(program.getName())
            try text.write(to: programURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file.
            return false
        }

        programs.append(program)
        programs.sort { $0.getName() < $1.getName() }

        return true
    }

    func deleteProgram(_ program: Prog57) -> Bool {
        if readonly { return false }

        do {
            for i in 0..<programs.count {
                if programs[i] == program {
                    programs.remove(at: i)
                    break
                }
            }
            try FileManager.default.removeItem(atPath: program.url!.path)
        } catch {
            return false
        }
        return true
    }

    func getProgramByName(_ programName: String) -> Prog57? {
        for libProgram in programs {
            if libProgram.getName() == programName {
                return libProgram
            }
        }
        return nil
    }
}
