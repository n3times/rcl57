import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var change: Change

    let aboutText = "Please, send feedback to:\nrcl.ti.59@gmail.com"

    @State private var hasTurboSpeed = Settings.hasTurboSpeed
    @State private var hasAlphaDisplay = Settings.hasAlphaDisplay
    @State private var hasHPLrnMode = Settings.hasHpLrnMode

    @State private var hasKeyClick = Settings.hasKeyClick
    @State private var hasHaptic = Settings.hasHaptic

    @State private var isPresentingReset = false
    @State private var isPresentingContact = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            VStack(spacing: 0) {
                MenuBarView(left: nil,
                            title: "Settings",
                            right: Style.downArrow,
                            width: width,
                            leftAction: {},
                            rightAction: { withAnimation {change.currentView = .calc} })
                .background(Color.gray)
                .frame(width: width)

                Form {
                    Section {
                        Button("Contact") {
                            isPresentingContact = true
                        }
                        .foregroundColor(Color.black)
                        .alert(isPresented: $isPresentingContact) {
                            Alert(title: Text("RCL-57\n" + "v" + Rcl57.version), message: Text(aboutText))
                        }
                        Button("Reset") {
                            isPresentingReset = true
                        }
                        .foregroundColor(Color.black)
                        .confirmationDialog("Reset?", isPresented: $isPresentingReset) {
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
                        Settings.hasHaptic = hasHaptic
                    }
                    .onChange(of: hasKeyClick) { _ in
                        Settings.hasKeyClick = hasKeyClick
                    }
                    .onChange(of: hasTurboSpeed) { _ in
                        Settings.hasTurboSpeed = hasTurboSpeed
                    }
                    .onChange(of: hasAlphaDisplay) { _ in
                        Settings.hasAlphaDisplay = hasAlphaDisplay
                    }
                    .onChange(of: hasHPLrnMode) { _ in
                        Settings.hasHpLrnMode = hasHPLrnMode
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
