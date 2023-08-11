import SwiftUI;
import Combine

/// Runs the emulator and allows subscribers to observe changes to its state.
class EmulatorState: ObservableObject {
    // MARK: Timer

    /// We run the emulator by short bursts. Each burst emulates running the actual TI-57 for a
    /// short period of time. In practice the emulator takes much less time to execute the burst.
    private static let burstMilliseconds: Int32 = 20

    /// Timer that runs the emulator.
    private let timer = Timer.publish(
        every: Double(burstMilliseconds) / 1000,
        on: .main,
        in: .default
    ).autoconnect()

    /// Used to cancel the timer.
    private var timerCancellable: AnyCancellable?

    
    // MARK: Published Properties.

    // Note that SwiftUI can't observe directly changes to the C emulator state. The relevant
    // state gets updated after every burst.

    /// The calculator display.
    @Published private(set) var displayString = Rcl57.shared.display

    /// The user registers.
    @Published private(set) var registers: [String] =
        [String](repeating: "", count: Rcl57.shared.registerCount)

    /// Whether all registers are cleared.
    @Published private(set) var isRegistersAllClear = Rcl57.shared.registersLastIndex < 0

    /// The program steps.
    @Published private(set) var steps: [String] =
        [String](repeating: "", count: Rcl57.shared.stepCount)

    /// Whether all steps are cleared.
    @Published private(set) var isStepsAllClear = Rcl57.shared.stepsLastIndex < 0

    /// The log timestamp, incremented whenever the log changes.
    @Published private(set) var logTimestamp = Log57.shared.logTimestamp

    /// The current operation
    @Published private(set) var currentOp: String = ""

    /// Whether the log is empty.
    @Published private(set) var isLogEmpty = Log57.shared.entryCount == 0


    init() {
        self.timerCancellable = timer
            .sink { _ in
                _ = Rcl57.shared.advance(milliseconds: EmulatorState.burstMilliseconds)
                if self.displayString != Rcl57.shared.display {
                    self.displayString = Rcl57.shared.display
                }

                for i in 0..<Rcl57.shared.registerCount {
                    let reg = Rcl57.shared.register(atIndex: i)
                    if reg != self.registers[i] {
                        self.registers[i] = reg
                    }
                }
                if self.isRegistersAllClear != (Rcl57.shared.registersLastIndex < 0) {
                    self.isRegistersAllClear = Rcl57.shared.registersLastIndex < 0
                }

                for i in 0..<Rcl57.shared.stepCount {
                    let step = Rcl57.shared.step(atIndex: i, isAlpha: true)
                    if step != self.steps[i] {
                        self.steps[i] = step
                    }
                }
                if self.isStepsAllClear != (Rcl57.shared.stepsLastIndex < 0) {
                    self.isStepsAllClear = Rcl57.shared.stepsLastIndex < 0
                }

                if self.logTimestamp != Log57.shared.logTimestamp {
                    self.logTimestamp = Log57.shared.logTimestamp
                }
                if self.currentOp != Log57.shared.currentOp {
                    self.currentOp = Log57.shared.currentOp
                }
                if self.isLogEmpty != (Log57.shared.entryCount == 0) {
                    self.isLogEmpty = Log57.shared.entryCount == 0
                }
            }
    }

    deinit {
        self.timerCancellable?.cancel()
    }
}
