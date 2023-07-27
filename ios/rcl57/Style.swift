import SwiftUI

extension Color {
    static let ivory = Color(red: 1.0, green: 1.0, blue: 0.93)
    static let lightGray = Color(red: 0.85, green: 0.85, blue: 0.85)
    static let blackish = Color(red: 0.137, green: 0.149, blue: 0.153)
    static let deepBlue = Color(red: 0.18, green: 0.35, blue: 0.58)
    static let deepGreen = Color(red: 0.18, green: 0.58, blue: 0.35)
    static let deepishBlue = Color(red: 0.6, green: 0.8, blue: 1.0)
    static let deepishGreen = Color(red: 0.7, green: 0.9, blue: 0.7)
    static let deeperBlue = Color(red: 0.13, green: 0.24, blue: 0.40)
}

struct Style {
    // iPod screen is special-cased.
    private static let isSmallScreen = UIScreen.main.bounds.width <= 320

    // Header.
    static let titleFont = Font.system(size: 22, weight: .medium)
    static let smallFont = Font.system(size: isSmallScreen ? 14 : 18, weight: .medium)
    static let directionsFont = Font.system(size: 22, weight: .regular, design: .monospaced)
    static let directionsFontLarge = Font.system(size: 26, weight: .regular, design: .monospaced)
    static let headerHeight = 44.0
    static let programFont =
        Font.system(size: isSmallScreen ? 12 : 14, weight:.medium, design: .default)
    static let operationFont =
        Font.system(size: isSmallScreen ? 14 : 16, weight:.medium, design: .default)

    // List.
    static let listLineFont =
        Font.system(size: isSmallScreen ? 17 : 20, weight:.semibold, design: .monospaced)
    static let listLineFontBold =
        Font.system(size: isSmallScreen ? 15 : 18, weight:.medium, design: .default)
    static let listLineHeight = isSmallScreen ? 22.0 : 27.0

    // Footer.
    static let footerFont = Font.system(size: 18, weight: .medium)
    static let footerHeight = 44.0

    // Directions.
    static let leftArrow = "\u{25c1}"
    static let rightArrow = "\u{25b7}"
    static let rightArrowFull = "\u{25b6}"
    static let downArrow = "\u{25bd}"
    static let upArrow = "\u{25b3}"
    static let square = "\u{25a2}"
    static let ying = "\u{25d0}"
    static let yang = "\u{25d1}"
}
