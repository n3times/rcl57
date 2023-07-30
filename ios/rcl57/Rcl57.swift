/**
 * Interface to the emulator.
 */

import Foundation

/**
 * LogEntry.
 */
struct LogEntry {
    let message: String
    let type: log57_type_t
    let flags: Int32

    init(entry: UnsafeMutablePointer<log57_entry_t>) {
        // Convert a C char[] into a Swift String:
        // 1. Swift treats the C char[] as Swift tuple of CChar: entry.pointee.message
        // 2. From entry.pointee.message, get a pointer to the tuple: messagePointer
        // 3. Convert messagePointer into a pointer to the first element of an array of UInt8:
        //    reboundedPointer (this is a C String)
        // 4. Finally use String(cString:) on reboundedPointer
        // Note: it would easier if we had a char * as opposed to a char[]
        message = withUnsafePointer(to: entry.pointee.message) { messagePointer in
            messagePointer.withMemoryRebound(
                to: UInt8.self,
                capacity: MemoryLayout.size(ofValue: messagePointer)
            ) { reboundedPointer in
                String(cString: reboundedPointer)
            }
        }

        type = entry.pointee.type
        flags = entry.pointee.flags
    }
}

/**
 * A singleton to access the state of the emulator.
 *
 * This includes the display, the registers, and the program steps. One can interact with the
 * calculator, notably by pressing and releasing keyboard keys.
 */
class Rcl57 {
    private static let stateFilename = "rcl57.dat"
    private static let versionKey = "version"

    // For minor changes, increment by 1 minorVersion. For non backward compatible changes,
    // increment by 1 majorVersion and reset to 0 minorVersion.
    static let majorVersion = 1
    static let minorVersion = 1
    static let version = "\(majorVersion).\(minorVersion)"

    static let shared = Rcl57(filename: stateFilename)

    var rcl57 = rcl57_t()

    private init() {
        rcl57_init(&rcl57)
    }

    /**
     * Initializes a RCL57 object from the state stored in a given file.
     */
    private init(filename: String) {
        var fileRawData: Data?
        var fileRawBuffer: UnsafePointer<Int8>?
        let dirURL: URL? =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        var fileURL: URL? = dirURL?.appendingPathComponent(filename)

        // Update version if it has changed.
        if let previousVersion = UserDefaults.standard.string(forKey: Rcl57.versionKey) {
            if previousVersion != Rcl57.version {
                let previousMajorVersion = Int(Float(previousVersion)!)
                if previousMajorVersion != Rcl57.majorVersion {
                    // Reset state since this is a non backward compatible change.
                    do {
                        try FileManager.default.removeItem(at: fileURL!)
                    } catch {
                        // Nothing.
                    }
                    fileURL = nil
                }
            }
            UserDefaults.standard.set(Rcl57.version, forKey: Rcl57.versionKey)
        }

        guard let fileURL else {
            rcl57_init(&rcl57)
            return
        }
        do {
            try fileRawData = Data(contentsOf: fileURL)
        } catch {
            rcl57_init(&rcl57)
            return
        }
        guard let fileRawData else {
            rcl57_init(&rcl57)
            return
        }
        fileRawBuffer = fileRawData.withUnsafeBytes({
            (ptr) -> UnsafePointer<Int8> in
            return ptr.baseAddress!.assumingMemoryBound(to: Int8.self)
        })
        guard let fileRawBuffer else {
            rcl57_init(&rcl57)
            return
        }
        memcpy(&rcl57, fileRawBuffer, MemoryLayout.size(ofValue: rcl57))
    }

    /** The calculator display as a string. */
    var display: String {
        String(cString: rcl57_get_display(&rcl57))
    }

    /** Should be called whenever the user presses a calculator key (row in 1..8 and col in 1..5). */
    func keyPress(row: Int, col: Int) {
        rcl57_key_press(&rcl57, Int32(row), Int32(col))
    }

    /** Should be called whenever the user releases a calculator key. */
    func keyRelease() {
        rcl57_key_release(&rcl57)
    }

    /** Runs the emulator for 'ms' milliseconds. */
    func advance(ms: Int32) -> Bool {
        return rcl57_advance(&rcl57, ms)
    }

    /** Whether the 2nd key is engaged. */
    var is2nd: Bool {
        ti57_is_2nd(&rcl57.ti57)
    }

    /** Whether the INV key is engaged. */
    var isInv: Bool {
        ti57_is_inv(&rcl57.ti57)
    }

    /** The current units in trigonometric mode. */
    var trigUnits: ti57_trig_t {
        ti57_get_trig(&rcl57.ti57)
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
    var speedupFactor: UInt32 {
        get {
            rcl57.speedup
        }
        set {
            rcl57.speedup = newValue
        }
    }

    /** Clears the state, only preserving the emulator options. */
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
        guard let programRawData else {
            return
        }
        programRawBuffer = programRawData.withUnsafeBytes({
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
    var loggedCount: Int {
        log57_get_logged_count(&rcl57.ti57.log)
    }

    /**
     * The log entry at a given index.
     *
     * 'index' should be between max(1, logged_count - LOG57_MAX_ENTRY_COUNT + 1) and logged_count.
     */
    func logEntry(index: Int) -> LogEntry {
        LogEntry(entry: log57_get_entry(&rcl57.ti57.log, index))
    }

    /** The current operation in EVAL mode. */
    var currentOp: String {
        String(cString: log57_get_current_op(&rcl57.ti57.log))
    }

    /** Returns a timestamp that can be used to find out whether the log has been updated. */
    var logTimestamp: Int {
        rcl57.ti57.log.timestamp;
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
            suffix = " \(d)"
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
    var programPc: Int {
        return Int(rcl57_get_program_pc(&rcl57))
    }

    var isLrnMode: Bool {
        return ti57_get_mode(&rcl57.ti57) == TI57_LRN
    }

    var isOpEditInLrn: Bool {
        ti57_is_op_edit_in_lrn(&rcl57.ti57)
    }
}
