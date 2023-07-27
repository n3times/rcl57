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
                MenuBarView(left: Style.leftArrow,
                            title: "Log",
                            right: nil,
                            width: width,
                            leftAction: { withAnimation {change.currentView = .calc} },
                            rightAction: {})
                .background(Color.blackish)

                if Rcl57.shared.loggedCount == 0 {
                    Text("Log is empty")
                        .frame(width: geometry.size.width,
                               height: geometry.size.height - Style.headerHeight - Style.footerHeight,
                               alignment: .center)
                        .background(Color.ivory)
                        .foregroundColor(.blackish)
                } else {
                    LogInnerView()
                        .background(Color.ivory)
                }

                HStack(spacing: 0) {
                    Spacer()
                    Button(action: {
                        isPresentingClear = true
                    }) {
                        Text("CLEAR")
                            .font(Style.footerFont)
                            .frame(maxWidth: width * 2 / 3, maxHeight: Style.footerHeight)
                            .contentShape(Rectangle())
                    }
                    .disabled(Rcl57.shared.loggedCount == 0)
                    .buttonStyle(.plain)
                    .confirmationDialog("Clear?", isPresented: $isPresentingClear) {
                        Button("Clear Log", role: .destructive) {
                            Rcl57.shared.clearLog()
                        }
                    }
                    Spacer()
                }
                .background(Color.blackish)
                .foregroundColor(.ivory)
            }
        }
    }

    struct LogView_Previews: PreviewProvider {
        static var previews: some View {
            LogView()
        }
    }
}
