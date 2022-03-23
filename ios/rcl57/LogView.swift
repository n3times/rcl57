/**
 * The view that holds user operations and results.
 */

import SwiftUI

/** Data for a LineView: a number and an operation. */
struct Line: Identifiable {
    let number: String
    let op: String
    let id: Int

    init(number: String, op: String, id: Int) {
        self.number = number
        self.op = op
        self.id = id
    }
}

/** A line in the LogView: a number on the left and an operation on the right. */
struct LineView: View {
    let line: Line

    init(line: Line) {
        self.line = line
    }

    var body: some View {
        HStack {
            Text(line.number)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
            Spacer(minLength: 25)
            Text(line.op)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .leading)
        } .font(.callout)
    }
}

/** A list of LineView's. */
struct LogView: View {
    let rcl57 : RCL57
    @State private var lines : [Line] = []
    @State private var currentLine = 0
    @State private var lastTimestamp = 0
    @State private var lastLoggedCount = 0
    private let maxLines = 1000
    private let timePublisher = Timer.TimerPublisher(interval: 0.02, runLoop: .main, mode: .default)
        .autoconnect()

    init(rcl57: RCL57) {
        self.rcl57 = rcl57
    }

    func makeLine(number: String, op: String) -> Line {
        return Line(number: number, op: op, id: currentLine)
    }

    func clear() {
        lines.removeAll()
        currentLine = 0
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
            var number = lines.last?.number
            var op = lines.last?.op
            let type = rcl57.getLogType(index: lastLoggedCount)
            if type == LOG57_OP || type == LOG57_PENDING_OP {
                op = rcl57.getLogMessage(index: lastLoggedCount)
            } else {
                number = rcl57.getLogMessage(index: lastLoggedCount)
            }
            lines.removeLast()
            lines.append(makeLine(number: number!, op: op!))
        }

        // Handle newly logged items.
        if (newLoggedCount > lastLoggedCount) {
            for i in lastLoggedCount+1...newLoggedCount {
                let type = rcl57.getLogType(index: i)
                if type == LOG57_OP || type == LOG57_PENDING_OP {
                    let number = lines.last?.number
                    let op = lines.last?.op
                    if op == "" {
                        lines.removeLast()
                        lines.append(makeLine(number: number!, op: rcl57.getLogMessage(index: i)))
                    } else {
                        currentLine += 1
                        lines.append(makeLine(number: "", op: rcl57.getLogMessage(index: i)))
                    }
                } else {
                    currentLine += 1
                    lines.append(makeLine(number: rcl57.getLogMessage(index: i), op: ""))
                }
            }
            lastLoggedCount = newLoggedCount
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            List(lines) {
                LineView(line: $0)
                    .listRowBackground(Color.black)
                    .foregroundColor(Color.white)
                    .listRowSeparator(.hidden)
            }
            .onAppear {
                if currentLine > 0 {
                    proxy.scrollTo(lines.last!.id, anchor: .bottom)
                }
            }
            .onChange(of: currentLine) { newValue in
                if currentLine > 0 {
                    proxy.scrollTo(lines.last!.id, anchor: .bottom)
                }
            }
            .onReceive(timePublisher) { (date) in
                updateLog()
            }
            .listStyle(PlainListStyle())
            .environment(\.defaultMinListRowHeight, 10)
        }
    }
}

struct Log_Previews: PreviewProvider {
    static var previews: some View {
        LogView(rcl57: RCL57())
    }
}
