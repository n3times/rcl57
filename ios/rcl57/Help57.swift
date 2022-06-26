import SwiftUI

struct Help57 {
    static func toHTML(hlpString: String) -> String {
        let hlp2html = UnsafeMutablePointer<hlp2html_t>.allocate(capacity: 1)
        var html = ""
        let out = UnsafeMutablePointer<UInt8>.allocate(capacity: 10000)

        hlp2html_init(hlp2html, "help.css", out, 10000)
        html += String(cString: UnsafeRawPointer(&out.pointee).assumingMemoryBound(to: CChar.self))
        hlp2html_next(hlp2html, hlpString, out, 10000)
        html += String(cString: UnsafeRawPointer(&out.pointee).assumingMemoryBound(to: CChar.self))
        hlp2html_done(hlp2html, out, 10000)
        html += String(cString: UnsafeRawPointer(&out.pointee).assumingMemoryBound(to: CChar.self))
        return html
    }
}
