import SwiftUI

/** Converts a string in 'hlp' format into 'html'. */
struct Help57 {
    private static let BUFFER_SIZE: Int32 = 5000
    private static let CSS_FILENAME = "help.css"

    static func hlpToHTML(helpString: String) -> String {
        var hlp2html = hlp2html_t()
        var html = ""
        let outBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(BUFFER_SIZE))

        hlp2html_init(&hlp2html, CSS_FILENAME, outBuffer, BUFFER_SIZE)
        html += String(cString: &outBuffer.pointee)

        for helpLine in helpString.split(whereSeparator: \.isNewline) {
            hlp2html_next(&hlp2html, String(helpLine), outBuffer, BUFFER_SIZE)
            html += String(cString: &outBuffer.pointee)
        }

        hlp2html_done(&hlp2html, outBuffer, BUFFER_SIZE)
        html += String(cString: &outBuffer.pointee)

        return html
    }
}
