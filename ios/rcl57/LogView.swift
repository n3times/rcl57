import SwiftUI

struct Line: Identifiable {
    let left: String
    let right: String
    let id: Int

    init(left: String, right: String, id: Int) {
        self.left = left
        self.right = right
        self.id = id
    }
}

struct LineView: View {
    let left: String
    let right: String

    init(left: String, right: String) {
        self.left = left
        self.right = right
    }

    var body: some View {
        HStack {
            Text(left)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
            Spacer(minLength: 25)
            Text(right)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .leading)
        } .font(.callout)
    }
}

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

    func makeLine(left: String, right: String) -> Line {
        return Line(left: left, right: right, id: currentLine)
    }

    func clear() {
        lines.removeAll()
        currentLine = 0
        lastTimestamp = 0
        lastLoggedCount = 0
    }

    func updateLog() {
        let newTimestamp = rcl57.getLogTimestamp()
        if newTimestamp == lastTimestamp { return }  // No changes.
        lastTimestamp = newTimestamp

        let newLoggedCount = rcl57.getLoggedCount()
        if newLoggedCount == 0 { clear(); return }

        var left = lines.last?.left
        var right = lines.last?.right
        if (lastLoggedCount > 0) {
            let type = rcl57.getLogType(index: lastLoggedCount)
            if type == LOG57_OP || type == LOG57_PENDING_OP {
                right = rcl57.getLogMessage(index: lastLoggedCount)
            } else {
                left = rcl57.getLogMessage(index: lastLoggedCount)
            }
            lines.removeLast()
            lines.append(makeLine(left: left!, right: right!))
        }

        if (newLoggedCount > lastLoggedCount) {
            for i in lastLoggedCount+1...newLoggedCount {
                let type = rcl57.getLogType(index: i)
                if type == LOG57_OP || type == LOG57_PENDING_OP {
                    let left = lines.last?.left
                    let right = lines.last?.right
                    if right == "" {
                        lines.removeLast()
                        lines.append(makeLine(left: left!, right: rcl57.getLogMessage(index: i)))
                    } else {
                        currentLine += 1
                        lines.append(makeLine(left: "", right: rcl57.getLogMessage(index: i)))
                    }
                } else {
                    currentLine += 1
                    lines.append(makeLine(left: rcl57.getLogMessage(index: i), right: ""))
                }
            }
        }

        lastLoggedCount = newLoggedCount
    }

    var body: some View {
        ScrollViewReader { proxy in
            List(lines) {
                LineView(left: $0.left, right: $0.right)
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
