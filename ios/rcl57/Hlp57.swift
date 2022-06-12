import SwiftUI

struct Hlp57 {
    static func getHTML(hlp: String) -> String {
        let hlp2html = UnsafeMutablePointer<hlp2html_t>.allocate(capacity: 1)
        var html = ""
        let out = UnsafeMutablePointer<UInt8>.allocate(capacity: 10000)

        hlp2html_init(hlp2html, "help.css", out, 10000)
        html += String(cString: UnsafeRawPointer(&out.pointee).assumingMemoryBound(to: CChar.self))
        hlp2html_next(hlp2html, hlp, out, 10000)
        html += String(cString: UnsafeRawPointer(&out.pointee).assumingMemoryBound(to: CChar.self))
        hlp2html_done(hlp2html, out, 10000)
        html += String(cString: UnsafeRawPointer(&out.pointee).assumingMemoryBound(to: CChar.self))
        return html
    }

    static func getHlpAsString(url: URL) -> String {
        let hlp: String
        do {
            hlp = try String(contentsOf: url)
        } catch {
            hlp = "Error"
        }
        return hlp
    }

    static func getHTML(url: URL) -> String {
        let html: String
        do {
            let hlp = try String(contentsOf: url)
            html = getHTML(hlp: hlp)
        } catch {
            html = "Error"
        }
        return html
    }
}
