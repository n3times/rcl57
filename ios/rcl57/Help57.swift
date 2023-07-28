import SwiftUI

/**
 * Utility to convert text in 'hlp' formal into HTML.
 *
 * The 'hlp' format is a markup language for writing RCL-57 help files.
 */
struct Help57 {
    private static let bufferSize = 4096
    private static let cssFilename = "help.css"

    static func hlpToHTML(helpString: String) -> String {
        var hlp2html = hlp2html_t()
        var html = ""
        let outBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)

        defer {
            outBuffer.deallocate()
        }

        hlp2html_init(&hlp2html, cssFilename, outBuffer, Int32(bufferSize))
        if let initialString = String(validatingUTF8: outBuffer) {
            html += initialString
        }

        for helpLine in helpString.split(whereSeparator: \.isNewline) {
            hlp2html_next(&hlp2html, String(helpLine), outBuffer, Int32(bufferSize))
            if let nextString = String(validatingUTF8: outBuffer) {
                html += nextString
            }
        }

        hlp2html_done(&hlp2html, outBuffer, Int32(bufferSize))
        if let doneString = String(validatingUTF8: outBuffer) {
            html += doneString
        }

        return html
    }
}
