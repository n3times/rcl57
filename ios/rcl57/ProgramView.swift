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
    let inactiveColor = Color(red: 0.8, green: 0.8, blue: 0.8)

    init(line: Line) {
        self.line = line
    }

    var body: some View {
        Self._printChanges()
        return HStack {
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
        .background(line.active ? .white : inactiveColor)
        .foregroundColor(.black)
    }
}

struct ProgramView: View {
    private let rcl57: RCL57
    private let showPc: Bool

    @State private var middle: Int
    @State private var pc: Int
    @State private var isOpEditInLrn: Bool
    @State private var isHpLrn: Bool
    @EnvironmentObject var change: Change

    init(rcl57: RCL57, showPc: Bool) {
        let pc = rcl57.getProgramPc()
        self.rcl57 = rcl57
        self.showPc = showPc
        self.pc = pc
        self.isOpEditInLrn = rcl57.isOpEditInLrn()
        self.isHpLrn = rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        if pc == -1 { middle = 0 }
        else if pc == 0 && !rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG) { middle = 1 }
        else if pc == 49 { middle = 48 }
        else { middle = pc }
    }

    private func updateMiddle() {
        let pc = rcl57.getProgramPc()
        self.pc = pc
        self.isOpEditInLrn = rcl57.isOpEditInLrn()
        self.isHpLrn = rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        if pc == -1 { middle = 0 }
        else if pc == 0 && !rcl57.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG) { middle = 1 }
        else if pc == 49 { middle = 48 }
        else { middle = pc }
    }

    private func getLineView(_ index: Int, active: Bool) -> some View {
        let c = rcl57.getProgramPc()
        let last = rcl57.getProgramLastIndex()
        if index == -1 {
            return LineView(line: Line(index: 99,
                                       op: "",
                                       active: index <= last,
                                       isPc: showPc && c == -1))
        }
        return LineView(line: Line(index: index,
                                   op: rcl57.getProgramOp(index: index, isAlpha: true),
                                   active: index <= last,
                                   isPc: showPc && index == c))
    }

    var body: some View {
        Self._printChanges()
        return ScrollView {
            ScrollViewReader { proxy in
                VStack(alignment: .leading, spacing: 0) {
                    ForEach((self.isHpLrn ? -1 : 0)...49, id: \.self) {
                        getLineView($0, active: $0 == pc)
                            .frame(height: 28)
                            .lineSpacing(0)
                    }
                }
                .onAppear {
                    if showPc {
                        proxy.scrollTo(middle, anchor: .center)
                    }
                }
                .onChange(of: self.isOpEditInLrn) { _ in
                    if showPc {
                        proxy.scrollTo(pc, anchor: .center)
                    }
                }
                .onReceive(change.$changeCount) { _ in
                    if showPc {
                        updateMiddle()
                        proxy.scrollTo(middle, anchor: .center)
                    }
                }
                .onTapGesture(count: 1) {
                    withAnimation {
                        proxy.scrollTo(middle, anchor: .center)
                    }
                }
            }
        }
    }
}

struct ProgramView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramView(rcl57: RCL57(), showPc: false)
    }
}
