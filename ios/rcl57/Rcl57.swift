/**
 * Interface to the emulator.
 */

import Foundation

struct LogEntry {
    let entry: UnsafeMutablePointer<log57_entry_t>

    func getMessage() -> String {
        let message = withUnsafePointer(to: entry.pointee.message) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                String(cString: $0)
            }
        }
        return message
    }

    func getType() -> log57_type_t {
        return entry.pointee.type
    }

    func getFlags() -> Int32 {
        return entry.pointee.flags
    }
}

class Rcl57 {
    private static let stateFilename = "rcl57.dat"
    private static let versionKey = "version"
    static let version = "beta 2"

    static let shared = Rcl57(filename: stateFilename)

    var rcl57 = rcl57_t()

    init() {
        rcl57_init(&rcl57)
    }

    // Initializes a RCL57 object from the state stored in a given file.
    init(filename: String) {
        var fileRawData: Data?
        var fileRawBuffer: UnsafePointer<Int8>?
        let dirURL: URL? =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        var fileURL: URL? = dirURL?.appendingPathComponent(filename)

        let version = UserDefaults.standard.string(forKey: Rcl57.versionKey)
        if version != Rcl57.version {
            do {
                try FileManager.default.removeItem(at: fileURL!)
            } catch {
                // Nothing.
            }
            fileURL = nil
            UserDefaults.standard.set(Rcl57.version, forKey: Rcl57.versionKey)
        }

        if fileURL == nil {
            rcl57_init(&rcl57)
            return
        }
        do {
            try fileRawData = Data(contentsOf: fileURL!)
        } catch {
            rcl57_init(&rcl57)
            return
        }
        if fileRawData == nil {
            rcl57_init(&rcl57)
            return
        }
        fileRawBuffer = fileRawData!.withUnsafeBytes({
            (ptr) -> UnsafePointer<Int8> in
            return ptr.baseAddress!.assumingMemoryBound(to: Int8.self)
        })
        if fileRawBuffer == nil {
            rcl57_init(&rcl57)
            return
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

    /** Saves the RCL57 object. Returns 'true' if the object was saved successfully. */
    func save() -> Bool {
        let size = MemoryLayout.size(ofValue: rcl57)
        let rawData = Data(bytes: &rcl57, count: size)
        let dirURL: URL? =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL: URL? = dirURL?.appendingPathComponent(Rcl57.stateFilename)

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

    func saveState() -> Bool {
        let filename = "tmp.r57"
        var X = rcl57.ti57.X
        var Y = rcl57.ti57.Y
        let sizeX = MemoryLayout.size(ofValue: X)
        var rawDataX = Data(bytes: &X, count: sizeX)
        let rawDataY = Data(bytes: &Y, count: sizeX)
        rawDataX.append(contentsOf: rawDataY)
        let dirURL: URL? =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL: URL? = dirURL?.appendingPathComponent(filename)

        if fileURL != nil {
            do {
                try rawDataX.write(to: fileURL!, options: .atomic)
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

    /** Clears the user program. */
    func clearProgram() {
        ti57_clear_program(&rcl57.ti57)
    }

    /** Clears the 8 user registers. */
    func clearRegisters() {
        ti57_clear_registers(&rcl57.ti57)
    }

    func loadProgram(programURL: URL) {
        var programRawData: Data?
        var programRawBuffer: UnsafePointer<Int8>?

        do {
            try programRawData = Data(contentsOf: programURL)
        } catch {
            return
        }
        if programRawData == nil {
            return
        }
        programRawBuffer = programRawData!.withUnsafeBytes({
            (ptr) -> UnsafePointer<Int8> in
            return ptr.baseAddress!.assumingMemoryBound(to: Int8.self)
        })
        if programRawBuffer == nil {
            return
        }
        let sizeX = MemoryLayout.size(ofValue: rcl57.ti57.X)
        memcpy(&rcl57.ti57.X, programRawBuffer, sizeX * 2)
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

    func getRegister(index: Int) -> String {
        let reg = ti57_get_user_reg(&rcl57.ti57, Int32(index))
        let str = utils57_user_reg_to_str(reg, false, 9)
        return String(cString: str!)
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
        if ti57_is_op_edit_in_lrn(&rcl57.ti57) && index == ti57_get_program_pc(&rcl57.ti57) {
            suffix = " _"
        }

        return (isInv ? (isAlpha ? "INV " : "-") : "") + keyName + suffix
    }

    /** Returns the index of the last non-zero step, or -1 if none,*/
    func getProgramLastIndex() -> Int {
        return Int(ti57_get_program_last_index(&rcl57.ti57))
    }

    /** Returns the index of the last non-zero user register, or -1 if none,*/
    func getRegistersLastIndex() -> Int {
        return Int(ti57_get_registers_last_index(&rcl57.ti57))
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
