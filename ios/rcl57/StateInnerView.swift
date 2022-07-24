/**
 * A mini view that shows the user program.
 */

import SwiftUI

/** Data for a ProgramLineView: a step index and an operation. */
private struct ProgramLine: Identifiable {
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
        self.id = ProgramLine.lineId
        ProgramLine.lineId += 1
    }
}

/** A line view in a ProgramView: a number on the left and an operation on the right. */
private struct ProgramLineView: View {
    private let line: ProgramLine
    private let activeBackgroundColor = Style.ivory
    private let inactiveBackgroundColor = Style.ivory
    private let foregroundColor = Style.blackish
    private let inactiveForegroundColor = Style.blackish

    init(line: ProgramLine) {
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
        .font(Style.listLineFont)
        .listRowBackground(line.active ? activeBackgroundColor
                                       : inactiveBackgroundColor)
        .background(line.active ? activeBackgroundColor : inactiveBackgroundColor)
        .foregroundColor(line.active ? foregroundColor: inactiveForegroundColor)
    }
}

private struct RegisterLine: Identifiable {
    static var lineId = 0
    let index: Int
    let reg: String
    let id: Int

    init(index: Int, reg: String) {
        self.index = index
        self.reg = reg
        self.id = ProgramLine.lineId
        RegisterLine.lineId += 1
    }
}

private struct RegisterLineView: View {
    private let line: RegisterLine
    private let backgroundColor = Style.ivory
    private let foregroundColor = Style.blackish

    init(line: RegisterLine) {
        self.line = line
    }

    var body: some View {
        return HStack {
            Spacer(minLength: 10)
            Text(String(format: "   %d", line.index))
                .frame(maxWidth: 100, idealHeight:10, alignment: .leading)
            Text(line.reg)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
            Spacer(minLength: 20)
        }
        .font(Style.listLineFont)
        .listRowBackground(backgroundColor)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
    }
}

struct StateInnerView: View {
    @State private var lines : [ProgramLine] = []

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

    private func getRegisterLineView(_ index: Int) -> some View {
        return RegisterLineView(line: RegisterLine(index: index,
                                                   reg: Rcl57.shared.getRegister(index: index)))
        .listRowSeparator(.hidden)
    }

    private func getProgramLineView(_ index: Int, active: Bool) -> some View {
        let c = Rcl57.shared.getProgramPc()
        let last = Rcl57.shared.getProgramLastIndex()

        if index == -1 {
            return ProgramLineView(line: ProgramLine(index: 99,
                                       op: "",
                                       active: isMiniView || index <= last,
                                       isPc: isMiniView && c == -1))
            .listRowSeparator(.hidden)
        }
        return ProgramLineView(line: ProgramLine(index: index,
                                   op: Rcl57.shared.getProgramOp(index: index, isAlpha: true),
                                   active: isMiniView || index <= last,
                                   isPc: isMiniView && index == c))
        .listRowSeparator(.hidden)
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if (isMiniView || change.showStepsInState) {
                    ForEach(((self.isHpLrn && isMiniView) ? -1 : 0)...49, id: \.self) {
                        getProgramLineView($0, active: $0 == pc)
                    }
                } else {
                    ForEach(0...7, id: \.self) {
                        getRegisterLineView($0)
                    }
                }
            }
            .background(Style.ivory)
            .listStyle(PlainListStyle())
            .environment(\.defaultMinListRowHeight, Style.listLineHeight)
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
            .onReceive(change.$showMiniView) { _ in
                if isMiniView && change.showMiniView {
                    updateMiddle()
                    proxy.scrollTo(middle, anchor: .bottom)
                }
            }
        }
    }
}

struct StateInnerView_Previews: PreviewProvider {
    static var previews: some View {
        StateInnerView(isMiniView: false)
    }
}
