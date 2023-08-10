import Foundation

/// A single entry in the log.
struct LogEntry {
    /// A String representing the input number, the operation, or the result.
    let message: String

    /// Whether the log message represents an input number, an operation, or a result. See
    /// `log57.h`.
    let type: log57_type_t

    /// Gives additional information about the message. See `log57.h`.
    let flags: Int32

    init(entry: UnsafeMutablePointer<log57_entry_t>) {
        // Convert `entry.pointer.message` (originally a C char[16]) into a Swift String:
        // - Swift treats `entry.pointee.message` as a tuple of 16 CChar.
        // - messagePointer is a pointer to that tuple.
        // - reboundedPointer is a pointer to the first CChar of that tuple.
        message = withUnsafePointer(to: entry.pointee.message) { messagePointer in
            messagePointer.withMemoryRebound(
                to: CChar.self,
                capacity: MemoryLayout.size(ofValue: messagePointer)
            ) { reboundedPointer in
                String(cString: reboundedPointer)
            }
        }

        type = entry.pointee.type
        flags = entry.pointee.flags
    }
}

/// A singleton class to access and clear the log.
class Log57 {
    /// The Log57 singleton.
    static let shared = Log57()

    /// The number of entries logged since the last reset.
    var entryCount: Int {
        log57_get_logged_count(&Rcl57.shared.rcl57.ti57.log)
    }

    /// The current timestamp, incremented whenever the log is modified.
    var logTimestamp: Int {
        Rcl57.shared.rcl57.ti57.log.timestamp;
    }

    /// The current operation in EVAL mode.
    var currentOp: String {
        String(cString: log57_get_current_op(&Rcl57.shared.rcl57.ti57.log))
    }

    /// The log entry at a given index (1-based). The log holds `LOG57_MAX_ENTRY_COUNT` entries
    /// (see `log57.h`) and `index` should be in the interval:
    /// `max(1, loggedCount - LOG57_MAX_ENTRY_COUNT + 1)` ... `loggedCount`.
    func logEntry(atIndex index: Int) -> LogEntry {
        LogEntry(entry: log57_get_entry(&Rcl57.shared.rcl57.ti57.log, index))
    }

    /// Clears all entries from the log.
    func clearEntries() {
        log57_reset(&Rcl57.shared.rcl57.ti57.log)
    }
}
