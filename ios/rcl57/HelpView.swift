import SwiftUI
import WebKit

struct HelpView: UIViewRepresentable {
    let headerString = "<head><meta name='viewport' content='width=device-width, " +
        "initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head>"
    let hlpString: String

    init(hlpString: String) {
        self.hlpString = hlpString
    }

    init(hlpURL: URL) {
        do {
            hlpString = try String(contentsOf: hlpURL)
        } catch {
            hlpString = "Error"
        }
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlString = Help57.toHTML(hlpString: hlpString)
        webView.loadHTMLString(headerString + htmlString, baseURL: Bundle.main.bundleURL)
    }
}
