import SwiftUI

/** A list of LineView's. */
struct FullProgramView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false

    let rcl57 : RCL57

    var body: some View {
        return GeometryReader { geometry in
            let calcWidth = geometry.size.width
            VStack(spacing: 0) {
                // Menu.
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: calcWidth / 6, height: Style.headerHeight)
                    Text("Program")
                        .frame(width: calcWidth * 2 / 3, height: Style.headerHeight)
                        .font(Style.titleFont)
                    // Right button.
                    Button(action: {
                        withAnimation {
                            change.isFullProgram.toggle()
                        }
                    }) {
                        Text("\u{25b7}")
                            .frame(width: calcWidth / 6, height: Style.headerHeight)
                            .font(Style.directionsFont)
                            .contentShape(Rectangle())
                    }
                }
                .background(Style.blackish)
                .foregroundColor(Style.ivory)

                // Program.
                ProgramView(rcl57: rcl57, showPc: false)
                    .background(Style.ivory)
                    .environmentObject(change)
                    .onTapGesture(count: 2) {
                        withAnimation {
                            change.isFullProgram.toggle()
                        }
                    }

                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: calcWidth / 6, height: Style.footerHeight)
                    Button("Clear") {  // Left arrow.
                        isPresentingConfirm = true
                    }
                    .font(Style.titleFont)
                    .frame(width: calcWidth * 2 / 3, height: Style.footerHeight)
                    .disabled(rcl57.getProgramLastIndex() == -1)
                    .buttonStyle(.plain)
                    .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        Button("Clear Program", role: .destructive) {
                            rcl57.clearProgram()
                            change.forceUpdate()
                        }
                    }
                    Spacer()
                        .frame(width: calcWidth / 6, height: Style.footerHeight)
                }
                .background(Style.blackish)
                .foregroundColor(Style.ivory)
            }
        }
    }
}

struct FullProgramView_Previews: PreviewProvider {
    static var previews: some View {
        FullProgramView(rcl57: RCL57())
    }
}
