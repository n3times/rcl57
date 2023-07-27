import SwiftUI

/** A generic menu bar with 3 sections and 2 controls. */
struct MenuBarView: View {
    @EnvironmentObject var change: Change

    let left: String?
    let title: String
    let right: String?
    let width: CGFloat
    let leftAction: () -> Void?
    let rightAction: () -> Void?

    var body: some View {
        HStack(spacing: 0) {
            if let left {
                Button(action: {
                    leftAction()
                }) {
                    Text(left)
                        .frame(maxWidth: width / 5, maxHeight: Style.headerHeight, alignment: .leading)
                        .offset(x: 15)
                        .font(Style.directionsFont)
                        .contentShape(Rectangle())
                }
            } else {
                Spacer()
                    .frame(maxWidth: width / 5, maxHeight: Style.headerHeight)
            }
            Text(title)
                .frame(maxWidth: width * 3 / 5, maxHeight: Style.headerHeight)
                .font(Style.titleFont)
            if let right {
                Button(action: {
                    rightAction()
                }) {
                    Text(right)
                        .frame(maxWidth: width / 5, maxHeight: Style.headerHeight, alignment: .trailing)
                        .offset(x: -15)
                        .font(Style.directionsFont)
                        .contentShape(Rectangle())
                }
            } else {
                Spacer()
                    .frame(maxWidth: width / 5, maxHeight: Style.headerHeight)
            }
        }
        .foregroundColor(.ivory)
    }
}
