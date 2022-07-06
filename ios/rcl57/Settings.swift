import UIKit

struct Settings {
    private static let HAS_HAPTIC_KEY = "has_haptic"
    private static let HAS_KEY_CLICK_KEY = "has_key_click"
    private static let TURBO_KEY = "turbo_key"
    private static let ALPHA_KEY = "alpha_key"
    private static let HP_KEY = "hp_key"

    // Turbo Speed.
    static func setTurboSpeed(turbo: Bool) {
        UserDefaults.standard.set(turbo, forKey: TURBO_KEY)
        Rcl57.shared.setSpeedup(speedup: turbo ? 1000 : 2)
        Rcl57.shared.setOptionFlag(option: RCL57_SHOW_RUN_INDICATOR_FLAG, value: turbo)

        // We set these values to always true since the original behavior can be very frustrating.
        Rcl57.shared.setOptionFlag(option: RCL57_QUICK_STOP_FLAG, value: true)
        Rcl57.shared.setOptionFlag(option: RCL57_SHORT_PAUSE_FLAG, value: true)
        Rcl57.shared.setOptionFlag(option: RCL57_FASTER_TRACE_FLAG, value: true)
    }

    static func getTurboSpeed() -> Bool {
        return UserDefaults.standard.bool(forKey: TURBO_KEY)
    }

    // Alpha Display.
    static func setAlphaDisplay(alpha: Bool) {
        UserDefaults.standard.set(alpha, forKey: ALPHA_KEY)
        Rcl57.shared.setOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG, value: alpha)
    }

    static func getAlphaDisplay() -> Bool {
        return UserDefaults.standard.bool(forKey: ALPHA_KEY)
    }

    // HP LRN Mode.
    static func setHPLrnMode(hpLrn: Bool) {
        UserDefaults.standard.set(hpLrn, forKey: HP_KEY)
        Rcl57.shared.setOptionFlag(option: RCL57_HP_LRN_MODE_FLAG, value: hpLrn)
    }

    static func getHPLrnMode() -> Bool {
        return UserDefaults.standard.bool(forKey: HP_KEY)
    }

    // Haptic Feedback.
    static func hasHaptic() -> Bool {
        return UserDefaults.standard.bool(forKey: HAS_HAPTIC_KEY)
    }

    static func setHasHaptic(has_haptic: Bool) {
        UserDefaults.standard.set(has_haptic, forKey: HAS_HAPTIC_KEY)
    }

    // Key Click.
    static func hasKeyClick() -> Bool {
        return UserDefaults.standard.bool(forKey: HAS_KEY_CLICK_KEY)
    }

    static func setHasKeyClick(has_key_click: Bool) {
        UserDefaults.standard.set(has_key_click, forKey: HAS_KEY_CLICK_KEY)
    }
}
