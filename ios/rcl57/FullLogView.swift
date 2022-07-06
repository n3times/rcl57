/**
 * The view that shows operations and results.
 */

import SwiftUI

/** A list of LineView's. */
struct FullLogView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false

    var body: some View {
        return GeometryReader { geometry in
            let width = geometry.size.width
            VStack(spacing: 0) {
                // Menu.
                HStack(spacing: 0) {
                    // Left button.
                    Button(action: {
                        withAnimation {
                            change.currentView = .calc
                        }
                    }) {
                        Text(Style.leftArrow)
                            .frame(width: width / 6, height: Style.headerHeight)
                            .font(Style.directionsFont)
                            .contentShape(Rectangle())
                    }
                    Text("Log")
                        .frame(width: width * 2 / 3, height: Style.headerHeight)
                        .font(Style.titleFont)
                    Spacer()
                        .frame(width: width / 6, height: Style.headerHeight)
                }
                .background(Style.blackish)
                .foregroundColor(Style.ivory)

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
                    Button("Clear") {  // Left arrow.
                        isPresentingConfirm = true
                    }
                    .font(Style.footerFont)
                    .frame(width: width / 6, height: Style.footerHeight)
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
}

struct FullLogView_Previews: PreviewProvider {
    static var previews: some View {
        FullLogView()
    }
}
