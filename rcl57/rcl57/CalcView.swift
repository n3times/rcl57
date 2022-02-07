import SwiftUI
import AudioToolbox

// The main view. It holds the calculator with its keyboard and display. It listens to key presses
// events and runs the animation loop.
struct CalcView: View {
    private let pentaSeven: Penta7
    @State private var displayText = "READY"
    @State private var isTapped = false
    @State private var imageName = "pentaseven"

    init(pentaSeven: Penta7) {
        self.pentaSeven = pentaSeven
    }

    private static func getCalculatorKey(standardizedLocation: CGPoint) -> CGPoint? {
        // Top left corner of top left key ("?").
        let x0 = 28.0
        let y0 = 209.0

        // Dimensions of each key.
        let w = 54.4
        let h = 40.8

        // Separation between keys.
        let interX = 13.2
        let interY = 12.8

        let x = Double(standardizedLocation.x) - x0
        let y = Double(standardizedLocation.y) - y0

        var i = (x + interX / 2) / (w + interX)
        var j = (y + interY / 2) / (h + interY)

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
    
    static var on = false

    private func runDisplayAnimationLoop() {
        if (CalcView.on) {
            return
        }
        CalcView.on = true
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { timer in
            NSLog("--")
            self.pentaSeven.advance()
            self.displayText = self.pentaSeven.display()
            self.imageName = self.pentaSeven.is2nd() ? "secondary" : "primary"
        })
    }

    private func getView(_ metrics: GeometryProxy) -> some View {
        let standardCalcWidth = 375.0
        let standardCalcHeight = 647.0
        let standardDisplayHeight = 96.0
        let standardDisplayOffsetY = 95.0

        let screenWidth = Double(metrics.size.width)
        let screenHeight = Double(metrics.size.height)

        let screenAspectRatio = screenHeight / screenWidth
        let calcAspectRatio = standardCalcHeight / standardCalcWidth
        let isPortrait = screenAspectRatio >= calcAspectRatio

        let calcWidth = isPortrait ? screenWidth : screenHeight / calcAspectRatio
        let calcHeight = isPortrait ? screenWidth * calcAspectRatio : screenHeight

        let scaleFactor = calcWidth / standardCalcWidth

        let displayWidth = calcWidth
        let displayHeight = standardDisplayHeight * scaleFactor

        let displayOffsetX = CGFloat(0.0)
        let displayOffsetY =
            (standardDisplayOffsetY - (standardCalcHeight - standardDisplayHeight)/2) * scaleFactor

        return ZStack {
            Color(red: 16.0/255, green: 16.0/255, blue: 16.0/255).edgesIgnoringSafeArea(.all)
            Image(imageName)
                .resizable()
                .frame(width: CGFloat(calcWidth), height: CGFloat(calcHeight), alignment: .center)
                .gesture(
                    // To be responsive, handle key presses as soon as the user touches the screen,
                    // instead of waiting until the user lifts the finger/stylus.
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged {
                            if (self.isTapped) { return; }
                            let standardizedLocation =
                                CGPoint(x: $0.location.x / CGFloat(scaleFactor),
                                        y: $0.location.y / CGFloat(scaleFactor))
                            let c = CalcView.getCalculatorKey(
                                standardizedLocation: standardizedLocation)
                            if c != nil {
                                AudioServicesPlaySystemSound(SystemSoundID(0x450))
                                self.isTapped = true;
                                self.pentaSeven.pressKey(row:Int32(c!.x), col:Int32(c!.y))
                                self.displayText = self.pentaSeven.display()
                                self.pentaSeven.advance()
                            }
                        }
                        .onEnded {_ in
                            if (self.isTapped) {
                                self.pentaSeven.pressRelease()
                                self.pentaSeven.advance()
                            }
                            self.isTapped = false
                        }
                )
                .accessibility(identifier: "calculator")
                .accessibility(label: Text(self.displayText))
            LEDView(self.displayText)
                .offset(x: CGFloat(displayOffsetX), y: CGFloat(displayOffsetY))
                .frame(width: CGFloat(displayWidth),
                       height: CGFloat(displayHeight),
                       alignment: .center)
                .onAppear {
                    self.displayText = self.pentaSeven.display()
                    self.runDisplayAnimationLoop()
                }
        }
    }

    var body: some View {
        return GeometryReader { metrics in
            self.getView(metrics)
        }
    }
}

struct CalcView_Previews: PreviewProvider {
    static var previews: some View {
        CalcView(pentaSeven: Penta7())
    }
}
