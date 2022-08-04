/**
 * The view that shows operations and results.
 */

import SwiftUI

/** Shows the instructions keyed in by the user, and the results. */
struct LogView: View {
    @EnvironmentObject private var change: Change
    @State private var isPresentingClear: Bool = false

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
                .background(Style.blackish)

                if Rcl57.shared.getLoggedCount() == 0 {
                    Text("Log is empty")
                        .frame(width: geometry.size.width,
                               height: geometry.size.height - Style.headerHeight - Style.footerHeight,
                               alignment: .center)
                        .background(Style.ivory)
                        .foregroundColor(Style.blackish)
                } else {
                    LogInnerView()
                        .background(Style.ivory)
                }

                HStack(spacing: 0) {
                    Spacer()
                    Button("CLEAR") {
                        isPresentingClear = true
                    }
                    .font(Style.footerFont)
                    .frame(width: width / 3, height: Style.footerHeight)
                    .disabled(Rcl57.shared.getLoggedCount() == 0)
                    .buttonStyle(.plain)
                    .confirmationDialog("Clear?", isPresented: $isPresentingClear) {
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

    struct LogView_Previews: PreviewProvider {
        static var previews: some View {
            LogView()
        }
    }
}
