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
        let stateTypeName = change.showStepsInState ? "Steps" : "Registers"
        let viewTitle = isProgramNew ? stateTypeName : (program!.readOnly ? "" : "") + programName!

        ZStack {
            GeometryReader { geometry in
                let width = geometry.size.width

                VStack(spacing: 0) {
                    MenuBarView(change: change,
                                left: change.showStepsInState ? Style.yang : Style.ying,
                                title: viewTitle + (!isProgramNew && program!.stepsNeedSaving() ? "'" : ""),
                                right: Style.rightArrow,
                                width: width,
                                leftAction: { change.showStepsInState.toggle() },
                                rightAction: { withAnimation {change.currentView = .calc} })
                    .background(Style.blackish)

                    // Type (steps or registers)
                    HStack(spacing: 0) {
                        Button(isProgramNew ? "" : stateTypeName.uppercased()) {
                            change.showStepsInState.toggle()
                        }
                        .offset(x: 15, y: -3)
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
                        .confirmationDialog("Are you sure?", isPresented: $isPresentingClose) {
                            if !isProgramNew {
                                Button("Close " + programName!, role: .destructive) {
                                    change.setLoadedProgram(program: nil)
                                    change.forceUpdate()
                                }
                            }
                        }

                        Button("CLEAR") {
                            isPresentingClear = true
                        }
                        .font(Style.footerFont)
                        .frame(width: width / 3, height: Style.footerHeight)
                        .disabled(change.showStepsInState ? Rcl57.shared.getProgramLastIndex() == -1
                                  : Rcl57.shared.getRegistersLastIndex() == -1)
                        .buttonStyle(.plain)
                        .confirmationDialog("Are you sure?", isPresented: $isPresentingClear) {
                            if change.showStepsInState {
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
                                change.showPreview = false
                                withAnimation {
                                    change.createProgram = true
                                }
                            }
                        }
                        .font(Style.footerFont)
                        .frame(width: width / 3, height: Style.footerHeight)
                        .buttonStyle(.plain)
                        .disabled(isProgramReadWrite && (change.showStepsInState ? !program!.stepsNeedSaving()
                                                  : !program!.registersNeedSaving()))
                        .confirmationDialog("Are you sure?", isPresented: $isPresentingSave) {
                            if isProgramReadWrite {
                                Button("Save " + (change.showStepsInState ? "Steps" : "Registers"), role: .destructive) {
                                    if change.showStepsInState {
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

            if change.createProgram {
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
