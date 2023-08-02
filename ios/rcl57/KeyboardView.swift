import SwiftUI
import AudioToolbox

/// A triangle pointing to the left, used to indicate the trig mode.
private struct TrigModeIndicator: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: rect.minX, y: height / 2))
        path.addLine(to: CGPoint(x: width, y: rect.minY))
        path.addLine(to: CGPoint(x: width, y: height))
        return path
    }
}

/// Displays the keyboard view and handles key presses/releases.
struct KeyboardView: View {
    @EnvironmentObject private var change: Change
    @EnvironmentObject private var settings: UserSettings

    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(UserSettings.isHapticKey) private var hasHaptic = false
    @AppStorage(UserSettings.isClickKey) private var hasKeyClick = false

    private let imageName = "button_pad"

    @State private var isKeyPressed = false
    @State private var is2nd = Rcl57.shared.is2nd
    @State private var isInv = Rcl57.shared.isInv

    private static func keyPosition(standardizedLocation: CGPoint,
                                    factor: Double) -> (row: Int, col: Int)? {
        // Top left corner of top left key ("2nd").
        let x0 = 5.0 * factor
        let y0 = 10.0 * factor

        // Dimensions of each key.
        let w = 365.0 / 5
        let h = 490 / 8 * factor

        let x = Double(standardizedLocation.x) - x0
        let y = Double(standardizedLocation.y) - y0

        var i = x / w
        var j = y / h

        // If the key press is a near miss, we choose the closest key.
        if i >= -0.2 && j >= -0.15 && i < 5.2 && j < 8.15 {
            if i < 0 { i = 0 }
            if j < 0 { j = 0 }
            if i >= 5 { i = 4 }
            if j >= 8 { j = 7 }
            let col = Int(i)
            let row = Int(j)
            return (row: row, col: col)
        } else {
            return nil
        }
    }

    private func getTrigOffsetY(units: ti57_trig_t, scaleFactor: Double) -> Double {
        switch units {
        case TI57_DEG: return 8.5 * scaleFactor
        case TI57_RAD: return 71 * scaleFactor
        case TI57_GRAD: return 132.5 * scaleFactor
        default: return 0
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let standardCalcWidth = 375.0
            let standardCalcHeight = 497.46

            let width = proxy.size.width
            let height = proxy.size.height

            let scaleFactorH = width / standardCalcWidth
            let scaleFactorV = height / standardCalcHeight

            ZStack {
                // Draw an image representing the keyboard and handle events.
                Image(imageName)
                    .resizable()
                    .gesture(
                        // Handle key press as soon as the user touches the key.
                        DragGesture(minimumDistance: 0)
                            .onChanged {
                                if isKeyPressed { return }
                                let standardizedLocation =
                                    CGPoint(x: $0.location.x / CGFloat(scaleFactorH),
                                            y: $0.location.y / CGFloat(scaleFactorH))
                                // Return if the user taps close to the bottom edge of the screen since
                                // this probably means they are closing the app (by swiping) and not
                                // tapping on a button.
                                if standardizedLocation.y / CGFloat(scaleFactorV / scaleFactorH) > 490 {
                                    return
                                }
                                let c = KeyboardView.keyPosition(
                                    standardizedLocation: standardizedLocation,
                                    factor: scaleFactorV / scaleFactorH)
                                if let c {
                                    isKeyPressed = true
                                    if hasKeyClick {
                                        AudioServicesPlaySystemSound(SystemSoundID(0x450))
                                    }
                                    if hasHaptic {
                                        let feedback = UIImpactFeedbackGenerator(style: .medium)
                                        feedback.impactOccurred()
                                    }
                                    Rcl57.shared.keyPress(row:Int(c.row) + 1, col:Int(c.col) + 1)
                                    // Make sure the key press is registered with the engine.
                                    _ = Rcl57.shared.advance(milliseconds: 50)
                                }
                            }
                            .onEnded { _ in
                                if isKeyPressed {
                                    isKeyPressed = false
                                }
                            }
                    )
                    .onChange(of: scenePhase) { newScenePhase in
                        // Handle the situation where DragGesture.onEnded(:) is not called because
                        // the user is closing the app.
                        if newScenePhase == .inactive {
                            if isKeyPressed {
                                isKeyPressed = false
                            }
                        }
                    }
                    .onChange(of: isKeyPressed) { _ in
                        if isKeyPressed {
                            is2nd = Rcl57.shared.is2nd
                            isInv = Rcl57.shared.isInv
                        } else {
                            Rcl57.shared.keyRelease()
                        }
                    }
                // Draw a border around the `2nd` key if it is engaged.
                if is2nd {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(Color.brown, lineWidth: 4 * CGFloat(scaleFactorV))
                        .offset(x: -141.5 * CGFloat(scaleFactorH), y: -207 * CGFloat(scaleFactorV))
                        .frame(width: 56 * CGFloat(scaleFactorH), height: 39 * CGFloat(scaleFactorV))
                }
                // Draw a border around the `INV` key if it is engaged.
                if isInv {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(Color.brown, lineWidth: 4 * CGFloat(scaleFactorV))
                        .offset(x: -71 * CGFloat(scaleFactorH), y: -207 * CGFloat(scaleFactorV))
                        .frame(width: 56 * CGFloat(scaleFactorH), height: 39 * CGFloat(scaleFactorV))
                }
                // Draw a yellow triangle indicating `deg`, `rad` or `grad`.
                TrigModeIndicator()
                    .fill(Color.brown)
                    .frame(width: 10 * scaleFactorH, height: 9 * scaleFactorH)
                    .offset(x: 174 * scaleFactorH,
                            y: getTrigOffsetY(units: Rcl57.shared.trigUnits, scaleFactor: scaleFactorV))
            }
        }
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardView()
    }
}
