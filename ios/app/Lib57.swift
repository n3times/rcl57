import Foundation

/**
 * Represents the 2 libraries of programs in RCL-57:
 * - `samplesLib` contains a fixed set of sample programs
 * - `userLib` contains user programs
 */
class Lib57 {
    /// A library that contains user programs.
    static let userLib: Lib57 = {
        let userLibURL =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return Lib57(directoryURL: userLibURL, name: "User Programs", readonly: false)
    }()

    /// A library with a fixed set of sample programs.
    static let samplesLib: Lib57 = {
        let samplesLibURL =
            Bundle.main.bundleURL.appendingPathComponent("samplesLib")
        return Lib57(directoryURL: samplesLibURL, name: "Sample Programs", readonly: true)
    }()

    /// The directory where the programs are stored.
    private let directoryURL: URL?

    /// The name of the library.
    let name: String

    /// Whether the user can add, remove, and modify programs.
    let isReadOnly: Bool

    /// The programs the library contains.
    private(set) var programs: [Prog57]

    private init(directoryURL: URL?, name: String, readonly: Bool) {
        self.directoryURL = directoryURL
        self.name = name
        programs = []

        guard let directoryURL else {
            // Being extra cautious but this should never happen with `userLib` or `samplesLib`.
            self.isReadOnly = true
            return
        }

        self.isReadOnly = readonly

        let enumerator =
            FileManager.default.enumerator(at: directoryURL, includingPropertiesForKeys: [])
        if let enumerator {
            while let programURLObject = enumerator.nextObject() {
                guard let programURL = programURLObject as? URL else {
                    continue
                }
                if programURL.path.hasSuffix(Prog57.programFileExtension) {
                    if let program = Prog57(fromURL: programURL, readOnly: readonly, library: self) {
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
        if isReadOnly { return false }
        if programByName(program.name) != nil { return false }
        guard let directoryURL else { return false }

        do {
            let programURL = directoryURL.appendingPathComponent(program.name)
            try program.rawText.write(to: programURL, atomically: true, encoding: .utf8)
        } catch {
            return false
        }

        programs.append(program)
        programs.sort { $0.name < $1.name }

        return true
    }

    /// Returns `true` if the program was successfully deleted.
    func deleteProgram(_ program: Prog57) -> Bool {
        if isReadOnly { return false }

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

    /// Returns the program in the library with given name.
    func programByName(_ programName: String) -> Prog57? {
        var lo = 0
        var hi = programs.count - 1

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
