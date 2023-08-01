import SwiftUI

private enum ProgramType {
    case new
    case readOnly
    case readWrite
}

private func getProgramType(program: Prog57?) -> ProgramType {
    if let program {
        return program.isReadOnly ? .readOnly : .readWrite
    } else {
        return .new
    }
}

private struct LibInfoView: View {
    @EnvironmentObject var change: Change

    var body: some View {
        let program = change.loadedProgram
        let programType = getProgramType(program: program)

        GeometryReader { proxy in
            let width = proxy.size.width
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: width / 3, height: 20, alignment: .leading)

                Text(programType == .readOnly ? "Samples" : programType == .readWrite ? "User" : "")
                    .offset(y: -3)
                    .frame(width: width / 3, height: 20)

                Spacer()
                    .frame(width: width / 3, height: 20)
            }
            .background(Color.blackish)
            .foregroundColor(.ivory)
            .font(Style.programFont)
        }
        .frame(height: 20)
    }
}

private struct FooterView: View {
    @EnvironmentObject var change: Change

    @State private var isPresentingClose = false
    @State private var isPresentingClear = false
    @State private var isPresentingSave = false

    var body: some View {
        let program = change.loadedProgram
        let programType = getProgramType(program: program)
        let stateNeedsSaving: Bool = {
            guard let program else { return false }
            if programType != .readWrite { return false }
            if change.isStepsInState {
                return program.stepsNeedSaving()
            } else {
                return program.registersNeedSaving()
            }
        }()

        GeometryReader { proxy in
            let width = proxy.size.width
            HStack(spacing: 0) {
                Button("CLOSE") {
                    isPresentingClose = true
                }
                .font(Style.footerFont)
                .frame(width: width / 3, height: Style.footerHeight)
                .disabled(program == nil)
                .buttonStyle(.plain)
                .confirmationDialog("Close?", isPresented: $isPresentingClose) {
                    if let program {
                        Button("Close \(program.name)", role: .destructive) {
                            change.setLoadedProgram(program: nil)
                        }
                    }
                }

                Button("CLEAR") {
                    isPresentingClear = true
                }
                .font(Style.footerFont)
                .frame(width: width / 3, height: Style.footerHeight)
                .disabled(change.isStepsInState ? Rcl57.shared.getProgramLastIndex() == -1
                          : Rcl57.shared.getRegistersLastIndex() == -1)
                .buttonStyle(.plain)
                .confirmationDialog("Clear?", isPresented: $isPresentingClear) {
                    if change.isStepsInState {
                        Button("Clear Steps", role: .destructive) {
                            Rcl57.shared.clearProgram()
                            change.forceUpdate()
                        }
                    } else {
                        Button("Clear Registers", role: .destructive) {
                            Rcl57.shared.clearRegisters()
                            change.forceUpdate()
                        }
                    }
                }

                Button(programType == .readWrite ? "SAVE" : "NEW") {
                    if programType == .readWrite {
                        isPresentingSave = true
                    } else {
                        change.isPreviewInEditProgram = false
                        withAnimation {
                            change.isCreateProgramInState = true
                        }
                    }
                }
                .font(Style.footerFont)
                .frame(width: width / 3, height: Style.footerHeight)
                .buttonStyle(.plain)
                .disabled(programType == .readWrite && !stateNeedsSaving)
                .confirmationDialog("Save?", isPresented: $isPresentingSave) {
                    if programType == .readWrite {
                        Button("Save " + (change.isStepsInState ? "Steps" : "Registers"), role: .destructive) {
                            if let program {
                                if change.isStepsInState {
                                    program.setStepsFromMemory()
                                } else {
                                    program.setRegistersFromMemory()
                                }
                                _ = program.save(filename: program.name)
                                change.forceUpdate()
                            }
                        }
                    }
                }
            }
            .background(Color.blackish)
            .foregroundColor(.ivory)
        }
        .frame(height: Style.footerHeight)
    }
}

/**
 * The steps and registers of the calculator.
 */
struct StateView: View {
    @EnvironmentObject var change: Change

    var body: some View {
        let program = change.loadedProgram
        let viewTitle: String = {
            guard let program else {
                return change.isStepsInState ? "Steps" : "Registers"
            }
            if program.stepsNeedSaving() {
                return "\(program.name)'"
            } else {
                return program.name
            }
        }()

        ZStack {
            VStack(spacing: 0) {
                NavigationBar(left: change.isStepsInState ? Style.yang : Style.ying,
                              title: viewTitle,
                              right: Style.rightArrow,
                              leftAction: { change.isStepsInState.toggle() },
                              rightAction: { withAnimation { change.currentViewType = .calc } })
                .background(Color.blackish)

                if program != nil {
                    LibInfoView()
                }

                StateContentView()
                FooterView()
            }

            if change.isCreateProgramInState {
                ProgramEditView()
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
}

struct StateView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramEditView()
    }
}
