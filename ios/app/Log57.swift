import Foundation

/// A single entry in the log.
struct LogEntry {
    /// A String with the input number, the operation, or the result.
    let message: String

    /// Whether the log message is for an input number, an operation, or a result. See
    /// `log57_type_t`.
    let type: log57_type_t

    /// Gives more information about the message. See `log57.h`.
    let flags: Int32

    init(entry: UnsafeMutablePointer<log57_entry_t>) {
        // Convert a C char[] into a Swift String:
        // 1. Swift treats the C char[] as Swift tuple of CChar: entry.pointee.message
        // 2. From entry.pointee.message, get a pointer to the tuple: messagePointer
        // 3. Convert messagePointer into a pointer to the first element of an array of UInt8:
        //    reboundedPointer (this is a C String)
        // 4. Finally use String(cString:) on reboundedPointer
        // Note: it would be easier if we had a char * as opposed to a char[]
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

/// A singleton class to access and clear the log.
class Log57 {
    /// The Log57 singleton.
    static let shared = Log57()

    /// The number of logged items since reset.
    var loggedCount: Int {
        log57_get_logged_count(&Rcl57.shared.rcl57.ti57.log)
    }

    /// The log timestamp, used to find out whether a log entry has been added or the last log has
    /// been updated.
    var logTimestamp: Int {
        Rcl57.shared.rcl57.ti57.log.timestamp;
    }

    /// The current operation in EVAL mode.
    var currentOp: String {
        String(cString: log57_get_current_op(&Rcl57.shared.rcl57.ti57.log))
    }

    /// The log entry at a given 1-based index. The log only holds `LOG57_MAX_ENTRY_COUNT` entries
    /// (see `log57.h`) and `index` should be in the interval:
    /// `max(1, loggedCount - LOG57_MAX_ENTRY_COUNT + 1)` ... `loggedCount`.
    func logEntry(atIndex index: Int) -> LogEntry {
        LogEntry(entry: log57_get_entry(&Rcl57.shared.rcl57.ti57.log, index))
    }

    /// Clears the log.
    func clearLog() {
        log57_reset(&Rcl57.shared.rcl57.ti57.log)
    }
}
