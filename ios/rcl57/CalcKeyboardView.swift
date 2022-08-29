import SwiftUI
import AudioToolbox

struct TrigIndicator: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                path.move(to: CGPoint(x: 0, y: height / 2))
                path.addLine(to: CGPoint(x: width, y: 0))
                path.addLine(to: CGPoint(x: width, y: height))
            }
            .fill(Color.brown)
        }
    }
}

/**
 * The keyboard view. It also interacts with the engine when keys are pressed and released.
 */
struct CalcKeyboardView: View {
    private let imageName = "button_pad"

    @State private var isKeyPressed = false
    @State private var is2nd: Bool
    @State private var isInv: Bool

    @GestureState private var dragGestureActive: Bool = false

    @EnvironmentObject var change: Change

    init() {
        self.is2nd = Rcl57.shared.is2nd()
        self.isInv = Rcl57.shared.isInv()
    }

    private static func getCalculatorKey(standardizedLocation: CGPoint,
                                         factor: Double) -> CGPoint? {
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
            return CGPoint(x:row, y:col)
        } else {
            return nil
        }
    }

    private func getTrigOffsetY(units: ti57_trig_t, scaleFactor: Double) -> Double {
        switch (units) {
        case TI57_DEG: return 8.5 * scaleFactor
        case TI57_RAD: return 71 * scaleFactor
        case TI57_GRAD: return 132.5 * scaleFactor
        default: return 0
        }
    }

    private func getView(_ geometry: GeometryProxy) -> some View {
        let standardCalcWidth = 375.0
        let standardCalcHeight = 497.46

        let width = geometry.size.width
        let height = geometry.size.height

        let scaleFactorH = width / standardCalcWidth
        let scaleFactorV = height / standardCalcHeight

        return ZStack {
            Image(imageName)
                .resizable()
                .gesture(
                    // Handle key presses as soon as the user touches the screen.
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged {
                            if dragGestureActive { return }
                            let standardizedLocation =
                                CGPoint(x: $0.location.x / CGFloat(scaleFactorH),
                                        y: $0.location.y / CGFloat(scaleFactorH))
                            // Return if the user taps close to the bottom edge of the screen since
                            // this probably means they are closing the app (by swiping) and not
                            // tapping on a button.
                            if standardizedLocation.y / CGFloat(scaleFactorV / scaleFactorH) > 490 {
                                return
                            }
                            let c = CalcKeyboardView.getCalculatorKey(
                                standardizedLocation: standardizedLocation,
                                factor: scaleFactorV / scaleFactorH)
                            if c != nil {
                                isKeyPressed = true
                                if Settings.hasKeyClick() {
                                    AudioServicesPlaySystemSound(SystemSoundID(0x450))
                                }
                                if Settings.hasHaptic() {
                                    let feedback = UIImpactFeedbackGenerator(style: .medium)
                                    feedback.impactOccurred()
                                }
                                Rcl57.shared.keyPress(row:Int(c!.x) + 1, col:Int(c!.y) + 1)
                                // Make sure the key press is registered with the engine.
                                _ = Rcl57.shared.advance(ms: 50)
                            }

                        }
                        .updating($dragGestureActive) { value, state, transaction in
                            state = true
                        }
                )
                .onChange(of: dragGestureActive) { isActive in
                    // Handle key release here instead of "onEnded" to make sure we always release
                    // the key even when closing the app.
                    if isActive == false {
                        if isKeyPressed {
                            isKeyPressed = false
                            is2nd = Rcl57.shared.is2nd()
                            isInv = Rcl57.shared.isInv()
                            Rcl57.shared.keyRelease()
                            change.updateLogTimestamp()
                        }
                    }
                }
            if is2nd {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(Color.brown,lineWidth: 4 * CGFloat(scaleFactorV))
                    .offset(x: -141.5 * CGFloat(scaleFactorH), y: -207 * CGFloat(scaleFactorV))
                    .frame(width: 56 * CGFloat(scaleFactorH), height: 39 * CGFloat(scaleFactorV))
            }
            if isInv {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(Color.brown,lineWidth: 4 * CGFloat(scaleFactorV))
                    .offset(x: -71 * CGFloat(scaleFactorH), y: -207 * CGFloat(scaleFactorV))
                    .frame(width: 56 * CGFloat(scaleFactorH), height: 39 * CGFloat(scaleFactorV))
            }
            TrigIndicator()
                .frame(width: 10 * scaleFactorH, height: 9 * scaleFactorH)
                .offset(x: 174 * scaleFactorH,
                        y: getTrigOffsetY(units: Rcl57.shared.getTrigUnits(), scaleFactor: scaleFactorV))
        }
    }

    var body: some View {
        GeometryReader { geometry in
            getView(geometry)
        }
    }
}

struct CalcKeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        CalcKeyboardView()
    }
}
