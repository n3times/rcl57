import SwiftUI

/** A list of LineView's. */
struct FullProgramView: View {
    @EnvironmentObject var change: Change

    let rcl57 : RCL57

    init(rcl57: RCL57) {
        self.rcl57 = rcl57
    }

    var body: some View {
        return GeometryReader { geometry in
            let calcWidth = geometry.size.width
            VStack(spacing: 0) {
                // Menu.
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: calcWidth / 6, height: 55)
                    Text("Program")
                        .frame(width: calcWidth * 2 / 3, height: 55)
                        .font(Font.system(size: 21, weight: .regular))
                    // Right button.
                    Button(action: {
                        withAnimation {
                            change.isFullProgram.toggle()
                        }
                    }) {
                        Text("\u{25b7}")
                            .frame(width: calcWidth / 6, height: 55)
                            .contentShape(Rectangle())
                    }
                }
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                .foregroundColor(Color.white)
                .font(Font.system(size: 20, weight: .regular, design: .monospaced))

                // Program.
                ProgramView(rcl57: rcl57, showPc: false)
                    .environmentObject(change)

                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: calcWidth / 6, height: 45)
                    Button("Clear") {  // Left arrow.
                        rcl57.clearProgram()
                        change.forceUpdate()
                    }
                    .frame(width: calcWidth * 2 / 3, height: 45)
                    Text("")
                        .frame(width: calcWidth / 6, height: 45)
                }
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                .foregroundColor(Color.white)
                .font(.title2)
            }
        }
    }
}

struct FullProgramView_Previews: PreviewProvider {
    static var previews: some View {
        FullProgramView(rcl57: RCL57())
    }
}
