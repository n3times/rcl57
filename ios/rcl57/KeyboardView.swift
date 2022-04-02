import SwiftUI
import AudioToolbox

struct KeyboardView: View {
    private let rcl57: RCL57
    private let imageName = "button_pad"

    @State private var isKeyPressed = false
    @State private var is2nd = false
    @State private var isInv = false
    @State private var trigUnits = TI57_DEG

    init(rcl57: RCL57) {
        self.rcl57 = rcl57
    }

    private static func getCalculatorKey(standardizedLocation: CGPoint) -> CGPoint? {
        // Top left corner of top left key ("2nd").
        let x0 = 0.0
        let y0 = 10.0

        // Dimensions of each key.
        let w = 375.0 / 5
        let h = 496.0 / 8

        let x = Double(standardizedLocation.x) - x0
        let y = Double(standardizedLocation.y) - y0

        var i = x / w
        var j = y / h

        // If the key press is a near miss, we choose the closest key.
        if (i >= -0.2 && j >= -0.15 && i < 5.2 && j < 8.15) {
            if i < 0 { i = 0 }
            if j < 0 { j = 0 }
            if i >= 5 { i = 4 }
            if (j >= 8) { j = 7 }
            let col = Int(i)
            let row = Int(j)
            return CGPoint(x:row, y:col)
        } else {
            return nil
        }
    }

    private func burst() {
        _ = self.rcl57.advance(ms: 20)
        self.is2nd = self.rcl57.is2nd()
        self.isInv = self.rcl57.isInv()
        self.trigUnits = self.rcl57.getTrigUnits()
    }

    private func getTrigIndicatorView(trigUnits: ti57_trig_t, scaleFactor: Double) -> some View {
        let x = 368.0
        var y = 0.0
        switch (trigUnits) {
        case TI57_DEG: y = 256; break
        case TI57_RAD: y = 318; break
        case TI57_GRAD: y = 380; break
        default: break
        }
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 8, y: -5))
            path.addLine(to: CGPoint(x: 8, y: 5))
        }
        .offset(x: x * scaleFactor, y: y * scaleFactor)
        .fill(Color.brown)
    }

    private func getView(_ geometry: GeometryProxy) -> some View {
        let standardCalcWidth = 375.0

        let calcWidth =  geometry.size.width

        let scaleFactor = calcWidth / standardCalcWidth

        return ZStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .gesture(
                    // Handle key presses as soon as the user touches the screen.
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged {
                            if self.isKeyPressed { return }
                            let standardizedLocation =
                                CGPoint(x: $0.location.x / CGFloat(scaleFactor),
                                        y: $0.location.y / CGFloat(scaleFactor))
                            let c = KeyboardView.getCalculatorKey(
                                standardizedLocation: standardizedLocation)
                            if c != nil {
                                AudioServicesPlaySystemSound(SystemSoundID(0x450))
                                self.isKeyPressed = true;
                                burst()
                                self.rcl57.keyPress(row:Int32(c!.x + 1), col:Int32(c!.y + 1))
                            }
                        }
                        .onEnded { _ in
                            if self.isKeyPressed {
                                self.isKeyPressed = false
                                burst()
                                self.rcl57.keyRelease()
                            }
                        }
                )
            if is2nd {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(Color.brown,lineWidth: 4 * CGFloat(scaleFactor))
                    .offset(x: -152 * CGFloat(scaleFactor), y: -207 * CGFloat(scaleFactor))
                    .frame(width: 56 * CGFloat(scaleFactor), height: 39 * CGFloat(scaleFactor))
            }
            if isInv {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(Color.brown,lineWidth: 4 * CGFloat(scaleFactor))
                    .offset(x: -77 * CGFloat(scaleFactor), y: -207 * CGFloat(scaleFactor))
                    .frame(width: 56 * CGFloat(scaleFactor), height: 39 * CGFloat(scaleFactor))
            }
            getTrigIndicatorView(trigUnits: trigUnits, scaleFactor: scaleFactor)
        }
    }

    var body: some View {
        return GeometryReader { geometry in
            self.getView(geometry)
        }
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardView(rcl57: RCL57())
    }
}
