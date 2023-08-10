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
    let line: LogLineData

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
                Text(line.numberEntry?.message ?? "")
                    .frame(width: leftWidth, height: Style.listLineHeight, alignment: .trailing)
                    .foregroundColor(foregroundColor(forEntry: line.numberEntry))
                Spacer(minLength: spacerLength)
                Text(line.opLogEntry?.message ?? "")
                    .frame(width: rightWidth, height: Style.listLineHeight, alignment: .leading)
                    .foregroundColor(Color.black)
            }
        }
        .font(Style.listLineFont)
    }
}

/// Displays operations and results.
struct LogContentView: View {
    @EnvironmentObject private var emulatorState: EmulatorState

    @State private var logLines: [LogLineData] = []
    @State private var logTimestamp = 0
    @State private var loggedCount = 0

    private let maxLines = 500

    private func clear() {
        logLines.removeAll()
        logTimestamp = 0
        loggedCount = 0
    }

    private func updateLog() {
        // Return right away if there are no changes.
        if logTimestamp == Log57.shared.logTimestamp { return }
        logTimestamp = Log57.shared.logTimestamp

        // Clear log and return if necessary.
        if Log57.shared.entryCount == 0 {
            clear();
            return
        }

        // Reevaluate the item that was last logged in case it has been updated.
        if loggedCount > 0 {
            var numberEntry = logLines.last?.numberEntry
            var opEntry = logLines.last?.opLogEntry
            let type = Log57.shared.logEntry(atIndex: loggedCount).type
            if type == LOG57_OP || type == LOG57_PENDING_OP {
                opEntry = Log57.shared.logEntry(atIndex: loggedCount)
            } else {
                numberEntry = Log57.shared.logEntry(atIndex: loggedCount)
            }
            logLines.removeLast()
            if let numberEntry, let opEntry {
                logLines.append(LogLineData(numberEntry: numberEntry, opEntry: opEntry))
            }
        }

        // Handle new log entries.
        if Log57.shared.entryCount > loggedCount {
            let start = max(loggedCount+1, Log57.shared.entryCount - Int(LOG57_MAX_ENTRY_COUNT) + 1)
            for i in start...Log57.shared.entryCount {
                let entry = Log57.shared.logEntry(atIndex: i)
                let type = entry.type
                if type == LOG57_OP || type == LOG57_PENDING_OP {
                    let numberEntry = logLines.last?.numberEntry
                    let opEntry = logLines.last?.opLogEntry
                    if opEntry?.message == "" {
                        logLines.removeLast()
                        if let numberEntry {
                            logLines.append(LogLineData(numberEntry: numberEntry, opEntry: entry))
                        }
                    } else {
                        if logLines.count == maxLines {
                            logLines.removeFirst()
                        }
                        logLines.append(LogLineData(numberEntry: nil, opEntry: entry))
                    }
                } else {
                    if logLines.count == maxLines {
                        logLines.removeFirst()
                    }
                    logLines.append(LogLineData(numberEntry: entry, opEntry: LogEntry(entry: LOG57_BLANK_ENTRY)))
                }
            }
            loggedCount = Log57.shared.entryCount
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            List(logLines) {
                LogLineView(line: $0)
                    .listRowBackground(Color.ivory)
                    .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .environment(\.defaultMinListRowHeight, Style.listLineHeight)
            .onAppear {
                updateLog()
                if let lastLine = logLines.last {
                    proxy.scrollTo(lastLine.id, anchor: .bottom)
                }
            }
            .onChange(of: logTimestamp) { _ in
                if let lastLine = logLines.last {
                    proxy.scrollTo(lastLine.id, anchor: .bottom)
                }
            }
            .onReceive(emulatorState.$logTimestamp) { _ in
                updateLog()
            }
        }
    }
}

struct LogContentView_Previews: PreviewProvider {
    static var previews: some View {
        LogContentView()
    }
}
