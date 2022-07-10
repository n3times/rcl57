import SwiftUI

class Lib57 {
    private let libURL: URL
    private let readonly: Bool

    let name: String
    var programs: [Prog57]

    private static let examplesLibURL =
        Bundle.main.bundleURL.appendingPathComponent("examples_lib")
    static let examplesLib = Lib57(url: examplesLibURL, name: "Examples Library", readonly: true)

    private static let userLibURL =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    static let userLib = Lib57(url: userLibURL!, name: "User Library", readonly: false)

    init(url: URL, name: String, readonly: Bool) {
        self.libURL = url
        self.name = name
        self.readonly = readonly

        programs = []
        let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [])
        while let programURLObject = enumerator!.nextObject() {
            let programURL = programURLObject as! URL
            if programURL.path.hasSuffix(".p57") {
                programs.append(Prog57(url: programURL)!)
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
}
