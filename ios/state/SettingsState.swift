import Foundation

/**
 * Manages user settings.
 *
 * The user can control elements of the UI as well as elements of the emulator. The settings are
 * stored in `UserDefaults`.
 */
class SettingsState: ObservableObject {
    // MARK: UI Settings.

    // The app uses @AppStorage directly for these.

    /// The `UserDefaults` key to control haptic mode.
    static let isHapticKey = "IS_HAPTIC_KEY"

    /// The `UserDefaults` key to control whether the keyboad has a clicking sound.
    static let isClickKey = "IS_CLICK_KEY"


    // MARK: Emulator Settings.

    // They require additional logic when set, so we use UserDefaults directly.

    /// The `UserDefaults` key for Turbo mode.
    private static let isTurboKey = "IS_TURBO_KEY"

    /// The `UserDefaults` key for alpha mode.
    private static let isAlphaKey = "IS_ALPHA_KEY"

    /// The `UserDefaults` key for HP LRN mode.
    private static let isHpKey = "IS_HP_KEY"


    /// We use a "Y" and "N" instead of a Bool to distinguish between false and the absence of
    /// value.
    private static func setBoolValue(forKey key: String, value: Bool) {
        UserDefaults.standard.set(value ? "Y" : "N", forKey: key)
    }

    /// Returns the boolean value for a given `UserDefaults` key.
    private static func boolValue(forKey key: String, defaultValue: Bool) -> Bool {
        let value = UserDefaults.standard.string(forKey: key)
        if value == "Y" { return true }
        if value == "N" { return false }
        return defaultValue
    }

    /// Whether the emulator is in Turbo mode.
    @Published var isInTurboMode: Bool {
        didSet {
            SettingsState.setBoolValue(forKey: SettingsState.isTurboKey, value: isInTurboMode)

            // The 2x speedup in the standard case makes the emulator more enjoyable to use.
            Rcl57.shared.speedupFactor = isInTurboMode ? 1000 : 2
            Rcl57.shared.setEmulatorOption(flag: RCL57_SHOW_RUN_INDICATOR_FLAG, value: isInTurboMode)
        }
    }

    /// Whether the display can show alpha characters.
    @Published var isDisplayAlpha: Bool {
        didSet {
            SettingsState.setBoolValue(forKey: SettingsState.isAlphaKey, value: isDisplayAlpha)
            Rcl57.shared.setEmulatorOption(flag: RCL57_ALPHA_LRN_MODE_FLAG, value: isDisplayAlpha)
        }
    }

    /// Whether the emulator shows, in LRN mode, the last operation entered.
    @Published var isHpLnrMode: Bool {
        didSet {
            SettingsState.setBoolValue(forKey: SettingsState.isHpKey, value: isHpLnrMode)
            Rcl57.shared.setEmulatorOption(flag: RCL57_HP_LRN_MODE_FLAG, value: isHpLnrMode)
        }
    }

    init() {
        // Get the emulator option values from UserDefaults.
        isInTurboMode = SettingsState.boolValue(forKey: SettingsState.isTurboKey, defaultValue: true)
        isDisplayAlpha = SettingsState.boolValue(forKey: SettingsState.isAlphaKey, defaultValue: true)
        isHpLnrMode = SettingsState.boolValue(forKey: SettingsState.isHpKey, defaultValue: true)

        // Inform the emulator.
        // The 2x speedup in the standard case makes the emulator more enjoyable to use.
        Rcl57.shared.speedupFactor = isInTurboMode ? 1000 : 2
        Rcl57.shared.setEmulatorOption(flag: RCL57_SHOW_RUN_INDICATOR_FLAG, value: isInTurboMode)
        Rcl57.shared.setEmulatorOption(flag: RCL57_ALPHA_LRN_MODE_FLAG, value: isDisplayAlpha)
        Rcl57.shared.setEmulatorOption(flag: RCL57_HP_LRN_MODE_FLAG, value: isHpLnrMode)

        // The other emulator options cannot be set by the user.
        // These values improve the overall user experience.
        Rcl57.shared.setEmulatorOption(flag: RCL57_QUICK_STOP_FLAG, value: true)
        Rcl57.shared.setEmulatorOption(flag: RCL57_SHORT_PAUSE_FLAG, value: true)
        Rcl57.shared.setEmulatorOption(flag: RCL57_FASTER_TRACE_FLAG, value: true)
    }
}
