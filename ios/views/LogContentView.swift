import SwiftUI

/// Data for a LogLineView: a number and an operation.
private struct LogLineData: Identifiable {
    let numberEntry: LogEntry?
    let opLogEntry: LogEntry?

    /// Incremented by 1 on each new instance.
    static var lineId = 0

    /// Identifiable conformance.
    let id: Int

    init(numberEntry: LogEntry?, opEntry: LogEntry?) {
        self.numberEntry = numberEntry
        self.opLogEntry = opEntry

        self.id = LogLineData.lineId
        LogLineData.lineId += 1
    }
}

/// A single log line: a number on the left and an operation on the right.
private struct LogLineView: View {
    let lineData: LogLineData

    /// Used for log entries that have an error associated to them.
    private static let errorColor = Color(red: 0.5, green: 0.0, blue: 0.0)

    /// Returns the foregroundColor for a given entry.
    private func foregroundColor(forEntry entry: LogEntry?) -> Color {
        if let entry, (entry.flags & LOG57_ERROR_FLAG) != 0 {
            return LogLineView.errorColor
        } else {
            return Color.black
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let leftWidth = proxy.size.width * 0.5
            let spacerLength = 25.0
            let rightWidth = proxy.size.width * 0.5 - spacerLength

            HStack {
                Text(lineData.numberEntry?.message ?? "")
                    .frame(width: leftWidth, height: Style.listLineHeight, alignment: .trailing)
                    .foregroundColor(foregroundColor(forEntry: lineData.numberEntry))
                Spacer(minLength: spacerLength)
                Text(lineData.opLogEntry?.message ?? "")
                    .frame(width: rightWidth, height: Style.listLineHeight, alignment: .leading)
                    .foregroundColor(Color.black)
            }
            .offset(y: -4)
        }
        .font(Style.listLineFont)
    }
}

/// Displays operations and results.
struct LogContentView: View {
    @EnvironmentObject private var emulatorState: EmulatorState

    private static let maxLines = 500

    @State private var logLinesData: [LogLineData] = []
    @State private var logEntryCount = 0

    /// Update the log and scroll to the end.
    private func updateLog(scrollViewProxy: ScrollViewProxy?) {
        // See if log has been cleared.
        if Log57.shared.entryCount == 0 {
            logLinesData.removeAll()
            logEntryCount = 0
            return
        }

        // Reevaluate the last item in `logLinesData` in case it has changed.
        if logEntryCount > 0 {
            let logEntry = Log57.shared.logEntry(atIndex: logEntryCount)

            switch logEntry.type {
            case LOG57_PENDING_OP:
                fallthrough
            case LOG57_OP:
                // For example: "STO _" -> "STO 2".
                if logEntry != logLinesData.last?.opLogEntry {
                    logLinesData[logLinesData.count - 1] =
                        LogLineData(numberEntry: logLinesData.last?.numberEntry, opEntry: logEntry)
                }
            case LOG57_NUMBER_IN:
                // For example: "3.1" -> "3.14".
                if logEntry != logLinesData.last?.numberEntry {
                    logLinesData[logLinesData.count - 1] =
                        LogLineData(numberEntry: logEntry, opEntry: nil)
                }
            default:
                break
            }
        }

        // Handle additional log entries.
        if Log57.shared.entryCount > logEntryCount {
            let start = max(logEntryCount + 1,
                            Log57.shared.entryCount - Int(LOG57_MAX_ENTRY_COUNT) + 1)
            for i in start...Log57.shared.entryCount {
                if logLinesData.count == LogContentView.maxLines {
                    logLinesData.removeFirst()
                }

                var numberEntry: LogEntry? = nil
                var opEntry: LogEntry? = nil
                let logEntry = Log57.shared.logEntry(atIndex: i)
                var doReplace = false

                switch logEntry.type {
                case LOG57_OP:
                    fallthrough
                case LOG57_PENDING_OP:
                    // Add log entry to the last log line if possible.
                    if logLinesData.last?.opLogEntry == nil {
                        numberEntry = logLinesData.last?.numberEntry
                        if !logLinesData.isEmpty {
                            doReplace = true
                        }
                    }
                    opEntry = logEntry
                default:
                    numberEntry = logEntry
                }
                if doReplace {
                    logLinesData[logLinesData.count - 1] =
                        LogLineData(numberEntry: numberEntry, opEntry: opEntry)
                } else {
                    logLinesData.append(LogLineData(numberEntry: numberEntry, opEntry: opEntry))
                }
            }
        }

        logEntryCount = Log57.shared.entryCount

        // Scroll to the end of the log.
        if let scrollViewProxy {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let lastLine = logLinesData.last {
                    scrollViewProxy.scrollTo(lastLine.id, anchor: .bottom)
                }
            }
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            List(logLinesData) {
                LogLineView(lineData: $0)
                    .listRowBackground(Color.ivory)
                    .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .environment(\.defaultMinListRowHeight, Style.listLineHeight)
            .onAppear {
                updateLog(scrollViewProxy: proxy)
            }
            .onReceive(emulatorState.$logTimestamp) { _ in
                updateLog(scrollViewProxy: proxy)
            }
        }
    }
}

struct LogContentView_Previews: PreviewProvider {
    static var previews: some View {
        LogContentView()
    }
}
