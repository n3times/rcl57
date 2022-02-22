import Foundation
import CoreText

// The Penta7 object used to run the emulator.
class Penta7 {
    private var penta7 = penta7_t()

    init() {
        let options = PENTA7_FASTER_TRACE_FLAG |
                      PENTA7_SHORT_PAUSE_FLAG |
                      PENTA7_QUICK_STOP_FLAG |
                      PENTA7_SHOW_RUN_INDICATOR_FLAG;
        
        penta7_init(&penta7)
        penta7.options = options
        penta7.speedup = 1000;
    }

    // Initializes a Penta7 object from the state stored in a given file.
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
        memcpy(&penta7, fileRawBuffer, MemoryLayout.size(ofValue: penta7))
    }

    // Returns the calculator display.
    func display() -> String {
        return String(cString: penta7_get_display(&penta7))
    }

    // Should be called whenever the user presses a calculator key.
    func keyPress(row: Int32, col: Int32) {
        penta7_key_press(&penta7, row, col)
    }

    // Should be called whenever the user releases a calculator key.
    func keyRelease() {
        penta7_key_release(&penta7)
    }

    // Should be called every 50ms.
    func advance() -> Bool {
        return penta7_advance(&penta7, 50)
    }

    // Whether the 2nd key is engaged.
    func is2nd() -> Bool {
        return ti57_is_2nd(&penta7.ti57)
    }

    // Whether the INV key is engaged.
    func isInv() -> Bool {
        return ti57_is_inv(&penta7.ti57)
    }

    // Saves the Penta7 object in a given file. Returns 'true' if the object was saved
    // successfully.
    func save(filename: String) -> Bool {
        let size = MemoryLayout.size(ofValue: penta7)
        let rawData = Data(bytes: &penta7, count: size)
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
        return penta7.options & option != 0
    }

    // Sets or clears a given option flag.
    func setOptionFlag(option: Int32, value: Bool) {
        if value {
            penta7.options |= option
        } else {
            penta7.options &= ~option
        }
    }

    func getSpeedup() -> UInt32 {
        return penta7.speedup
    }

    func setSpeedup(speedup: UInt32) {
        penta7.speedup = speedup
    }

    // Clears the state while preserving the options.
    func clear() {
        penta7_clear(&penta7)
    }
}
