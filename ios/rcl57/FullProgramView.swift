import SwiftUI

/** A list of LineView's. */
struct FullProgramView: View {
    @EnvironmentObject var isFullProgram: BoolObject
    @EnvironmentObject var change: Change

    let rcl57 : RCL57

    init(rcl57: RCL57) {
        self.rcl57 = rcl57
    }

    var body: some View {
        return GeometryReader { geometry in
            let calcWidth = geometry.size.width
            VStack {
                // Menu.
                HStack {
                    Spacer()
                        .frame(width: calcWidth / 6, height: 45)
                    Text("Program")
                        .frame(width: calcWidth * 2 / 3, height: 45)
                    Button("\u{25b7}") {  // Right arrow.
                        withAnimation {
                            isFullProgram.value.toggle()
                        }
                    }
                    .frame(width: calcWidth / 6, height: 45)
                }
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                .foregroundColor(Color.white)
                .font(.title2)

                // Program.
                ProgramView(rcl57: rcl57, showPc: false)
                    ///.background(logBackgroundColor)
                    .environmentObject(change)

                HStack(spacing: 0) {
                    Button("Clear") {  // Left arrow.
                        rcl57.clearProgram()
                        change.update()
                    }
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
