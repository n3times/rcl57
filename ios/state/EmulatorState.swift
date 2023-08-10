import SwiftUI;
import Combine

/// Runs the emulator and allows for observing changes to its state.
class EmulatorState: ObservableObject {
    // MARK: Timer

    /// We run the emulator by short bursts. Each burst emulates running the actual TI-57 for a
    /// short period of time. In practice the emulator takes much less time to execute the burst.
    private static let burstMilliseconds = 20

    /// Timer that runs the emulator.
    private let timer = Timer.publish(
        every: Double(burstMilliseconds) / 1000,
        on: .main,
        in: .default
    ).autoconnect()

    /// Used to cancel the timer.
    private var timerCancellable: AnyCancellable?

    
    // MARK: State

    // Note that SwiftUI can't observe directly changes to the C emulator state. The relevant
    // state gets updated after every burst.

    /// The display, updated once per burst.
    @Published private(set) var displayString = Rcl57.shared.display

    /// The log timestamp, updated once per burst.
    @Published private(set) var logTimestamp = Log57.shared.logTimestamp


    init() {
        self.timerCancellable = timer
            .sink { _ in
                _ = Rcl57.shared.advance(milliseconds: Int32(EmulatorState.burstMilliseconds))
                if self.displayString != Rcl57.shared.display {
                    self.displayString = Rcl57.shared.display
                }
                if self.logTimestamp != Log57.shared.logTimestamp {
                    self.logTimestamp = Log57.shared.logTimestamp
                }
            }
    }

    deinit {
        self.timerCancellable?.cancel()
    }
}
