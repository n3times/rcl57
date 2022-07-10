import SwiftUI

struct Style {
    private static let isIpod = UIScreen.main.bounds.width <= 320

    // Colors.
    static let ivory = Color(red: 1.0, green: 1.0, blue: 0.93)
    static let blackish = Color(red: 0.1, green: 0.1, blue: 0.11)

    // Header.
    static let titleFont = Font.system(size: 22, weight: .medium)
    static let directionsFont = Font.system(size: 22, weight: .regular, design: .monospaced)
    static let directionsFontLarge = Font.system(size: 28, weight: .regular, design: .monospaced)
    static let headerHeight = 44.0
    static let programFont =
        Font.system(size: isIpod ? 12 : 14, weight:.medium, design: .default)

    // List.
    static let listLineFont =
        Font.system(size: isIpod ? 17 : 20, weight:.semibold, design: .monospaced)
    static let listLineHeight = isIpod ? 22.0 : 27.0

    // Footer.
    static let footerFont = Font.system(size: 22, weight: .medium)
    static let footerHeight = 44.0

    // Mini View.
    static let miniViewLineCount = 2

    // Directions.
    static let leftArrow = "\u{25c1}"
    static let rightArrow = "\u{25b7}"
    static let downArrow = "\u{25bd}"
    static let upArrow = "\u{25b3}"
    static let circle = "\u{25ef}"
    static let square = "\u{25a2}"
    static let ying = "\u{25d0}"
    static let yang = "\u{25d1}"
}
