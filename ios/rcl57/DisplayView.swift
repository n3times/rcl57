import SwiftUI

/**
 * Describes the shapes of the LED segments.
 *
 * Each LED has 14 segments:
 *  --   <- this represents only 1 segment
 * |\/|
 *  --   <- this represents 2 segments
 * |/\|
 *  __   <- this represents only 1 segment
 *
 * The shape of each segment is described in `segmentData`. For a smoother look, there are two
 * visual optimizations:
 * - `combinedData` combines two adjacent segments into one, with no gap.
 * - `combinedShoterData` is used for some characters (such as "X" or "+") that look better when the
 *   segments are a little shorter.
 */
private struct LedSegmentData {
    struct Pair<T: Hashable>: Hashable {
        let first: T
        let second: T

        init(_ first: T, _ second: T) {
            self.first = first
            self.second = second
        }
    }

    enum SegmentData {
        case straight(CGRect)
        case angled([CGPoint])
    }

    static let segmentData: [SegmentData] = [
        .straight(CGRect(x: 0, y: 0, width: 19, height: 3)),
        .straight(CGRect(x: 0, y: 0, width: 3, height: 15)),
        .angled([CGPoint(x: 1, y: 1), CGPoint(x: 1+2, y: 1), CGPoint(x: 10, y: 15-3),
                 CGPoint(x: 10, y: 15), CGPoint(x: 10-2, y: 15), CGPoint(x: 1, y: 1+3)]),
        .straight(CGRect(x: 8, y: 0, width: 3, height: 15)),
        .angled([CGPoint(x: 18, y: 1+3), CGPoint(x: 9+2, y: 15), CGPoint(x: 9, y: 15),
                 CGPoint(x: 9, y: 15-3), CGPoint(x: 18-2, y: 1), CGPoint(x: 18, y: 1)]),
        .straight(CGRect(x: 16, y: 0, width: 3, height: 15)),
        .straight(CGRect(x: 0, y: 13, width: 10, height: 3)),
        .straight(CGRect(x: 9, y: 13, width: 10, height: 3)),
        .straight(CGRect(x: 0, y: 14, width: 3, height: 15)),
        .angled([CGPoint(x: 1, y: 28-3), CGPoint(x: 10-2, y: 14), CGPoint(x: 10, y: 14),
                 CGPoint(x: 10, y: 14+3), CGPoint(x: 1+2, y: 28), CGPoint(x: 1, y: 28)]),
        .straight(CGRect(x: 8, y: 14, width: 3, height: 15)),
        .angled([CGPoint(x: 18, y: 28), CGPoint(x: 18-2, y: 28), CGPoint(x: 9, y: 14+3),
                 CGPoint(x: 9, y: 14), CGPoint(x: 9+2, y: 14), CGPoint(x: 18, y: 28-3)]),
        .straight(CGRect(x: 16, y: 14, width: 3, height: 15)),
        .straight(CGRect(x: 0, y: 26, width: 19, height: 3))
    ]

    static let combinedData: [Pair<Int>: SegmentData] = [
        Pair(1, 8): .straight(CGRect(x: 0, y: 0, width: 3, height: 29)),
        Pair(3, 10): .straight(CGRect(x: 8, y: 0, width: 3, height: 29)),
        Pair(5, 12): .straight(CGRect(x: 16, y: 0, width: 3, height: 29)),
        Pair(6, 7): .straight(CGRect(x: 0, y: 13, width: 19, height: 3)),
        Pair(2, 11): .angled([CGPoint(x: 1, y: 1), CGPoint(x: 1+2, y: 1), CGPoint(x: 18, y: 28-3),
                              CGPoint(x: 18, y: 28), CGPoint(x: 18-2, y: 28), CGPoint(x: 1, y: 1+3)]),
        Pair(4, 9): .angled([CGPoint(x: 1, y: 28-3), CGPoint(x: 18-2, y: 1), CGPoint(x: 18, y: 1),
                             CGPoint(x: 18, y: 1+3), CGPoint(x: 1+2, y: 28), CGPoint(x: 1, y: 28)]),
    ]

    static let combinedShoterData: [Pair<Int>: SegmentData] = [
        Pair(1, 8): .straight(CGRect(x: 0, y: 4, width: 3, height: 23)),
        Pair(3, 10): .straight(CGRect(x: 8, y: 4, width: 3, height: 23)),
        Pair(5, 12): .straight(CGRect(x: 16, y: 4, width: 3, height: 23)),
        Pair(6, 7): .straight(CGRect(x: 0, y: 13, width: 19, height: 3)),
        Pair(2, 11): .angled([CGPoint(x: 3, y: 5), CGPoint(x: 3+2, y: 5), CGPoint(x: 17, y: 25-3),
                              CGPoint(x: 17, y: 25), CGPoint(x: 17-2, y: 25), CGPoint(x: 3, y: 5+3)]),
        Pair(4, 9): .angled([CGPoint(x: 3, y: 25-3), CGPoint(x: 17-2, y: 5), CGPoint(x: 17, y: 5),
                             CGPoint(x: 17, y: 5+3), CGPoint(x: 3+2, y: 25), CGPoint(x: 3, y: 25)]),
    ]

