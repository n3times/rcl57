/**
 * The view that shows operations and results.
 */

import SwiftUI

/** A list of LineView's. */
struct FullLogView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            VStack(spacing: 0) {
                MenuBarView(change: change,
                            left: Style.leftArrow,
                            title: "Log",
                            right: nil,
                            width: width,
                            leftAction: { withAnimation {change.currentView = .calc} },
                            rightAction: {})

                if Rcl57.shared.getLoggedCount() == 0 {
                    Text("Log is empty")
                        .frame(width: geometry.size.width,
                               height: geometry.size.height - Style.headerHeight - Style.footerHeight,
                               alignment: .center)
                        .background(Style.ivory)
                        .foregroundColor(Style.blackish)
                } else {
                    LogView()
                        .background(Style.ivory)
                }

                HStack(spacing: 0) {
                    Spacer()
                    Button("CLEAR") {
                        isPresentingConfirm = true
                    }
                    .font(Style.footerFont)
                    .frame(width: width / 3, height: Style.footerHeight)
                    .disabled(Rcl57.shared.getLoggedCount() == 0)
                    .buttonStyle(.plain)
                    .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        Button("Clear Log", role: .destructive) {
                            Rcl57.shared.clearLog()
                        }
                    }
                    Spacer()
                }
                .background(Style.blackish)
                .foregroundColor(Style.ivory)
            }
        }
    }

    struct FullLogView_Previews: PreviewProvider {
        static var previews: some View {
            FullLogView()
        }
    }
}
