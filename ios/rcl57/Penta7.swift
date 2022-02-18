import Foundation

// The Penta7 object used to run the emulator.
class Penta7 {
    var p7 = penta7_t()

    init() {
        let options = PENTA7_FASTER_PAUSE_FLAG |
                      PENTA7_FAST_STOP_WHEN_RUNNING_FLAG |
                      PENTA7_SHOW_INDICATOR_WHEN_RUNNING_FLAG;
        
        penta7_init(&p7)
        penta7_set_options(&p7,options);
    }

    deinit {
    }

    // Returns the calculator display.
    func display() -> String {
        return String(cString: penta7_get_display(&p7))
    }

    // Should be called whenever the user presses a calculator key.
    func pressKey(row: Int32, col: Int32) {
        penta7_key_press(&p7, row, col)
    }

    // Should be called whenever the user releases a calculator key.
    func pressRelease() {
        penta7_key_release(&p7)
    }

    // Should be called every 50ms.
    func advance() {
        penta7_advance(&p7, 50, 1000)
    }

    // Whether the 2nd key is engaged.
    func is2nd() -> Bool {
        return ti57_is_2nd(&p7.ti57)
    }

    // Whether the INV key is engaged.
    func isInv() -> Bool {
        return ti57_is_inv(&p7.ti57)
    }
}
