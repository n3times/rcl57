import SwiftUI

struct FlavorsView: View {
    let rcl57: Rcl57

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

struct SettingsView: View {
    let rcl57 : Rcl57
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
                NavigationLink(destination: ManualView(showBack: $showBack)) {
                    HStack {
                        Text("Help")
                    }
                }
                NavigationLink(destination: LibraryView(showBack: $showBack, lib: Lib57.examplesLib)) {
                    HStack {
                        Text("Library")
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
                        Alert(title: Text("RCL-57 alpha 1.4"), message: Text(aboutText))
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
        SettingsView(rcl57: Rcl57(), showBack: .constant(false))
    }
}
