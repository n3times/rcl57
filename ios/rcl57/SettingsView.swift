import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var change: Change
    @EnvironmentObject private var settings: UserSettings

    let aboutText = "Please, send feedback to:\nrcl.ti.59@gmail.com"

    @State private var isPresentingReset = false
    @State private var isPresentingContact = false

    @AppStorage(UserSettings.isHapticKey) private var hasHaptic = false
    @AppStorage(UserSettings.isClickKey) private var hasKeyClick = false

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            VStack(spacing: 0) {
                NavigationBar(left: nil,
                              title: "Settings",
                              right: Style.downArrow,
                              leftAction: nil,
                              rightAction: { withAnimation { change.currentViewType = .calc } })
                .background(Color.gray)
                .frame(width: width)

                Form {
                    Section {
                        Button("Contact") {
                            isPresentingContact = true
                        }
                        .foregroundColor(Color.black)
                        .alert(isPresented: $isPresentingContact) {
                            Alert(title: Text("RCL-57\nv\(Rcl57.version)"), message: Text(aboutText))
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
                        Toggle(isOn: $settings.hasTurboSpeed) {
                            Text("Turbo Speed")
                        }
                        Toggle(isOn: $settings.hasAlphaDisplay) {
                            Text("Alpha Display")
                        }
                        Toggle(isOn: $settings.hasHpLrnMode) {
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
