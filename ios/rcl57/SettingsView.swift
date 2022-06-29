import SwiftUI

struct SettingsView: View {
    static let FEEDBACK_NONE = UIImpactFeedbackGenerator.FeedbackStyle.soft
    let aboutText = "Please, send feedback to:\nrcl.ti.59@gmail.com"

    @State private var hasTurboSpeed = Settings.getTurboSpeed()
    @State private var hasAlphaDisplay = Settings.getAlphaDisplay()
    @State private var hasHPLrnMode = Settings.getHPLrnMode()

    @State private var hapticStyle = Settings.getHapticStyle() == nil ? FEEDBACK_NONE
                                                                      : Settings.getHapticStyle()!
    @State private var hasKeyClick = Settings.hasKeyClick()
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
                        Text(Lib57.examplesLib.name)
                    }
                }
                Section("Emulator Options") {
                    Toggle(isOn: $hasTurboSpeed) {
                        Text("Turbo Speed")
                    }
                    Toggle(isOn: $hasAlphaDisplay) {
                        Text("Alpha Display")
                    }
                    Toggle(isOn: $hasHPLrnMode) {
                        Text("HP LRN Mode")
                    }
                }
                Section("Keyboard Options") {
                    Toggle(isOn: $hasKeyClick) {
                        Text("Key Click")
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
                            Rcl57.shared.clearAll()
                        }
                    }
                    .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        Button("Clear Program, Log and Memory", role: .destructive) {
                            Rcl57.shared.clearAll()
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
                    Settings.setHasKeyClick(has_key_click: hasKeyClick)
                }
                .onChange(of: hasTurboSpeed) { _ in
                    Settings.setTurboSpeed(turbo: hasTurboSpeed)
                }
                .onChange(of: hasAlphaDisplay) { _ in
                    Settings.setAlphaDisplay(alpha: hasAlphaDisplay)
                }
                .onChange(of: hasHPLrnMode) { _ in
                    Settings.setHPLrnMode(hpLrn: hasHPLrnMode)
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
        SettingsView(showBack: .constant(false))
    }
}
