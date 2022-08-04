import SwiftUI

/** Data for a StepLineView: a step index and an operation. */
private struct StepLine: Identifiable {
    static var lineId = 0
    let index: Int
    let op: String
    let active: Bool
    let id: Int

    init(index: Int, op: String, active: Bool) {
        self.index = index
        self.op = op
        self.active = active
        self.id = StepLine.lineId
        StepLine.lineId += 1
    }
}

private struct StepLineView: View {
    private let line: StepLine
    private let activeBackgroundColor = Style.ivory
    private let inactiveBackgroundColor = Style.ivory
    private let foregroundColor = Style.blackish
    private let inactiveForegroundColor = Style.blackish

    init(line: StepLine) {
        self.line = line
    }

    var body: some View {
        return HStack {
            Spacer(minLength: 10)
            Text(line.index == 99 ? "  LRN" : String(format: "   %02d", line.index))
            .frame(maxWidth: .infinity, idealHeight:10, alignment: .leading)
            Text(line.op)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
            Spacer(minLength: 20)
        }
        .font(Style.listLineFont)
        .listRowBackground(line.active ? activeBackgroundColor
                           : inactiveBackgroundColor)
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
        self.id = StepLine.lineId
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
            Text(String(format: "   R%d", line.index))
                .frame(maxWidth: 100, idealHeight:10, alignment: .leading)
            Text(line.reg)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
            Spacer(minLength: 20)
        }
        .font(Style.listLineFont)
        .listRowBackground(backgroundColor)
        .foregroundColor(foregroundColor)
    }
}

struct StateInnerView: View {
    @State private var lines: [StepLine] = []
    @State private var middle: Int
    @State private var pc: Int
    @State private var isOpEditInLrn: Bool
    @State private var isHpLrn: Bool

    @EnvironmentObject var change: Change

    init() {
        let pc = Rcl57.shared.getProgramPc()
        self.pc = pc
        self.isOpEditInLrn = Rcl57.shared.isOpEditInLrn()
        self.isHpLrn = Rcl57.shared.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        if pc == -1 { middle = 0 }
        else if pc == 0 && !Rcl57.shared.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG) { middle = 1 }
        else if pc == 49 { middle = 48 }
        else { middle = pc}
    }

    private func getRegisterLineView(_ index: Int) -> some View {
        return RegisterLineView(line: RegisterLine(index: index,
                                                   reg: Rcl57.shared.getRegister(index: index)))
        .listRowSeparator(.hidden)
    }

    private func getProgramLineView(_ index: Int, active: Bool) -> some View {
        let last = Rcl57.shared.getProgramLastIndex()

        if index == -1 {
            return StepLineView(line: StepLine(index: 99,
                                               op: "",
                                               active: index <= last))
            .listRowSeparator(.hidden)
        }
        return StepLineView(line: StepLine(index: index,
                                           op: Rcl57.shared.getProgramOp(index: index, isAlpha: true),
                                           active: index <= last))
        .listRowSeparator(.hidden)
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if change.showStepsInState {
                    ForEach(0...49, id: \.self) {
                        getProgramLineView($0, active: $0 == pc)
                    }
                } else {
                    ForEach(0...7, id: \.self) {
                        getRegisterLineView($0)
                    }
                }
            }
            .background(Style.ivory)
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Style.listLineHeight)
        }
    }
}

struct StateInnerView_Previews: PreviewProvider {
    static var previews: some View {
        StateInnerView()
    }
}
