/**
 * The display, composed of 12 14-segment LEDs. In addition, each LED has an optional dot
 * to the right (decimal point).
 */

import SwiftUI

struct DisplayView: View {
    // A string composed of up to 12 non-dot characters, each one optionally followed by a
    // a dot. The string will be right-justified within the display.
    private var displayString: String

    private static let ledColor = Color.red
    private static let maxLedCount = 12
    private static let ledWidth = 19.0
    private static let ledHeight = 26.0
    private static let interLedX = 32.0
    private static let segmentCount = 14
    private static let slant = 0.05
    private static let scaleFactor = 0.85

    private static func getDisplayRect() -> CGRect {
        let width = (Double(maxLedCount - 1)) * interLedX + ledWidth
        return CGRect(x: 0, y: 0, width: width, height: ledHeight)
    }

    /*
     * LED SEGMENT DATA
     */

    // Describes the 10 horizontal and vertical segments.
    private static let rightSegmentsData = [
        0: CGRect(x: 0, y: 0, width: 19, height: 3),
        1: CGRect(x: 0, y: 0, width: 3, height: 15),
        3: CGRect(x: 8, y: 0, width: 3, height: 15),
        5: CGRect(x: 16, y: 0, width: 3, height: 15),
        6: CGRect(x: 0, y: 13, width: 10, height: 3),
        7: CGRect(x: 9, y: 13, width: 10, height: 3),
        8: CGRect(x: 0, y: 14, width: 3, height: 15),
        10: CGRect(x: 8, y: 14, width: 3, height: 15),
        12: CGRect(x: 16, y: 14, width: 3, height: 15),
        13: CGRect(x: 0, y: 26, width: 19, height: 3),
    ]

    // Combines pairs of segments into a single segment, for a smoother look.
    private static let combinedRightSegmentsData = [
        [1, 8]: CGRect(x: 0, y: 0, width: 3, height: 29),
        [3, 10]: CGRect(x: 8, y: 0, width: 3, height: 29),
        [5, 12]: CGRect(x: 16, y: 0, width: 3, height: 29),
        [6, 7]: CGRect(x: 0, y: 13, width: 19, height: 3),
    ]

    // Alternative to 'combinedRightSegmentsData', slightly shorter for some characters.
    private static let combinedShorterRightSegmentsData = [
        [1, 8]: CGRect(x: 0, y: 4, width: 3, height: 23),
        [3, 10]: CGRect(x: 8, y: 4, width: 3, height: 23),
        [5, 12]: CGRect(x: 16, y: 4, width: 3, height: 23),
        [6, 7]: CGRect(x: 0, y: 13, width: 19, height: 3),
    ]

    // Describes the 4 angled segments. Points of each hexagon should be listed clockwise.
    private static let angledSegmentsData = [
        2: [CGPoint(x: 1, y: 1), CGPoint(x: 1+2, y: 1), CGPoint(x: 10, y: 15-3),
            CGPoint(x: 10, y: 15), CGPoint(x: 10-2, y: 15), CGPoint(x: 1, y: 1+3)],
        4: [CGPoint(x: 18, y: 1+3), CGPoint(x: 9+2, y: 15), CGPoint(x: 9, y: 15),
            CGPoint(x: 9, y: 15-3), CGPoint(x: 18-2, y: 1), CGPoint(x: 18, y: 1)],
        9: [CGPoint(x: 1, y: 28-3), CGPoint(x: 10-2, y: 14), CGPoint(x: 10, y: 14),
            CGPoint(x: 10, y: 14+3), CGPoint(x: 1+2, y: 28), CGPoint(x: 1, y: 28)],
        11: [CGPoint(x: 18, y: 28), CGPoint(x: 18-2, y: 28), CGPoint(x: 9, y: 14+3),
            CGPoint(x: 9, y: 14), CGPoint(x: 9+2, y: 14), CGPoint(x: 18, y: 28-3)],
    ]

    // Combines pairs of angled segments into a single segment, for a smoother look.
    private static let combinedAngledSegmentsData = [
        [2, 11]: [CGPoint(x: 1, y: 1), CGPoint(x: 1+2, y: 1), CGPoint(x: 18, y: 28-3),
                  CGPoint(x: 18, y: 28), CGPoint(x: 18-2, y: 28), CGPoint(x: 1, y: 1+3)],
        [4, 9]: [CGPoint(x: 1, y: 28-3), CGPoint(x: 18-2, y: 1), CGPoint(x: 18, y: 1),
                 CGPoint(x: 18, y: 1+3), CGPoint(x: 1+2, y: 28), CGPoint(x: 1, y: 28)],
    ]

    // Alternative to 'combinedAngledSegmentsData', slightly shorter for some characters.
    private static let combinedShorterAngledSegmentsData = [
        [2, 11]: [CGPoint(x: 3, y: 5), CGPoint(x: 3+2, y: 5), CGPoint(x: 17, y: 25-3),
                  CGPoint(x: 17, y: 25), CGPoint(x: 17-2, y: 25), CGPoint(x: 3, y: 5+3)],
        [4, 9]: [CGPoint(x: 3, y: 25-3), CGPoint(x: 17-2, y: 5), CGPoint(x: 17, y: 5),
                 CGPoint(x: 17, y: 5+3), CGPoint(x: 3+2, y: 25), CGPoint(x: 3, y: 25)],
    ]

