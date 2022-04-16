/**
 * A mini view that shows the user program.
 */

import SwiftUI

/** Data for a LineView: a step index and an operation. */
private struct Line {
    let index: Int
    let op: String
    let active: Bool
    let isPc: Bool

    init(index: Int, op: String, active: Bool, isPc: Bool) {
        self.index = index
        self.op = op
        self.active = active
        self.isPc = isPc
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
            Spacer(minLength: 10)
            Text(line.index == 99 ? (line.isPc ? "> LRN" : "  LRN")
                                  : String(format: "%@  %02d", line.isPc ? ">" : " ", line.index))
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .leading)
            Text(line.op)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
            Spacer(minLength: 20)
        }
        .padding(3.0)
        .font(Font.system(.title3, design: .monospaced))
        .listRowBackground(Color.black)
        .background(line.active ? .white : .gray)
        .foregroundColor(.black)
    }
}

struct MiniProgramView: View {
    let rcl57: RCL57
    let middle: Int
    @State private var pc: Int

    init(rcl57: RCL57) {
        let pc = rcl57.getProgramPc()
        self.rcl57 = rcl57
        self.pc = pc
        if pc == -1 { middle = 0 }
        else if pc == 0 && !rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG) { middle = 1 }
        else if pc == 49 { middle = 48 }
        else { middle = pc }
    }

    private func makeLine(index: Int, op: String, active: Bool, isPc: Bool) -> Line {
        return Line(index: index, op: op, active: active, isPc: isPc)
    }

    private func getLineView(_ index: Int, active: Bool) -> some View {
        let c = rcl57.getProgramPc()
        let last = rcl57.getProgramLastIndex()
        if index == -1 {
            return LineView(line: Line(index: 99, op: "", active: index <= last, isPc: c == -1))
        }
        return LineView(line: Line(index: index,
                                   op: rcl57.getProgramStep(index: index),
                                   active: index <= last,
                                   isPc: index == c))
    }

    var body: some View {
        Self._printChanges()
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(-1...1, id: \.self) {
                getLineView(middle + $0, active: middle + $0 == pc)
            }
        }
        .lineSpacing(0)
    }
}

struct MiniProgramView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramView(rcl57: RCL57(), maxLines: 3)
    }
}
