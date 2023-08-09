import Foundation

/**
 * The main class for interfacing with the emulator.
 *
 * This includes accessing the display, the registers, and the program steps. From this class, one
 * can interact with the calculator through the keyboard.
 */
class Rcl57 {
    /// The Rcl57 singleton.
    static let shared = Rcl57(filename: stateFilename)

    private static let stateFilename = "rcl57.dat"
    private static let versionKey = "version"

    /// Incremented by 1 for non backward compatible changes.
    static let majorVersion = 1

    /// Incremented by 1 for minor changes, and reset to 0 for non backward compatible changes.
    static let minorVersion = 1

    /// The current version of the app.
    static let version = "\(majorVersion).\(minorVersion)"

    /// The C backing struct.
    var rcl57 = rcl57_t()

    /// The calculator display as a string.
    var display: String {
        String(cString: rcl57_get_display(&rcl57))
    }


    // MARK: Initialization.

    /// Initializes a blank Rcl57 object.
    private init() {
        rcl57_init(&rcl57)
    }

    /// Returns the content at a given URL as a "char *".
    private func rawData(atURL url: URL) -> UnsafePointer<CChar>? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        var bytePointer: UnsafePointer<Int8>?
        data.withUnsafeBytes { ptr in
            if let baseAddress = ptr.baseAddress {
                bytePointer = baseAddress.assumingMemoryBound(to: Int8.self)
            }
        }

        return bytePointer
    }

    // Updates version if it has changed.
    private func updateVersion(stateURL: inout URL?) {
        if let previousVersion = UserDefaults.standard.string(forKey: Rcl57.versionKey) {
            if previousVersion != Rcl57.version {
                let previousMajorVersion = Int(Float(previousVersion) ?? 0)
                if previousMajorVersion != Rcl57.majorVersion {
                    // Reset state since this is a non backward compatible change.
                    if let nonOptionalFileURL = stateURL {
                        _ = try? FileManager.default.removeItem(at: nonOptionalFileURL)
                        stateURL = nil
                    }
                }
            }
            UserDefaults.standard.set(Rcl57.version, forKey: Rcl57.versionKey)
        }
    }

    /// Initializes an Rcl57 object from the raw state stored in a given file.
    private init(filename: String) {
        let dirURL: URL? =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        var stateURL: URL? = dirURL?.appendingPathComponent(filename)

        updateVersion(stateURL: &stateURL)

        guard let stateURL, let rawData = rawData(atURL: stateURL) else {
            rcl57_init(&rcl57)
            return
        }
        memcpy(&rcl57, rawData, MemoryLayout.size(ofValue: rcl57))
    }


    // MARK: Modes.

    /// Whether the 2nd key is engaged.
    var is2nd: Bool {
        ti57_is_2nd(&rcl57.ti57)
    }

    /// Whether the INV key is engaged.
    var isInv: Bool {
        ti57_is_inv(&rcl57.ti57)
    }

    /// The current unit for trigonometric operations.
    var trigUnit: ti57_trig_t {
        ti57_get_trig(&rcl57.ti57)
    }


    // MARK: Registers.

    /// The number of registers.
    let registerCount = 8

    /// The register at a given index, as a String.
    func register(atIndex index: Int) -> String {
        let reg = ti57_get_user_reg(&rcl57.ti57, Int32(index))
        let str = utils57_user_reg_to_str(reg, false, 9)
        if let str {
            return String(cString: str)
        } else {
            return String("Unreadable")
        }
    }

    /// The index of the last non-zero user register, or -1 if none.
    var registersLastIndex: Int {
        Int(ti57_get_registers_last_index(&rcl57.ti57))
    }

    /// Clears the user registers.
    func clearRegisters() {
        ti57_clear_registers(&rcl57.ti57)
    }


    // MARK: Steps.

    /// The number of program steps.
    let stepCount = 50

    /// The operation at a given index, as a String.
    func stepOp(atIndex index: Int, isAlpha: Bool) -> String {
        guard let op = ti57_get_program_op(&rcl57.ti57, Int32(index)) else { return "ERR" }

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

    /// The index of the last non-zero step, or -1 if none.
    var stepsLastIndex: Int {
        return Int(ti57_get_program_last_index(&rcl57.ti57))
    }

    /// Clears the user program.
    func clearSteps() {
        ti57_clear_program(&rcl57.ti57)
    }


    // MARK: Emulator.

    /// Controls the speed of the emulator.
    var speedupFactor: UInt32 {
        get {
            rcl57.speedup
        }
        set {
            rcl57.speedup = newValue
        }
    }

    /// Should be called whenever the user presses a calculator key.
    func keyPress(row: Int, col: Int) {
        precondition(row >= 1 && row <= 8 && col >= 1 && col <= 5)
        rcl57_key_press(&rcl57, Int32(row), Int32(col))
    }

    /// Should be called whenever the user releases a calculator key.
    func keyRelease() {
        rcl57_key_release(&rcl57)
    }

    /// Runs the emulator for a given amount of time.
    func advance(milliseconds: Int32) -> Bool {
        return rcl57_advance(&rcl57, milliseconds)
    }

    /// Returns `true` if a given emulator option is on. See `rcl57.h`.
    func emulatorOption(flag: Int32) -> Bool {
        return rcl57.options & flag != 0
    }

    /// Sets or clears a given emulator option. See `rcl57.h`.
    func setEmulatorOption(flag: Int32, value: Bool) {
        if value {
            rcl57.options |= flag
        } else {
            rcl57.options &= ~flag
        }
    }


    // MARK: State.

    /// Saves the Rcl57 object. Returns `true` if the object was saved successfully.
    func saveState() -> Bool {
        let size = MemoryLayout.size(ofValue: rcl57)
        let rawData = Data(bytes: &rcl57, count: size)
        let dirURL: URL? =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL: URL? = dirURL?.appendingPathComponent(Rcl57.stateFilename)

        if let fileURL {
            do {
                try rawData.write(to: fileURL, options: .atomic)
                return true
            } catch {
                // Nothing
            }
        }
        return false
    }

    /// Clears the state, only preserving the emulator options.
    func clearState() {
        rcl57_clear(&rcl57)
    }
}