    // The data for the decimal point.
    private let dotData = CGRect(x: 22, y: 25, width: 4, height: 4)

    /*
     * SEGMENT PATHS
     */

    // Returns a rectangle path with the corners slightly clipped.
    private func getRectSegmentPath(rect: CGRect) -> Path? {
        var path = Path()
        let d = 1.5
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + d))
        path.addLine(to: CGPoint(x: rect.minX + d, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - d, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + d))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - d))
        path.addLine(to: CGPoint(x: rect.maxX - d, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + d, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - d))
        return path
    }

    private func getAngledSegmentPath(points: [CGPoint]) -> Path? {
        var path = Path()
        path.move(to: points[0])
        for i in 1...5 {
            path.addLine(to: points[i])
        }
        return path
    }

    // Returns true if the segment of a given index is on.
    private func isSegmentOn(segments: Int32, i: Int) -> Bool {
        return segments & (1 << (DisplayView.segmentCount - 1 - i)) != 0
    }

    /*
     * SINGLE LED PATH
     */

    private func getLedPath(c: Character,
                            startX: CGFloat,
                            hasDot: Bool,
                            combineSegments:Bool) -> Path? {
        let segments = leds57_get_segments(UInt8(c.asciiValue!))
        var isSegmentResolved = [Bool](repeating: false, count: 14)

        var path = Path()

        let useShortSegments = c == "+" || c == "-" || c == "x" || c == "/" || c == "@"

        // Draw the combined LED segments.
        if combineSegments {
            for pair in DisplayView.combinedRightSegmentsData.keys {
                if isSegmentOn(segments: segments, i: pair[0]) &&
                   isSegmentOn(segments: segments, i: pair[1]) {
                    let rect = useShortSegments ? DisplayView.combinedShorterRightSegmentsData[pair]
                                                : DisplayView.combinedRightSegmentsData[pair]
                    let segmentPath = getRectSegmentPath(rect: rect!)
                    path.addPath(segmentPath!.offsetBy(dx: startX, dy: 0))
                    isSegmentResolved[pair[0]] = true
                    isSegmentResolved[pair[1]] = true
                }
            }
            for pair in DisplayView.combinedAngledSegmentsData.keys {
                if isSegmentOn(segments: segments, i: pair[0]) &&
                   isSegmentOn(segments: segments, i: pair[1]) {
                    let points =
                        useShortSegments ? DisplayView.combinedShorterAngledSegmentsData[pair]
                                         : DisplayView.combinedAngledSegmentsData[pair]
                    let segmentPath = getAngledSegmentPath(points: points!)
                    path.addPath(segmentPath!.offsetBy(dx: startX, dy: 0))
                    isSegmentResolved[pair[0]] = true
                    isSegmentResolved[pair[1]] = true
                }
            }
        }

        // Draw the non-combined LED segments.
        for i in 0...(DisplayView.segmentCount - 1) {
            if isSegmentOn(segments: segments, i: i) {
                let segmentPath: Path?
                let isAngled = i == 2 || i == 4 || i == 9 || i == 11
                if isAngled {
                    segmentPath =
                        getAngledSegmentPath(points: DisplayView.angledSegmentsData[i]!)
                } else {
                    segmentPath = getRectSegmentPath(rect: DisplayView.rightSegmentsData[i]!)
                }
                if (segmentPath != nil && !isSegmentResolved[i]) {
                    path.addPath(segmentPath!.offsetBy(dx: startX, dy: 0))
                }
            }
        }

        // Draw the dot if present.
        if (hasDot) {
            path.addRect(dotData.offsetBy(dx: startX, dy: 0))
        }

        return path
    }

    /*
     * DISPLAY PATH
     */

    private func getDisplayPath(displayString: String) -> TransformedShape<Path> {
        var path = Path()
        let displayCharacters = Array(displayString)

        // Count the number of LEDs needed.
        var ledCount = 0
        for c in displayCharacters {
            if c != "." {
                ledCount += 1
            }
        }

        // Go through every character and generate the associated LED path.
        var index = 0
        for i in 0..<displayCharacters.count {
            if displayCharacters[i] == "." { continue }

            // Right justify.
            let position = index + (DisplayView.maxLedCount - ledCount)
            let hasDot = i < displayCharacters.count - 1 && displayCharacters[i + 1] == "."
            let ledPath = getLedPath(c: displayCharacters[i],
                                     startX: DisplayView.interLedX * CGFloat(position),
                                     hasDot: hasDot,
                                     combineSegments: true)
            if ledPath != nil { path.addPath(ledPath!) }
            index += 1
        }

        // Slant display slightly
        let slantedPath = path.transform(CGAffineTransform.init(a: 1,
                                                                b: 0,
                                                                c: -DisplayView.slant,
                                                                d: 1,
                                                                tx: 0,
                                                                ty: 0))

        return slantedPath
    }

    init(_ displayText: String) {
        self.displayString = displayText
    }

    var body: some View {
        GeometryReader { geometry in
            let rect = DisplayView.getDisplayRect()
            let scaleFactor = geometry.size.width / rect.width * DisplayView.scaleFactor
            let offsetX = (geometry.size.width - rect.width) / 2
            let offsetY = (geometry.size.height - rect.height) / 2
            getDisplayPath(displayString: displayString)
                .offset(x: offsetX, y: offsetY)
                .scale(scaleFactor)
                .fill(DisplayView.ledColor)
        }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView("READY")
    }
}
