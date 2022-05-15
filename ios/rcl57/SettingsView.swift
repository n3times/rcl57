import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var change: Change

    let rcl57 : RCL57
    static let FEEDBACK_NONE = UIImpactFeedbackGenerator.FeedbackStyle.soft
    let aboutText = "Please, send feedback to:\nrcl.ti.59@gmail.com"

    @State private var hapticStyle = Settings.getHapticStyle() == nil ? FEEDBACK_NONE
                                                                      : Settings.getHapticStyle()!
    @State private var hasOriginalSpeed = Settings.hasOriginalSpeed()
    @State private var hasOriginalDisplay = Settings.hasOriginalDisplay()
    @State private var hasOriginalLrn = Settings.hasOriginalLrn()

    @State private var isPresentingConfirm = false
    @State private var showingAlert = false

    private func setFlavor(isOriginal: Bool) {
        Settings.setOriginalLrn(has_original_lrn: isOriginal, rcl57: rcl57)
        Settings.setOriginalDisplay(has_original_display: isOriginal, rcl57: rcl57)
        Settings.setOriginalSpeed(has_original_speed: isOriginal, rcl57: rcl57)
        hasOriginalSpeed = Settings.hasOriginalSpeed()
        hasOriginalLrn = Settings.hasOriginalLrn()
        hasOriginalDisplay = Settings.hasOriginalDisplay()
    }

    private func isOriginalFlavor() -> Bool {
        return hasOriginalSpeed && hasOriginalLrn && hasOriginalDisplay
    }

    private func isRebootedFlavor() -> Bool {
        return !hasOriginalSpeed && !hasOriginalLrn && !hasOriginalDisplay
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Flavors") {
                    Button(action: { setFlavor(isOriginal: true) }) {
                        HStack {
                            Text("Original")
                            if isOriginalFlavor() {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    Button(action: { setFlavor(isOriginal: false) }) {
                        HStack {
                            Text("Rebooted")
                            if isRebootedFlavor() {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                Section("Emulator Options") {
                    Picker("Speed", selection: $hasOriginalSpeed) {
                        Text("Original").tag(true)
                        Text("Turbo").tag(false)
                    }
                    Picker("Display", selection: $hasOriginalDisplay) {
                        Text("Original").tag(true)
                        Text("Alphanumeric").tag(false)
                    }
                    Picker("LRN Mode", selection: $hasOriginalLrn) {
                        Text("Original").tag(true)
                        Text("HP Style").tag(false)
                    }
                }
                Section {
                    Picker("Haptic Feedback", selection: $hapticStyle) {
                        Text("None").tag(SettingsView.FEEDBACK_NONE)
                        Text("Light").tag(UIImpactFeedbackGenerator.FeedbackStyle.light)
                        Text("Medium").tag(UIImpactFeedbackGenerator.FeedbackStyle.medium)
                        Text("Heavy").tag(UIImpactFeedbackGenerator.FeedbackStyle.heavy)
                    }
                }
                Section {
                    Button("About") {
                        showingAlert = true
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("RCL-57 alpha 1.1"), message: Text(aboutText), dismissButton: .default(Text("Dismiss")))
                    }
                    Button("Reset") {  // Left arrow.
                        isPresentingConfirm = true
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
                .onChange(of: hasOriginalSpeed) { _ in
                    Settings.setOriginalSpeed(has_original_speed: hasOriginalSpeed, rcl57: rcl57)
                }
                .onChange(of: hasOriginalDisplay) { _ in
                    Settings.setOriginalDisplay(has_original_display: hasOriginalDisplay, rcl57: rcl57)
                }
                .onChange(of: hasOriginalLrn) { _ in
                    Settings.setOriginalLrn(has_original_lrn: hasOriginalLrn, rcl57: rcl57)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(
                trailing:
                    Button("Done") {
                        withAnimation {
                            change.showBack.toggle()
                        }
                    }
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(rcl57: RCL57())
    }
}
