import Foundation

/**
 * Manages user's settings.
 *
 * The user can control a few elements of the UI as well as elements of the emulator.
 * The settings are stored in `UserDefaults` so they can be preserved during version upgrades.
 */
class UserSettings: ObservableObject {
    // UI Settings.
    // The app uses @AppStorage directly for these.
    static let isHapticKey = "IS_HAPTIC_KEY"
    static let isClickKey = "IS_CLICK_KEY"

    // Emulator Settings.
    // They require additional logic when set, so we use UserDefaults directly.
    private static let isTurboKey = "IS_TURBO_KEY"
    private static let isAlphaKey = "IS_ALPHA_KEY"
    private static let isHpKey = "IS_HP_KEY"

    // We use a String instead of a Bool to distinguish between false and the absence of a value.
    private static func setBoolValue(key: String, value: Bool) {
        UserDefaults.standard.set(value ? "Y" : "N", forKey: key)
    }

    private static func getBoolValue(key: String, defaultValue: Bool) -> Bool {
        let value = UserDefaults.standard.string(forKey: key)
        if value == "Y" { return true }
        if value == "N" { return false }
        return defaultValue
    }

    @Published var hasTurboSpeed: Bool {
        didSet {
            UserSettings.setBoolValue(key: UserSettings.isTurboKey, value: hasTurboSpeed)

            // The 2x speedup in the standard case makes the emulator more enjoyable to use.
            Rcl57.shared.speedupFactor = hasTurboSpeed ? 1000 : 2
            Rcl57.shared.setOptionFlag(option: RCL57_SHOW_RUN_INDICATOR_FLAG, value: hasTurboSpeed)
        }
    }

    @Published var hasAlphaDisplay: Bool {
        didSet {
            UserSettings.setBoolValue(key: UserSettings.isAlphaKey, value: hasAlphaDisplay)
            Rcl57.shared.setOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG, value: hasAlphaDisplay)
        }
    }

    @Published var hasHpLrnMode: Bool {
        didSet {
            UserSettings.setBoolValue(key: UserSettings.isHpKey, value: hasHpLrnMode)
            Rcl57.shared.setOptionFlag(option: RCL57_HP_LRN_MODE_FLAG, value: hasHpLrnMode)
        }
    }

    init() {
        // Get the emulator option values from UserDefaults.
        hasTurboSpeed = UserSettings.getBoolValue(key: UserSettings.isTurboKey, defaultValue: true)
        hasAlphaDisplay = UserSettings.getBoolValue(key: UserSettings.isAlphaKey, defaultValue: true)
        hasHpLrnMode = UserSettings.getBoolValue(key: UserSettings.isHpKey, defaultValue: true)

        // Inform the emulator.
        // The 2x speedup in the standard case makes the emulator more enjoyable to use.
        Rcl57.shared.speedupFactor = hasTurboSpeed ? 1000 : 2
        Rcl57.shared.setOptionFlag(option: RCL57_QUICK_STOP_FLAG, value: hasTurboSpeed)
        Rcl57.shared.setOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG, value: hasAlphaDisplay)
        Rcl57.shared.setOptionFlag(option: RCL57_HP_LRN_MODE_FLAG, value: hasHpLrnMode)

        // The other emulator options cannot be set by the user.
        // These values improve the overall user experience.
        Rcl57.shared.setOptionFlag(option: RCL57_QUICK_STOP_FLAG, value: true)
        Rcl57.shared.setOptionFlag(option: RCL57_SHORT_PAUSE_FLAG, value: true)
        Rcl57.shared.setOptionFlag(option: RCL57_FASTER_TRACE_FLAG, value: true)
    }
}
