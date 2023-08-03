import SwiftUI

private struct StepLineView: View {
    /// Data for a StepLineView: a step index and an operation.
    struct StepLineData: Identifiable {
        static var lineId = 0
        let index: Int
        let op: String
        let active: Bool
        let id: Int

        init(index: Int, op: String, active: Bool) {
            self.index = index
            self.op = op
            self.active = active
            self.id = StepLineData.lineId
            StepLineData.lineId += 1
        }
    }

    private let line: StepLineData
    private let activeBackgroundColor = Color.ivory
    private let inactiveBackgroundColor = Color.lightGray
    private let foregroundColor = Color.blackish
    private let inactiveForegroundColor = Color.blackish

    init(line: StepLineData) {
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

private struct RegisterLineView: View {
    struct RegisterLine: Identifiable {
        static var lineId = 0
        let index: Int
        let reg: String
        let id: Int

        init(index: Int, reg: String) {
            self.index = index
            self.reg = reg
            self.id = RegisterLine.lineId
            RegisterLine.lineId += 1
        }
    }

    private let line: RegisterLine
    private let backgroundColor = Color.ivory
    private let foregroundColor = Color.blackish

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

private struct ProgramLineView: View {
    let last = Rcl57.shared.getProgramLastIndex()
    let index: Int
    let active: Bool

    var body: some View {
        if index == -1 {
            return StepLineView(line: StepLineView.StepLineData(index: 99,
                                                            op: "",
                                                            active: index <= last))
            .listRowSeparator(.hidden)
        }
        return StepLineView(line: StepLineView.StepLineData(index: index,
                                                        op: Rcl57.shared.getProgramOp(index: index, isAlpha: true),
                                                        active: index <= last))
        .listRowSeparator(.hidden)
    }
}

struct StateContentView: View {
    @EnvironmentObject private var change: Change

    @State private var lines: [StepLineView.StepLineData] = []
    @State private var middle: Int
    @State private var pc: Int
    @State private var isOpEditInLrn: Bool
    @State private var isHpLrn: Bool

    // Use a timer to refresh the registers in case they have change. This is necessary because
    // those belong to the emulator and are not directly observed by SwifUI.
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    @State private var refreshCounter: Int64 = 0

    init() {
        let pc = Rcl57.shared.programPc
        self.pc = pc
        self.isOpEditInLrn = Rcl57.shared.isOpEditInLrn
        self.isHpLrn = Rcl57.shared.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG)
        if pc == -1 { middle = 0 }
        else if pc == 0 && !Rcl57.shared.getOptionFlag(option: RCL57_HP_LRN_MODE_FLAG) { middle = 1 }
        else if pc == 49 { middle = 48 }
        else { middle = pc}
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if change.stateViewMode == .steps {
                    ForEach(0...49, id: \.self) {
                        ProgramLineView(index: $0, active: $0 == pc)
                    }
                } else {
                    ForEach(0...7, id: \.self) {
                        RegisterLineView(line: RegisterLineView.RegisterLine(
                            index: $0,
                            reg: Rcl57.shared.getRegister(index: $0)
                        ))
                        .listRowSeparator(.hidden)
                    }
                    .id(refreshCounter)
                }
            }
            .background(Color.ivory)
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Style.listLineHeight)
        }
        .onReceive(timer) { _ in
            refreshCounter += 1
        }
    }
}

struct StateContentView_Previews: PreviewProvider {
    static var previews: some View {
        StateContentView()
    }
}
