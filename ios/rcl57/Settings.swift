import UIKit

enum Flavor: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case turbo = "Turbo"
    case alpha = "Alpha"
    case rebooted = "Rebooted"

    var id: Self { self }
}

struct Settings {
    static let FLAVOR_KEY = "flavor_key"
    static let HAS_HAPTIC_KEY = "has_haptic"
    static let HAPTIC_STYLE_KEY = "haptic_style"
    static let HAS_KEY_CLICK_KEY = "has_key_click"

    static private func setOriginalSpeed(has_original_speed: Bool, rcl57: Rcl57) {
        rcl57.setSpeedup(speedup: has_original_speed ? 2 : 1000)
        rcl57.setOptionFlag(option: RCL57_SHORT_PAUSE_FLAG, value: !has_original_speed)
        rcl57.setOptionFlag(option: RCL57_FASTER_TRACE_FLAG, value: !has_original_speed)
        rcl57.setOptionFlag(option: RCL57_QUICK_STOP_FLAG, value: !has_original_speed)
        rcl57.setOptionFlag(option: RCL57_SHOW_RUN_INDICATOR_FLAG, value: !has_original_speed)
    }

    static func setFlavor(flavor: Flavor, rcl57: Rcl57) {
        UserDefaults.standard.set(flavor.rawValue, forKey: FLAVOR_KEY)
        setOriginalSpeed(has_original_speed: flavor == .classic, rcl57: rcl57)
        rcl57.setOptionFlag(
            option: RCL57_ALPHA_LRN_MODE_FLAG, value: flavor == .alpha || flavor == .rebooted)
        rcl57.setOptionFlag(option: RCL57_HP_LRN_MODE_FLAG, value: flavor == .rebooted)
    }

    static func getFlavor() -> Flavor {
        let rawFlavor = UserDefaults.standard.string(forKey: FLAVOR_KEY)
        if rawFlavor == nil {
            return .turbo
        }
        let flavor = Flavor(rawValue: rawFlavor!)
        if flavor == nil {
            return .turbo
        }
        return flavor!
    }

    static func getHapticStyle() -> UIImpactFeedbackGenerator.FeedbackStyle? {
        if !UserDefaults.standard.bool(forKey: HAS_HAPTIC_KEY) {
            return nil
        }
        let rawValue = UserDefaults.standard.integer(forKey: HAPTIC_STYLE_KEY)
        return UIImpactFeedbackGenerator.FeedbackStyle(rawValue: rawValue)
    }

    static func setHapticStyle(style: UIImpactFeedbackGenerator.FeedbackStyle?) {
        UserDefaults.standard.set(style != nil, forKey: HAS_HAPTIC_KEY)
        if style == nil {
            return
        }
        UserDefaults.standard.set(style!.rawValue, forKey: HAPTIC_STYLE_KEY)
    }

    static func hasKeyClick() -> Bool {
        return UserDefaults.standard.bool(forKey: HAS_KEY_CLICK_KEY)
    }

    static func setHasKeyClick(has_key_click: Bool, rcl57: Rcl57) {
        UserDefaults.standard.set(has_key_click, forKey: HAS_KEY_CLICK_KEY)
    }
}
