import SwiftUI

/** A list of LineView's. */
struct FullStateView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false
    @State private var isPresentingSave: Bool = false
    @State private var isPresentingClose: Bool = false

    func placeOrder() { }

    var body: some View {
        ZStack {
            if !change.createProgram {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let program = change.loadedProgram
                    let typeName = change.showStepsInState ? "Program" : "Data"
                    let title = program == nil ? typeName : program!.getName()

                    VStack(spacing: 0) {
                        MenuBarView(change: change,
                                    left: !change.showStepsInState ? Style.ying : Style.yang,
                                    title: title,
                                    right: Style.rightArrow,
                                    width: width,
                                    leftAction: { change.showStepsInState.toggle() },
                                    rightAction: { withAnimation {change.currentView = .calc} })

                        // Program Name
                        Text(program != nil ? typeName : "")
                            .foregroundColor(Style.ivory)
                            .font(Style.programFont)
                            .frame(width: width, height: 20, alignment: .leading)
                            .offset(x:15, y: -5)
                            .background(Style.blackish)

                        // State
                        StateView(isMiniView: false)
                            .background(Style.ivory)

                        HStack(spacing: 0) {
                            Button("CLOSE") {
                                isPresentingClose = true
                            }
                            .font(Style.footerFont)
                            .frame(width: width / 3, height: Style.footerHeight)
                            .disabled(change.loadedProgram == nil)
                            .buttonStyle(.plain)
                            .confirmationDialog("Are you sure?", isPresented: $isPresentingClose) {
                                if change.loadedProgram != nil {
                                    Button("Close " + change.loadedProgram!.getName(), role: .destructive) {
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

                            Button(change.loadedProgram == nil ? "NEW" : "SAVE") {
                                if change.loadedProgram == nil {
                                    withAnimation {
                                        change.createProgram = true
                                    }
                                } else {
                                    isPresentingSave = true
                                }
                            }
                            .font(Style.footerFont)
                            .frame(width: width / 3, height: Style.footerHeight)
                            .disabled(program != nil && program!.readOnly)
                            .buttonStyle(.plain)
                            .confirmationDialog("Are you sure?", isPresented: $isPresentingSave) {
                                if change.loadedProgram != nil {
                                    Button("Save " + change.loadedProgram!.getName(), role: .destructive) {
                                        let program = change.loadedProgram!
                                        program.saveState()
                                        _ = program.save(filename: program.getName())
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
            }
        }
    }
}

struct FullStateView_Previews: PreviewProvider {
    static var previews: some View {
        FullStateView()
    }
}
