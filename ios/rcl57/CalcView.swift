import SwiftUI
import AudioToolbox

// The main view. It holds the calculator with its keyboard and display. It listens to key presses
// events and runs the animation loop.
struct CalcView: View {
    private let penta7: Penta7

    @State private var displayText = ""
    @State private var isKeyPressed = false
    @State private var imageName = "button_pad"
    @State private var is2nd = false
    @State private var isInv = false

    @State private var isHPStyleLRN: Bool
    @State private var isAlphanumericLRN: Bool
    @State private var isTurboMode: Bool

    init(penta7: Penta7) {
        self.penta7 = penta7

        isHPStyleLRN = penta7.getOptionFlag(option: PENTA7_HP_LRN_MODE_FLAG)
        isAlphanumericLRN = penta7.getOptionFlag(option: PENTA7_ALPHANUMERIC_LRN_MODE_FLAG)
        isTurboMode = penta7.getSpeedup() == 1000
    }

    private static func getCalculatorKey(standardizedLocation: CGPoint) -> CGPoint? {
        // Top left corner of top left key ("2nd").
        let x0 = 0.0
        let y0 = 196.0

        // Dimensions of each key.
        let w = 75.0
        let h = 61.2

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
    
    static var isAnimating = false

    private func runDisplayAnimationLoop() {
        if CalcView.isAnimating { return }
        CalcView.isAnimating = true
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { timer in
            _ = self.penta7.advance(ms: 20)
            self.displayText = self.penta7.display()
            self.is2nd = self.penta7.is2nd()
            self.isInv = self.penta7.isInv()
        })
    }

    private func setOption(option: Int32, value: Bool) {
        self.penta7.setOptionFlag(option: option, value: value)
        self.displayText = self.penta7.display()
    }

    private func getView(_ metrics: GeometryProxy) -> some View {
        let standardCalcWidth = 375.0
        let standardCalcHeight = 682.0
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
                .aspectRatio(contentMode: .fit)
                .frame(width: CGFloat(calcWidth), height: CGFloat(calcHeight), alignment: .bottom)
                .gesture(
                    // Handle key presses as soon as the user touches the screen.
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged {
                            if self.isKeyPressed { return }
                            let standardizedLocation =
                                CGPoint(x: $0.location.x / CGFloat(scaleFactor),
                                        y: $0.location.y / CGFloat(scaleFactor))
                            let c = CalcView.getCalculatorKey(
                                standardizedLocation: standardizedLocation)
                            if c != nil {
                                AudioServicesPlaySystemSound(SystemSoundID(0x450))
                                self.isKeyPressed = true;
                                runDisplayAnimationLoop()
                                self.penta7.keyPress(row:Int32(c!.x), col:Int32(c!.y))
                                self.displayText = self.penta7.display()
                            }
                        }
                        .onEnded {_ in
                            if self.isKeyPressed {
                                self.isKeyPressed = false
                                runDisplayAnimationLoop()
                                self.penta7.keyRelease()
                                self.displayText = self.penta7.display()
                            }
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
                    self.displayText = self.penta7.display()
                    self.runDisplayAnimationLoop()
                }
            if is2nd {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(Color.brown,lineWidth: 4)
                    .offset(x: -152, y: -115)
                    .frame(width: 56, height: 39)
            }
            if isInv {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(Color.brown, lineWidth: 4)
                    .offset(x: -77, y: -115)
                    .frame(width: 56, height: 39)
            }
            Menu("Options") {
                Button("Clear", action: {
                    penta7.clear()
                    runDisplayAnimationLoop()
                    self.displayText = self.penta7.display()
                })
                Toggle("Turbo Mode", isOn: $isTurboMode)
                    .onChange(of: isTurboMode) {_ in
                        if isTurboMode {
                            penta7.setSpeedup(speedup: 1000)
                        } else {
                            penta7.setSpeedup(speedup: 1)
                        }
                        setOption(option: PENTA7_SHORT_PAUSE_FLAG, value: isTurboMode)
                        setOption(option: PENTA7_FASTER_TRACE_FLAG, value: isTurboMode)
                        setOption(option: PENTA7_QUICK_STOP_FLAG, value: isTurboMode)
                        setOption(option: PENTA7_SHOW_RUN_INDICATOR_FLAG, value: isTurboMode)
                    }
                Toggle("HP-style LRN Mode", isOn: $isHPStyleLRN)
                    .onChange(of: isHPStyleLRN) {
                        _ in setOption(option: PENTA7_HP_LRN_MODE_FLAG, value: isHPStyleLRN)}
                Toggle("Alphanumeric LRN Mode", isOn: $isAlphanumericLRN)
                    .onChange(of: isAlphanumericLRN) {
                        _ in setOption(option: PENTA7_ALPHANUMERIC_LRN_MODE_FLAG,
                                       value: isAlphanumericLRN)}
            }
            .padding(10)
            .background(Color.gray)
            .foregroundColor(Color.white)
            .offset(x: -128, y: -315)
            .font(.title)
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
        CalcView(penta7: Penta7())
    }
}
