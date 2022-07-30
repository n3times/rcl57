import SwiftUI

class Lib57 {
    private let libURL: URL
    private let readonly: Bool

    let name: String
    var programs: [Prog57]

    private static let samplesLibURL =
        Bundle.main.bundleURL.appendingPathComponent("samples_lib")
    static let samplesLib = Lib57(url: samplesLibURL, name: "Sample Programs", readonly: true)

    private static let userLibURL =
        Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    static let userLib = Lib57(url: userLibURL!, name: "User Programs", readonly: false)

    init(url: URL, name: String, readonly: Bool) {
        self.libURL = url
        self.name = name
        self.readonly = readonly

        programs = []
        let enumerator = Foundation.FileManager.default.enumerator(at: url, includingPropertiesForKeys: [])
        while let programURLObject = enumerator!.nextObject() {
            let programURL = programURLObject as! URL
            if programURL.path.hasSuffix(".p57") {
                programs.append(Prog57(url: programURL, readOnly: readonly)!)
            }
        }
        programs = programs.sorted { $0.getName() < $1.getName() }
    }

    func add(program: Prog57) {
        var exists = false
        let programName = program.getName()
        for libProgram in programs {
            if libProgram.getName() == programName {
                exists = true
            }
        }
        if exists {
            return
        }

        programs.append(program)
        programs.sort { $0.getName() < $1.getName() }

        do {
            let text = program.toText()
            let programURL = libURL.appendingPathComponent(program.getName())
            try text.write(to: programURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file.
        }
    }

    func findProgram(name: String) -> Prog57? {
        for libProgram in programs {
            if libProgram.getName() == name {
                return libProgram
            }
        }
        return nil
    }

    func delete(program: Prog57) {
        do {
            try FileManager.default.removeItem(atPath: program.url!.path)
            for i in 0..<programs.count {
                if programs[i] == program {
                    programs.remove(at: i)
                    break
                }
            }
        } catch {

        }
    }
}
