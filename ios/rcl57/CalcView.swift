import SwiftUI
import AudioToolbox

// The main view. It holds the calculator with its keyboard and display. It listens to key presses
// events and runs the animation loop.
struct CalcView: View {
    private let penta7: Penta7
    @State private var displayText = ""
    @State private var isTapped = false
    @State private var imageName = "button_pad"
    @State private var is2nd = false
    @State private var isInv = false

    @State private var hpStyleOn: Bool
    @State private var mnemonicsOn: Bool
    @State private var fastPauseOn: Bool
    @State private var fastTraceOn: Bool
    @State private var fastStopOn: Bool
    @State private var runIndicatorOn: Bool
    @State private var showArithmeticOn: Bool

    init(penta7: Penta7) {
        self.penta7 = penta7

        hpStyleOn = penta7.getOption(option: PENTA7_HP_LRN_MODE_FLAG)
        mnemonicsOn = penta7.getOption(option: PENTA7_MNEMONICS_LRN_MODE_FLAG)
        fastPauseOn = penta7.getOption(option: PENTA7_FASTER_PAUSE_FLAG)
        fastTraceOn = penta7.getOption(option: PENTA7_FASTER_TRACE_FLAG)
        fastStopOn = penta7.getOption(option: PENTA7_FAST_STOP_FLAG)
        runIndicatorOn = penta7.getOption(option: PENTA7_SHOW_RUN_INDICATOR_FLAG)
        showArithmeticOn = penta7.getOption(option: PENTA7_DISPLAY_ARITHMETIC_OPERATORS_FLAG)
    }

    private static func getCalculatorKey(standardizedLocation: CGPoint) -> CGPoint? {
        // Top left corner of top left key ("?").
        let x0 = 28.0
        let y0 = 209.0

        // Dimensions of each key.
        let w = 54.4
        let h = 47.8

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
            self.penta7.advance()
            self.displayText = self.penta7.display()
            self.is2nd = self.penta7.is2nd()
            self.isInv = self.penta7.isInv()
        })
    }

    private func toggleOption(option: Int32) {
        let currentOption = self.penta7.getOption(option: option)
        self.penta7.setOption(option: option, value: !currentOption)
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
                                self.penta7.pressKey(row:Int32(c!.x), col:Int32(c!.y))
                                self.displayText = self.penta7.display()
                                self.penta7.advance()
                            }
                        }
                        .onEnded {_ in
                            if (self.isTapped) {
                                self.penta7.pressRelease()
                                self.penta7.advance()
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
                Button("HP-style LRN mode " + (hpStyleOn ? "ON" : "OFF"), action: {
                    toggleOption(option: PENTA7_HP_LRN_MODE_FLAG)
                    hpStyleOn = penta7.getOption(option: PENTA7_HP_LRN_MODE_FLAG)
                })
                Button("Mnemonics in LRN " + (mnemonicsOn ? "ON" : "OFF"), action: {
                    toggleOption(option: PENTA7_MNEMONICS_LRN_MODE_FLAG)
                    mnemonicsOn = penta7.getOption(option: PENTA7_MNEMONICS_LRN_MODE_FLAG)
                })
                Button("Fast Pause " + (fastPauseOn ? "ON" : "OFF"), action: {
                    toggleOption(option: PENTA7_FASTER_PAUSE_FLAG)
                    fastPauseOn = penta7.getOption(option: PENTA7_FASTER_PAUSE_FLAG)
                })
                Button("Fast Trace " + (fastTraceOn ? "ON" : "OFF"), action: {
                    toggleOption(option: PENTA7_FASTER_TRACE_FLAG)
                    fastPauseOn = penta7.getOption(option: PENTA7_FASTER_TRACE_FLAG)
                })
                Button("Fast Stop " + (fastStopOn ? "ON" : "OFF"), action: {
                    toggleOption(option: PENTA7_FAST_STOP_FLAG)
                    fastStopOn = penta7.getOption(option: PENTA7_FAST_STOP_FLAG)
                })
                Button("Show RUN Indicator " + (runIndicatorOn ? "ON" : "OFF"), action: {
                    toggleOption(option: PENTA7_SHOW_RUN_INDICATOR_FLAG)
                    runIndicatorOn = penta7.getOption(option: PENTA7_SHOW_RUN_INDICATOR_FLAG)
                })
                Button("Display Arithmetic " + (showArithmeticOn ? "ON" : "OFF"), action: {
                    toggleOption(option: PENTA7_DISPLAY_ARITHMETIC_OPERATORS_FLAG)
                    showArithmeticOn =
                        penta7.getOption(option: PENTA7_DISPLAY_ARITHMETIC_OPERATORS_FLAG)
                })

            }
            .padding(4)
            .background(Color.gray)
            .foregroundColor(Color.white)
            .offset(x: -142, y: -315)
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
