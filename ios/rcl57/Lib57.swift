import Foundation

/**
 * Represents the 2 libraries of RCL-57 programs:
 * - "samplesLib" contains a fixed set of sample programs
 * - "userLib" is where users can add, remove and edit their own programs
 */
class Lib57 {
    static let userLib: Lib57 = {
        let userLibURL =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return Lib57(folderURL: userLibURL, name: "User Programs", readonly: false)
    }()

    static let samplesLib: Lib57 = {
        let samplesLibURL =
            Bundle.main.bundleURL.appendingPathComponent("samplesLib")
        return Lib57(folderURL: samplesLibURL, name: "Sample Programs", readonly: true)
    }()

    private let folderURL: URL?

    let name: String
    let readonly: Bool

    var programs: [Prog57] = []

    private init(folderURL: URL?, name: String, readonly: Bool) {
        self.folderURL = folderURL
        self.name = name

        guard let folderURL else {
            // Being cautious but this should never happen with userLib or samplesLib.
            self.readonly = true
            return
        }

        self.readonly = readonly

        let enumerator =
            FileManager.default.enumerator(at: folderURL, includingPropertiesForKeys: [])
        if let enumerator {
            while let programURLObject = enumerator.nextObject() {
                guard let programURL = programURLObject as? URL else {
                    continue
                }
                if programURL.path.hasSuffix(Prog57.programFileExtension) {
                    if let program = Prog57(url: programURL, readOnly: readonly) {
                        programs.append(program)
                    }
                }
            }
        }
        programs = programs.sorted { $0.name < $1.name }
    }

    func addProgram(_ program: Prog57) -> Bool {
        if readonly { return false }
        if programByName(program.name) != nil { return false }
        guard let folderURL else { return false }

        do {
            let text = program.toString()
            let programURL = folderURL.appendingPathComponent(program.name)
            try text.write(to: programURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            return false
        }

        programs.append(program)
        programs.sort { $0.name < $1.name }

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
            if let programURL = program.url {
                try FileManager.default.removeItem(atPath: programURL.path)
            }
        } catch {
            return false
        }
        return true
    }

    func programByName(_ programName: String) -> Prog57? {
        for program in programs {
            if program.name == programName {
                return program
            }
        }
        return nil
    }
}
