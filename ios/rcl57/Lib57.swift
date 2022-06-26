import SwiftUI

class Lib57 {
    private let url: URL
    private let readonly: Bool

    let name: String
    var programs: [Prog57]

    private static let examplesURL =
        Bundle.main.bundleURL.appendingPathComponent("example_programs")
    static let examplesLib = Lib57(url: examplesURL, name: "Example Programs", readonly: true)

    init(url: URL, name: String, readonly: Bool) {
        self.url = url
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
    }
}
