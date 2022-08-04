import SwiftUI
import WebKit

/**
 * A Web View capable of showing a page in '.hlp' format.
 */
struct HelpView: UIViewRepresentable {
    let headerString = "<head><meta name='viewport' content='width=device-width, " +
        "initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head>"
    let helpString: String

    init(helpString: String) {
        self.helpString = helpString
    }

    init(helpURL: URL) {
        do {
            helpString = try String(contentsOf: helpURL)
        } catch {
            helpString = "Error"
        }
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlString = Help57.hlpToHTML(helpString: helpString)
        webView.loadHTMLString(headerString + htmlString, baseURL: Bundle.main.bundleURL)
    }
}
