import SwiftUI

/** Utility to convert a string from 'hlp' to 'html' format. */
struct Help57 {
    private static let BUFFER_SIZE: Int32 = 5000
    private static let CSS_FILENAME = "help.css"

    static func hlpToHTML(helpString: String) -> String {
        var hlp2html = hlp2html_t()
        var html = ""
        let outBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(BUFFER_SIZE))

        defer {
            outBuffer.deallocate()
        }

        hlp2html_init(&hlp2html, CSS_FILENAME, outBuffer, BUFFER_SIZE)
        if let initialString = String(validatingUTF8: outBuffer) {
            html += initialString
        }

        for helpLine in helpString.split(whereSeparator: \.isNewline) {
            hlp2html_next(&hlp2html, String(helpLine), outBuffer, BUFFER_SIZE)
            if let nextString = String(validatingUTF8: outBuffer) {
                html += nextString
            }
        }

        hlp2html_done(&hlp2html, outBuffer, BUFFER_SIZE)
        if let doneString = String(validatingUTF8: outBuffer) {
            html += doneString
        }

        return html
    }
}
