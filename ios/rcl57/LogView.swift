import SwiftUI

struct Line: Identifiable {
    let content: String
    let id: Int

    init(content: String, id: Int) {
        self.content = content
        self.id = id
    }
}

struct LogView: View {
    let rcl57 : RCL57
    @State private var lines : [Line] = []
    @State private var numLines = 0;
    @State private var lastTimestamp = 0;
    @State private var lastLoggedCount = 0;
    private let maxLines = 1000
    private let timePublisher = Timer.TimerPublisher(interval: 0.02, runLoop: .main, mode: .default)
        .autoconnect()

    init(rcl57: RCL57) {
        self.rcl57 = rcl57
    }

    func makeLine(content: String) -> Line {
        return Line(content: content, id: numLines)
    }

    func clear() {
        lines.removeAll()
        numLines = 0
        lastTimestamp = 0
        lastLoggedCount = 0
    }

    func updateLog() {
        let newTimestamp = rcl57.getLogTimestamp()
        if newTimestamp == lastTimestamp { return }  // No changes.
        lastTimestamp = newTimestamp

        let newLoggedCount = rcl57.getLoggedCount()
        if newLoggedCount == 0 { clear(); return }
        if newLoggedCount == lastLoggedCount {
            // Change to the last log line.
            lines.removeLast()
            lines.append(makeLine(content: rcl57.getLogMessage(index: numLines)))
            return
        }

        // At least a new line.

        if numLines >= maxLines {
            lines.removeFirst()
        }

        var reAdd = false
        if numLines > 0 {
            // Remove the last line in case it needs to be updated
            lines.removeLast()
            numLines -= 1
            reAdd = true
        }

        let start = reAdd ? lastLoggedCount : lastLoggedCount + 1
        for _ in start...newLoggedCount {
            numLines += 1
            lines.append(makeLine(content: rcl57.getLogMessage(index: numLines)))
        }
        lastLoggedCount = newLoggedCount
    }

    var body: some View {
        ScrollViewReader { proxy in
            List(lines) {
                Text($0.content)
                    .listRowBackground(Color.black)
                    .foregroundColor(Color.white)
                    .listRowSeparator(.hidden)
            }
            .onAppear {
                if numLines > 0 {
                    proxy.scrollTo(lines.last!.id, anchor: .bottom)
                }
            }
            .onChange(of: numLines) { newValue in
                if numLines > 0 {
                    proxy.scrollTo(lines.last!.id, anchor: .bottom)
                }
            }
            .onReceive(timePublisher) { (date) in
                updateLog()
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct Log_Previews: PreviewProvider {
    static var previews: some View {
        LogView(rcl57: RCL57())
    }
}
