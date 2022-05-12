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

struct KeyboardView: View {
    let rcl57: RCL57
    private let imageName = "button_pad"

    @State private var isKeyPressed = false
    @State private var is2nd = false
    @State private var isInv = false
    @State private var trigUnits = TI57_DEG

    @EnvironmentObject var change: Change

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
        self.change.update()
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
                            if self.isKeyPressed { return }
                            let standardizedLocation =
                                CGPoint(x: $0.location.x / CGFloat(scaleFactorH),
                                        y: $0.location.y / CGFloat(scaleFactorH))
                            let c = KeyboardView.getCalculatorKey(
                                standardizedLocation: standardizedLocation,
                                factor: scaleFactorV / scaleFactorH)
                            if c != nil {
                                AudioServicesPlaySystemSound(SystemSoundID(0x450))
                                self.isKeyPressed = true;
                                burst()
                                self.rcl57.keyPress(row:Int(c!.x) + 1, col:Int(c!.y) + 1)
                                burst()
                                self.change.update()
                            }
                        }
                        .onEnded { _ in
                            if self.isKeyPressed {
                                self.isKeyPressed = false
                                burst()
                                self.rcl57.keyRelease()
                                burst()
                                self.change.update()
                            }
                        }
                )
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
                        y: getTrigOffsetY(units: rcl57.getTrigUnits(), scaleFactor: scaleFactorV))
        }
    }

    var body: some View {
        GeometryReader { geometry in
            self.getView(geometry)
        }
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardView(rcl57: RCL57())
    }
}
