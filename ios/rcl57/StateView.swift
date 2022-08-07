import SwiftUI

/** The steps and registers of the calculator. */
struct StateView: View {
    @EnvironmentObject var change: Change

    @State private var isPresentingClose: Bool = false
    @State private var isPresentingClear: Bool = false
    @State private var isPresentingSave: Bool = false

    var body: some View {
        let program = change.loadedProgram
        let programName = program?.getName()
        let isProgramNew = program == nil
        let isProgramReadOnly = !isProgramNew && program!.readOnly
        let isProgramReadWrite = !isProgramNew && !isProgramReadOnly
        let stateTypeName = change.isStepsInState ? "Steps" : "Registers"
        let viewTitle = isProgramNew ? stateTypeName : (program!.readOnly ? "" : "") + programName!

        ZStack {
            GeometryReader { geometry in
                let width = geometry.size.width

                VStack(spacing: 0) {
                    MenuBarView(change: change,
                                left: change.isStepsInState ? Style.yang : Style.ying,
                                title: viewTitle + (!isProgramNew && program!.stepsNeedSaving() ? "'" : ""),
                                right: Style.rightArrow,
                                width: width,
                                leftAction: { change.isStepsInState.toggle() },
                                rightAction: { withAnimation {change.currentView = .calc} })
                    .background(Style.blackish)

                    // Type (steps or registers)
                    if !isProgramNew {
                        HStack(spacing: 0) {
                            Spacer()
                                .frame(width: width / 3, height: 20, alignment: .leading)

                            Text(isProgramReadOnly ? "Samples" : isProgramReadWrite ? "User" : "")
                                .offset(y: -3)
                                .frame(width: width / 3, height: 20)

                            Spacer()
                                .frame(width: width / 3, height: 20)
                        }
                        .background(Style.blackish)
                        .foregroundColor(Style.ivory)
                        .font(Style.programFont)
                    }

                    // State
                    StateInnerView()
                        .background(Style.ivory)

                    HStack(spacing: 0) {
                        Button("CLOSE") {
                            isPresentingClose = true
                        }
                        .font(Style.footerFont)
                        .frame(width: width / 3, height: Style.footerHeight)
                        .disabled(isProgramNew)
                        .buttonStyle(.plain)
                        .confirmationDialog("Close?", isPresented: $isPresentingClose) {
                            if !isProgramNew {
                                Button("Close " + programName!, role: .destructive) {
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

                        Button(isProgramReadWrite ? "SAVE" : "NEW") {
                            if isProgramReadWrite {
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
                        .disabled(isProgramReadWrite && (change.isStepsInState ? !program!.stepsNeedSaving()
                                                         : !program!.registersNeedSaving()))
                        .confirmationDialog("Save?", isPresented: $isPresentingSave) {
                            if isProgramReadWrite {
                                Button("Save " + (change.isStepsInState ? "Steps" : "Registers"), role: .destructive) {
                                    if change.isStepsInState {
                                        program!.setStepsFromMemory()
                                    } else {
                                        program!.setRegistersFromMemory()
                                    }
                                    _ = program!.save(filename: programName!)
                                    change.forceUpdate()
                                }
                            }
                        }
                    }
                    .background(Style.blackish)
                    .foregroundColor(Style.ivory)
                }
            }

            if change.isCreateProgramInState {
                ProgramEditView()
                    .environmentObject(change)
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
