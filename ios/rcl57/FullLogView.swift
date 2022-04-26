/**
 * The view that shows operations and results.
 */

import SwiftUI

/** A list of LineView's. */
struct FullLogView: View {
    @EnvironmentObject var isFullLog: BoolObject

    let rcl57 : RCL57

    init(rcl57: RCL57) {
        self.rcl57 = rcl57
    }

    var body: some View {
        return GeometryReader { geometry in
            let calcWidth = geometry.size.width
            VStack {
                // Menu.
                HStack(spacing: 0) {
                    Button("\u{25c1}") {  // Left arrow.
                        withAnimation {
                            isFullLog.value.toggle()
                        }
                    }
                    .frame(width: calcWidth / 6, height: 45)
                    Text("Log")
                        .frame(width: calcWidth * 2 / 3, height: 45)
                    Spacer()
                        .frame(width: calcWidth / 6, height: 45)
                }
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                .foregroundColor(Color.white)
                .font(.title2)

                LogView(rcl57: rcl57)
                    ///.background(logBackgroundColor)

                HStack(spacing: 0) {
                    Button("Clear") {  // Left arrow.
                        rcl57.clearLog()
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

struct FullLogView_Previews: PreviewProvider {
    static var previews: some View {
        FullLogView(rcl57: RCL57())
    }
}
