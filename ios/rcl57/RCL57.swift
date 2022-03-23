import Foundation
import CoreText
import SwiftUI

// The RCL57 object used to run the emulator.
class RCL57 {
    private var rcl57 = rcl57_t()

    init() {
        let options = RCL57_FASTER_TRACE_FLAG |
                      RCL57_SHORT_PAUSE_FLAG |
                      RCL57_QUICK_STOP_FLAG |
                      RCL57_SHOW_RUN_INDICATOR_FLAG;
        
        rcl57_init(&rcl57)
        rcl57.options = options
        rcl57.speedup = 1000;
    }

    // Initializes a RCL57 object from the state stored in a given file.
    // Returns nil if the object was not successfully initialized.
    init?(filename: String) {
        var fileRawData: Data?
        var fileRawBuffer: UnsafePointer<Int8>?
        let dirURL: URL? =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL: URL? = dirURL?.appendingPathComponent(filename)

        if fileURL == nil {
            return nil
        }
        do {
            try fileRawData = Data(contentsOf: fileURL!)
        } catch {
            return nil
        }
        if fileRawData == nil {
            return nil
        }
        fileRawBuffer = fileRawData!.withUnsafeBytes({
            (ptr) -> UnsafePointer<Int8> in
            return ptr.baseAddress!.assumingMemoryBound(to: Int8.self)
        })
        if fileRawBuffer == nil {
            return nil
        }
        memcpy(&rcl57, fileRawBuffer, MemoryLayout.size(ofValue: rcl57))
    }

    // Returns the calculator display.
    func display() -> String {
        return String(cString: rcl57_get_display(&rcl57))
    }

    // Should be called whenever the user presses a calculator key.
    // row in 1..8 and col in 1..5
    func keyPress(row: Int32, col: Int32) {
        rcl57_key_press(&rcl57, row, col)
    }

    // Should be called whenever the user releases a calculator key.
    func keyRelease() {
        rcl57_key_release(&rcl57)
    }

    // Should be called every 'ms' ms.
    func advance(ms: Int32) -> Bool {
        return rcl57_advance(&rcl57, ms)
    }

    // Whether the 2nd key is engaged.
    func is2nd() -> Bool {
        return ti57_is_2nd(&rcl57.ti57)
    }

    // Whether the INV key is engaged.
    func isInv() -> Bool {
        return ti57_is_inv(&rcl57.ti57)
    }

    // Saves the RCL57 object in a given file. Returns 'true' if the object was saved
    // successfully.
    func save(filename: String) -> Bool {
        let size = MemoryLayout.size(ofValue: rcl57)
        let rawData = Data(bytes: &rcl57, count: size)
        let dirURL: URL? =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL: URL? = dirURL?.appendingPathComponent(filename)

        if fileURL != nil {
            do {
                try rawData.write(to: fileURL!, options: .atomic)
                return true
            } catch {
                // Nothing
            }
        }
        return false
    }

    // Returns true if a given option flag is set.
    func getOptionFlag(option:Int32) -> Bool {
        return rcl57.options & option != 0
    }

    // Sets or clears a given option flag.
    func setOptionFlag(option: Int32, value: Bool) {
        if value {
            rcl57.options |= option
        } else {
            rcl57.options &= ~option
        }
    }

    func getSpeedup() -> UInt32 {
        return rcl57.speedup
    }

    func setSpeedup(speedup: UInt32) {
        rcl57.speedup = speedup
    }

    // Clears the state, only preserving the options.
    func clearAll() {
        rcl57_clear(&rcl57)
    }

    /**
     * LOGGING.
     */

    func currentOp() -> String {
        return String(cString: log57_get_current_op(&rcl57.ti57.log))
    }

    func getLoggedCount() -> Int {
        return log57_get_logged_count(&rcl57.ti57.log)
    }

    func getLogMessage(index: Int) -> String {
        let message = log57_get_message(&rcl57.ti57.log, index)!
        return String(cString: message)
    }

    func getLogType(index: Int) -> log57_type_t {
        return log57_get_type(&rcl57.ti57.log, index)
    }

    func getLogTimestamp() -> Int {
        return rcl57.ti57.log.timestamp;
    }

    // Clears the log.
    func clearLog() {
        log57_reset(&rcl57.ti57.log)
    }
}
