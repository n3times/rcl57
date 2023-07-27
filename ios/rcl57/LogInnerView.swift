/**
 * The view that shows operations and results.
 */

import SwiftUI

/** Data for a LineView: a number and an operation. */
private struct LogLine: Identifiable {
    static var lineId = 0
    let numberLogEntry: LogEntry
    let opLogEntry: LogEntry
    let id: Int

    init(numberEntry: LogEntry, opEntry: LogEntry) {
        self.numberLogEntry = numberEntry
        self.opLogEntry = opEntry
        self.id = LogLine.lineId
        LogLine.lineId += 1
    }
}

/** A line view in a LogView: a number on the left and an operation on the right. */
private struct LogLineView: View {
    let line: LogLine
    private let foregroundColor: Color
    private let foregroundColorError: Color

    init(line: LogLine) {
        self.line = line
        self.foregroundColor = Color.black
        self.foregroundColorError = Color(red: 0.5, green: 0.0, blue: 0.0)
    }

    private func getColor(entry: LogEntry) -> Color {
        let isError = (entry.flags & LOG57_ERROR_FLAG) != 0

        return isError ? foregroundColorError: foregroundColor
    }

    var body: some View {
        HStack {
            Text(line.numberLogEntry.message)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
                .foregroundColor(getColor(entry: line.numberLogEntry))
            HStack {
                Spacer(minLength: 25)
                Text(line.opLogEntry.message)
                    .frame(maxWidth: .infinity, idealHeight:10, alignment: .leading)
                    .foregroundColor(foregroundColor)
            }
        }
        .font(Style.listLineFont)
    }
}

/** A list of LineView's. */
struct LogInnerView: View {
    @EnvironmentObject private var change: Change

    @State private var lines: [LogLine] = []
    @State private var currentLineIndex = 0
    @State private var lastTimestamp = 0
    @State private var lastLoggedCount = 0
    private let maxLines: Int

    init() {
        self.maxLines = 500
        updateLog()
    }

    private func makeLine(numberEntry: LogEntry, opEntry: LogEntry) -> LogLine {
        return LogLine(numberEntry: numberEntry, opEntry: opEntry)
    }

    private func clear() {
        lines.removeAll()
        currentLineIndex = 0
        lastTimestamp = 0
        lastLoggedCount = 0
    }

    private func updateLog() {
        // Return right away if there are no changes.
        let newTimestamp = Rcl57.shared.logTimestamp
        if newTimestamp == lastTimestamp {
            return
        }
        lastTimestamp = newTimestamp

        // Clear log and return if necessary.
        let newLoggedCount = Rcl57.shared.loggedCount
        if newLoggedCount == 0 {
            clear();
            return
        }

        // Reevaluate the item that was last logged in case it has been updated.
        if lastLoggedCount > 0 {
            var numberEntry = lines.last?.numberLogEntry
            var opEntry = lines.last?.opLogEntry
            let type = Rcl57.shared.logEntry(index: lastLoggedCount).type
            if type == LOG57_OP || type == LOG57_PENDING_OP {
                opEntry = Rcl57.shared.logEntry(index: lastLoggedCount)
            } else {
                numberEntry = Rcl57.shared.logEntry(index: lastLoggedCount)
            }
            lines.removeLast()
            lines.append(makeLine(numberEntry: numberEntry!, opEntry: opEntry!))
        }

        // Handle new log entries.
        if newLoggedCount > lastLoggedCount {
            let start = max(lastLoggedCount+1, newLoggedCount - Int(LOG57_MAX_ENTRY_COUNT) + 1)
            for i in start...newLoggedCount {
                let entry = Rcl57.shared.logEntry(index: i)
                let type = entry.type
                if type == LOG57_OP || type == LOG57_PENDING_OP {
                    let numberEntry = lines.last?.numberLogEntry
                    let opEntry = lines.last?.opLogEntry
                    if opEntry?.message == "" {
                        lines.removeLast()
                        lines.append(makeLine(numberEntry: numberEntry!, opEntry: entry))
                    } else {
                        currentLineIndex += 1
                        if lines.count == maxLines {
                            lines.removeFirst()
                        }
                        lines.append(makeLine(numberEntry: LogEntry(entry: LOG57_BLANK_ENTRY),
                                              opEntry: entry))
                    }
                } else {
                    currentLineIndex += 1
                    if lines.count == maxLines {
                        lines.removeFirst()
                    }
                    lines.append(makeLine(numberEntry: entry,
                                          opEntry: LogEntry(entry: LOG57_BLANK_ENTRY)))
                }
            }
            lastLoggedCount = newLoggedCount
        }
    }

    var body: some View {
        return ScrollViewReader { proxy in
            List(lines) {
                LogLineView(line: $0)
                    .listRowBackground(Color.ivory)
                    .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .environment(\.defaultMinListRowHeight, Style.listLineHeight)
            .onAppear {
                updateLog()
                if lines.count > 0 {
                    proxy.scrollTo(lines.last!.id, anchor: .bottom)
                }
            }
            .onChange(of: lastTimestamp) { _ in
                if lines.count > 0 {
                    proxy.scrollTo(lines.last!.id, anchor: .bottom)
                }
            }
            .onReceive(change.$logTimestamp) { _ in
                updateLog()
            }
            .onReceive(change.$displayString) { _ in
                updateLog()
            }
            .onReceive(change.$changeCount) { _ in
                updateLog()
            }

        }
    }
}

struct LogInnerView_Previews: PreviewProvider {
    static var previews: some View {
        LogInnerView()
    }
}
