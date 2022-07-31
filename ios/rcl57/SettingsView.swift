import SwiftUI

struct SettingsView: View {
    let aboutText = "Please, send feedback to:\nrcl.ti.59@gmail.com"

    @EnvironmentObject private var change: Change

    @State private var hasTurboSpeed = Settings.getTurboSpeed()
    @State private var hasAlphaDisplay = Settings.getAlphaDisplay()
    @State private var hasHPLrnMode = Settings.getHPLrnMode()

    @State private var hasKeyClick = Settings.hasKeyClick()
    @State private var hasHaptic = Settings.hasHaptic()

    @State private var isPresentingReset = false
    @State private var isPresentingContact = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            VStack(spacing: 0) {
                MenuBarView(change: change,
                            left: nil,
                            title: "Settings",
                            right: Style.downArrow,
                            width: width,
                            background: Color.gray,
                            leftAction: {},
                            rightAction: { withAnimation {change.currentView = .calc} })
                .frame(width: width)

                Form {
                    Section {
                        Button("Contact") {
                            isPresentingContact = true
                        }
                        .foregroundColor(Color.black)
                        .alert(isPresented: $isPresentingContact) {
                            Alert(title: Text("RCL-57 " + Rcl57.version), message: Text(aboutText))
                        }
                        Button("Reset") {
                            isPresentingReset = true
                        }
                        .foregroundColor(Color.black)
                        .confirmationDialog("Are you sure?", isPresented: $isPresentingReset) {
                            Button("Clear Steps, Registers and Log", role: .destructive) {
                                Rcl57.shared.clearAll()
                                change.setLoadedProgram(program: nil)
                            }
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
                        Toggle(isOn: $hasHaptic) {
                            Text("Haptic Feedback")
                        }
                    }
                    .onChange(of: hasHaptic) { _ in
                        Settings.setHasHaptic(has_haptic: hasHaptic)
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
            }
        }
    }

    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }
}
