/**
 * The view that shows the user program.
 */

import SwiftUI

/** Data for a LineView: a step index and an operation. */
private struct Line: Identifiable {
    static var lineId = 0
    let index: Int
    let op: String
    let active: Bool
    let id: Int

    init(index: Int, op: String, active: Bool) {
        self.index = index
        self.op = op
        self.active = active
        self.id = Line.lineId
        Line.lineId += 1
    }
}

/** A line view in a ProgramView: a number on the left and an operation on the right. */
private struct LineView: View {
    let line: Line

    init(line: Line) {
        self.line = line
    }

    var body: some View {
        HStack {
            Spacer(minLength: 30)
            Text(String(format: "%02d", line.index))
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .leading)
            Text(line.op)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
            Spacer(minLength: 10)
        }
        .padding(3.0)
        .font(Font.system(.title3, design: .monospaced))
        .listRowBackground(Color.black)
        .background(line.active ? .white : .gray)
        .foregroundColor(.black)
    }
}

/** A list of LineView's. */
struct ProgramView: View {
    let rcl57 : RCL57
    @State private var lines : [Line] = []

    init(rcl57: RCL57, maxLines: Int32) {
        self.rcl57 = rcl57
    }

    private func makeLine(index: Int, op: String, active: Bool) -> Line {
        return Line(index: index, op: op, active: active)
    }

    private func getLineView(_ line: Line) -> some View {
        return LineView(line: line)
    }

    var body: some View {
        ScrollViewReader { proxy in
            List(lines) {
                getLineView($0)
            }
            .onAppear {
                let last_index = rcl57.getProgramLastIndex()
                for i in 0...49 {
                    let op = rcl57.getProgramStep(index: Int32(i))
                    lines.append(makeLine(index: i, op: op, active: i <= last_index))
                }
            }
            .listStyle(PlainListStyle())
            .environment(\.defaultMinListRowHeight, 10)
        }
    }
}

struct ProgramView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramView(rcl57: RCL57(), maxLines: 3)
    }
}
