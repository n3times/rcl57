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
    @EnvironmentObject private var appState: AppState

    @State private var lines: [LogLineData] = []
    @State private var currentLineIndex = 0
    @State private var lastTimestamp = 0
    @State private var lastLoggedCount = 0
    private let maxLines = 500

    init() {
        updateLog()
    }

    private func clear() {
        lines.removeAll()
        currentLineIndex = 0
        lastTimestamp = 0
        lastLoggedCount = 0
    }

    private func updateLog() {
        // Return right away if there are no changes.
        let newTimestamp = Log57.shared.logTimestamp
        if newTimestamp == lastTimestamp {
            return
        }
        lastTimestamp = newTimestamp

        // Clear log and return if necessary.
        let newLoggedCount = Log57.shared.loggedCount
        if newLoggedCount == 0 {
            clear();
            return
        }

        // Reevaluate the item that was last logged in case it has been updated.
        if lastLoggedCount > 0 {
            var numberEntry = lines.last?.numberEntry
            var opEntry = lines.last?.opLogEntry
            let type = Log57.shared.logEntry(atIndex: lastLoggedCount).type
            if type == LOG57_OP || type == LOG57_PENDING_OP {
                opEntry = Log57.shared.logEntry(atIndex: lastLoggedCount)
            } else {
                numberEntry = Log57.shared.logEntry(atIndex: lastLoggedCount)
            }
            lines.removeLast()
            if let numberEntry, let opEntry {
                lines.append(LogLineData(numberEntry: numberEntry, opEntry: opEntry))
            }
        }

        // Handle new log entries.
        if newLoggedCount > lastLoggedCount {
            let start = max(lastLoggedCount+1, newLoggedCount - Int(LOG57_MAX_ENTRY_COUNT) + 1)
            for i in start...newLoggedCount {
                let entry = Log57.shared.logEntry(atIndex: i)
                let type = entry.type
                if type == LOG57_OP || type == LOG57_PENDING_OP {
                    let numberEntry = lines.last?.numberEntry
                    let opEntry = lines.last?.opLogEntry
                    if opEntry?.message == "" {
                        lines.removeLast()
                        if let numberEntry {
                            lines.append(LogLineData(numberEntry: numberEntry, opEntry: entry))
                        }
                    } else {
                        currentLineIndex += 1
                        if lines.count == maxLines {
                            lines.removeFirst()
                        }
                        lines.append(LogLineData(numberEntry: nil, opEntry: entry))
                    }
                } else {
                    currentLineIndex += 1
                    if lines.count == maxLines {
                        lines.removeFirst()
                    }
                    lines.append(LogLineData(numberEntry: entry, opEntry: LogEntry(entry: LOG57_BLANK_ENTRY)))
                }
            }
            lastLoggedCount = newLoggedCount
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            List(lines) {
                LogLineView(line: $0)
                    .listRowBackground(Color.ivory)
                    .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .environment(\.defaultMinListRowHeight, Style.listLineHeight)
            .onAppear {
                updateLog()
                if let lastLine = lines.last {
                    proxy.scrollTo(lastLine.id, anchor: .bottom)
                }
            }
            .onChange(of: lastTimestamp) { _ in
                if let lastLine = lines.last {
                    proxy.scrollTo(lastLine.id, anchor: .bottom)
                }
            }
            .onReceive(appState.$logTimestamp) { _ in
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
