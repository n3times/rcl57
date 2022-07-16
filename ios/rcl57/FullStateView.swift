import SwiftUI

/** A list of LineView's. */
struct FullStateView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false
    @State private var isPresentingSave: Bool = false
    @State private var isPresentingClose: Bool = false

    func placeOrder() { }

    var body: some View {
        let program = change.loadedProgram
        let typeName = change.showStepsInState ? "Program" : "Data"
        let programName = program?.getName()
        let isNew = program == nil
        let isReadOnly = !isNew && program!.readOnly
        let isReadWrite = !isNew && !isReadOnly
        let title = isNew ? "" : (program!.readOnly ? "" : "") + programName!

        ZStack {
            if true { /// change.createProgram {
                GeometryReader { geometry in
                    let width = geometry.size.width

                    VStack(spacing: 0) {
                        MenuBarView(change: change,
                                    left: change.showStepsInState ? Style.yang : Style.ying,
                                    title: title,
                                    right: Style.rightArrow,
                                    width: width,
                                    leftAction: { change.showStepsInState.toggle() },
                                    rightAction: { withAnimation {change.currentView = .calc} })

                        // Type (program or data)
                        HStack(spacing: 0) {
                            Button(typeName) {
                                change.showStepsInState.toggle()
                            }
                            .frame(width: width / 6, height: 20)
                            .offset(x: change.showStepsInState ? 5 : 0, y: -3)

                            Text(isReadOnly ? "Examples" : "")
                                .frame(width: width * 2 / 3, height: 20)

                            Spacer()
                                .frame(width: width / 6, height: 20)
                        }
                        .offset(y: -3)
                        .background(Style.blackish)
                        .foregroundColor(Style.ivory)
                        .font(Style.programFont)

                        // State
                        StateView(isMiniView: false)
                            .background(Style.ivory)

                        HStack(spacing: 0) {
                            Button("CLOSE") {
                                isPresentingClose = true
                            }
                            .font(Style.footerFont)
                            .frame(width: width / 3, height: Style.footerHeight)
                            .disabled(isNew)
                            .buttonStyle(.plain)
                            .confirmationDialog("Are you sure?", isPresented: $isPresentingClose) {
                                if !isNew {
                                    Button("Close " + programName!, role: .destructive) {
                                        change.setLoadedProgram(program: nil)
                                        change.forceUpdate()
                                    }
                                }
                            }

                            Button("CLEAR") {
                                isPresentingConfirm = true
                            }
                            .font(Style.footerFont)
                            .frame(width: width / 3, height: Style.footerHeight)
                            .disabled(change.showStepsInState ? Rcl57.shared.getProgramLastIndex() == -1
                                      : Rcl57.shared.getRegistersLastIndex() == -1)
                            .buttonStyle(.plain)
                            .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                                if change.showStepsInState {
                                    Button("Clear Program", role: .destructive) {
                                        Rcl57.shared.clearProgram()
                                        change.forceUpdate()
                                    }
                                } else {
                                    Button("Clear Data", role: .destructive) {
                                        Rcl57.shared.clearRegisters()
                                        change.forceUpdate()
                                    }
                                }
                            }

                            Button(isReadWrite ? "SAVE" : "NEW") {
                                if isReadWrite {
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
                            .confirmationDialog("Are you sure?", isPresented: $isPresentingSave) {
                                if isReadWrite {
                                    Button("Save " + programName!, role: .destructive) {
                                        program!.saveState()
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
                .transition(.move(edge: .top))
            }
            if change.createProgram {
                CreateProgramView()
                    .environmentObject(change)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
}

struct FullStateView_Previews: PreviewProvider {
    static var previews: some View {
        FullStateView()
    }
}
