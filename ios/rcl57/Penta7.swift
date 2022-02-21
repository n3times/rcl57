import Foundation
import CoreText

// The Penta7 object used to run the emulator.
class Penta7 {
    var p7 = penta7_t()

    init() {
        let options = PENTA7_FASTER_TRACE_FLAG |
                      PENTA7_QUICK_STOP_FLAG |
                      PENTA7_SHOW_RUN_INDICATOR_FLAG;
        
        penta7_init(&p7)
        p7.options = options
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
        memcpy(&p7, fileRawBuffer, MemoryLayout.size(ofValue: p7))
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

    // Saves the Penta7 object in a given file. Returns 'true' if the object was saved
    // successfully.
    func save(filename: String) -> Bool {
        let size = MemoryLayout.size(ofValue: p7)
        let rawData = Data(bytes: &p7, count: size)
        let dirURL: URL? =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL: URL? = dirURL?.appendingPathComponent(filename)

        if (fileURL != nil) {
            do {
                try rawData.write(to: fileURL!, options: .atomic)
                return true
            } catch {
                // Nothing
            }
        }
        return false
    }

    func getOption(option:Int32) -> Bool {
        return p7.options & option != 0
    }

    func setOption(option: Int32, value: Bool) {
        if (value) {
            p7.options |= option
        } else {
            p7.options &= ~option
        }
    }

    func clear() {
        penta7_clear(&p7)
    }
}
