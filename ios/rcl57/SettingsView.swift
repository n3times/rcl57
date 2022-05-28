import SwiftUI
import WebKit

struct FlavorsView: View {
    let rcl57: RCL57

    @Binding var flavor: Flavor
    @Binding var showBack: Bool

    private func setFlavor(flavor: Flavor) {
        Settings.setFlavor(flavor: flavor, rcl57: rcl57)
    }

    var body: some View {
        Form {
            Picker("Choose Flavor", selection: $flavor) {
                ForEach(Flavor.allCases) { flavor in
                    Text(flavor.rawValue)
                        .tag(flavor)
                }
            }.pickerStyle(.inline)
            Section(flavor.rawValue + " Ingredients") {
                HStack {
                    Text("Speed")
                    Spacer()
                    Text(flavor == .classic ? "Original" : "1000x")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Display")
                    Spacer()
                    Text(flavor == .classic || flavor == .turbo ? "Original" : "Alphanumeric")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("LRN Mode")
                    Spacer()
                    Text(flavor != .rebooted ? "Original" : "HP Style")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Flavor")
        .navigationBarItems(
            trailing:
                Button(action: {
                    withAnimation {
                        showBack.toggle()
                    }
                }) {
                    Text(Style.circle)
                        .frame(width: 70, height: Style.headerHeight, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .font(Style.directionsFont)
        )
        .onChange(of: flavor) { _ in
            setFlavor(flavor: flavor)
        }
    }
}

struct WebView: UIViewRepresentable {
    let headerString = "<head><meta name='viewport' content='width=device-width, " +
        "initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head>"
    let htmlString: String

    init(htmlString: String) {
        self.htmlString = htmlString
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(headerString + htmlString, baseURL: Bundle.main.bundleURL)
    }
}

struct PageView: View {
    @Binding var showBack: Bool

    let title: String
    let hlp: String
    var url: URL {
        Bundle.main.url(forResource: hlp, withExtension: "hlp")!
    }

    var body: some View {

        HStack {
            WebView(htmlString: Help57.getHTML(url: url))
        }
        .navigationBarItems(
            trailing:
                Button(action: {
                    withAnimation {
                        showBack.toggle()
                    }
                }) {
                    Text(Style.circle)
                        .frame(width: 70, height: Style.headerHeight, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .font(Style.directionsFont)
        )
    }
}

struct HelpView: View {
    @Binding var showBack: Bool

    var body: some View {
        List {
            NavigationLink(destination: PageView(showBack: $showBack, title: "About", hlp: "about")) {
                Text("About RCL-57")
            }
            NavigationLink(destination: PageView(showBack: $showBack, title: "Flavors", hlp: "flavors")) {
                Text("Emulator Flavors")
            }
            NavigationLink(destination: PageView(showBack: $showBack, title: "Basics", hlp: "basics")) {
                Text("Calculator Basics")
            }
            NavigationLink(destination: PageView(showBack: $showBack, title: "Math", hlp: "math")) {
                Text("Math Functions")
            }
            NavigationLink(destination: PageView(showBack: $showBack, title: "Registers", hlp: "registers")) {
                Text("Registers")
            }
            NavigationLink(destination: PageView(showBack: $showBack, title: "Hello World", hlp: "hello")) {
                Text("Hello World")
            }
            NavigationLink(destination: PageView(showBack: $showBack, title: "Flow Control", hlp: "flow")) {
                Text("Flow Control")
            }
            NavigationLink(destination: PageView(showBack: $showBack, title: "Help Files", hlp: "help")) {
                Text("Help Files")
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Help")
        .navigationBarItems(
            trailing:
                Button(action: {
                    withAnimation {
                        showBack.toggle()
                    }
                }) {
                    Text(Style.circle)
                        .frame(width: 70, height: Style.headerHeight, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .font(Style.directionsFont)
        )
    }
}

struct SettingsView: View {
    let rcl57 : RCL57
    static let FEEDBACK_NONE = UIImpactFeedbackGenerator.FeedbackStyle.soft
    let aboutText = "Please, send feedback to:\nrcl.ti.59@gmail.com"

    @State private var hapticStyle = Settings.getHapticStyle() == nil ? FEEDBACK_NONE
                                                                      : Settings.getHapticStyle()!
    @State private var hasKeyClick = Settings.hasKeyClick()
    @State private var flavor = Settings.getFlavor()
    @State private var isPresentingConfirm = false
    @State private var showingAlert = false

    @Binding var showBack: Bool

    var body: some View {
        return NavigationView {
            Form {
                NavigationLink(destination: HelpView(showBack: $showBack)) {
                    HStack {
                        Text("Help")
                    }
                }
                Section("Options") {
                    NavigationLink(destination: FlavorsView(rcl57: rcl57, flavor: $flavor, showBack: $showBack)) {
                        HStack {
                            Text("Flavor")
                            Spacer()
                            Text(flavor.rawValue)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Toggle(isOn: $hasKeyClick) {
                        Text("Click Sound")
                    }
                    Picker("Haptic Feedback", selection: $hapticStyle) {
                        Text("None").tag(SettingsView.FEEDBACK_NONE)
                        Text("Light").tag(UIImpactFeedbackGenerator.FeedbackStyle.light)
                        Text("Medium").tag(UIImpactFeedbackGenerator.FeedbackStyle.medium)
                        Text("Heavy").tag(UIImpactFeedbackGenerator.FeedbackStyle.heavy)
                    }
                }
                Section {
                    Button("Contact") {
                        showingAlert = true
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("RCL-57 alpha 1.2"), message: Text(aboutText))
                    }
                    Button("Reset") {
                        isPresentingConfirm = true
                    }
                    .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        Button("Clear Program, Log and Memory", role: .destructive) {
                            rcl57.clearAll()
                        }
                    }
                    .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        Button("Clear Program, Log and Memory", role: .destructive) {
                            rcl57.clearAll()
                        }
                    }
                }
                .onChange(of: hapticStyle) { _ in
                    if hapticStyle == SettingsView.FEEDBACK_NONE {
                        Settings.setHapticStyle(style: nil)
                    } else {
                        Settings.setHapticStyle(style: hapticStyle)
                    }
                }
                .onChange(of: hasKeyClick) { _ in
                    Settings.setHasKeyClick(has_key_click: hasKeyClick, rcl57: rcl57)
                }
            }
            .navigationBarItems(
                trailing:
                    Button(action: {
                        withAnimation {
                            showBack.toggle()
                        }
                    }) {
                        Text(Style.circle)
                            .frame(width: 70, height: Style.headerHeight, alignment: .trailing)
                            .contentShape(Rectangle())
                    }
                    .font(Style.directionsFont)
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(rcl57: RCL57(), showBack: .constant(false))
    }
}
