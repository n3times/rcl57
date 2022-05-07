/**
 * The view that shows operations and results.
 */

import SwiftUI

/** A list of LineView's. */
struct FullLogView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false

    let rcl57 : RCL57

    var body: some View {
        return GeometryReader { geometry in
            let calcWidth = geometry.size.width
            VStack(spacing: 0) {
                // Menu.
                HStack(spacing: 0) {
                    // Left button.
                    Button(action: {
                        withAnimation {
                            change.isFullLog.toggle()
                        }
                    }) {
                        Text("\u{25c1}")
                            .frame(width: calcWidth / 6, height: 55)
                            .contentShape(Rectangle())
                    }
                    Text("Log")
                        .frame(width: calcWidth * 2 / 3, height: 55)
                        .font(Font.system(size: 20, weight: .regular))
                    Spacer()
                        .frame(width: calcWidth / 6, height: 55)
                }
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                .foregroundColor(Color.white)
                .font(Font.system(size: 20, weight: .regular, design: .monospaced))

                if rcl57.getLoggedCount() == 0 {
                    Text("Log is empty")
                        .frame(width: geometry.size.width,
                               height: geometry.size.height - 55 - 45,
                               alignment: .center)
                        .background(ivory)
                        .foregroundColor(Color.black)
                } else {
                    LogView(rcl57: rcl57)
                        .background(ivory)
                        .environmentObject(change)
                }

                HStack(spacing: 0) {
                    Spacer()
                    Button("Clear") {  // Left arrow.
                        isPresentingConfirm = true
                    }
                    .frame(width: calcWidth / 6, height: 45)
                    .disabled(rcl57.getLoggedCount() == 0)
                    .buttonStyle(.plain)
                    .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        Button("Clear Log", role: .destructive) {
                            rcl57.clearLog()
                        }
                     }
                    Spacer()
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
