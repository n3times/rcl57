/**
 * Interface to the emulator.
 */

import SwiftUI

struct LogEntry {
    let entry: UnsafeMutablePointer<log57_entry_t>

    init(entry: UnsafeMutablePointer<log57_entry_t>) {
        self.entry = entry
    }

    func getMessage() -> String {
        return String(cString: UnsafeRawPointer(&entry.pointee.message).assumingMemoryBound(to: CChar.self))
    }

    func getType() -> log57_type_t {
        return entry.pointee.type
    }

    func getFlags() -> Int32 {
        return entry.pointee.flags
    }
}

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

    /** Returns the calculator display as a string. */
    func display() -> String {
        return String(cString: rcl57_get_display(&rcl57))
    }

    /** Should be called whenever the user presses a calculator key (row in 1..8 and col in 1..5). */
    func keyPress(row: Int, col: Int) {
        rcl57_key_press(&rcl57, Int32(row), Int32(col))
    }

    /** Should be called whenever the user releases a calculator key. */
    func keyRelease() {
        rcl57_key_release(&rcl57)
    }

    /** Runs the emulator for 'ms' ms. */
    func advance(ms: Int32) -> Bool {
        return rcl57_advance(&rcl57, ms)
    }

    /** Whether the 2nd key is engaged. */
    func is2nd() -> Bool {
        return ti57_is_2nd(&rcl57.ti57)
    }

    /** Whether the INV key is engaged. */
    func isInv() -> Bool {
        return ti57_is_inv(&rcl57.ti57)
    }

    /**
     * The current units in trigonometric mode.
     */
    func getTrigUnits() -> ti57_trig_t {
        return ti57_get_trig(&rcl57.ti57)
    }

    /** Saves the RCL57 object in a given file. Returns 'true' if the object was saved successfully. */
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

    /* Returns true if a given option flag is set. */
    func getOptionFlag(option: Int32) -> Bool {
        return rcl57.options & option != 0
    }

    /* Sets or clears a given option flag. */
    func setOptionFlag(option: Int32, value: Bool) {
        if value {
            rcl57.options |= option
        } else {
            rcl57.options &= ~option
        }
    }

    /**  */
    func getSpeedup() -> UInt32 {
        return rcl57.speedup
    }

    /** */
    func setSpeedup(speedup: UInt32) {
        rcl57.speedup = speedup
    }

    /** Clears the state, only preserving the options. */
    func clearAll() {
        rcl57_clear(&rcl57)
    }

    /**
     * LOGGING.
     */

    /** Clears the log. */
    func clearLog() {
        log57_reset(&rcl57.ti57.log)
    }

    /** Returns the number of logged items since reset. */
    func getLoggedCount() -> Int {
        return log57_get_logged_count(&rcl57.ti57.log)
    }

    /**
     * The log entry at a given index.
     *
     * 'index' should be between max(1, logged_count - LOG57_MAX_ENTRY_COUNT + 1) and logged_count.
     */
    func getLogEntry(index: Int) -> LogEntry {
        return LogEntry(entry: log57_get_entry(&rcl57.ti57.log, index))
    }

    /** The current operation in EVAL mode. */
    func currentOp() -> String {
        return String(cString: log57_get_current_op(&rcl57.ti57.log))
    }

    /** Returns a timestamp that can be used to find out whether the log has been updated. */
    func getLogTimestamp() -> Int {
        return rcl57.ti57.log.timestamp;
    }

    func getProgramOp(index: Int, isAlpha: Bool) -> String {
        let op = ti57_get_program_op(&rcl57.ti57, Int32(index))!;

        let isInv = op.pointee.inv
        let key = op.pointee.key
        let keyName = isAlpha ? String(cString: key57_get_unicode_name(key))
                              : String(format: "%02d", (key >> 4) * 10 + (key & 0x0f))
        let d = op.pointee.d
        var suffix = ""
        if d >= 0 {
            suffix = " " + String(d)
        }
        if (ti57_is_op_edit_in_lrn(&rcl57.ti57) && index == ti57_get_program_pc(&rcl57.ti57)) {
            suffix = " _"
        }

        return (isInv ? (isAlpha ? "INV " : "-") : "") + keyName + suffix
    }

    /** Returns the index of the first non-zero step, or -1 if none,*/
    func getProgramLastIndex() -> Int {
        return Int(ti57_get_program_last_index(&rcl57.ti57))
    }

    /**
     * Returns the program counter (-1..49 ), taking into account whether the mode is "HP lrn" or not.
     * -1 if pc is at the beginning of the program in HP lrn mode.
     */
    func getProgramPc() -> Int {
        return Int(rcl57_get_program_pc(&rcl57))
    }

    func isLrnMode() -> Bool {
        return ti57_get_mode(&rcl57.ti57) == TI57_LRN
    }

    func isOpEditInLrn() -> Bool {
        ti57_is_op_edit_in_lrn(&rcl57.ti57)
    }
}
