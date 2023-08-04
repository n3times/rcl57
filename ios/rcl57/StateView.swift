import SwiftUI

private enum ProgramType {
    case new
    case readOnly
    case readWrite
}

private func programType(forProgram program: Prog57?) -> ProgramType {
    if let program {
        return program.isReadOnly ? .readOnly : .readWrite
    } else {
        return .new
    }
}

/// Displays the name of the library the program belongs too.
private struct LibInfoView: View {
    @EnvironmentObject private var appState: AppState

    var program: Prog57

    var body: some View {
        let programType = programType(forProgram: program)

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

/// Allows the user to clear and save the state.
private struct StateViewToolbar: View {
    @EnvironmentObject private var appState: AppState

    @State private var isPresentingClose = false
    @State private var isPresentingClear = false
    @State private var isPresentingSave = false

    @Binding var refreshCounter: Int64

    var body: some View {
        let program = appState.loadedProgram
        let programType = programType(forProgram: program)
        let stateNeedsSaving: Bool = {
            guard let program else { return false }
            if programType != .readWrite { return false }
            if appState.stateViewMode == .steps {
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
                .font(Style.toolbarFont)
                .frame(width: width / 3, height: Style.toolbarHeight)
                .disabled(program == nil)
                .buttonStyle(.plain)
                .confirmationDialog("Close?", isPresented: $isPresentingClose) {
                    if let program {
                        Button("Close \(program.name)", role: .destructive) {
                            appState.loadedProgram = nil
                        }
                    }
                }

                Button("CLEAR") {
                    isPresentingClear = true
                }
                .font(Style.toolbarFont)
                .frame(width: width / 3, height: Style.toolbarHeight)
                .disabled(appState.stateViewMode == .steps ? Rcl57.shared.programLastIndex == -1
                          : Rcl57.shared.registersLastIndex == -1)
                .buttonStyle(.plain)
                .confirmationDialog("Clear?", isPresented: $isPresentingClear) {
                    if appState.stateViewMode == .steps {
                        Button("Clear Steps", role: .destructive) {
                            Rcl57.shared.clearProgram()
                            refreshCounter += 1
                        }
                    } else {
                        Button("Clear Registers", role: .destructive) {
                            Rcl57.shared.clearRegisters()
                            refreshCounter += 1
                        }
                    }
                }

                Button(programType == .readWrite ? "SAVE" : "NEW") {
                    if programType == .readWrite {
                        isPresentingSave = true
                    } else {
                        withAnimation {
                            appState.isProgramEditing = true
                        }
                    }
                }
                .font(Style.toolbarFont)
                .frame(width: width / 3, height: Style.toolbarHeight)
                .buttonStyle(.plain)
                .disabled(programType == .readWrite && !stateNeedsSaving)
                .confirmationDialog("Save?", isPresented: $isPresentingSave) {
                    if programType == .readWrite {
                        Button("Save " + (appState.stateViewMode == .steps ? "Steps" : "Registers"), role: .destructive) {
                            if let program {
                                if appState.stateViewMode == .steps {
                                    program.setStepsFromMemory()
                                } else {
                                    program.setRegistersFromMemory()
                                }
                                _ = program.save(filename: program.name)
                                refreshCounter += 1
                            }
                        }
                    }
                }
            }
            .background(Color.blackish)
            .foregroundColor(.ivory)
        }
        .frame(height: Style.toolbarHeight)
    }
}

/// Displays the steps and registers of the calculator.
struct StateView: View {
    @EnvironmentObject private var appState: AppState

    /// Used to refresh the view when the steps/registers are saved or cleared. This is necessary
    /// because those belong to the emulator and are not directly observed by SwifUI.
    @State private var refreshCounter: Int64 = 0

    var body: some View {
        let program = appState.loadedProgram
        let viewTitle: String = {
            guard let program else {
                return appState.stateViewMode == .steps ? "Steps" : "Registers"
            }
            if program.stepsNeedSaving() {
                return "\(program.name)'"
            } else {
                return program.name
            }
        }()

        ZStack {
            VStack(spacing: 0) {
                NavigationBar(left: appState.stateViewMode == .steps ? Style.yang : Style.ying,
                              title: viewTitle,
                              right: Style.rightArrow,
                              leftAction: {
                                  appState.stateViewMode = appState.stateViewMode == .registers ? .steps : .registers
                              },
                              rightAction: { withAnimation { appState.appLocation = .calc } })
                .background(Color.blackish)

                if let program {
                    LibInfoView(program: program)
                }

                switch appState.stateViewMode {
                case .registers:
                    RegistersView()
                case .steps:
                    StepsView()
                }
                StateViewToolbar(refreshCounter: $refreshCounter)
            }
            .id(refreshCounter)

            if appState.isProgramEditing {
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
