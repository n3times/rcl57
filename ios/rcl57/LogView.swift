/**
 * The view that shows operations and results.
 */

import SwiftUI

/** Data for a LineView: a number and an operation. */
struct Line: Identifiable {
    let numberEntry: LogEntry
    let opEntry: LogEntry
    let id: Int

    init(numberEntry: LogEntry, opEntry: LogEntry, id: Int) {
        self.numberEntry = numberEntry
        self.opEntry = opEntry
        self.id = id
    }
}

/** A line view in a LogView: a number on the left and an operation on the right. */
struct LineView: View {
    let line: Line

    init(line: Line) {
        self.line = line
    }

    private func getColor(entry: LogEntry) -> Color {
        let isError = (entry.getFlags() & LOG57_ERROR_FLAG) != 0
        return isError ? Color.yellow : Color.white
    }

    var body: some View {
        HStack {
            Text(line.numberEntry.getMessage())
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
                .foregroundColor(getColor(entry: line.numberEntry))
            Spacer(minLength: 25)
            Text(line.opEntry.getMessage())
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .leading)
                .foregroundColor(Color.white)
        } .font(Font.system(.callout, design: .monospaced))
    }
}

/** A list of LineView's. */
struct LogView: View {
    let rcl57 : RCL57
    @State private var lines : [Line] = []
    @State private var currentLineIndex = 0
    @State private var lastTimestamp = 0
    @State private var lastLoggedCount = 0
    private let maxLines = 1000
    private let timePublisher = Timer.TimerPublisher(interval: 0.02, runLoop: .main, mode: .default)
        .autoconnect()

    init(rcl57: RCL57) {
        self.rcl57 = rcl57
    }

    func makeLine(numberEntry: LogEntry,
                  opEntry: LogEntry) -> Line {
        return Line(numberEntry: numberEntry, opEntry: opEntry, id: currentLineIndex)
    }

    func clear() {
        lines.removeAll()
        currentLineIndex = 0
        lastTimestamp = 0
        lastLoggedCount = 0
    }

    func updateLog() {
        // Return right away if there are no changes.
        let newTimestamp = rcl57.getLogTimestamp()
        if newTimestamp == lastTimestamp { return }
        lastTimestamp = newTimestamp

        // Clear log and return if necessary.
        let newLoggedCount = rcl57.getLoggedCount()
        if newLoggedCount == 0 { clear(); return }

        // Reevaluate the item that was last logged in case it has been updated.
        if (lastLoggedCount > 0) {
            var numberEntry = lines.last?.numberEntry
            var opEntry = lines.last?.opEntry
            let type = rcl57.getLogEntry(index: lastLoggedCount).getType()
            if type == LOG57_OP || type == LOG57_PENDING_OP {
                opEntry = rcl57.getLogEntry(index: lastLoggedCount)
            } else {
                numberEntry = rcl57.getLogEntry(index: lastLoggedCount)
            }
            lines.removeLast()
            lines.append(makeLine(numberEntry: numberEntry!, opEntry: opEntry!))
        }

        // Handle newly logged entries.
        if (newLoggedCount > lastLoggedCount) {
            for i in lastLoggedCount+1...newLoggedCount {
                let entry = rcl57.getLogEntry(index: i)
                let type = entry.getType()
                if type == LOG57_OP || type == LOG57_PENDING_OP {
                    let numberEntry = lines.last?.numberEntry
                    let opEntry = lines.last?.opEntry
                    if opEntry?.getMessage() == "" {
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

    private func getLineView(_ line: Line) -> some View {
        return LineView(line: line)
            .listRowBackground(Color.black)
            .listRowSeparator(.hidden)
    }

    var body: some View {
        ScrollViewReader { proxy in
            List(lines) {
                getLineView($0)
            }
            .onAppear {
                if lines.count > 0 {
                    proxy.scrollTo(lines.last!.id, anchor: .bottom)
                }
            }
            .onChange(of: currentLineIndex) { _ in
                if lines.count > 0 {
                    proxy.scrollTo(lines.last!.id, anchor: .bottom)
                }
            }
            .onReceive(timePublisher) { _ in
                updateLog()
            }
            .listStyle(PlainListStyle())
            .environment(\.defaultMinListRowHeight, 10)
        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView(rcl57: RCL57())
    }
}
