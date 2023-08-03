import Foundation

/**
 * Represents the 2 libraries of RCL-57 programs:
 * - `samplesLib` contains a fixed set of sample programs
 * - `userLib` is for User programs
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
            // Being extra cautious but this should never happen with `userLib` or `samplesLib`.
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
                    if let program = Prog57(url: programURL, readOnly: readonly, library: self) {
                        programs.append(program)
                    }
                }
            }
        }
        programs.sort { $0.name < $1.name }
    }

    /// Returns `true` if the program was successfully added.
    /// Note that program names within the library must be unique.
    func addProgram(_ program: Prog57) -> Bool {
        if readonly { return false }
        if programByName(program.name) != nil { return false }
        guard let folderURL else { return false }

        do {
            let text = program.asString()
            let programURL = folderURL.appendingPathComponent(program.name)
            try text.write(to: programURL, atomically: true, encoding: .utf8)
        } catch {
            return false
        }

        programs.append(program)
        programs.sort { $0.name < $1.name }

        return true
    }

    /// Returns `true` if the program was successfully deleted.
    func deleteProgram(_ program: Prog57) -> Bool {
        if readonly { return false }

        do {
            var isProgramRemoved = false
            for i in 0..<programs.count {
                if programs[i] == program {
                    programs.remove(at: i)
                    isProgramRemoved = true
                    break
                }
            }
            if !isProgramRemoved {
                return false
            }
            if let programURL = program.url {
                try FileManager.default.removeItem(atPath: programURL.path)
            } else {
                return false
            }
        } catch {
            return false
        }
        return true
    }

    func programByName(_ programName: String) -> Prog57? {
        var lo = 0
        var hi = programs.count

        // Do binary search on sorted `programs`.
        var res: Prog57? = nil
        while lo <= hi {
            let mid = lo + (hi-lo)/2
            if programs[mid].name == programName {
                res = programs[mid]
                break
            }
            if programs[mid].name < programName {
                lo = mid + 1
            } else {
                hi = mid - 1
            }
        }
        return res
    }
}
