import SwiftUI
import WebKit

struct HlpView: UIViewRepresentable {
    let headerString = "<head><meta name='viewport' content='width=device-width, " +
        "initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head>"
    let hlpString: String

    init(hlpString: String) {
        self.hlpString = hlpString
    }

    init(hlpURL: URL) {
        self.hlpString =  Hlp57.getHlpAsString(url: hlpURL)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlString = Hlp57.getHTML(hlp: hlpString)
        webView.loadHTMLString(headerString + htmlString, baseURL: Bundle.main.bundleURL)
    }
}
