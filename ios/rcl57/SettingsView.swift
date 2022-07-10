import SwiftUI

struct SettingsView: View {
    let aboutText = "Please, send feedback to:\nrcl.ti.59@gmail.com"

    @State private var hasTurboSpeed = Settings.getTurboSpeed()
    @State private var hasAlphaDisplay = Settings.getAlphaDisplay()
    @State private var hasHPLrnMode = Settings.getHPLrnMode()

    @State private var hasHaptic = Settings.hasHaptic()
    @State private var hasKeyClick = Settings.hasKeyClick()
    @State private var isPresentingConfirm = false
    @State private var showingAlert = false

    @EnvironmentObject private var change: Change

    var body: some View {
        ZStack {
            if change.showHelpInSettings {
                ManualView()
                    .transition(.move(edge: .trailing))
            }

            if !change.showHelpInSettings {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    VStack(spacing: 0) {
                        MenuBarView(change: change,
                                    left: nil,
                                    title: "Settings and Help",
                                    right: Style.downArrow,
                                    width: width,
                                    leftAction: {},
                                    rightAction: { withAnimation {change.currentView = .calc} })
                        .frame(width: width)

                        Form {
                            Button("Help") {
                                withAnimation {
                                    change.showHelpInSettings = true
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
                            Section {
                                Button("Contact") {
                                    showingAlert = true
                                }
                                .alert(isPresented: $showingAlert) {
                                    Alert(title: Text("RCL-57 alpha 1.6"), message: Text(aboutText))
                                }
                                Button("Reset") {
                                    isPresentingConfirm = true
                                }
                                .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                                    Button("Clear Program, Log and Memory", role: .destructive) {
                                        Rcl57.shared.clearAll()
                                        change.setLoadedProgram(program: nil)
                                    }
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
                .transition(.move(edge: .leading))
            }
        }
    }

    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }
}
