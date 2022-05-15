import UIKit
struct Settings {
    static let HAS_HAPTIC_KEY = "has_haptic"
    static let HAPTIC_STYLE_KEY = "haptic_style"
    static let HAS_ORIGINAL_SPEED_KEY = "has_original_speed"
    static let HAS_ORIGINAL_DISPLAY_KEY = "has_original_display"
    static let HAS_ORIGINAL_LRN_KEY = "has_original_lrn"

    static func getHapticStyle() -> UIImpactFeedbackGenerator.FeedbackStyle? {
        if !UserDefaults.standard.bool(forKey: HAS_HAPTIC_KEY) {
            return nil
        }
        let rawValue = UserDefaults.standard.integer(forKey: HAPTIC_STYLE_KEY)
        return UIImpactFeedbackGenerator.FeedbackStyle(rawValue: rawValue)
    }

    static func setHapticStyle(style: UIImpactFeedbackGenerator.FeedbackStyle?) {
        if style == nil {
            UserDefaults.standard.set(false, forKey: HAS_HAPTIC_KEY)
            return
        }
        UserDefaults.standard.set(true, forKey: HAS_HAPTIC_KEY)
        UserDefaults.standard.set(style!.rawValue, forKey: HAPTIC_STYLE_KEY)
    }

    static func hasOriginalSpeed() -> Bool {
        return UserDefaults.standard.bool(forKey: HAS_ORIGINAL_SPEED_KEY)
    }

    static func setOriginalSpeed(has_original_speed: Bool, rcl57: RCL57) {
        UserDefaults.standard.setValue(has_original_speed, forKey: HAS_ORIGINAL_SPEED_KEY)
        rcl57.setSpeedup(speedup: has_original_speed ? 2 : 1000)
        rcl57.setOptionFlag(option: RCL57_SHORT_PAUSE_FLAG, value: !has_original_speed)
        rcl57.setOptionFlag(option: RCL57_FASTER_TRACE_FLAG, value: !has_original_speed)
        rcl57.setOptionFlag(option: RCL57_QUICK_STOP_FLAG, value: !has_original_speed)
        rcl57.setOptionFlag(option: RCL57_SHOW_RUN_INDICATOR_FLAG, value: !has_original_speed)
    }

    static func hasOriginalDisplay() -> Bool {
        return UserDefaults.standard.bool(forKey: HAS_ORIGINAL_DISPLAY_KEY)
    }

    static func setOriginalDisplay(has_original_display: Bool, rcl57: RCL57) {
        UserDefaults.standard.set(has_original_display, forKey: HAS_ORIGINAL_DISPLAY_KEY)
        rcl57.setOptionFlag(option: RCL57_ALPHA_LRN_MODE_FLAG, value: !has_original_display)
    }

    static func hasOriginalLrn() -> Bool {
        return UserDefaults.standard.bool(forKey: HAS_ORIGINAL_LRN_KEY)
    }

    static func setOriginalLrn(has_original_lrn: Bool, rcl57: RCL57) {
        UserDefaults.standard.set(has_original_lrn, forKey: HAS_ORIGINAL_LRN_KEY)
        rcl57.setOptionFlag(option: RCL57_HP_LRN_MODE_FLAG, value: !has_original_lrn)
    }
}
