import UIKit

struct Settings {
    private static let IS_HAPTIC_KEY = "IS_HAPTIC_KEY"
    private static let IS_CLICK_KEY = "IS_CLICK_KEY"
    private static let IS_TURBO_KEY = "IS_TURBO_KEY"
    private static let IS_ALPHA_KEY = "IS_ALPHA_KEY"
    private static let IS_HP_KEY = "IS_HP_KEY"

    private static func setValue(key: String, value: Bool) {
        UserDefaults.standard.set(value ? "Y" : "N", forKey: key)
        Rcl57.shared.setOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG, value: value)
    }

    private static func getValue(key: String, defaultValue: Bool) -> Bool {
        let value = UserDefaults.standard.string(forKey: key)
        if value == "Y" { return true }
        if value == "N" { return false }
        return defaultValue
    }

    // Turbo Speed.
    static func setTurboSpeed(_ value: Bool) {
        setValue(key: IS_TURBO_KEY, value: value)

        Rcl57.shared.setSpeedup(speedup: value ? 1000 : 2)
        Rcl57.shared.setOptionFlag(option: RCL57_SHOW_RUN_INDICATOR_FLAG, value: value)

        // We set these values to always true since the original behavior can be very frustrating.
        Rcl57.shared.setOptionFlag(option: RCL57_QUICK_STOP_FLAG, value: true)
        Rcl57.shared.setOptionFlag(option: RCL57_SHORT_PAUSE_FLAG, value: true)
        Rcl57.shared.setOptionFlag(option: RCL57_FASTER_TRACE_FLAG, value: true)
    }

    static func getTurboSpeed() -> Bool {
        return getValue(key: IS_TURBO_KEY, defaultValue: true)
    }

    // Alpha Display.
    static func setAlphaDisplay(_ value: Bool) {
        setValue(key: IS_ALPHA_KEY, value: value)
        Rcl57.shared.setOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG, value: value)
    }

    static func getAlphaDisplay() -> Bool {
        return getValue(key: IS_ALPHA_KEY, defaultValue: true)
    }

    // HP LRN Mode.
    static func setHPLrnMode(_ value: Bool) {
        setValue(key: IS_HP_KEY, value: value)
        Rcl57.shared.setOptionFlag(option: RCL57_HP_LRN_MODE_FLAG, value: value)
    }

    static func getHPLrnMode() -> Bool {
        return getValue(key: IS_HP_KEY, defaultValue: true)
    }

    // Haptic Feedback.
    static func setHasHaptic(_ value: Bool) {
        setValue(key: IS_HAPTIC_KEY, value: value)
    }

    static func hasHaptic() -> Bool {
        return getValue(key: IS_HAPTIC_KEY, defaultValue: true)
    }

    // Key Click.
    static func setHasKeyClick(_ value: Bool) {
        setValue(key: IS_CLICK_KEY, value: value)
    }

    static func hasKeyClick() -> Bool {
        return getValue(key: IS_CLICK_KEY, defaultValue: false)
    }
}