    static let dotData = SegmentData.straight(CGRect(x: 22, y: 25, width: 4, height: 4))
}

/**
 * The display, composed of 12 LEDs. In addition, each LED has an optional dot to the right (decimal
 * point).
 *
 * Note that the TI-57 has 7-segment LEDs but RCL-57 supports alpha mode.
 */
struct DisplayView: View {
    private static let ledColor = Color.red
    private static let maxLedCount = 12
    private static let segmentCount = 14
    private static let ledWidth = 19.0
    private static let ledHeight = 26.0
    private static let interLedX = 32.0
    private static let slant = 0.05

    /// A string composed of up to 12 non-dot characters, each one optionally followed by a
    /// a dot. The string will be right-justified within the display.
    let displayString: String

    private static func getDisplayPathRect() -> CGRect {
        let width = Double(maxLedCount - 1) * interLedX + ledWidth
        return CGRect(x: 0, y: 0, width: width, height: ledHeight)
    }

    // MARK: Single-Segment Path

    // Returns a rectangle path with the corners slightly clipped.
    private func ledStraightSegmentPath(rect: CGRect) -> Path {
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
        path.closeSubpath()
        return path
    }

    private func ledAngledSegmentPath(points: [CGPoint]) -> Path {
        var path = Path()
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        path.closeSubpath()
        return path
    }

    // Returns true if the segment of a given index is on.
    private func isSegmentOn(segments: Int32, i: Int) -> Bool {
        return segments & (1 << (DisplayView.segmentCount - 1 - i)) != 0
    }

    // MARK: Single-Led Path

    private func getLedPath(c: Character,
                            startX: CGFloat,
                            hasDot: Bool,
                            combineSegments:Bool) -> Path? {
        let ampersandAsciiValue: UInt8 = 64
        let c = c.asciiValue != nil ? c : "@"
        let segments = leds57_get_segments(c.asciiValue ?? ampersandAsciiValue)
        var isSegmentResolved = [Bool](repeating: false, count: DisplayView.segmentCount)

        var path = Path()

        let useShortSegments = c == "+" || c == "-" || c == "x" || c == "/" || c == "@"

        // Draw the combined LED segments.
        if combineSegments {
            for pair in LedSegmentData.combinedData.keys {
                if isSegmentOn(segments: segments, i: pair.first) &&
                    isSegmentOn(segments: segments, i: pair.second) {
                    let combinedData = useShortSegments ? LedSegmentData.combinedShoterData
                    : LedSegmentData.combinedData
                    switch combinedData[pair] {
                    case .straight(let rect):
                        let segmentPath = ledStraightSegmentPath(rect: rect)
                        path.addPath(segmentPath.offsetBy(dx: startX, dy: 0))
                    case .angled(let points):
                        let segmentPath = ledAngledSegmentPath(points: points)
                        path.addPath(segmentPath.offsetBy(dx: startX, dy: 0))
                    default:
                        break
                    }
                    isSegmentResolved[pair.first] = true
                    isSegmentResolved[pair.second] = true
                }
            }
        }

        // Draw the non-combined LED segments if they haven't been resolved.
        for i in 0...(DisplayView.segmentCount - 1) {
            if isSegmentResolved[i] { continue }
            if isSegmentOn(segments: segments, i: i) {
                let segmentPath = {
                    switch LedSegmentData.segmentData[i] {
                    case .straight(let rect):
                        return ledStraightSegmentPath(rect: rect)
                    case .angled(let points):
                        return ledAngledSegmentPath(points: points)
                    }
                }()
                path.addPath(segmentPath.offsetBy(dx: startX, dy: 0))
            }
        }

        // Draw the dot if present.
        if hasDot {
            switch LedSegmentData.dotData {
            case .angled:
                break
            case .straight(let rect):
                path.addRect(rect.offsetBy(dx: startX, dy: 0))
            }
        }

        return path
    }

    // MARK: All-Leds Path

    private func getDisplayPath(displayString: String, boundingRect: CGRect) -> some Shape {
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
            if let ledPath { path.addPath(ledPath) }
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

    var body: some View {
        let displayRect = DisplayView.getDisplayPathRect()

        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let boundingRect = CGRect(x: 0, y: 0, width: width, height: height)
            getDisplayPath(displayString: displayString, boundingRect: boundingRect)
                .offset(x: (boundingRect.width - displayRect.width) / 2, y: (boundingRect.height - displayRect.height) / 2)
                .scale(boundingRect.width / displayRect.width)
                .fill(DisplayView.ledColor)
        }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView(displayString: "READY")
    }
}
