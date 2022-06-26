/**
 * A mini view that shows the user program.
 */

import SwiftUI

/** Data for a LineView: a step index and an operation. */
private struct Line: Identifiable {
    static var lineId = 0
    let index: Int
    let op: String
    let active: Bool
    let isPc: Bool
    let id: Int

    init(index: Int, op: String, active: Bool, isPc: Bool) {
        self.index = index
        self.op = op
        self.active = active
        self.isPc = isPc
        self.id = Line.lineId
        Line.lineId += 1
    }
}

/** A line view in a ProgramView: a number on the left and an operation on the right. */
private struct LineView: View {
    private let line: Line
    private let activeBackgroundColor = Style.ivory
    private let inactiveBackgroundColor = Style.ivory
    private let foregroundColor = Style.blackish
    private let inactiveForegroundColor = Style.blackish

    init(line: Line) {
        self.line = line
    }

    var body: some View {
        return HStack {
            Spacer(minLength: 10)
            Text(line.index == 99 ? (line.isPc ? "> LRN" : "  LRN")
                                  : String(format: "%@  %02d", line.isPc ? ">" : " ", line.index))
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .leading)
            Text(line.op)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
            Spacer(minLength: 20)
        }
        .font(Style.lineFont)
        .listRowBackground(line.active ? activeBackgroundColor
                                       : inactiveBackgroundColor)
        .background(line.active ? activeBackgroundColor : inactiveBackgroundColor)
        .foregroundColor(line.active ? foregroundColor: inactiveForegroundColor)
    }
}

struct LrnView: View {
    @State private var lines : [Line] = []

    private let isMiniView: Bool

    @State private var middle: Int
    @State private var pc: Int
    @State private var isOpEditInLrn: Bool
    @State private var isHpLrn: Bool

    @EnvironmentObject var change: Change

    init(isMiniView: Bool) {
        let pc = Rcl57.shared.getProgramPc()
        self.isMiniView = isMiniView
        self.pc = pc
        self.isOpEditInLrn = Rcl57.shared.isOpEditInLrn()
        self.isHpLrn = Rcl57.shared.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        if pc == -1 { middle = 0 }
        else if pc == 0 && !Rcl57.shared.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG) { middle = 1 }
        else if pc == 49 { middle = 48 }
        else { middle = pc}
    }

    private func updateMiddle() {
        let pc = Rcl57.shared.getProgramPc()
        middle = pc
        self.pc = pc
        self.isOpEditInLrn = Rcl57.shared.isOpEditInLrn()
        self.isHpLrn = Rcl57.shared.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        if pc == -1 { middle = 0 }
        else if pc == 0 && !self.isHpLrn { middle = 1 }
        else { middle = pc }
    }

    private func getLineView(_ index: Int, active: Bool) -> some View {
        let c = Rcl57.shared.getProgramPc()
        let last = Rcl57.shared.getProgramLastIndex()

        if index == -1 {
            return LineView(line: Line(index: 99,
                                       op: "",
                                       active: isMiniView || index <= last,
                                       isPc: isMiniView && c == -1))
            .listRowSeparator(.hidden)
        }
        return LineView(line: Line(index: index,
                                   op: Rcl57.shared.getProgramOp(index: index, isAlpha: true),
                                   active: isMiniView || index <= last,
                                   isPc: isMiniView && index == c))
        .listRowSeparator(.hidden)
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(((self.isHpLrn && isMiniView) ? -1 : 0)...49, id: \.self) {
                    getLineView($0, active: $0 == pc)
                }
            }
            .onAppear {
                if isMiniView {
                    updateMiddle()
                    proxy.scrollTo(middle, anchor: .bottom)
                }
            }
            .onChange(of: self.isOpEditInLrn) { _ in
                if isMiniView {
                    proxy.scrollTo(pc, anchor: .bottom)
                }
            }
            .onReceive(change.$changeCount) { _ in
                if isMiniView {
                    updateMiddle()
                    proxy.scrollTo(middle, anchor: .bottom)
                }
            }
            .onReceive(change.$isMiniViewVisible) { _ in
                if isMiniView && change.isMiniViewVisible {
                    updateMiddle()
                    proxy.scrollTo(middle, anchor: .bottom)
                }
            }
            .listStyle(PlainListStyle())
            .environment(\.defaultMinListRowHeight, Style.lineHeight)
        }
    }
}

struct LrnView_Previews: PreviewProvider {
    static var previews: some View {
        LrnView(isMiniView: false)
    }
}
