import SwiftUI

struct Help57 {
    /** Converts a string in hlp format into HTML. */
    static func toHTML(hlpString: String) -> String {
        let BUFFER_SIZE: Int32 = 5000
        let CSS_FILENAME = "help.css"

        var hlp2html = hlp2html_t()
        var html = ""
        let outBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(BUFFER_SIZE))

        hlp2html_init(&hlp2html, CSS_FILENAME, outBuffer, BUFFER_SIZE)
        html += String(cString: &outBuffer.pointee)

        hlp2html_next(&hlp2html, hlpString, outBuffer, BUFFER_SIZE)
        html += String(cString: &outBuffer.pointee)

        hlp2html_done(&hlp2html, outBuffer, BUFFER_SIZE)
        html += String(cString: &outBuffer.pointee)

        return html
    }
}
