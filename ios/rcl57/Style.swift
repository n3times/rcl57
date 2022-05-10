import SwiftUI

struct Style {
    static let isIpod = UIScreen.main.bounds.width <= 320

    static let ivory = Color(red: 1.0, green: 1.0, blue: 0.93)
    static let blackish = Color(red: 0.1, green: 0.1, blue: 0.11)

    static let directionsFont = Font.system(size: 22, weight: .regular, design: .monospaced)
    static let titleFont = Font.system(size: 22, weight: .medium)
    static let lineFont = Font.system(size: isIpod ? 16 : 20, weight:.semibold, design: .monospaced)

    static let lineHeight = isIpod ? 22.0 : 27.0
    static let headerHeight = 55.0
    static let footerHeight = 45.0
}
