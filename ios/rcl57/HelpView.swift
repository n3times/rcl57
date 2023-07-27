import SwiftUI
import WebKit

/**
 * A Web View capable of showing a page in '.hlp' format.
 */
struct HelpView: UIViewRepresentable {
    private let headerString = "<head><meta name='viewport' content='width=device-width, " +
        "initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head>"
    private let helpString: String

    init(helpString: String) {
        self.helpString = helpString
    }

    init(helpURL: URL) {
        let helpString: String
        do {
            helpString = try String(contentsOf: helpURL)
        } catch {
            helpString = "Error"
        }
        self.init(helpString: helpString)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let htmlString = Help57.hlpToHTML(helpString: helpString)
        webView
            .loadHTMLString(headerString + htmlString, baseURL: Bundle.main.bundleURL)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Nothing to update.
    }
}
